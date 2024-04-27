package router

import (
	"time"
	"userauth/internal/handlers"

	ginzap "github.com/gin-contrib/zap"
	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"go.uber.org/zap"
)

func InitRoutes(handler *handlers.UserAuthHandler, logger *zap.Logger) *gin.Engine {
	r := gin.Default()
	r.Use(ginzap.Ginzap(logger, time.RFC3339, true))
	apiRoutes := r.Group("/auth")
	{
		// Route for getting drivers within a radius
		apiRoutes.POST("/validate", handler.ValidateToken)
		apiRoutes.POST("/login", handler.LoginUser)
		apiRoutes.POST("/register", handler.RegisterUser)
		apiRoutes.GET("/session", handler.GetSession)
		apiRoutes.POST("/waitfortracker", handler.WaitForTracker)
		apiRoutes.POST("/findcomposer", handler.FindComposer)

	}
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))

	return r
}
