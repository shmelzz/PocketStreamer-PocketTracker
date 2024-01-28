package service

import "userauth/internal/repository"

type UserAuthService struct {
	UserAuthRepository *repository.UserAuthRepository
}

func NewUserAuthService(userAuthRepository *repository.UserAuthRepository) *UserAuthService {
	return &UserAuthService{
		UserAuthRepository: userAuthRepository,
	}
}
