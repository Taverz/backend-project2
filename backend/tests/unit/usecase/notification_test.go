package testutil

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	domainNotif "github.com/nikitakovalevtaverz/chirp/internal/domain/notification"
	"github.com/nikitakovalevtaverz/chirp/internal/adapter/memory"
	usecaseNotif "github.com/nikitakovalevtaverz/chirp/internal/usecase/notification"
)

func setupNotifications(t *testing.T) (notifRepo *memory.NotificationRepo, list *usecaseNotif.ListUseCase, count *usecaseNotif.CountUnreadUseCase, markRead *usecaseNotif.MarkReadUseCase) {
	t.Helper()
	repo := memory.NewNotificationRepo()
	return repo,
		usecaseNotif.NewListUseCase(repo),
		usecaseNotif.NewCountUnreadUseCase(repo),
		usecaseNotif.NewMarkReadUseCase(repo)
}

func TestNotification_Create(t *testing.T) {
	repo, list, count, _ := setupNotifications(t)
	userID := uuid.New().String()

	repo.Create(context.Background(), &domainNotif.Notification{
		UserID: userID, Type: "like", ActorID: "user1", TweetID: "tweet1",
		CreatedAt: time.Now().UTC(),
	})

	items, _, err := list.Execute(context.Background(), userID, 20, "")
	if err != nil {
		t.Fatalf("list failed: %v", err)
	}
	if len(items) != 1 {
		t.Fatalf("expected 1 notification, got %d", len(items))
	}
	if items[0].Type != "like" {
		t.Fatalf("expected type 'like', got %s", items[0].Type)
	}

	unread, _ := count.Execute(context.Background(), userID)
	if unread != 1 {
		t.Fatalf("expected 1 unread, got %d", unread)
	}
}

func TestNotification_MarkRead(t *testing.T) {
	repo, list, count, markRead := setupNotifications(t)
	userID := uuid.New().String()

	n := &domainNotif.Notification{
		UserID: userID, Type: "follow", ActorID: "user2",
		CreatedAt: time.Now().UTC(),
	}
	repo.Create(context.Background(), n)

	markRead.Execute(context.Background(), n.ID, userID)

	items, _, _ := list.Execute(context.Background(), userID, 20, "")
	if len(items) != 1 || items[0].Read != true {
		t.Fatal("expected notification to be marked as read")
	}

	unread, _ := count.Execute(context.Background(), userID)
	if unread != 0 {
		t.Fatalf("expected 0 unread after mark read, got %d", unread)
	}
}

func TestNotification_OtherUserCannotMarkRead(t *testing.T) {
	repo, _, _, markRead := setupNotifications(t)
	userID := uuid.New().String()

	n := &domainNotif.Notification{
		UserID: userID, Type: "like", ActorID: "user3",
		CreatedAt: time.Now().UTC(),
	}
	repo.Create(context.Background(), n)

	// Other user tries to mark as read
	markRead.Execute(context.Background(), n.ID, uuid.New().String())

	items, _, _ := (*usecaseNotif.ListUseCase)(usecaseNotif.NewListUseCase(repo)).Execute(context.Background(), userID, 20, "")
	if len(items) > 0 && items[0].Read {
		t.Fatal("other user should not be able to mark as read")
	}
}

func TestNotification_Pagination(t *testing.T) {
	repo, list, _, _ := setupNotifications(t)
	userID := uuid.New().String()

	for i := 0; i < 5; i++ {
		repo.Create(context.Background(), &domainNotif.Notification{
			UserID: userID, Type: "like", ActorID: "user",
			CreatedAt: time.Now().UTC(),
		})
	}

	items, cursor, err := list.Execute(context.Background(), userID, 2, "")
	if err != nil {
		t.Fatalf("list failed: %v", err)
	}
	if len(items) != 2 {
		t.Fatalf("expected 2 items (limit=2), got %d", len(items))
	}
	if cursor == "" {
		t.Fatal("expected next cursor when more items exist")
	}
}

func TestNotification_CountUnread_Empty(t *testing.T) {
	_, _, count, _ := setupNotifications(t)
	c, _ := count.Execute(context.Background(), uuid.New().String())
	if c != 0 {
		t.Fatalf("expected 0 for empty user, got %d", c)
	}
}
