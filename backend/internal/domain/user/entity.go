// Package user contains the user domain model.
package user

import "time"

// User represents a registered user.
type User struct {
	ID           string
	Username     string
	Email        string
	PasswordHash string
	DisplayName  string
	Bio          string
	CreatedAt    time.Time
	UpdatedAt    time.Time
}

// Profile is the user's public-facing information.
type Profile struct {
	ID          string `json:"id"`
	Username    string `json:"username"`
	DisplayName string `json:"display_name"`
	Bio         string `json:"bio"`
}

// Profile returns the user's public profile.
func (u *User) Profile() Profile {
	return Profile{
		ID:          u.ID,
		Username:    u.Username,
		DisplayName: u.DisplayName,
		Bio:         u.Bio,
	}
}
