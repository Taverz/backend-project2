package timeline

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// UnfollowUseCase handles unfollowing a user.
type UnfollowUseCase struct {
	repo port.FollowRepository
}

// NewUnfollowUseCase creates an UnfollowUseCase.
func NewUnfollowUseCase(repo port.FollowRepository) *UnfollowUseCase {
	return &UnfollowUseCase{repo: repo}
}

// Execute unfollows a user.
func (uc *UnfollowUseCase) Execute(ctx context.Context, followerID, followeeID string) error {
	return uc.repo.Unfollow(ctx, followerID, followeeID)
}
