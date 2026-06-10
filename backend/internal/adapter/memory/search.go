package memory

import (
	"context"
	"sort"
	"strings"
	"sync"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/search"
	"github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
)

type SearchEngine struct {
	mu      sync.RWMutex
	tweets  []*tweet.Tweet
}

func NewSearchEngine() *SearchEngine {
	return &SearchEngine{}
}

func (s *SearchEngine) IndexTweet(_ context.Context, t *tweet.Tweet) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.tweets = append(s.tweets, t)
	return nil
}

func (s *SearchEngine) SearchTweets(_ context.Context, query string, limit int, cursor string) ([]*search.SearchResult, string, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if limit <= 0 || limit > 50 {
		limit = 20
	}
	q := strings.ToLower(query)

	var results []*search.SearchResult
	for _, t := range s.tweets {
		if strings.Contains(strings.ToLower(t.Body), q) {
			results = append(results, &search.SearchResult{
				TweetID:   t.ID,
				AuthorID:  t.AuthorID,
				Body:      t.Body,
				Score:     0,
				CreatedAt: t.CreatedAt.Format("2006-01-02T15:04:05Z"),
			})
		}
	}

	sort.Slice(results, func(i, j int) bool {
		return results[i].TweetID > results[j].TweetID
	})

	start := 0
	if cursor != "" {
		for i, r := range results {
			if r.TweetID == cursor {
				start = i + 1
				break
			}
		}
	}
	end := start + limit
	if end > len(results) {
		end = len(results)
	}
	nextCursor := ""
	if end < len(results) {
		nextCursor = results[end-1].TweetID
	}
	return results[start:end], nextCursor, nil
}
