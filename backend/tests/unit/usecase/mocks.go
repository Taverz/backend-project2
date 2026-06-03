package testutil

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/user"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// MockUserRepo implements port.UserRepository for testing.
type MockUserRepo struct {
	users map[string]*user.User
}

func NewMockUserRepo() *MockUserRepo {
	return &MockUserRepo{users: make(map[string]*user.User)}
}

func (r *MockUserRepo) Create(ctx context.Context, u *user.User) error {
	r.users[u.ID] = u
	return nil
}

func (r *MockUserRepo) GetByID(ctx context.Context, id string) (*user.User, error) {
	return r.users[id], nil
}

func (r *MockUserRepo) GetByEmail(ctx context.Context, email string) (*user.User, error) {
	for _, u := range r.users {
		if u.Email == email {
			return u, nil
		}
	}
	return nil, nil
}

func (r *MockUserRepo) GetByUsername(ctx context.Context, uname string) (*user.User, error) {
	for _, u := range r.users {
		if u.Username == uname {
			return u, nil
		}
	}
	return nil, nil
}

// MockPasswordHasher implements port.PasswordHasher for testing.
type MockPasswordHasher struct{}

func NewMockPasswordHasher() *MockPasswordHasher {
	return &MockPasswordHasher{}
}

func (h *MockPasswordHasher) Hash(password string) (string, error) {
	return "hashed_" + password, nil
}

func (h *MockPasswordHasher) Compare(hash, password string) error {
	if hash == "hashed_"+password {
		return nil
	}
	return nil
}

// MockAuthService implements port.AuthService for testing.
type MockAuthService struct{}

func NewMockAuthService() *MockAuthService {
	return &MockAuthService{}
}

func (s *MockAuthService) IssueTokenPair(ctx context.Context, userID string) (*port.TokenPair, error) {
	return &port.TokenPair{
		AccessToken:  "access_" + userID,
		RefreshToken: "refresh_" + userID,
	}, nil
}

func (s *MockAuthService) ValidateAccessToken(ctx context.Context, token string) (string, error) {
	return token, nil
}
