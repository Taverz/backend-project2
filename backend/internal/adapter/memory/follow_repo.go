package memory

import (
	"context"
	"sort"
	"sync"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/timeline"
)

// FollowRepo is an in-memory implementation of port.FollowRepository.
type FollowRepo struct {
	mu        sync.RWMutex
	followers map[string]map[string]bool // userID -> set of followerIDs
	following map[string]map[string]bool // userID -> set of followeeIDs
}

// NewFollowRepo creates an empty FollowRepo.
func NewFollowRepo() *FollowRepo {
	return &FollowRepo{
		followers: make(map[string]map[string]bool),
		following: make(map[string]map[string]bool),
	}
}

func (r *FollowRepo) Follow(_ context.Context, followerID, followeeID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.following[followerID] == nil {
		r.following[followerID] = make(map[string]bool)
	}
	if r.followers[followeeID] == nil {
		r.followers[followeeID] = make(map[string]bool)
	}
	r.following[followerID][followeeID] = true
	r.followers[followeeID][followerID] = true
	return nil
}

func (r *FollowRepo) Unfollow(_ context.Context, followerID, followeeID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.following[followerID] != nil {
		delete(r.following[followerID], followeeID)
	}
	if r.followers[followeeID] != nil {
		delete(r.followers[followeeID], followerID)
	}
	return nil
}

func (r *FollowRepo) IsFollowing(_ context.Context, followerID, followeeID string) (bool, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	set := r.following[followerID]
	return set != nil && set[followeeID], nil
}

func (r *FollowRepo) ListFollowers(_ context.Context, userID string, limit int, cursor string) ([]*timeline.Follow, string, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	set := r.followers[userID]
	return paginateIDs(set, limit, cursor, true), "", nil
}

func (r *FollowRepo) ListFollowing(_ context.Context, userID string, limit int, cursor string) ([]*timeline.Follow, string, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	set := r.following[userID]
	return paginateIDs(set, limit, cursor, false), "", nil
}

func (r *FollowRepo) CountFollowers(_ context.Context, userID string) (int, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	return len(r.followers[userID]), nil
}

func (r *FollowRepo) CountFollowing(_ context.Context, userID string) (int, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	return len(r.following[userID]), nil
}

func paginateIDs(set map[string]bool, limit int, cursor string, follower bool) []*timeline.Follow {
	if limit <= 0 || limit > 50 {
		limit = 20
	}
	ids := make([]string, 0, len(set))
	for id := range set {
		ids = append(ids, id)
	}
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

	result := make([]*timeline.Follow, 0, end-start)
	for _, id := range ids[start:end] {
		f := &timeline.Follow{}
		if follower {
			f.FollowerID = id
			f.FolloweeID = ""
		} else {
			f.FollowerID = ""
			f.FolloweeID = id
		}
		result = append(result, f)
	}
	return result
}
