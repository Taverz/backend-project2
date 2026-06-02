package api

// Cursor is an opaque pagination cursor (typically a base64-encoded ID).
type Cursor string

// PageRequest holds cursor-based pagination parameters.
type PageRequest struct {
	Cursor Cursor `json:"cursor,omitempty"`
	Limit  int    `json:"limit"`
}

// PageResponse wraps a paginated collection.
type PageResponse[T any] struct {
	Data       []T    `json:"data"`
	NextCursor Cursor `json:"next_cursor,omitempty"`
	HasMore    bool   `json:"has_more"`
}

// DefaultLimit returns limit clamped to [1, max].
func DefaultLimit(limit, fallback, max int) int {
	if limit < 1 {
		return fallback
	}
	if limit > max {
		return max
	}
	return limit
}
