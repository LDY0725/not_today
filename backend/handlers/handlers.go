package handlers

import (
	"encoding/json"
	"log"
	"net/http"
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

func GetIndustryStats() []models.IndustryData {
	statsCache.mu.RLock()
	defer statsCache.mu.RUnlock()

	if time.Since(statsCache.LastCalculated) < 24*time.Hour {
		return statsCache.IndustryStats
	}
	return nil
}

func CalculateAndCacheStats() {
	db, err := database.InitDB()
	if err != nil {
		log.Printf("Failed to init DB: %v", err)
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
	return []models.IndustryData{}
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

	db, err := database.InitDB()
	if err != nil {
		log.Printf("Failed to init DB: %v", err)
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

	if user == nil {
		user, err = db.CreateUser(req.UserId, req.City, req.Industry)
		if err != nil {
			log.Printf("Failed to create user: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
			return
		}
		isNewCheckIn = true
	} else {
		if user.City != req.City {
			user.City = req.City
		}
		if user.Industry != req.Industry {
			user.Industry = req.Industry
		}
		var checkedInDates []string
		if err := json.Unmarshal([]byte(user.CheckedInDates), &checkedInDates); err != nil {
			log.Printf("Failed to unmarshal checkedInDates: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}
		alreadyCheckedIn := false
		for _, date := range checkedInDates {
			if date == today {
				alreadyCheckedIn = true
				break
			}
		}

		if !alreadyCheckedIn {
			var checkedInDates []string
			if err := json.Unmarshal([]byte(user.CheckedInDates), &checkedInDates); err != nil {
				log.Printf("Failed to unmarshal checkedInDates: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
				return
			}
			checkedInDates = append(checkedInDates, today)
			checkedInDatesJSON, _ := json.Marshal(checkedInDates)
			user.CheckedInDates = string(checkedInDatesJSON)
			user.Days++
			user.LastUpdated = time.Now()
			isNewCheckIn = true
			if err := db.UpdateUser(user); err != nil {
				log.Printf("Failed to update user: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user"})
				return
			}
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

	if len(industryStats) > 5 {
		industryStats = industryStats[:5]
	}

	var checkedInDates []string
	if err := json.Unmarshal([]byte(user.CheckedInDates), &checkedInDates); err != nil {
		log.Printf("Failed to unmarshal checkedInDates: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
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

	c.JSON(http.StatusOK, response)
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
