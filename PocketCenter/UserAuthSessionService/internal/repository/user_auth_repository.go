package repository

import (
	"context"
	"errors"
	"fmt"
	"userauth/internal/model"

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

// CreateUser inserts a new user into the database
func (r *UserAuthRepository) CreateUser(ctx context.Context, user *model.User) error {
	sql := `INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id`
	return r.pgxPool.QueryRow(ctx, sql, user.Username, user.Password).Scan(&user.ID)
}

// Is user exist
func (r *UserAuthRepository) IsUserExist(ctx context.Context, username string) (bool, error) {
	sql := `SELECT EXISTS (
		SELECT 1 
		FROM users 
		WHERE username = $1
	   )`
	var isUserExist bool
	err := r.pgxPool.QueryRow(ctx, sql, username).Scan(&isUserExist)
	if err != nil {
		return false, fmt.Errorf("error cant found is user exist %w", err)
	}
	return isUserExist, nil
}

// GetUserByUsername fetches a user by username
func (r *UserAuthRepository) GetUserByUsername(ctx context.Context, username string) (*model.User, error) {
	var user model.User
	sql := `SELECT id, username, password FROM users WHERE username = $1`
	err := r.pgxPool.QueryRow(ctx, sql, username).Scan(&user.ID, &user.Username, &user.Password)
	if err != nil {
		return nil, fmt.Errorf("error fetching user: %w", err)
	}
	return &user, nil
}

// UpdateUser updates a user's credentials
func (r *UserAuthRepository) UpdateUser(ctx context.Context, user *model.User) error {
	sql := `UPDATE users SET password = $2 WHERE id = $1`
	commandTag, err := r.pgxPool.Exec(ctx, sql, user.ID, user.Password)
	if err != nil {
		return fmt.Errorf("error updating user: %w", err)
	}

	if commandTag.RowsAffected() != 1 {
		return errors.New("no rows affected")
	}

	return nil
}
