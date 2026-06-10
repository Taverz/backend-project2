package memory

import (
	"context"
	"log/slog"
	"sync"

	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

type EventBus struct {
	mu       sync.RWMutex
	handlers map[string][]port.EventHandler
}

func NewEventBus() *EventBus {
	return &EventBus{handlers: make(map[string][]port.EventHandler)}
}

func (b *EventBus) Publish(_ context.Context, topic string, event port.Event) error {
	b.mu.RLock()
	handlers := b.handlers[topic]
	b.mu.RUnlock()

	for _, h := range handlers {
		func(h port.EventHandler) {
			defer func() {
				if r := recover(); r != nil {
					slog.Error("event handler panic", "topic", topic, "recover", r)
				}
			}()
			_ = h(context.Background(), event)
		}(h)
	}
	return nil
}

func (b *EventBus) Subscribe(topic string, handler port.EventHandler) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.handlers[topic] = append(b.handlers[topic], handler)
}
