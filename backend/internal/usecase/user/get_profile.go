package user

import (
	"context"

	domainUser "github.com/nikitakovalevtaverz/chirp/internal/domain/user"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// GetProfileUseCase retrieves a user's profile by ID.
type GetProfileUseCase struct {
	repo port.UserRepository
}

// NewGetProfileUseCase creates a GetProfileUseCase.
func NewGetProfileUseCase(repo port.UserRepository) *GetProfileUseCase {
	return &GetProfileUseCase{repo: repo}
}

// Execute returns the user's profile.
func (uc *GetProfileUseCase) Execute(ctx context.Context, userID string) (*UserResponse, error) {
	u, err := uc.repo.GetByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, domainUser.ErrUserNotFound
	}
	resp := FromUser(u)
	return &resp, nil
}
