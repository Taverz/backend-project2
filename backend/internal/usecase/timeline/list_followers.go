package timeline

import (
	"context"

	domainTL "github.com/nikitakovalevtaverz/chirp/internal/domain/timeline"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// ListFollowersUseCase lists followers of a user.
type ListFollowersUseCase struct {
	repo port.FollowRepository
}

// NewListFollowersUseCase creates a ListFollowersUseCase.
func NewListFollowersUseCase(repo port.FollowRepository) *ListFollowersUseCase {
	return &ListFollowersUseCase{repo: repo}
}

// ListInput is pagination input.
type ListInput struct {
	UserID string
	Limit  int
	Cursor string
}

// Execute returns a paginated list of followers.
func (uc *ListFollowersUseCase) Execute(ctx context.Context, input ListInput) ([]*domainTL.Follow, string, int, error) {
	follows, cursor, err := uc.repo.ListFollowers(ctx, input.UserID, input.Limit, input.Cursor)
	if err != nil {
		return nil, "", 0, err
	}
	count, err := uc.repo.CountFollowers(ctx, input.UserID)
	if err != nil {
		return nil, "", 0, err
	}
	return follows, cursor, count, nil
}
