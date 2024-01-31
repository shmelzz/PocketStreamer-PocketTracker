package service

import (
	"context"
	"errors"
	"userauth/internal/repository"
)

type SessionService struct {
	SessionRepository *repository.SessionRepository
}

func NewSessionService(sessionRepository *repository.SessionRepository) *SessionService {
	return &SessionService{
		SessionRepository: sessionRepository,
	}
}

func (s *SessionService) GetSessionId(ctx context.Context) (string, error) {
	sessionId, err := s.SessionRepository.CreateSessionId(ctx)

	if err != nil {
		return "", errors.New("cant save to repo sessionId")
	}
	return sessionId, nil
}
