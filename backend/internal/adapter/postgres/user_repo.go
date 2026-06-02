package postgres

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/nikitakovalevtaverz/chirp/internal/domain/user"
)

// UserRepo implements port.UserRepository with PostgreSQL.
type UserRepo struct {
	pool *Pool
}

// NewUserRepo creates a UserRepo.
func NewUserRepo(pool *Pool) *UserRepo {
	return &UserRepo{pool: pool}
}

func (r *UserRepo) Create(ctx context.Context, u *user.User) error {
	const q = `INSERT INTO users (id, username, email, password_hash, display_name, bio, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`
	now := time.Now().UTC()
	u.CreatedAt = now
	u.UpdatedAt = now
	_, err := r.pool.Exec(ctx, q,
		u.ID, u.Username, u.Email, u.PasswordHash,
		u.DisplayName, u.Bio, u.CreatedAt, u.UpdatedAt,
	)
	return err
}

func (r *UserRepo) GetByID(ctx context.Context, id string) (*user.User, error) {
	const q = `SELECT id, username, email, password_hash, display_name, bio, created_at, updated_at
		FROM users WHERE id = $1`
	var u user.User
	err := r.pool.QueryRow(ctx, q, id).Scan(
		&u.ID, &u.Username, &u.Email, &u.PasswordHash,
		&u.DisplayName, &u.Bio, &u.CreatedAt, &u.UpdatedAt,
	)
	if err != nil {
		if isNoRows(err) {
			return nil, nil
		}
		return nil, err
	}
	return &u, nil
}

func (r *UserRepo) GetByEmail(ctx context.Context, email string) (*user.User, error) {
	const q = `SELECT id, username, email, password_hash, display_name, bio, created_at, updated_at
		FROM users WHERE email = $1`
	var u user.User
	err := r.pool.QueryRow(ctx, q, email).Scan(
		&u.ID, &u.Username, &u.Email, &u.PasswordHash,
		&u.DisplayName, &u.Bio, &u.CreatedAt, &u.UpdatedAt,
	)
	if err != nil {
		if isNoRows(err) {
			return nil, nil
		}
		return nil, err
	}
	return &u, nil
}

func (r *UserRepo) GetByUsername(ctx context.Context, username string) (*user.User, error) {
	const q = `SELECT id, username, email, password_hash, display_name, bio, created_at, updated_at
		FROM users WHERE username = $1`
	var u user.User
	err := r.pool.QueryRow(ctx, q, username).Scan(
		&u.ID, &u.Username, &u.Email, &u.PasswordHash,
		&u.DisplayName, &u.Bio, &u.CreatedAt, &u.UpdatedAt,
	)
	if err != nil {
		if isNoRows(err) {
			return nil, nil
		}
		return nil, err
	}
	return &u, nil
}

func isNoRows(err error) bool {
	return errors.Is(err, pgx.ErrNoRows)
}
