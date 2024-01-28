package repository

import (
	"github.com/jackc/pgx/v4/pgxpool"
	_ "github.com/lib/pq"
)

type UserAuthRepository struct {
	pgxPool *pgxpool.Pool
}

func NewUserAuthRepository(pgxPool *pgxpool.Pool) *UserAuthRepository {
	return &UserAuthRepository{
		pgxPool: pgxPool,
	}
}
