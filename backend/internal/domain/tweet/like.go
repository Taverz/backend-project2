package tweet

import "time"

// Like represents a user liking a tweet.
type Like struct {
	UserID    string
	TweetID   string
	CreatedAt time.Time
}
