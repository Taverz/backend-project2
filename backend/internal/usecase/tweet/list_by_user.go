package tweet

import (
	"context"

	domainTweet "github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// ListByUserUseCase lists tweets by author.
type ListByUserUseCase struct {
	repo port.TweetRepository
}

// NewListByUserUseCase creates a ListByUserUseCase.
func NewListByUserUseCase(repo port.TweetRepository) *ListByUserUseCase {
	return &ListByUserUseCase{repo: repo}
}

// ListInput is the DTO for listing tweets.
type ListInput struct {
	AuthorID string
	Limit    int
	Cursor   string
}

// Execute returns a paginated list.
func (uc *ListByUserUseCase) Execute(ctx context.Context, input ListInput) ([]*domainTweet.Tweet, string, error) {
	return uc.repo.ListByAuthor(ctx, input.AuthorID, input.Limit, input.Cursor)
}
