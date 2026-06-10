package memory

import (
	"context"
	"sort"
	"sync"

	"github.com/google/uuid"
	"github.com/nikitakovalevtaverz/chirp/internal/domain/notification"
)

type NotificationRepo struct {
	mu    sync.RWMutex
	items []*notification.Notification
}

func NewNotificationRepo() *NotificationRepo {
	return &NotificationRepo{}
}

func (r *NotificationRepo) Create(_ context.Context, n *notification.Notification) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if n.ID == "" {
		n.ID = uuid.New().String()
	}
	n.Read = false
	r.items = append(r.items, n)
	return nil
}

func (r *NotificationRepo) ListByUser(_ context.Context, userID string, limit int, cursor string) ([]*notification.Notification, string, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	if limit <= 0 || limit > 50 {
		limit = 20
	}

	var userItems []*notification.Notification
	for _, n := range r.items {
		if n.UserID == userID {
			userItems = append(userItems, n)
		}
	}

	sort.Slice(userItems, func(i, j int) bool {
		return userItems[i].CreatedAt.After(userItems[j].CreatedAt)
	})

	start := 0
	if cursor != "" {
		for i, n := range userItems {
			if n.ID == cursor {
				start = i + 1
				break
			}
		}
	}
	end := start + limit
	if end > len(userItems) {
		end = len(userItems)
	}
	nextCursor := ""
	if end < len(userItems) {
		nextCursor = userItems[end-1].ID
	}
	return userItems[start:end], nextCursor, nil
}

func (r *NotificationRepo) MarkRead(_ context.Context, id string, userID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, n := range r.items {
		if n.ID == id && n.UserID == userID {
			n.Read = true
			break
		}
	}
	return nil
}

func (r *NotificationRepo) CountUnread(_ context.Context, userID string) (int, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	count := 0
	for _, n := range r.items {
		if n.UserID == userID && !n.Read {
			count++
		}
	}
	return count, nil
}
