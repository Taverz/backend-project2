package tweet

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	domainTweet "github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// CreateUseCase handles tweet creation.
type CreateUseCase struct {
	repo port.TweetRepository
}

// NewCreateUseCase creates a CreateUseCase.
func NewCreateUseCase(repo port.TweetRepository) *CreateUseCase {
	return &CreateUseCase{repo: repo}
}

// CreateInput is the DTO for creating a tweet.
type CreateInput struct {
	Body     string
	AuthorID string
	ParentID string // optional
}

// Execute creates a new tweet.
func (uc *CreateUseCase) Execute(ctx context.Context, input CreateInput) (*domainTweet.Tweet, error) {
	body, err := domainTweet.NewBody(input.Body)
	if err != nil {
		return nil, err
	}
	if input.ParentID != "" {
		parent, _ := uc.repo.GetByID(ctx, input.ParentID)
		if parent == nil {
			return nil, fmt.Errorf("parent tweet not found")
		}
	}

	t := &domainTweet.Tweet{
		ID:       uuid.New().String(),
		AuthorID: input.AuthorID,
		Body:     string(body),
		ParentID: input.ParentID,
	}

	if err := uc.repo.Create(ctx, t); err != nil {
		return nil, err
	}
	return t, nil
}
