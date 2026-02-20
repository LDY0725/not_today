package models

import "time"

type User struct {
	ID              uint      `gorm:"primaryKey" json:"-"`
	UserId          string    `gorm:"uniqueIndex;size:64" json:"userId"`
	Days            int       `gorm:"default:0" json:"days"`
	City            string    `gorm:"size:100;default:''" json:"city"`
	Industry        string    `gorm:"size:100;default:''" json:"industry"`
	LastUpdated     time.Time `json:"lastUpdated"`
	CheckedInDates  string    `gorm:"type:text"`
	DailyReasonData string    `gorm:"type:text"`
	CreatedAt       time.Time `json:"createdAt"`
	UpdatedAt       time.Time `json:"updatedAt"`
}

type CheckInRequest struct {
	UserId          string              `json:"userId"`
	City            string              `json:"city"`
	Industry        string              `json:"industry"`
	DailyReasonData *DailyReasonRequest `json:"dailyReasonData,omitempty"`
}

type DailyReasonRequest struct {
	Date    string                  `json:"date"`
	Reasons []DailyReasonItemRequest `json:"reasons"`
}

type DailyReasonItemRequest struct {
	ReasonName string  `json:"reasonName"`
	Score      float64 `json:"score"`
	TapCount   int     `json:"tapCount"`
}

type IndustryData struct {
	IndustryName          string  `json:"industryName"`
	ResignationPercentage float64 `json:"resignationPercentage"`
}

type UserResponse struct {
	UserId                  string         `json:"userId"`
	Days                    int           `json:"days"`
	City                    string        `json:"city"`
	Industry                string        `json:"industry"`
	LastUpdated             time.Time     `json:"lastUpdated"`
	CheckedInDates          []string      `json:"checkedInDates"`
	IndustryResignationInfo  []IndustryData `json:"industryResignationInfo"`
	AppRankingPercentile    float64       `json:"appRankingPercentile"`
}
