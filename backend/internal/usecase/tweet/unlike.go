package tweet

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// UnlikeUseCase handles unliking a tweet.
type UnlikeUseCase struct {
	repo port.LikeRepository
}

// NewUnlikeUseCase creates an UnlikeUseCase.
func NewUnlikeUseCase(repo port.LikeRepository) *UnlikeUseCase {
	return &UnlikeUseCase{repo: repo}
}

// Execute unlikes a tweet.
func (uc *UnlikeUseCase) Execute(ctx context.Context, userID, tweetID string) error {
	return uc.repo.Unlike(ctx, userID, tweetID)
}
