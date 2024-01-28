package router

import (
	"userauth/internal/handlers"

	"github.com/gin-gonic/gin"
)

func InitRoutes(handler *handlers.UserAuthHandler) *gin.Engine {
	r := gin.Default()
	// setup route group for the API
	// apiRoutes := r.Group("/auth")
	// {
	// 	// Route for getting drivers within a radius
	// 	apiRoutes.GET("/drivers", handler.GetDrivers)
	// }

	return r
}
