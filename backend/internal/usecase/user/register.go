package user

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/user"
	domainUser "github.com/nikitakovalevtaverz/chirp/internal/domain/user"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// RegisterUseCase handles user registration.
type RegisterUseCase struct {
	repo     port.UserRepository
	hasher   port.PasswordHasher
	authSvc  port.AuthService
}

// NewRegisterUseCase creates a RegisterUseCase with injected dependencies.
func NewRegisterUseCase(
	repo port.UserRepository,
	hasher port.PasswordHasher,
	authSvc port.AuthService,
) *RegisterUseCase {
	return &RegisterUseCase{repo: repo, hasher: hasher, authSvc: authSvc}
}

// Execute registers a new user and returns tokens.
func (uc *RegisterUseCase) Execute(ctx context.Context, input RegisterInput) (*AuthResponse, error) {
	// Validate username
	uname, err := user.NewUsername(input.Username)
	if err != nil {
		return nil, err
	}

	// Validate email
	email, err := user.NewEmail(input.Email)
	if err != nil {
		return nil, err
	}

	// Validate password
	pwd, err := user.NewPassword(input.Password)
	if err != nil {
		return nil, err
	}

	// Check uniqueness
	existing, _ := uc.repo.GetByEmail(ctx, string(email))
	if existing != nil {
		return nil, domainUser.ErrEmailTaken
	}
	existing, _ = uc.repo.GetByUsername(ctx, string(uname))
	if existing != nil {
		return nil, domainUser.ErrUsernameTaken
	}

	// Hash password
	hash, err := uc.hasher.Hash(string(pwd))
	if err != nil {
		return nil, err
	}

	// Create user
	u := &user.User{
		ID:           newID(),
		Username:     string(uname),
		Email:        string(email),
		PasswordHash: hash,
	}

	if err := uc.repo.Create(ctx, u); err != nil {
		return nil, err
	}

	// Issue tokens
	tokens, err := uc.authSvc.IssueTokenPair(ctx, u.ID)
	if err != nil {
		return nil, err
	}

	return &AuthResponse{
		User:         FromUser(u),
		AccessToken:  tokens.AccessToken,
		RefreshToken: tokens.RefreshToken,
	}, nil
}
