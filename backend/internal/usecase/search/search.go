package search

import (
	"context"

	domainSearch "github.com/nikitakovalevtaverz/chirp/internal/domain/search"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

type SearchTweetsUseCase struct {
	engine port.SearchEngine
}

func NewSearchTweetsUseCase(engine port.SearchEngine) *SearchTweetsUseCase {
	return &SearchTweetsUseCase{engine: engine}
}

func (uc *SearchTweetsUseCase) Execute(ctx context.Context, query string, limit int, cursor string) ([]*domainSearch.SearchResult, string, error) {
	return uc.engine.SearchTweets(ctx, query, limit, cursor)
}


