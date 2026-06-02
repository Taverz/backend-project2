package tweet

import "time"

// Tweet represents a single post.
type Tweet struct {
	ID        string
	AuthorID  string
	Body      string
	ParentID  string // empty if root tweet, otherwise ID of parent
	CreatedAt time.Time
	UpdatedAt time.Time
}
