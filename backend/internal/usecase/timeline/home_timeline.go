package timeline

import (
	"context"

	domainTimeline "github.com/nikitakovalevtaverz/chirp/internal/domain/timeline"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// GetHomeTimelineUseCase returns the home timeline for a user.
type GetHomeTimelineUseCase struct {
	timelineRepo port.TimelineRepository
}

// NewGetHomeTimelineUseCase creates a GetHomeTimelineUseCase.
func NewGetHomeTimelineUseCase(timelineRepo port.TimelineRepository) *GetHomeTimelineUseCase {
	return &GetHomeTimelineUseCase{timelineRepo: timelineRepo}
}

// Execute returns a paginated home timeline.
func (uc *GetHomeTimelineUseCase) Execute(ctx context.Context, userID string, limit int, cursor string) ([]*domainTimeline.Entry, string, error) {
	return uc.timelineRepo.GetHomeTimeline(ctx, userID, limit, cursor)
}
