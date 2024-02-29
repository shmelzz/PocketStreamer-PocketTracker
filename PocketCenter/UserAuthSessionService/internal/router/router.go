package router

import (
	"userauth/internal/handlers"

	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func InitRoutes(handler *handlers.UserAuthHandler) *gin.Engine {
	r := gin.Default()
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
