package tweet

import "errors"

// Domain errors.
var (
	ErrTweetNotFound = errors.New("tweet not found")
	ErrBodyTooLong   = errors.New("tweet body: must be at most 280 characters")
	ErrBodyEmpty     = errors.New("tweet body: must not be empty")
	ErrNotOwner      = errors.New("not the owner of this tweet")
)

// Body validates a tweet body.
type Body string

// NewBody creates a validated Body.
func NewBody(raw string) (Body, error) {
	switch {
	case raw == "":
		return "", ErrBodyEmpty
	case len([]rune(raw)) > 280:
		return "", ErrBodyTooLong
	}
	return Body(raw), nil
}
