package database

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	"not-today-backend/models"

	_ "github.com/mattn/go-sqlite3"
)

type DB struct {
	*sql.DB
}

var db *DB

const dbPath = "./data.db"

func InitDB() (*DB, error) {
	if _, err := os.Stat(dbPath); os.IsNotExist(err) {
		os.Create(dbPath)
	}

	var err error
	sqlDB, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		return nil, err
	}

	db = &DB{sqlDB}

	if err := db.createTables(); err != nil {
		return nil, err
	}

	return db, nil
}

func (d *DB) createTables() error {
	createUsersTable := `
	CREATE TABLE IF NOT EXISTS users (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		user_id TEXT UNIQUE NOT NULL,
		days INTEGER DEFAULT 0,
		city TEXT DEFAULT '',
		industry TEXT DEFAULT '',
		last_updated TEXT,
		checked_in_dates TEXT DEFAULT '[]',
		created_at TEXT DEFAULT CURRENT_TIMESTAMP,
		updated_at TEXT DEFAULT CURRENT_TIMESTAMP
	);
	`
	_, err := d.Exec(createUsersTable)
	if err != nil {
		return fmt.Errorf("failed to create users table: %w", err)
	}

	return nil
}

func (d *DB) GetUserByUserId(userId string) (*models.User, error) {
	query := `
	SELECT id, user_id, days, city, industry, last_updated, checked_in_dates, created_at, updated_at
	FROM users WHERE user_id = ?
	`
	row := d.QueryRow(query, userId)

	var user models.User
	var checkedInDatesJSON string

	err := row.Scan(
		&user.ID,
		&user.UserId,
		&user.Days,
		&user.City,
		&user.Industry,
		&user.LastUpdated,
		&checkedInDatesJSON,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	json.Unmarshal([]byte(checkedInDatesJSON), &user.CheckedInDates)
	return &user, nil
}

func (d *DB) CreateUser(userId, city, industry string) (*models.User, error) {
	now := time.Now()
	checkedInDates := []string{now.Format("2006-01-02")}
	checkedInDatesJSON, _ := json.Marshal(checkedInDates)

	query := `
	INSERT INTO users (user_id, days, city, industry, last_updated, checked_in_dates, created_at, updated_at)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?)
	`
	result, err := d.Exec(query, userId, 1, city, industry, now.Format(time.RFC3339), string(checkedInDatesJSON), now, now)
	if err != nil {
		return nil, err
	}

	id, _ := result.LastInsertId()
	return &models.User{
		ID:             id,
		UserId:         userId,
		Days:           1,
		City:           city,
		Industry:       industry,
		LastUpdated:    now,
		CheckedInDates: string(checkedInDatesJSON),
		CreatedAt:      now,
		UpdatedAt:      now,
	}, nil
}

func (d *DB) UpdateUser(user *models.User) error {
	checkedInDatesJSON, _ := json.Marshal(user.CheckedInDates)
	now := time.Now()

	query := `
	UPDATE users SET days = ?, city = ?, industry = ?, last_updated = ?, checked_in_dates = ?, updated_at = ?
	WHERE user_id = ?
	`
	_, err := d.Exec(query, user.Days, user.City, user.Industry,
		user.LastUpdated.Format(time.RFC3339), string(checkedInDatesJSON), now, user.UserId)
	return err
}

func (d *DB) GetTotalUsers() (int, error) {
	var count int
	err := d.QueryRow("SELECT COUNT(*) FROM users").Scan(&count)
	return count, err
}

func (d *DB) GetUsersWithMoreDays(days int) (int, error) {
	var count int
	err := d.QueryRow("SELECT COUNT(*) FROM users WHERE days > ?", days).Scan(&count)
	return count, err
}

func (d *DB) GetUsersWithSameOrMoreDays(days int) (int, error) {
	var count int
	err := d.QueryRow("SELECT COUNT(*) FROM users WHERE days >= ?", days).Scan(&count)
	return count, err
}

func (d *DB) GetIndustryStats() ([]models.IndustryData, error) {
	query := `
	SELECT industry, COUNT(*) as count
	FROM users
	WHERE industry != ''
	GROUP BY industry
	ORDER BY count DESC
	`
	rows, err := d.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.IndustryData
	totalUsers := 0

	type industryCount struct {
		industry string
		count    int
	}
	var counts []industryCount

	for rows.Next() {
		var ic industryCount
		if err := rows.Scan(&ic.industry, &ic.count); err != nil {
			log.Println(err)
			continue
		}
		counts = append(counts, ic)
		totalUsers += ic.count
	}

	for _, ic := range counts {
		percentage := 0
		if totalUsers > 0 {
			percentage = int(float64(ic.count) / float64(totalUsers) * 100)
		}

		results = append(results, models.IndustryData{
			IndustryName:          ic.industry,
			ResignationPercentage: percentage,
		})
	}

	return results, nil
}
