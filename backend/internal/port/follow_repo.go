package port

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/timeline"
)

// FollowRepository is the persistence port for follows.
type FollowRepository interface {
	Follow(ctx context.Context, followerID, followeeID string) error
	Unfollow(ctx context.Context, followerID, followeeID string) error
	IsFollowing(ctx context.Context, followerID, followeeID string) (bool, error)
	ListFollowers(ctx context.Context, userID string, limit int, cursor string) ([]*timeline.Follow, string, error)
	ListFollowing(ctx context.Context, userID string, limit int, cursor string) ([]*timeline.Follow, string, error)
	CountFollowers(ctx context.Context, userID string) (int, error)
	CountFollowing(ctx context.Context, userID string) (int, error)
}
