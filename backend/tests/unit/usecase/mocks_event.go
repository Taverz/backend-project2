package testutil

import (
	"context"
	"sync"

	domainNotif "github.com/nikitakovalevtaverz/chirp/internal/domain/notification"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// MockEventBus implements port.EventBus for testing.
type MockEventBus struct {
	mu       sync.RWMutex
	handlers map[string][]port.EventHandler
}

func NewMockEventBus() *MockEventBus {
	return &MockEventBus{handlers: make(map[string][]port.EventHandler)}
}

func (b *MockEventBus) Publish(_ context.Context, topic string, event port.Event) error {
	b.mu.RLock()
	hs := b.handlers[topic]
	b.mu.RUnlock()
	for _, h := range hs {
		go func(h port.EventHandler) { _ = h(context.Background(), event) }(h)
	}
	return nil
}

func (b *MockEventBus) Subscribe(topic string, handler port.EventHandler) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.handlers[topic] = append(b.handlers[topic], handler)
}

// MockNotifRepo implements port.NotificationRepository for testing.
type MockNotifRepo struct {
	mu    sync.Mutex
	items []domainNotif.Notification
}

func NewMockNotifRepo() *MockNotifRepo {
	return &MockNotifRepo{}
}

func (r *MockNotifRepo) Create(_ context.Context, n *domainNotif.Notification) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.items = append(r.items, *n)
	return nil
}

func (r *MockNotifRepo) ListByUser(_ context.Context, userID string, limit int, cursor string) ([]*domainNotif.Notification, string, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var res []*domainNotif.Notification
	for _, n := range r.items {
		if n.UserID == userID {
			cp := n
			res = append(res, &cp)
		}
	}
	return res, "", nil
}

func (r *MockNotifRepo) MarkRead(_ context.Context, id, userID string) error {
	return nil
}

func (r *MockNotifRepo) CountUnread(_ context.Context, userID string) (int, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	c := 0
	for _, n := range r.items {
		if n.UserID == userID && !n.Read {
			c++
		}
	}
	return c, nil
}
