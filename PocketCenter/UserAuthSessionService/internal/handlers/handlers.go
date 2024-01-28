package handlers

import (
	"userauth/internal/service"
)

type UserAuthHandler struct {
	userAuthService *service.UserAuthService
}

func NewUserAuthHandler(userAuthService *service.UserAuthService) *UserAuthHandler {
	return &UserAuthHandler{
		userAuthService: userAuthService,
	}
}
