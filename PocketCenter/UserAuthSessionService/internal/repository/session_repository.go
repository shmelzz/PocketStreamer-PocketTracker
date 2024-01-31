package repository

import (
	"context"
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
