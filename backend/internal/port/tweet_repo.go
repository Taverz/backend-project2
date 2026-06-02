package port

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
)

// TweetRepository is the persistence port for tweets.
type TweetRepository interface {
	Create(ctx context.Context, t *tweet.Tweet) error
	GetByID(ctx context.Context, id string) (*tweet.Tweet, error)
	ListByAuthor(ctx context.Context, authorID string, limit int, cursor string) ([]*tweet.Tweet, string, error)
	Delete(ctx context.Context, id string) error
}
