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

	// Sort by scored_at desc, tweet_id desc
	sort.Slice(entries, func(i, j int) bool {
		if entries[i].ScoredAt.Equal(entries[j].ScoredAt) {
			return entries[i].TweetID > entries[j].TweetID
		}
		return entries[i].ScoredAt.After(entries[j].ScoredAt)
	})

	start := 0
	if cursor != "" {
		for i, e := range entries {
			if e.TweetID == cursor {
				start = i + 1
				break
			}
		}
	}
	end := start + limit
	if end > len(entries) {
		end = len(entries)
	}

	nextCursor := ""
	if end < len(entries) {
		nextCursor = entries[end-1].TweetID
	}

	return entries[start:end], nextCursor, nil
}
