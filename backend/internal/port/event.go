package port

import "context"

type Event struct {
	Type string
	Data map[string]string
}

type EventHandler func(ctx context.Context, e Event) error

type EventBus interface {
	Publish(ctx context.Context, topic string, event Event) error
	Subscribe(topic string, handler EventHandler)
}
