package memory

import (
	"context"
	"sort"
	"sync"

	domainTweet "github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
)

// LikeRepo is an in-memory implementation of port.LikeRepository.
type LikeRepo struct {
	mu       sync.RWMutex
	likes    map[string]map[string]bool // tweetID -> set of userIDs
}

// NewLikeRepo creates an empty LikeRepo.
func NewLikeRepo() *LikeRepo {
	return &LikeRepo{likes: make(map[string]map[string]bool)}
}

func (r *LikeRepo) Like(_ context.Context, userID, tweetID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.likes[tweetID] == nil {
		r.likes[tweetID] = make(map[string]bool)
	}
	r.likes[tweetID][userID] = true
	return nil
}

func (r *LikeRepo) Unlike(_ context.Context, userID, tweetID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.likes[tweetID] != nil {
		delete(r.likes[tweetID], userID)
	}
	return nil
}

func (r *LikeRepo) IsLiked(_ context.Context, userID, tweetID string) (bool, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	set := r.likes[tweetID]
	return set != nil && set[userID], nil
}

func (r *LikeRepo) Count(_ context.Context, tweetID string) (int, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	return len(r.likes[tweetID]), nil
}

func (r *LikeRepo) ListUsers(_ context.Context, tweetID string, limit int, cursor string) ([]*domainTweet.Like, string, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	if limit <= 0 || limit > 50 {
		limit = 20
	}
	set := r.likes[tweetID]
	ids := make([]string, 0, len(set))
	for id := range set {
		ids = append(ids, id)
	}
	sort.Strings(ids)

	start := 0
	if cursor != "" {
		for i, id := range ids {
			if id == cursor {
				start = i + 1
				break
			}
		}
	}
	end := start + limit
	if end > len(ids) {
		end = len(ids)
	}

	result := make([]*domainTweet.Like, 0, end-start)
	for _, id := range ids[start:end] {
		result = append(result, &domainTweet.Like{UserID: id, TweetID: tweetID})
	}
	nextCursor := ""
	if end < len(ids) {
		nextCursor = ids[end]
	}
	return result, nextCursor, nil
}
