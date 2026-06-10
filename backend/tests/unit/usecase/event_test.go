package testutil

import (
	"context"
	"testing"
	"time"

	domainNotif "github.com/nikitakovalevtaverz/chirp/internal/domain/notification"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

func TestEventBus_PublishSubscribe(t *testing.T) {
	bus := NewMockEventBus()
	received := make(chan port.Event, 1)

	bus.Subscribe("test.topic", func(c context.Context, e port.Event) error {
		received <- e
		return nil
	})

	event := port.Event{Type: "test", Data: map[string]string{"key": "value"}}
	bus.Publish(context.Background(), "test.topic", event)

	select {
	case e := <-received:
		if e.Type != "test" {
			t.Fatalf("expected type 'test', got %s", e.Type)
		}
		if e.Data["key"] != "value" {
			t.Fatalf("expected value, got %s", e.Data["key"])
		}
	case <-time.After(time.Second):
		t.Fatal("timeout waiting for event")
	}
}

func TestEventBus_UnpublishedTopic(t *testing.T) {
	bus := NewMockEventBus()
	err := bus.Publish(context.Background(), "unknown", port.Event{Type: "test"})
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestEvent_FollowCreatesNotification(t *testing.T) {
	notifRepo := NewMockNotifRepo()
	eventBus := NewMockEventBus()

	eventBus.Subscribe("user.followed", func(ctx context.Context, e port.Event) error {
		if e.Data["target_user_id"] == e.Data["actor_id"] {
			return nil
		}
		return notifRepo.Create(ctx, &domainNotif.Notification{
			UserID: e.Data["target_user_id"], Type: "follow",
		})
	})

	eventBus.Publish(context.Background(), "user.followed", port.Event{
		Data: map[string]string{"actor_id": "follower", "target_user_id": "target"},
	})

	time.Sleep(50 * time.Millisecond)
	notifs, _, _ := notifRepo.ListByUser(context.Background(), "target", 20, "")
	if len(notifs) != 1 {
		t.Fatalf("expected 1 notification, got %d", len(notifs))
	}
}

func TestEvent_SelfLikeNoNotification(t *testing.T) {
	notifRepo := NewMockNotifRepo()
	eventBus := NewMockEventBus()

	eventBus.Subscribe("tweet.liked", func(ctx context.Context, e port.Event) error {
		if e.Data["tweet_author_id"] == e.Data["actor_id"] {
			return nil
		}
		return notifRepo.Create(ctx, &domainNotif.Notification{
			UserID: e.Data["tweet_author_id"], Type: "like",
		})
	})

	eventBus.Publish(context.Background(), "tweet.liked", port.Event{
		Data: map[string]string{"tweet_id": "t1", "actor_id": "u1", "tweet_author_id": "u1"},
	})

	time.Sleep(50 * time.Millisecond)
	notifs, _, _ := notifRepo.ListByUser(context.Background(), "u1", 20, "")
	if len(notifs) != 0 {
		t.Fatal("no notification should be created for self-like")
	}
}
