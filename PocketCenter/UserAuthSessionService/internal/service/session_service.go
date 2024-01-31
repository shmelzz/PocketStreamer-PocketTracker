package service

import (
	"context"
	"errors"
	"fmt"
	"sync"
	"time"
	"userauth/internal/model"
	"userauth/internal/repository"
)

type SessionService struct {
	SessionRepository *repository.SessionRepository
	waitingComposers  map[string]chan model.WaitForTrackerResponse
	mu                sync.RWMutex
}

func NewSessionService(sessionRepository *repository.SessionRepository) *SessionService {
	return &SessionService{
		SessionRepository: sessionRepository,
		waitingComposers:  make(map[string]chan model.WaitForTrackerResponse),
	}
}

func (s *SessionService) GetSessionId(ctx context.Context) (string, error) {
	sessionId, err := s.SessionRepository.CreateSessionId(ctx)

	if err != nil {
		return "", errors.New("cant save to repo sessionId")
	}
	return sessionId, nil
}

func (s *SessionService) WaitForTracker(ctx context.Context, sessionId string) (model.WaitForTrackerResponse, error) {
	ch := make(chan model.WaitForTrackerResponse)
	s.waitingComposers[sessionId] = ch

	timeoutCtx, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()

	for {
		select {
		case val := <-ch:
			s.mu.RLock()
			delete(s.waitingComposers, sessionId)
			s.mu.RUnlock()
			return val, nil
		case <-timeoutCtx.Done():
			// Handle the cancellation case
			s.mu.RLock()
			delete(s.waitingComposers, sessionId)
			s.mu.RUnlock()
			return model.WaitForTrackerResponse{}, fmt.Errorf("request was cancelled after 5 second timemout ")
		case <-ctx.Done():
			// Handle the cancellation case
			s.mu.RLock()
			delete(s.waitingComposers, sessionId)
			s.mu.RUnlock()
			return model.WaitForTrackerResponse{}, fmt.Errorf("request was cancelled")
		}
	}
}

func (s *SessionService) FindComposer(ctx context.Context, sessionId string, username string, token string) error {
	s.mu.RLock()
	ch, ok := s.waitingComposers[sessionId] // check for existence
	s.mu.RUnlock()
	if ok {
		ch <- model.WaitForTrackerResponse{
			Username: username,
			Token:    token,
		}
		return nil
	}
	return fmt.Errorf("cant find composer with this id")
}
