package transport

import (
	"errors"
	"net/http"

	domainUser "github.com/nikitakovalevtaverz/chirp/internal/domain/user"
	usecaseUser "github.com/nikitakovalevtaverz/chirp/internal/usecase/user"
	"github.com/nikitakovalevtaverz/chirp/pkg/api"
)

// RegisterRequest is the HTTP request body for registration.
type RegisterRequest struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

// LoginRequest is the HTTP request body for login.
type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// AuthHandler handles authentication endpoints.
type AuthHandler struct {
	register *usecaseUser.RegisterUseCase
	login    *usecaseUser.LoginUseCase
}

// NewAuthHandler creates an AuthHandler.
func NewAuthHandler(
	register *usecaseUser.RegisterUseCase,
	login *usecaseUser.LoginUseCase,
) *AuthHandler {
	return &AuthHandler{register: register, login: login}
}

// Register handles POST /api/v1/auth/register
//
//	@Summary		Register a new user
//	@Description	Creates a new account and returns JWT tokens.
//	@Tags			auth
//	@Accept			json
//	@Produce		json
//	@Param			body	body		RegisterRequest	true	"Registration payload"
//	@Success		201		{object}	usecaseUser.AuthResponse
//	@Failure		400		{object}	api.ProblemDetail
//	@Failure		409		{object}	api.ProblemDetail
//	@Router			/auth/register [post]
func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var req RegisterRequest
	if err := api.Decode(w, r, &req); err != nil {
		return
	}

	input := usecaseUser.RegisterInput{
		Username: req.Username,
		Email:    req.Email,
		Password: req.Password,
	}

	resp, err := h.register.Execute(r.Context(), input)
	if err != nil {
		mapAuthError(w, err)
		return
	}

	api.RespondCreated(w, resp)
}

// Login handles POST /api/v1/auth/login
//
//	@Summary		Login
//	@Description	Authenticates a user and returns JWT tokens.
//	@Tags			auth
//	@Accept			json
//	@Produce		json
//	@Param			body	body		LoginRequest	true	"Login payload"
//	@Success		200		{object}	usecaseUser.AuthResponse
//	@Failure		400		{object}	api.ProblemDetail
//	@Failure		401		{object}	api.ProblemDetail
//	@Router			/auth/login [post]
func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req LoginRequest
	if err := api.Decode(w, r, &req); err != nil {
		return
	}

	input := usecaseUser.LoginInput{
		Email:    req.Email,
		Password: req.Password,
	}

	resp, err := h.login.Execute(r.Context(), input)
	if err != nil {
		mapAuthError(w, err)
		return
	}

	api.RespondOK(w, resp)
}

// mapAuthError maps domain errors to HTTP responses.
func mapAuthError(w http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, domainUser.ErrEmailTaken):
		api.Conflict(w, "email already registered")
	case errors.Is(err, domainUser.ErrUsernameTaken):
		api.Conflict(w, "username already taken")
	case errors.Is(err, domainUser.ErrInvalidCredentials):
		api.Unauthorized(w, "invalid email or password")
	case isValidationError(err):
		api.BadRequest(w, err.Error())
	default:
		api.InternalError(w, "internal server error")
	}
}

func isValidationError(err error) bool {
	return errors.Is(err, domainUser.ErrUsernameTooShort) ||
		errors.Is(err, domainUser.ErrUsernameTooLong) ||
		errors.Is(err, domainUser.ErrUsernameInvalid) ||
		errors.Is(err, domainUser.ErrEmailEmpty) ||
		errors.Is(err, domainUser.ErrEmailInvalid) ||
		errors.Is(err, domainUser.ErrPasswordTooShort) ||
		errors.Is(err, domainUser.ErrPasswordTooLong)
}
