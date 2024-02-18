package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v4/pgxpool"
	_ "github.com/lib/pq"
)

type SessionRepository struct {
	pgxPool *pgxpool.Pool
}

func NewSessionRepository(pgxPool *pgxpool.Pool) *SessionRepository {
	return &SessionRepository{
		pgxPool: pgxPool,
	}
}

func (r *SessionRepository) CreateSessionId(ctx context.Context) (string, error) {
	id := ""
	sql := `INSERT INTO sessions (username, created_at, start_at) VALUES ($1, $2, $3) RETURNING id`
	now := time.Now()
	err := r.pgxPool.QueryRow(ctx, sql, nil, now, nil).Scan(&id)
	if err != nil {
		return "", err
	}
	return id, nil
}

func (r *SessionRepository) DeleteSessionById(ctx context.Context, id string) error {
	sql := `DELETE FROM sessions WHERE id = $1`
	_, err := r.pgxPool.Exec(ctx, sql, id)
	return err
}

func (r *SessionRepository) IsSessionExist(ctx context.Context, id string) (bool, error) {
	sql := `SELECT EXISTS (
		SELECT 1 
		FROM sessions 
		WHERE id = $1
	   )`
	var isSessionExist bool
	err := r.pgxPool.QueryRow(ctx, sql, id).Scan(&isSessionExist)
	if err != nil {
		return false, fmt.Errorf("error cant found is user exist %w", err)
	}
	return isSessionExist, nil
}
