package transport

import (
	"errors"
	"log/slog"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"

	domainTweet "github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
	"github.com/nikitakovalevtaverz/chirp/internal/transport/middleware"
	usecaseTL "github.com/nikitakovalevtaverz/chirp/internal/usecase/timeline"
	usecaseTweet "github.com/nikitakovalevtaverz/chirp/internal/usecase/tweet"
	"github.com/nikitakovalevtaverz/chirp/pkg/api"
)

// CreateTweetRequest is the HTTP request body for creating a tweet.
type CreateTweetRequest struct {
	Body     string `json:"body"`
	ParentID string `json:"parent_id,omitempty"`
}

// TweetResponse is the public API representation of a tweet.
type TweetResponse struct {
	ID        string `json:"id"`
	AuthorID  string `json:"author_id"`
	Body      string `json:"body"`
	ParentID  string `json:"parent_id,omitempty"`
	CreatedAt string `json:"created_at"`
}

// TweetHandler handles tweet endpoints.
type TweetHandler struct {
	create      *usecaseTweet.CreateUseCase
	getByID     *usecaseTweet.GetByIDUseCase
	listUser    *usecaseTweet.ListByUserUseCase
	delete      *usecaseTweet.DeleteUseCase
	fanOut      *usecaseTL.FanOutUseCase
	searchEngine port.SearchEngine
}

// NewTweetHandler creates a TweetHandler.
func NewTweetHandler(
	create *usecaseTweet.CreateUseCase,
	getByID *usecaseTweet.GetByIDUseCase,
	listUser *usecaseTweet.ListByUserUseCase,
	delete *usecaseTweet.DeleteUseCase,
	fanOut *usecaseTL.FanOutUseCase,
	searchEngine port.SearchEngine,
) *TweetHandler {
	return &TweetHandler{
		create:      create,
		getByID:     getByID,
		listUser:    listUser,
		delete:      delete,
		fanOut:      fanOut,
		searchEngine: searchEngine,
	}
}

// Create handles POST /api/v1/tweets
//
//	@Summary		Create a tweet
//	@Description	Creates a new tweet for the authenticated user.
//	@Tags			tweets
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			body	body		CreateTweetRequest	true	"Tweet payload"
//	@Success		201		{object}	TweetResponse
//	@Failure		400		{object}	api.ProblemDetail
//	@Failure		401		{object}	api.ProblemDetail
//	@Router			/tweets [post]
func (h *TweetHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		api.Unauthorized(w, "not authenticated")
		return
	}

	var req CreateTweetRequest
	if err := api.Decode(w, r, &req); err != nil {
		return
	}

	t, err := h.create.Execute(r.Context(), usecaseTweet.CreateInput{
		Body:     req.Body,
		AuthorID: userID,
		ParentID: req.ParentID,
	})
	if err != nil {
		mapTweetError(w, err)
		return
	}

	// Fan-out to followers (best-effort)
	if h.fanOut != nil {
		if err := h.fanOut.Execute(r.Context(), t.ID, t.AuthorID); err != nil {
			slog.Error("fanout failed", "error", err, "tweet_id", t.ID)
		}
	}

	// Index for search (best-effort)
	if h.searchEngine != nil {
		if err := h.searchEngine.IndexTweet(r.Context(), t); err != nil {
			slog.Error("search index failed", "error", err, "tweet_id", t.ID)
		}
	}

	api.RespondCreated(w, toTweetResponse(t))
}

// Get handles GET /api/v1/tweets/{id}
//
//	@Summary		Get a tweet
//	@Description	Returns a single tweet by ID.
//	@Tags			tweets
//	@Produce		json
//	@Param			id	path		string	true	"Tweet ID"
//	@Success		200	{object}	TweetResponse
//	@Failure		404	{object}	api.ProblemDetail
//	@Router			/tweets/{id} [get]
func (h *TweetHandler) Get(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	t, err := h.getByID.Execute(r.Context(), id)
	if err != nil {
		mapTweetError(w, err)
		return
	}
	api.RespondOK(w, toTweetResponse(t))
}

// ListByUser handles GET /api/v1/users/{id}/tweets
//
//	@Summary		List user tweets
//	@Description	Returns a paginated list of tweets by a user.
//	@Tags			tweets
//	@Produce		json
//	@Param			id		path		string	true	"User ID"
//	@Param			limit	query		int		false	"Limit (default 20, max 50)"
//	@Param			cursor	query		string	false	"Pagination cursor"
//	@Success		200		{object}	api.PageResponse[TweetResponse]
//	@Router			/users/{id}/tweets [get]
func (h *TweetHandler) ListByUser(w http.ResponseWriter, r *http.Request) {
	authorID := chi.URLParam(r, "id")
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	limit = api.DefaultLimit(limit, 20, 50)
	cursor := r.URL.Query().Get("cursor")

	tweets, nextCursor, err := h.listUser.Execute(r.Context(), usecaseTweet.ListInput{
		AuthorID: authorID,
		Limit:    limit,
		Cursor:   cursor,
	})
	if err != nil {
		mapTweetError(w, err)
		return
	}

	items := make([]TweetResponse, len(tweets))
	for i, t := range tweets {
		items[i] = toTweetResponse(t)
	}

	api.RespondOK(w, api.PageResponse[TweetResponse]{
		Data:       items,
		NextCursor: api.Cursor(nextCursor),
		HasMore:    nextCursor != "",
	})
}

// Delete handles DELETE /api/v1/tweets/{id}
//
//	@Summary		Delete a tweet
//	@Description	Deletes a tweet (only the author can delete).
//	@Tags			tweets
//	@Security		BearerAuth
//	@Param			id	path	string	true	"Tweet ID"
//	@Success		204
//	@Failure		403	{object}	api.ProblemDetail
//	@Failure		404	{object}	api.ProblemDetail
//	@Router			/tweets/{id} [delete]
func (h *TweetHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		api.Unauthorized(w, "not authenticated")
		return
	}

	id := chi.URLParam(r, "id")
	if err := h.delete.Execute(r.Context(), id, userID); err != nil {
		mapTweetError(w, err)
		return
	}

	api.RespondNoContent(w)
}

func toTweetResponse(t *domainTweet.Tweet) TweetResponse {
	return TweetResponse{
		ID:        t.ID,
		AuthorID:  t.AuthorID,
		Body:      t.Body,
		ParentID:  t.ParentID,
		CreatedAt: t.CreatedAt.Format("2006-01-02T15:04:05Z"),
	}
}

func mapTweetError(w http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, domainTweet.ErrTweetNotFound):
		api.NotFound(w, "tweet not found")
	case errors.Is(err, domainTweet.ErrNotOwner):
		api.Forbidden(w, "you can only delete your own tweets")
	case errors.Is(err, domainTweet.ErrBodyEmpty) || errors.Is(err, domainTweet.ErrBodyTooLong):
		api.BadRequest(w, err.Error())
	default:
		api.InternalError(w, "internal server error")
	}
}
