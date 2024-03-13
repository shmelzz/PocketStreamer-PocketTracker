package router

import (
	"streamingservice/internal/handlers"

	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"

	ginSwagger "github.com/swaggo/gin-swagger"
)

func InitRoutes(handler *handlers.OAuthHandler) *gin.Engine {
	r := gin.Default()
	googleApiRoutes := r.Group("/google")
	{
		googleApiRoutes.GET("/login", handler.Login)
	}

	twitchApiRoutes := r.Group("/twitch")
	{
		twitchApiRoutes.POST("channel-validation", handler.ValidateTwitchChannel)
	}
	r.GET("/message-trackered", handler.HandleReceiver)
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))
	return r
}
