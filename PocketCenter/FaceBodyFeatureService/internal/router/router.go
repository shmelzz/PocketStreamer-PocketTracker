package router

import (
	"pocketcenter/internal/handlers"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// InitRoutes initializes all the routes for the application.
// Need to rewrite to gin
func InitRoutes(handler *handlers.FeatureHandler) *gin.Engine {
	r := gin.Default()
	r.GET("/metrics", gin.WrapH(promhttp.Handler()))
	r.GET("/facetracking", handler.HandleFaceTracking)
	r.GET("/composed", handler.HandleReceiver)
	r.GET("/version", handler.HandleVersion)

	return r
}
