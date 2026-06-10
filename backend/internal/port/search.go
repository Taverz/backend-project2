package port

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/search"
	"github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
)

type SearchEngine interface {
	IndexTweet(ctx context.Context, t *tweet.Tweet) error
	SearchTweets(ctx context.Context, query string, limit int, cursor string) ([]*search.SearchResult, string, error)
}
