package router

import (
	"pocketcenter/internal/handlers"
	"time"

	ginzap "github.com/gin-contrib/zap"
	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"go.uber.org/zap"
)

// InitRoutes initializes all the routes for the application.
// Need to rewrite to gin
func InitRoutes(
	handler *handlers.FeatureHandler,
	bodyHandler *handlers.BodyFeatureHandler,
	logger *zap.Logger) *gin.Engine {
	r := gin.Default()
	r.Use(ginzap.Ginzap(logger, time.RFC3339, true))
	r.GET("/metrics", gin.WrapH(promhttp.Handler()))
	r.GET("/facetracking", handler.HandleFaceTracking)
	r.GET("/composed", handler.HandleReceiver)
	r.GET("/version", handler.HandleVersion)
	r.GET("/bodytracking", bodyHandler.HandleBodyTracking)
	r.GET("/bodycomposed", bodyHandler.HandleReceiver)

	return r
}
