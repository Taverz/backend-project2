package port

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
)

// LikeRepository is the persistence port for likes.
type LikeRepository interface {
	Like(ctx context.Context, userID, tweetID string) error
	Unlike(ctx context.Context, userID, tweetID string) error
	IsLiked(ctx context.Context, userID, tweetID string) (bool, error)
	Count(ctx context.Context, tweetID string) (int, error)
	ListUsers(ctx context.Context, tweetID string, limit int, cursor string) ([]*tweet.Like, string, error)
}
