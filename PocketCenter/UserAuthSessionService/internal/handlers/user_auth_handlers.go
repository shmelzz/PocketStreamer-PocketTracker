package handlers

import (
	"net/http"
	"userauth/internal/model"
	"userauth/internal/service"

	"github.com/gin-gonic/gin"
)

type UserAuthHandler struct {
	userAuthService *service.UserAuthService
	sessionService  *service.SessionService
}

func NewUserAuthHandler(
	userAuthService *service.UserAuthService,
	sessionService *service.SessionService,
) *UserAuthHandler {
	return &UserAuthHandler{
		userAuthService: userAuthService,
		sessionService:  sessionService,
	}
}

// FindComposer godoc
// @Summary Find composer
// @Description Find composer from waiting list
// @Tags session
// @Accept json
// @Produce json
// @Param Authorization header string true "Authorization"
// @Param sessionid body model.WaitForTrackerRequest true "Session Id"
// @Success 200 "Ok"
// @Failure 404 "Not Found"
// @Router /findcomposer [post]
func (h *UserAuthHandler) FindComposer(c *gin.Context) {
	tokenString := c.GetHeader("Authorization")

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

	var req model.WaitForTrackerRequest
	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = h.sessionService.FindComposer(c, req.SessionId, claims.Username, tokenString)

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
	} else {
		c.JSON(http.StatusOK, nil)
	}
}

// WaitForTacker godoc
// @Summary Wait for tracker to connect
// @Description Wait for tracker to connect
// @Tags session
// @Accept json
// @Produce json
// @Param sessionid body model.WaitForTrackerRequest true "Session Id"
// @Success 200 {object} model.WaitForTrackerResponse
// @Failure 404 "Not Found"
// @Router /waitfortracker [post]
func (h *UserAuthHandler) WaitForTracker(c *gin.Context) {
	var req model.WaitForTrackerRequest
	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	response, err := h.sessionService.WaitForTracker(c, req.SessionId)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
	} else {
		c.JSON(http.StatusOK, response)
	}
}

// GetSession godoc
// @Summary Get new generated session id
// @Description Generate new session id and return it
// @Tags session
// @Accept json
// @Produce json
// @Success 200 {object} model.GetSessionResponse
// @Failure 400 "Bad Request"
// @Failure 500 "Internal Server Error"
// @Router /session [get]
func (h *UserAuthHandler) GetSession(c *gin.Context) {
	id, err := h.sessionService.GetSessionId(c)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get session id"})
		return
	}
	response := model.GetSessionResponse{
		SessionId: id,
	}

	c.JSON(http.StatusOK, response)
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
	var req model.UserLoginRequest

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
	var req model.UserLoginRequest

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
	// TODO: If user really exist in the database
	tokenString := c.GetHeader("Authorization")

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
