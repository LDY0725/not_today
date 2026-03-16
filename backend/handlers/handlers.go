package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"strings"
	"sync"
	"time"

	"not-today-backend/database"
	"not-today-backend/models"

	"github.com/gin-gonic/gin"
)

type StatsCache struct {
	IndustryStats  []models.IndustryData
	LastCalculated time.Time
	mu             sync.RWMutex
}

var statsCache = &StatsCache{}
var dbInstance *database.DB

func InitDB() {
	if dbInstance == nil {
		var err error
		dbInstance, err = database.InitDB()
		if err != nil {
			log.Printf("Failed to init DB: %v", err)
		}
	}
}

func GetDB() *database.DB {
	if dbInstance == nil {
		InitDB()
	}
	return dbInstance
}

func GetIndustryStats() []models.IndustryData {
	statsCache.mu.RLock()
	defer statsCache.mu.RUnlock()

	if time.Since(statsCache.LastCalculated) < 24*time.Hour {
		return statsCache.IndustryStats
	}
	return nil
}

func CalculateAndCacheStats() {
	db := GetDB()
	if db == nil {
		return
	}

	stats, err := db.GetIndustryStats()
	if err != nil {
		log.Printf("Failed to get industry stats: %v", err)
		return
	}

	statsCache.mu.Lock()
	statsCache.IndustryStats = stats
	statsCache.LastCalculated = time.Now()
	statsCache.mu.Unlock()
}

func GetDefaultIndustryStats() []models.IndustryData {
	return []models.IndustryData{
		{IndustryName: "移动端开发", ResignationPercentage: 73.2},
		{IndustryName: "市场", ResignationPercentage: 66.8},
		{IndustryName: "设计师", ResignationPercentage: 66.7},
		{IndustryName: "产品经理", ResignationPercentage: 66.3},
		{IndustryName: "运营", ResignationPercentage: 66.2},
		{IndustryName: "后端开发", ResignationPercentage: 61.9},
		{IndustryName: "人事", ResignationPercentage: 60.4},
		{IndustryName: "前端开发", ResignationPercentage: 60.1},
		{IndustryName: "其他", ResignationPercentage: 52.3},
		{IndustryName: "财务", ResignationPercentage: 45.1},
	}
}

func parseCheckedInDates(raw string) []string {
	if raw == "" {
		return []string{}
	}

	var dates []string
	if err := json.Unmarshal([]byte(raw), &dates); err == nil {
		return dates
	}

	if strings.Contains(raw, ",") {
		parts := strings.Split(raw, ",")
		for _, p := range parts {
			p = strings.TrimSpace(p)
			p = strings.Trim(p, "\"")
			if p != "" && len(p) == 10 {
				dates = append(dates, p)
			}
		}
		return dates
	}

	return []string{}
}

func init() {
	go func() {
		for {
			CalculateAndCacheStats()
			time.Sleep(24 * time.Hour)
		}
	}()
}

func CheckIn(c *gin.Context) {
	var req models.CheckInRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	if req.UserId == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "userId is required"})
		return
	}

	db := GetDB()
	if db == nil {
		log.Printf("Failed to init DB")
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	user, err := db.GetUserByUserId(req.UserId)
	if err != nil {
		log.Printf("Failed to get user: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	today := time.Now().Format("2006-01-02")
	isNewCheckIn := false
	checkedInDates := []string{}

	if user == nil {
		user, err = db.CreateUser(req.UserId, req.City, req.Industry)
		if err != nil {
			log.Printf("Failed to create user: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
			return
		}
		isNewCheckIn = true
	} else {
		updated := false

		if user.City != req.City {
			user.City = req.City
			updated = true
		}
		if user.Industry != req.Industry {
			user.Industry = req.Industry
			updated = true
		}
		checkedInDates = parseCheckedInDates(user.CheckedInDates)

		alreadyCheckedIn := false
		for _, date := range checkedInDates {
			if date == today {
				alreadyCheckedIn = true
				break
			}
		}

		if !alreadyCheckedIn {
			checkedInDates = append(checkedInDates, today)
			user.Days++
			user.LastUpdated = time.Now()
			updated = true
			isNewCheckIn = true
			checkedInDatesJSON, _ := json.Marshal(checkedInDates)
			user.CheckedInDates = string(checkedInDatesJSON)

			if err := db.UpdateUser(user); err != nil {
				log.Printf("Failed to update user: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user"})
				return
			}
		} else if updated {
			if err := db.UpdateUser(user); err != nil {
				log.Printf("Failed to update user: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user"})
				return
			}
		}
	}

	if req.DailyReasonData != nil {
		if err := db.SaveDailyReasonData(req.UserId, req.DailyReasonData); err != nil {
			log.Printf("Failed to save daily reason data: %v", err)
		}
	}

	totalUsers, _ := db.GetTotalUsers()
	usersWithSameOrMoreDays, _ := db.GetUsersWithSameOrMoreDays(user.Days)
	var rankingPercentile float64 = 100.0
	if totalUsers > 0 {
		rankingPercentile = float64(usersWithSameOrMoreDays) / float64(totalUsers) * 100
	}

	var industryStats []models.IndustryData
	if isNewCheckIn {
		CalculateAndCacheStats()
	}
	industryStats = GetIndustryStats()
	if industryStats == nil {
		industryStats = GetDefaultIndustryStats()
	}

	if len(industryStats) > 10 {
		industryStats = industryStats[:10]
	}

	response := models.UserResponse{
		UserId:                  user.UserId,
		Days:                    user.Days,
		City:                    user.City,
		Industry:                user.Industry,
		LastUpdated:             user.LastUpdated,
		CheckedInDates:          checkedInDates,
		IndustryResignationInfo: industryStats,
		AppRankingPercentile:    rankingPercentile,
	}

	c.JSON(http.StatusOK, gin.H{"data": response, "code": 200})
}

func HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func ForceRecalculateStats(c *gin.Context) {
	CalculateAndCacheStats()
	stats := GetIndustryStats()
	if stats == nil {
		stats = GetDefaultIndustryStats()
	}
	c.JSON(http.StatusOK, gin.H{
		"status":        "recalculated",
		"lastUpdate":    statsCache.LastCalculated,
		"industryStats": stats,
	})
}
