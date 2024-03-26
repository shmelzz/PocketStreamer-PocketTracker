package router

import (
	"net/http"
	"pocketaction/internal/handlers"

	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"

	ginSwagger "github.com/swaggo/gin-swagger"
)

func InitRoutes(handler *handlers.PocketActionHandler) *gin.Engine {
	r := gin.Default()
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
