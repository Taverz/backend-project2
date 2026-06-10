package port

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/notification"
)

type NotificationRepository interface {
	Create(ctx context.Context, n *notification.Notification) error
	ListByUser(ctx context.Context, userID string, limit int, cursor string) ([]*notification.Notification, string, error)
	MarkRead(ctx context.Context, id string, userID string) error
	CountUnread(ctx context.Context, userID string) (int, error)
}
