package tweet

import (
	"context"

	domainTweet "github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// DeleteUseCase handles tweet deletion.
type DeleteUseCase struct {
	repo port.TweetRepository
}

// NewDeleteUseCase creates a DeleteUseCase.
func NewDeleteUseCase(repo port.TweetRepository) *DeleteUseCase {
	return &DeleteUseCase{repo: repo}
}

// Execute deletes a tweet if the requester is the owner.
func (uc *DeleteUseCase) Execute(ctx context.Context, id, requesterID string) error {
	t, err := uc.repo.GetByID(ctx, id)
	if err != nil {
		return err
	}
	if t == nil {
		return domainTweet.ErrTweetNotFound
	}
	if t.AuthorID != requesterID {
		return domainTweet.ErrNotOwner
	}
	return uc.repo.Delete(ctx, id)
}
