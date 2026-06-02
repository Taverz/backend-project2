package timeline

import "time"

// Follow represents a user following another user.
type Follow struct {
	FollowerID string
	FolloweeID string
	CreatedAt  time.Time
}
