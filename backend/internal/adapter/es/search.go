package es

import (
	"context"
	"log/slog"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/search"
	"github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
)

// SearchEngine is a stub for Elasticsearch.
// Real implementation requires go-elasticsearch/v8 — add when ES_URL is set.
type SearchEngine struct {
	index string
}

func NewSearchEngine(_ []string) (*SearchEngine, error) {
	slog.Warn("Elasticsearch adapter loaded but not connected — install go-elasticsearch/v8")
	return &SearchEngine{index: "tweets"}, nil
}

func (s *SearchEngine) IndexTweet(_ context.Context, _ *tweet.Tweet) error {
	return nil
}

func (s *SearchEngine) SearchTweets(_ context.Context, _ string, _ int, _ string) ([]*search.SearchResult, string, error) {
	return nil, "", nil
}
