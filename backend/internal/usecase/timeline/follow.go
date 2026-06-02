package timeline

import (
	"context"
	"fmt"

	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// FollowUseCase handles following a user.
type FollowUseCase struct {
	repo     port.FollowRepository
	userRepo port.UserRepository
}

// NewFollowUseCase creates a FollowUseCase.
func NewFollowUseCase(repo port.FollowRepository, userRepo port.UserRepository) *FollowUseCase {
	return &FollowUseCase{repo: repo, userRepo: userRepo}
}

// Execute follows a user. Returns nil if already following.
func (uc *FollowUseCase) Execute(ctx context.Context, followerID, followeeID string) error {
	if followerID == followeeID {
		return ErrCannotFollowSelf
	}
	u, err := uc.userRepo.GetByID(ctx, followeeID)
	if err != nil {
		return fmt.Errorf("check target user: %w", err)
	}
	if u == nil {
		return fmt.Errorf("user not found")
	}
	return uc.repo.Follow(ctx, followerID, followeeID)
}
