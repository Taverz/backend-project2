package user

import "github.com/google/uuid"

// newID generates a new unique identifier.
// In production, this would use UUID v7 from your database or a real UUID package.
func newID() string {
	return uuid.New().String()
}
