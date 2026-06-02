package timeline

import "time"

// Entry is a single item in a user's home timeline.
type Entry struct {
	RecipientID string    // user who sees this
	TweetID     string
	AuthorID    string
	ScoredAt    time.Time
}
