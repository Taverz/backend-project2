package memory

import (
	"context"
	"sort"
	"sync"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
)

// TweetRepo is an in-memory implementation of port.TweetRepository.
type TweetRepo struct {
	mu     sync.RWMutex
	tweets map[string]*tweet.Tweet
	byUser map[string][]string // authorID -> tweetIDs
}

// NewTweetRepo creates an empty TweetRepo.
func NewTweetRepo() *TweetRepo {
	return &TweetRepo{
		tweets: make(map[string]*tweet.Tweet),
		byUser: make(map[string][]string),
	}
}

func (r *TweetRepo) Create(_ context.Context, t *tweet.Tweet) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.tweets[t.ID] = t
	r.byUser[t.AuthorID] = append(r.byUser[t.AuthorID], t.ID)
	return nil
}

func (r *TweetRepo) GetByID(_ context.Context, id string) (*tweet.Tweet, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	return r.tweets[id], nil
}

func (r *TweetRepo) ListByAuthor(_ context.Context, authorID string, limit int, cursor string) ([]*tweet.Tweet, string, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	ids := r.byUser[authorID]
	if limit <= 0 || limit > 50 {
		limit = 20
	}

	// Sort by insertion order (ID acts as cursor)
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

	var result []*tweet.Tweet
	for _, id := range ids[start:end] {
		result = append(result, r.tweets[id])
	}

	nextCursor := ""
	if end < len(ids) {
		nextCursor = ids[end]
	}

	return result, nextCursor, nil
}

func (r *TweetRepo) Delete(_ context.Context, id string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	delete(r.tweets, id)
	return nil
}
