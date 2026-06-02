package timeline

import (
	"context"
	"time"

	domainTimeline "github.com/nikitakovalevtaverz/chirp/internal/domain/timeline"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// FanOutUseCase distributes a tweet to followers' timelines.
type FanOutUseCase struct {
	timelineRepo port.TimelineRepository
	followRepo   port.FollowRepository
}

// NewFanOutUseCase creates a FanOutUseCase.
func NewFanOutUseCase(
	timelineRepo port.TimelineRepository,
	followRepo port.FollowRepository,
) *FanOutUseCase {
	return &FanOutUseCase{timelineRepo: timelineRepo, followRepo: followRepo}
}

// Execute fans out a tweet to all followers of the author.
func (uc *FanOutUseCase) Execute(ctx context.Context, tweetID, authorID string) error {
	// Get all followers (no pagination — we need ALL for fan-out)
	follows, _, err := uc.followRepo.ListFollowers(ctx, authorID, 100000, "")
	if err != nil {
		return err
	}

	now := time.Now().UTC()
	for _, f := range follows {
		entry := &domainTimeline.Entry{
			RecipientID: f.FollowerID,
			TweetID:     tweetID,
			AuthorID:    authorID,
			ScoredAt:    now,
		}
		if err := uc.timelineRepo.AddEntry(ctx, entry); err != nil {
			return err
		}
	}
	return nil
}
