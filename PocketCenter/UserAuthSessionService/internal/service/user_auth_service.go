package service

import (
	"context"
	"errors"
	"time"
	"userauth/internal/model"
	"userauth/internal/repository"

	"github.com/golang-jwt/jwt/v4"
	"golang.org/x/crypto/bcrypt"
)

var jwtKey = []byte("your_secret_key") // replace with your secret key

type Claims struct {
	Username string `json:"username"`
	jwt.StandardClaims
}

type UserAuthService struct {
	UserAuthRepository *repository.UserAuthRepository
}

func NewUserAuthService(userAuthRepository *repository.UserAuthRepository) *UserAuthService {
	return &UserAuthService{
		UserAuthRepository: userAuthRepository,
	}
}

// RegisterUser handles the registration of a new user
func (s *UserAuthService) RegisterUser(ctx context.Context, username, password string) error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	user := model.User{
		Username: username,
		Password: string(hashedPassword),
	}

	return s.UserAuthRepository.CreateUser(ctx, &user)
}

// LoginUser handles user login and token generation
func (s *UserAuthService) LoginUser(ctx context.Context, username, password string) (string, error) {
	user, err := s.UserAuthRepository.GetUserByUsername(ctx, username)
	if err != nil {
		return "", err
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password))
	if err != nil {
		return "", errors.New("invalid credentials")
	}

	expirationTime := time.Now().Add(1 * time.Hour)
	claims := &Claims{
		Username: username,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: expirationTime.Unix(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

// ValidateToken checks the validity of a JWT token
func (s *UserAuthService) ValidateToken(tokenString string) (*jwt.Token, error) {
	claims := &Claims{}

	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return jwtKey, nil
	})

	if err != nil {
		return nil, err
	}

	if !token.Valid {
		return nil, errors.New("invalid token")
	}

	return token, nil
}
