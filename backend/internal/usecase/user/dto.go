package user

import domainUser "github.com/nikitakovalevtaverz/chirp/internal/domain/user"

// RegisterInput is the DTO for user registration.
type RegisterInput struct {
	Username string
	Email    string
	Password string
}

// LoginInput is the DTO for user login.
type LoginInput struct {
	Email    string
	Password string
}

// UserResponse is the public API representation of a user.
type UserResponse struct {
	ID          string `json:"id"`
	Username    string `json:"username"`
	Email       string `json:"email"`
	DisplayName string `json:"display_name"`
	Bio         string `json:"bio"`
	CreatedAt   string `json:"created_at"`
}

// AuthResponse is the response for login/register containing tokens.
type AuthResponse struct {
	User         UserResponse `json:"user"`
	AccessToken  string       `json:"access_token"`
	RefreshToken string       `json:"refresh_token"`
}

// FromUser maps a domain User to a UserResponse DTO.
func FromUser(u *domainUser.User) UserResponse {
	return UserResponse{
		ID:          u.ID,
		Username:    u.Username,
		Email:       u.Email,
		DisplayName: u.DisplayName,
		Bio:         u.Bio,
		CreatedAt:   u.CreatedAt.Format("2006-01-02T15:04:05Z"),
	}
}
