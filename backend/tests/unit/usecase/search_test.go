package testutil

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/nikitakovalevtaverz/chirp/internal/adapter/memory"
	"github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
	usecaseSearch "github.com/nikitakovalevtaverz/chirp/internal/usecase/search"
)

func setupSearch(t *testing.T) (port.SearchEngine, *usecaseSearch.SearchTweetsUseCase) {
	t.Helper()
	engine := memory.NewSearchEngine()
	return engine, usecaseSearch.NewSearchTweetsUseCase(engine)
}

func TestSearch_IndexAndFind(t *testing.T) {
	engine, uc := setupSearch(t)

	now := time.Now().UTC()
	t1 := &tweet.Tweet{
		ID: uuid.New().String(), AuthorID: uuid.New().String(),
		Body: "golang is awesome for backend", CreatedAt: now,
	}
	t2 := &tweet.Tweet{
		ID: uuid.New().String(), AuthorID: uuid.New().String(),
		Body: "python is great for data science", CreatedAt: now,
	}

	engine.IndexTweet(context.Background(), t1)
	engine.IndexTweet(context.Background(), t2)

	results, _, err := uc.Execute(context.Background(), "golang", 20, "")
	if err != nil {
		t.Fatalf("search failed: %v", err)
	}
	if len(results) != 1 {
		t.Fatalf("expected 1 result for 'golang', got %d", len(results))
	}
	if results[0].Body != "golang is awesome for backend" {
		t.Fatalf("wrong tweet body: %s", results[0].Body)
	}
}

func TestSearch_CaseInsensitive(t *testing.T) {
	engine, uc := setupSearch(t)

	engine.IndexTweet(context.Background(), &tweet.Tweet{
		ID: uuid.New().String(), AuthorID: uuid.New().String(),
		Body: "GoLang Microservices", CreatedAt: time.Now().UTC(),
	})

	results, _, _ := uc.Execute(context.Background(), "golang", 20, "")
	if len(results) != 1 {
		t.Fatal("search should be case-insensitive")
	}
}

func TestSearch_EmptyQuery(t *testing.T) {
	_, uc := setupSearch(t)

	results, _, err := uc.Execute(context.Background(), "", 20, "")
	if err != nil {
		t.Fatalf("empty query failed: %v", err)
	}
	if len(results) != 0 {
		t.Fatalf("expected 0 results for empty query, got %d", len(results))
	}
}

func TestSearch_NoMatch(t *testing.T) {
	engine, uc := setupSearch(t)

	engine.IndexTweet(context.Background(), &tweet.Tweet{
		ID: uuid.New().String(), AuthorID: uuid.New().String(),
		Body: "only this tweet exists", CreatedAt: time.Now().UTC(),
	})

	results, _, _ := uc.Execute(context.Background(), "nonexistent", 20, "")
	if len(results) != 0 {
		t.Fatalf("expected 0 results, got %d", len(results))
	}
}

func TestSearch_Cursor(t *testing.T) {
	engine, uc := setupSearch(t)

	now := time.Now().UTC()
	for i := 0; i < 5; i++ {
		engine.IndexTweet(context.Background(), &tweet.Tweet{
			ID: uuid.New().String(), AuthorID: uuid.New().String(),
			Body: "common keyword tweet", CreatedAt: now,
		})
	}

	first, cursor, err := uc.Execute(context.Background(), "common", 2, "")
	if err != nil {
		t.Fatalf("first page failed: %v", err)
	}
	if len(first) != 2 {
		t.Fatalf("expected 2 items on first page, got %d", len(first))
	}
	if cursor == "" {
		t.Fatal("expected next cursor")
	}
}
