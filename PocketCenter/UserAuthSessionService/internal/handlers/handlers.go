package handlers

import (
	"fmt"
	"net/http"
	"userauth/internal/service"

	"github.com/gin-gonic/gin"
)

type UserAuthHandler struct {
	userAuthService *service.UserAuthService
}

func NewUserAuthHandler(userAuthService *service.UserAuthService) *UserAuthHandler {
	return &UserAuthHandler{
		userAuthService: userAuthService,
	}
}

// RegisterUser godoc
// @Summary Register new user
// @Description Register a new user with a username and password
// @Tags auth
// @Accept json
// @Produce json
// @Param user body model.UserLoginRequest true "User Info"
// @Success 200 {object} model.UserRegisterResponse
// @Failure 400 "Bad Request"
// @Failure 500 "Internal Server Error"
// @Router /register [post]
func (h *UserAuthHandler) RegisterUser(c *gin.Context) {
	var req struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}

	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.userAuthService.RegisterUser(c, req.Username, req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to register user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "user registered successfully"})
}

// LoginUser godoc
// @Summary User login
// @Description Log in with username and password
// @Tags auth
// @Accept json
// @Produce json
// @Param user body model.UserLoginRequest true "Login Credentials"
// @Success 200 {object} model.UserLoginResponse
// @Failure 400 "Bad Request"
// @Failure 401 "Unauthorized"
// @Router /login [post]
func (h *UserAuthHandler) LoginUser(c *gin.Context) {
	var req struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}

	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	token, err := h.userAuthService.LoginUser(c, req.Username, req.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}

// ValidateToken godoc
// @Summary Validate JWT token
// @Description Check if the JWT token is valid
// @Tags auth
// @Accept json
// @Produce json
// @Param Authorization header string true "Authorization"
// @Success 200 {object} model.UserInfoResponse
// @Failure 401 "Unauthorized"
// @Failure 500 "Internal Server Error"
// @Router /validate [post]
func (h *UserAuthHandler) ValidateToken(c *gin.Context) {
	tokenString := c.GetHeader("Authorization")
	fmt.Println(c.Request.Header)

	token, err := h.userAuthService.ValidateToken(tokenString)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid or expired token"})
		return
	}

	claims, ok := token.Claims.(*service.Claims)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to parse claims"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"username": claims.Username})
}
