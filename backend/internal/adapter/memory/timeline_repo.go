package memory

import (
	"context"
	"sort"
	"sync"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/timeline"
)

// TimelineRepo is an in-memory implementation of port.TimelineRepository.
type TimelineRepo struct {
	mu      sync.RWMutex
	entries map[string][]*timeline.Entry // userID -> entries (sorted by scored_at desc, then id desc)
}

// NewTimelineRepo creates an empty TimelineRepo.
func NewTimelineRepo() *TimelineRepo {
	return &TimelineRepo{entries: make(map[string][]*timeline.Entry)}
}

func (r *TimelineRepo) AddEntry(_ context.Context, e *timeline.Entry) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	e.ScoredAt = e.ScoredAt.UTC()
	r.entries[e.RecipientID] = append(r.entries[e.RecipientID], e)
	return nil
}

func (r *TimelineRepo) GetHomeTimeline(_ context.Context, userID string, limit int, cursor string) ([]*timeline.Entry, string, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	if limit <= 0 || limit > 50 {
		limit = 20
	}

	entries := r.entries[userID]

	// Copy to avoid data race with concurrent AddEntry
	sorted := make([]*timeline.Entry, len(entries))
	copy(sorted, entries)

	// Sort by scored_at desc, tweet_id desc
	sort.Slice(sorted, func(i, j int) bool {
		if entries[i].ScoredAt.Equal(entries[j].ScoredAt) {
			return entries[i].TweetID > entries[j].TweetID
		}
		return sorted[i].ScoredAt.After(sorted[j].ScoredAt)
	})

	start := 0
	if cursor != "" {
		for i, e := range sorted {
			if e.TweetID == cursor {
				start = i + 1
				break
			}
		}
	}
	end := start + limit
	if end > len(sorted) {
		end = len(sorted)
	}

	nextCursor := ""
	if end < len(sorted) {
		nextCursor = sorted[end-1].TweetID
	}

	return sorted[start:end], nextCursor, nil
}
