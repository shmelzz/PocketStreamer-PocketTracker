package router

import (
	"net/http"
	"pocketaction/internal/handlers"
	"time"

	ginzap "github.com/gin-contrib/zap"
	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"
	"go.uber.org/zap"

	ginSwagger "github.com/swaggo/gin-swagger"
)

func InitRoutes(handler *handlers.PocketActionHandler, logger *zap.Logger) *gin.Engine {
	r := gin.Default()
	r.Use(ginzap.Ginzap(logger, time.RFC3339, true))
	r.StaticFS("/prez", http.Dir("./presentation"))
	apiRoutes := r.Group("/action")
	{
		apiRoutes.GET("/action-composed", handler.HandleReceiver)
		// Route for getting drivers within a radius
		apiRoutes.POST("/pocketaction", handler.HandlePocketAction)
		apiRoutes.GET("/version", handler.HandleVersion)
		apiRoutes.GET("/document", handler.HandlePocketActionDocument)
		apiRoutes.GET("/presentation", handler.HandlePresentation)
		apiRoutes.GET("/presentation-zip", handler.HandlePresentationZip)
	}
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))
	return r
}
