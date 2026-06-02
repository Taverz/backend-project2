package timeline

import (
	"context"

	domainTL "github.com/nikitakovalevtaverz/chirp/internal/domain/timeline"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// ListFollowingUseCase lists users followed by a user.
type ListFollowingUseCase struct {
	repo port.FollowRepository
}

// NewListFollowingUseCase creates a ListFollowingUseCase.
func NewListFollowingUseCase(repo port.FollowRepository) *ListFollowingUseCase {
	return &ListFollowingUseCase{repo: repo}
}

// Execute returns a paginated list of followed users.
func (uc *ListFollowingUseCase) Execute(ctx context.Context, input ListInput) ([]*domainTL.Follow, string, int, error) {
	follows, cursor, err := uc.repo.ListFollowing(ctx, input.UserID, input.Limit, input.Cursor)
	if err != nil {
		return nil, "", 0, err
	}
	count, err := uc.repo.CountFollowing(ctx, input.UserID)
	if err != nil {
		return nil, "", 0, err
	}
	return follows, cursor, count, nil
}
