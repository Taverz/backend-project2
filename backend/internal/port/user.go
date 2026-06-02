package port

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/user"
)

// UserRepository is the persistence port for users.
type UserRepository interface {
	Create(ctx context.Context, u *user.User) error
	GetByID(ctx context.Context, id string) (*user.User, error)
	GetByEmail(ctx context.Context, email string) (*user.User, error)
	GetByUsername(ctx context.Context, username string) (*user.User, error)
}
