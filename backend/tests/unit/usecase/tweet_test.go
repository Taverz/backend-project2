package testutil

import (
	"context"
	"testing"

	"github.com/google/uuid"
	domainTweet "github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
	usecaseTweet "github.com/nikitakovalevtaverz/chirp/internal/usecase/tweet"
)

func TestBody_Empty(t *testing.T) {
	_, err := domainTweet.NewBody("")
	if err == nil {
		t.Fatal("expected error for empty body")
	}
}

func TestBody_Valid(t *testing.T) {
	body, err := domainTweet.NewBody("hello world")
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if string(body) != "hello world" {
		t.Fatalf("expected hello world, got %s", body)
	}
}

func TestBody_TooLong(t *testing.T) {
	body := make([]byte, 281)
	for i := range body {
		body[i] = 'x'
	}
	_, err := domainTweet.NewBody(string(body))
	if err == nil {
		t.Fatal("expected error for long body")
	}
}

func TestCreateTweet_Valid(t *testing.T) {
	repo := NewMockTweetRepo()
	uc := usecaseTweet.NewCreateUseCase(repo)

	tweet, err := uc.Execute(context.Background(), usecaseTweet.CreateInput{
		Body:     "test tweet",
		AuthorID: uuid.New().String(),
	})
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if tweet.Body != "test tweet" {
		t.Fatalf("expected body test tweet, got %s", tweet.Body)
	}
	if tweet.AuthorID == "" {
		t.Fatal("expected non-empty author ID")
	}
	if tweet.ID == "" {
		t.Fatal("expected non-empty tweet ID")
	}
}

func TestCreateTweet_EmptyBody(t *testing.T) {
	repo := NewMockTweetRepo()
	uc := usecaseTweet.NewCreateUseCase(repo)

	_, err := uc.Execute(context.Background(), usecaseTweet.CreateInput{
		Body:     "",
		AuthorID: uuid.New().String(),
	})
	if err == nil {
		t.Fatal("expected error for empty body")
	}
}

func TestCreateTweet_TooLongBody(t *testing.T) {
	repo := NewMockTweetRepo()
	uc := usecaseTweet.NewCreateUseCase(repo)

	body := make([]byte, 281)
	for i := range body {
		body[i] = 'x'
	}

	_, err := uc.Execute(context.Background(), usecaseTweet.CreateInput{
		Body:     string(body),
		AuthorID: uuid.New().String(),
	})
	if err == nil {
		t.Fatal("expected error for too long body")
	}
}
