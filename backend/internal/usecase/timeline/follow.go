package timeline

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// FollowUseCase handles following a user.
type FollowUseCase struct {
	repo port.FollowRepository
}

// NewFollowUseCase creates a FollowUseCase.
func NewFollowUseCase(repo port.FollowRepository) *FollowUseCase {
	return &FollowUseCase{repo: repo}
}

// Execute follows a user. Returns nil if already following.
func (uc *FollowUseCase) Execute(ctx context.Context, followerID, followeeID string) error {
	if followerID == followeeID {
		return ErrCannotFollowSelf
	}
	return uc.repo.Follow(ctx, followerID, followeeID)
}
