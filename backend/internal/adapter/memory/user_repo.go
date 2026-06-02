package memory

import (
	"context"
	"sync"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/user"
)

// UserRepo is an in-memory implementation of port.UserRepository.
type UserRepo struct {
	mu    sync.RWMutex
	users map[string]*user.User // id -> user
}

// NewUserRepo creates an empty in-memory UserRepo.
func NewUserRepo() *UserRepo {
	return &UserRepo{users: make(map[string]*user.User)}
}

func (r *UserRepo) Create(_ context.Context, u *user.User) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.users[u.ID] = u
	return nil
}

func (r *UserRepo) GetByID(_ context.Context, id string) (*user.User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	u, ok := r.users[id]
	if !ok {
		return nil, nil
	}
	return u, nil
}

func (r *UserRepo) GetByEmail(_ context.Context, email string) (*user.User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	for _, u := range r.users {
		if u.Email == email {
			return u, nil
		}
	}
	return nil, nil
}

func (r *UserRepo) GetByUsername(_ context.Context, username string) (*user.User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	for _, u := range r.users {
		if u.Username == username {
			return u, nil
		}
	}
	return nil, nil
}
