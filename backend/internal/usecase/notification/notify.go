package notification

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/notification"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

type ListUseCase struct {
	repo port.NotificationRepository
}

func NewListUseCase(repo port.NotificationRepository) *ListUseCase {
	return &ListUseCase{repo: repo}
}

func (uc *ListUseCase) Execute(ctx context.Context, userID string, limit int, cursor string) ([]*notification.Notification, string, error) {
	return uc.repo.ListByUser(ctx, userID, limit, cursor)
}

type CountUnreadUseCase struct {
	repo port.NotificationRepository
}

func NewCountUnreadUseCase(repo port.NotificationRepository) *CountUnreadUseCase {
	return &CountUnreadUseCase{repo: repo}
}

func (uc *CountUnreadUseCase) Execute(ctx context.Context, userID string) (int, error) {
	return uc.repo.CountUnread(ctx, userID)
}

type MarkReadUseCase struct {
	repo port.NotificationRepository
}

func NewMarkReadUseCase(repo port.NotificationRepository) *MarkReadUseCase {
	return &MarkReadUseCase{repo: repo}
}

func (uc *MarkReadUseCase) Execute(ctx context.Context, id, userID string) error {
	return uc.repo.MarkRead(ctx, id, userID)
}
