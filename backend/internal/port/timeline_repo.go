package port

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/timeline"
)

// TimelineRepository manages home timeline entries.
type TimelineRepository interface {
	AddEntry(ctx context.Context, e *timeline.Entry) error
	GetHomeTimeline(ctx context.Context, userID string, limit int, cursor string) ([]*timeline.Entry, string, error)
}
