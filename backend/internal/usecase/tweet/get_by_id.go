package tweet

import (
	"context"

	domainTweet "github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// GetByIDUseCase retrieves a tweet by ID.
type GetByIDUseCase struct {
	repo port.TweetRepository
}

// NewGetByIDUseCase creates a GetByIDUseCase.
func NewGetByIDUseCase(repo port.TweetRepository) *GetByIDUseCase {
	return &GetByIDUseCase{repo: repo}
}

// Execute returns the tweet or an error.
func (uc *GetByIDUseCase) Execute(ctx context.Context, id string) (*domainTweet.Tweet, error) {
	t, err := uc.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if t == nil {
		return nil, domainTweet.ErrTweetNotFound
	}
	return t, nil
}
