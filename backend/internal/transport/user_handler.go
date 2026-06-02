package transport

import (
	"errors"
	"net/http"

	domainUser "github.com/nikitakovalevtaverz/chirp/internal/domain/user"
	usecaseUser "github.com/nikitakovalevtaverz/chirp/internal/usecase/user"
	"github.com/nikitakovalevtaverz/chirp/internal/transport/middleware"
	"github.com/nikitakovalevtaverz/chirp/pkg/api"
)

// UserHandler handles user profile endpoints.
type UserHandler struct {
	getProfile *usecaseUser.GetProfileUseCase
}

// NewUserHandler creates a UserHandler.
func NewUserHandler(getProfile *usecaseUser.GetProfileUseCase) *UserHandler {
	return &UserHandler{getProfile: getProfile}
}

// Me handles GET /api/v1/users/me
//
//	@Summary		Get current user profile
//	@Description	Returns the authenticated user's profile.
//	@Tags			users
//	@Produce		json
//	@Security		BearerAuth
//	@Success		200	{object}	usecaseUser.UserResponse
//	@Failure		401	{object}	api.ProblemDetail
//	@Router			/users/me [get]
func (h *UserHandler) Me(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		api.Unauthorized(w, "not authenticated")
		return
	}

	resp, err := h.getProfile.Execute(r.Context(), userID)
	if err != nil {
		if errors.Is(err, domainUser.ErrUserNotFound) {
			api.NotFound(w, "user not found")
			return
		}
		api.InternalError(w, "internal server error")
		return
	}

	api.RespondOK(w, resp)
}
