package transport

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"

	"github.com/nikitakovalevtaverz/chirp/internal/transport/middleware"
	usecaseTL "github.com/nikitakovalevtaverz/chirp/internal/usecase/timeline"
	"github.com/nikitakovalevtaverz/chirp/pkg/api"
)

// FollowUserResponse is a user summary in follow lists.
type FollowUserResponse struct {
	ID        string `json:"id"`
	Username  string `json:"username"`
	CreatedAt string `json:"created_at"`
}

// FollowHandler handles follow endpoints.
type FollowHandler struct {
	follow      *usecaseTL.FollowUseCase
	unfollow    *usecaseTL.UnfollowUseCase
	followers   *usecaseTL.ListFollowersUseCase
	following   *usecaseTL.ListFollowingUseCase
}

// NewFollowHandler creates a FollowHandler.
func NewFollowHandler(
	follow *usecaseTL.FollowUseCase,
	unfollow *usecaseTL.UnfollowUseCase,
	followers *usecaseTL.ListFollowersUseCase,
	following *usecaseTL.ListFollowingUseCase,
) *FollowHandler {
	return &FollowHandler{follow: follow, unfollow: unfollow, followers: followers, following: following}
}

// Follow handles POST /api/v1/users/{id}/follow
//
//	@Summary		Follow a user
//	@Security		BearerAuth
//	@Param			id	path	string	true	"User ID to follow"
//	@Success		204
//	@Failure		400	{object}	api.ProblemDetail
//	@Router			/users/{id}/follow [post]
func (h *FollowHandler) Follow(w http.ResponseWriter, r *http.Request) {
	userID, _ := middleware.UserIDFromContext(r.Context())
	targetID := chi.URLParam(r, "id")
	if err := h.follow.Execute(r.Context(), userID, targetID); err != nil {
		if errors.Is(err, usecaseTL.ErrCannotFollowSelf) {
			api.BadRequest(w, "cannot follow yourself")
			return
		}
		api.InternalError(w, "internal server error")
		return
	}
	api.RespondNoContent(w)
}

// Unfollow handles DELETE /api/v1/users/{id}/follow
//
//	@Summary		Unfollow a user
//	@Security		BearerAuth
//	@Param			id	path	string	true	"User ID to unfollow"
//	@Success		204
//	@Router			/users/{id}/follow [delete]
func (h *FollowHandler) Unfollow(w http.ResponseWriter, r *http.Request) {
	userID, _ := middleware.UserIDFromContext(r.Context())
	targetID := chi.URLParam(r, "id")
	if err := h.unfollow.Execute(r.Context(), userID, targetID); err != nil {
		api.InternalError(w, "internal server error")
		return
	}
	api.RespondNoContent(w)
}

// Followers handles GET /api/v1/users/{id}/followers
//
//	@Summary		List followers
//	@Param			id		path	string	true	"User ID"
//	@Param			limit	query	int		false	"Limit"
//	@Param			cursor	query	string	false	"Cursor"
//	@Success		200		{object}	api.PageResponse[FollowUserResponse]
//	@Router			/users/{id}/followers [get]
func (h *FollowHandler) Followers(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	limit = api.DefaultLimit(limit, 20, 50)
	cursor := r.URL.Query().Get("cursor")

	follows, nextCursor, total, err := h.followers.Execute(r.Context(), usecaseTL.ListInput{
		UserID: id, Limit: limit, Cursor: cursor,
	})
	if err != nil {
		api.InternalError(w, "internal server error")
		return
	}

	items := make([]FollowUserResponse, len(follows))
	for i, f := range follows {
		items[i] = FollowUserResponse{
			ID:        f.FollowerID,
			CreatedAt: f.CreatedAt.Format("2006-01-02T15:04:05Z"),
		}
	}

	api.RespondOK(w, map[string]any{
		"data":        items,
		"next_cursor": nextCursor,
		"has_more":    nextCursor != "",
		"total":       total,
	})
}

// Following handles GET /api/v1/users/{id}/following
//
//	@Summary		List following
//	@Param			id		path	string	true	"User ID"
//	@Param			limit	query	int		false	"Limit"
//	@Param			cursor	query	string	false	"Cursor"
//	@Success		200		{object}	api.PageResponse[FollowUserResponse]
//	@Router			/users/{id}/following [get]
func (h *FollowHandler) Following(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	limit = api.DefaultLimit(limit, 20, 50)
	cursor := r.URL.Query().Get("cursor")

	follows, nextCursor, total, err := h.following.Execute(r.Context(), usecaseTL.ListInput{
		UserID: id, Limit: limit, Cursor: cursor,
	})
	if err != nil {
		api.InternalError(w, "internal server error")
		return
	}

	items := make([]FollowUserResponse, len(follows))
	for i, f := range follows {
		items[i] = FollowUserResponse{
			ID:        f.FolloweeID,
			CreatedAt: f.CreatedAt.Format("2006-01-02T15:04:05Z"),
		}
	}

	api.RespondOK(w, map[string]any{
		"data":        items,
		"next_cursor": nextCursor,
		"has_more":    nextCursor != "",
		"total":       total,
	})
}
