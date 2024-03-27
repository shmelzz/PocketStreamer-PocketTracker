package service

import (
	"context"
	"userauth/internal/model"
)

type SessionServiceInterface interface {
	GetSessionId(ctx context.Context) (string, error)
	//	deleteSessionId(ctx context.Context, sessionId string) error
	WaitForTracker(ctx context.Context, sessionId string) (model.WaitForTrackerResponse, error)
	FindComposer(ctx context.Context, sessionId string, username string, token string) error
}
