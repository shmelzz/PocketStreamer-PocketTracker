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

func (s *SessionService) deleteSessionId(ctx context.Context, sessionId string) error {
	s.mu.RLock()
	delete(s.waitingComposers, sessionId)
	err := s.SessionRepository.DeleteSessionById(ctx, sessionId)
	s.mu.RUnlock()
	return err
}

func (s *SessionService) WaitForTracker(ctx context.Context, sessionId string) (model.WaitForTrackerResponse, error) {
	isSessionExist, err := s.SessionRepository.IsSessionExist(ctx, sessionId)
	if err != nil {
		return model.WaitForTrackerResponse{}, fmt.Errorf("cant perform exist repo")
	}
	if !isSessionExist {
		return model.WaitForTrackerResponse{}, fmt.Errorf("session not found")
	}
	ch := make(chan model.WaitForTrackerResponse)
	s.waitingComposers[sessionId] = ch

	timeout := time.Duration(30)
	timeoutCtx, cancel := context.WithTimeout(ctx, timeout*time.Second)
	defer cancel()

	for {
		select {
		case val := <-ch:
			s.deleteSessionId(ctx, sessionId)
			return val, nil
		case <-timeoutCtx.Done():
			// Handle the cancellation case
			s.deleteSessionId(ctx, sessionId)
			return model.WaitForTrackerResponse{}, fmt.Errorf("request was cancelled after 5 second timemout ")
		case <-ctx.Done():
			// Handle the cancellation case
			s.deleteSessionId(ctx, sessionId)
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
