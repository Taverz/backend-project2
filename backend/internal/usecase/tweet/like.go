package tweet

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// LikeUseCase handles liking a tweet.
type LikeUseCase struct {
	repo port.LikeRepository
}

// NewLikeUseCase creates a LikeUseCase.
func NewLikeUseCase(repo port.LikeRepository) *LikeUseCase {
	return &LikeUseCase{repo: repo}
}

// Execute likes a tweet. Idempotent — no error if already liked.
func (uc *LikeUseCase) Execute(ctx context.Context, userID, tweetID string) error {
	return uc.repo.Like(ctx, userID, tweetID)
}
