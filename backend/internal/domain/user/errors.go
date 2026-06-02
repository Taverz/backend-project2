package user

import "errors"

// Domain errors.
var (
	ErrUserNotFound      = errors.New("user not found")
	ErrUsernameTaken     = errors.New("username already taken")
	ErrEmailTaken        = errors.New("email already taken")
	ErrInvalidCredentials = errors.New("invalid email or password")
)
