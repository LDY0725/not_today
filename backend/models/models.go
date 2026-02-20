package models

import "time"

type CheckInRequest struct {
	UserId   string `json:"userId"`
	City     string `json:"city"`
	Industry string `json:"industry"`
}

type IndustryData struct {
	IndustryName          string `json:"industryName"`
	ResignationPercentage int    `json:"resignationPercentage"`
}

type UserResponse struct {
	UserId                  string         `json:"userId"`
	Days                    int            `json:"days"`
	City                    string         `json:"city"`
	Industry                string         `json:"industry"`
	LastUpdated             time.Time      `json:"lastUpdated"`
	CheckedInDates          []string       `json:"checkedInDates"`
	IndustryResignationInfo []IndustryData `json:"industryResignationInfo"`
	AppRankingPercentile    float64        `json:"appRankingPercentile"`
}

type User struct {
	ID             int64     `db:"id"`
	UserId         string    `db:"user_id"`
	Days           int       `db:"days"`
	City           string    `db:"city"`
	Industry       string    `db:"industry"`
	LastUpdated    time.Time `db:"last_updated"`
	CheckedInDates string    `db:"checked_in_dates"` // JSON string
	CreatedAt      time.Time `db:"created_at"`
	UpdatedAt      time.Time `db:"updated_at"`
}
