package database

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	"not-today-backend/models"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type DB struct {
	*gorm.DB
}

var db *DB

const (
	host     = "127.0.0.1"
	port     = 3306
	username = "root"
	password = "littlebridgeYYDS001"
	dbname   = "not_today"
)

func DSN() string {
	return fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		username, password, host, port, dbname)
}

func InitDB() (*DB, error) {
	var err error

	config := &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	}

	dbInst, err := gorm.Open(mysql.Open(DSN()), config)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	db = &DB{dbInst}

	if err := db.AutoMigrate(&models.User{}); err != nil {
		return nil, fmt.Errorf("failed to migrate database: %w", err)
	}

	log.Println("Database connected successfully")
	return db, nil
}

func (d *DB) GetUserByUserId(userId string) (*models.User, error) {
	var user models.User
	err := d.DB.Where("user_id = ?", userId).First(&user).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (d *DB) CreateUser(userId, city, industry string) (*models.User, error) {
	now := time.Now()
	checkedInDates := []string{now.Format("2006-01-02")}
	checkedInDatesJSON, _ := json.Marshal(checkedInDates)

	user := &models.User{
		UserId:         userId,
		Days:           1,
		City:           city,
		Industry:       industry,
		LastUpdated:    now,
		CheckedInDates: string(checkedInDatesJSON),
		CreatedAt:      now,
		UpdatedAt:      now,
	}

	if err := d.DB.Create(user).Error; err != nil {
		return nil, err
	}

	return user, nil
}

func (d *DB) UpdateUser(user *models.User) error {
	user.UpdatedAt = time.Now()
	return d.DB.Save(user).Error
}

func (d *DB) SaveDailyReasonData(userId string, reasonData *models.DailyReasonRequest) error {
	reasonDataJSON, _ := json.Marshal(reasonData)

	return d.DB.Model(&models.User{}).
		Where("user_id = ?", userId).
		Update("daily_reason_data", string(reasonDataJSON)).Error
}

func (d *DB) GetDailyReasonData(userId string) (*models.DailyReasonRequest, error) {
	var user models.User
	err := d.DB.Select("daily_reason_data").Where("user_id = ?", userId).First(&user).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	if user.DailyReasonData == "" || user.DailyReasonData == "" {
		return nil, nil
	}

	var result models.DailyReasonRequest
	if err := json.Unmarshal([]byte(user.DailyReasonData), &result); err != nil {
		return nil, err
	}

	return &result, nil
}

func (d *DB) GetTotalUsers() (int64, error) {
	var count int64
	err := d.DB.Model(&models.User{}).Count(&count).Error
	return count, err
}

func (d *DB) GetUsersWithMoreDays(days int) (int64, error) {
	var count int64
	err := d.DB.Model(&models.User{}).Where("days > ?", days).Count(&count).Error
	return count, err
}

func (d *DB) GetUsersWithSameOrMoreDays(days int) (int64, error) {
	var count int64
	err := d.DB.Model(&models.User{}).Where("days >= ?", days).Count(&count).Error
	return count, err
}

func (d *DB) GetIndustryStats() ([]models.IndustryData, error) {
	type result struct {
		Industry string
		Count    int
	}

	var results []result
	err := d.DB.Model(&models.User{}).
		Select("industry, COUNT(*) as count").
		Where("industry != ?", "").
		Group("industry").
		Order("count DESC").
		Scan(&results).Error
	if err != nil {
		return nil, err
	}

	var totalUsers int
	for _, r := range results {
		totalUsers += r.Count
	}

	var industryStats []models.IndustryData
	for _, r := range results {
		percentage := 0.0
		if totalUsers > 0 {
			percentage = float64(r.Count) / float64(totalUsers) * 100
		}
		industryStats = append(industryStats, models.IndustryData{
			IndustryName:          r.Industry,
			ResignationPercentage: percentage,
		})
	}

	return industryStats, nil
}
