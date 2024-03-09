package router

import (
	"streamingservice/internal/handlers"

	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"

	ginSwagger "github.com/swaggo/gin-swagger"
)

func InitRoutes(handler *handlers.GoogleOAuthHandler) *gin.Engine {
	r := gin.Default()
	apiRoutes := r.Group("/google")
	{
		apiRoutes.GET("/login", handler.Login)
	}
	r.GET("/message-trackered", handler.HandleReceiver)
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))
	return r
}
