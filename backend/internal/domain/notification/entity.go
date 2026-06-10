package notification

import "time"

type Notification struct {
	ID        string
	UserID    string
	Type      string // "like", "follow", "reply"
	ActorID   string
	TweetID   string
	Read      bool
	CreatedAt time.Time
}
