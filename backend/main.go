package main

import (
	"log"

	"not-today-backend/handlers"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.GET("/health", handlers.HealthCheck)
	r.POST("/api/checkin", handlers.CheckIn)
	r.POST("/api/recalculate-stats", handlers.ForceRecalculateStats)

	log.Println("Server starting on :8080")
	log.Println("API endpoints:")
	log.Println("  POST /api/checkin         - User check-in")
	log.Println("  GET  /health              - Health check")
	log.Println("  POST /api/recalculate-stats - Force recalculate stats (admin)")

	if err := r.Run(":8080"); err != nil {
		log.Fatal(err)
	}
}
