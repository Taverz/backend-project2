package kafka

import (
	"context"
	"log/slog"

	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// EventBus is a stub for Kafka.
// Real implementation requires kafka-go — add when KAFKA_BROKERS is set.
type EventBus struct{}

func NewEventBus(_ []string) (*EventBus, error) {
	slog.Warn("Kafka adapter loaded but not connected — install kafka-go")
	return &EventBus{}, nil
}

func (b *EventBus) Publish(_ context.Context, _ string, _ port.Event) error {
	return nil
}

func (b *EventBus) Subscribe(_ string, _ port.EventHandler) {}
