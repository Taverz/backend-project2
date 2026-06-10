package transport

import (
	"context"
	"net/http"
	"strconv"
	"time"

	"github.com/go-chi/chi/v5"
	domainNotif "github.com/nikitakovalevtaverz/chirp/internal/domain/notification"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
	usecaseNotif "github.com/nikitakovalevtaverz/chirp/internal/usecase/notification"
	usecaseSearch "github.com/nikitakovalevtaverz/chirp/internal/usecase/search"
	"github.com/nikitakovalevtaverz/chirp/internal/transport/middleware"
	"github.com/nikitakovalevtaverz/chirp/pkg/api"
)

type searchHandler struct {
	search *usecaseSearch.SearchTweetsUseCase
}

func NewSearchHandler(search *usecaseSearch.SearchTweetsUseCase) *searchHandler {
	return &searchHandler{search: search}
}

// GET /api/v1/tweets/search?q=...&limit=...&cursor=...
func (h *searchHandler) Search(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query().Get("q")
	if q == "" {
		api.BadRequest(w, "query parameter 'q' is required")
		return
	}
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	limit = api.DefaultLimit(limit, 20, 50)
	cursor := r.URL.Query().Get("cursor")

	results, nextCursor, err := h.search.Execute(r.Context(), q, limit, cursor)
	if err != nil {
		api.InternalError(w, "search failed")
		return
	}

	api.RespondOK(w, map[string]any{
		"data":        results,
		"next_cursor": nextCursor,
		"has_more":    nextCursor != "",
	})
}

type notificationHandler struct {
	list       *usecaseNotif.ListUseCase
	count      *usecaseNotif.CountUnreadUseCase
	markRead   *usecaseNotif.MarkReadUseCase
}

func NewNotificationHandler(
	list *usecaseNotif.ListUseCase,
	count *usecaseNotif.CountUnreadUseCase,
	markRead *usecaseNotif.MarkReadUseCase,
) *notificationHandler {
	return &notificationHandler{list: list, count: count, markRead: markRead}
}

// GET /api/v1/notifications
func (h *notificationHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, _ := middleware.UserIDFromContext(r.Context())
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	limit = api.DefaultLimit(limit, 20, 50)
	cursor := r.URL.Query().Get("cursor")

	items, nextCursor, err := h.list.Execute(r.Context(), userID, limit, cursor)
	if err != nil {
		api.InternalError(w, "failed to list notifications")
		return
	}
	unread, _ := h.count.Execute(r.Context(), userID)

	api.RespondOK(w, map[string]any{
		"data":        items,
		"next_cursor": nextCursor,
		"has_more":    nextCursor != "",
		"unread":      unread,
	})
}

// POST /api/v1/notifications/{id}/read
func (h *notificationHandler) MarkRead(w http.ResponseWriter, r *http.Request) {
	userID, _ := middleware.UserIDFromContext(r.Context())
	id := chi.URLParam(r, "id")
	if err := h.markRead.Execute(r.Context(), id, userID); err != nil {
		api.InternalError(w, "failed to mark as read")
		return
	}
	api.RespondNoContent(w)
}

// SetupEventSubscribers wires event handlers for notifications.
func SetupNotificationSubscribers(
	bus port.EventBus,
	notifRepo port.NotificationRepository,
) {
	bus.Subscribe("tweet.liked", func(ctx context.Context, e port.Event) error {
		authorID := e.Data["tweet_author_id"]
		actorID := e.Data["actor_id"]
		tweetID := e.Data["tweet_id"]
		if authorID == actorID {
			return nil // don't notify self
		}
		return notifRepo.Create(ctx, &domainNotif.Notification{
			UserID: authorID, Type: "like", ActorID: actorID, TweetID: tweetID,
			CreatedAt: time.Now().UTC(),
		})
	})

	bus.Subscribe("user.followed", func(ctx context.Context, e port.Event) error {
		targetID := e.Data["target_user_id"]
		actorID := e.Data["actor_id"]
		if targetID == actorID {
			return nil
		}
		return notifRepo.Create(ctx, &domainNotif.Notification{
			UserID: targetID, Type: "follow", ActorID: actorID,
			CreatedAt: time.Now().UTC(),
		})
	})
}
