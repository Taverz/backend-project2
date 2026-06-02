package user

import (
	"context"

	domainUser "github.com/nikitakovalevtaverz/chirp/internal/domain/user"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// LoginUseCase handles user authentication.
type LoginUseCase struct {
	repo    port.UserRepository
	hasher  port.PasswordHasher
	authSvc port.AuthService
}

// NewLoginUseCase creates a LoginUseCase.
func NewLoginUseCase(
	repo port.UserRepository,
	hasher port.PasswordHasher,
	authSvc port.AuthService,
) *LoginUseCase {
	return &LoginUseCase{repo: repo, hasher: hasher, authSvc: authSvc}
}

// Execute authenticates a user and returns tokens.
func (uc *LoginUseCase) Execute(ctx context.Context, input LoginInput) (*AuthResponse, error) {
	email, err := domainUser.NewEmail(input.Email)
	if err != nil {
		return nil, domainUser.ErrInvalidCredentials
	}

	u, err := uc.repo.GetByEmail(ctx, string(email))
	if err != nil || u == nil {
		return nil, domainUser.ErrInvalidCredentials
	}

	if err := uc.hasher.Compare(u.PasswordHash, input.Password); err != nil {
		return nil, domainUser.ErrInvalidCredentials
	}

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
