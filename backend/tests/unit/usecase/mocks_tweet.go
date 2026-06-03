package testutil

import (
	"context"

	"github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
	"github.com/nikitakovalevtaverz/chirp/internal/domain/timeline"
)

// MockTweetRepo implements port.TweetRepository for testing.
type MockTweetRepo struct {
	tweets map[string]*tweet.Tweet
	byUser map[string][]string
}

func NewMockTweetRepo() *MockTweetRepo {
	return &MockTweetRepo{
		tweets: make(map[string]*tweet.Tweet),
		byUser: make(map[string][]string),
	}
}

func (r *MockTweetRepo) Create(ctx context.Context, t *tweet.Tweet) error {
	r.tweets[t.ID] = t
	r.byUser[t.AuthorID] = append(r.byUser[t.AuthorID], t.ID)
	return nil
}

func (r *MockTweetRepo) GetByID(ctx context.Context, id string) (*tweet.Tweet, error) {
	return r.tweets[id], nil
}

func (r *MockTweetRepo) ListByAuthor(ctx context.Context, authorID string, limit int, cursor string) ([]*tweet.Tweet, string, error) {
	return nil, "", nil
}

func (r *MockTweetRepo) Delete(ctx context.Context, id string) error {
	delete(r.tweets, id)
	for authorID, ids := range r.byUser {
		for i, tid := range ids {
			if tid == id {
				r.byUser[authorID] = append(ids[:i], ids[i+1:]...)
				break
			}
		}
	}
	return nil
}

// MockFollowRepo implements port.FollowRepository for testing.
type MockFollowRepo struct {
	follows map[string]map[string]bool
}

func NewMockFollowRepo() *MockFollowRepo {
	return &MockFollowRepo{follows: make(map[string]map[string]bool)}
}

func (r *MockFollowRepo) Follow(ctx context.Context, followerID, followeeID string) error {
	if r.follows[followerID] == nil {
		r.follows[followerID] = make(map[string]bool)
	}
	r.follows[followerID][followeeID] = true
	return nil
}

func (r *MockFollowRepo) Unfollow(ctx context.Context, followerID, followeeID string) error {
	if r.follows[followerID] != nil {
		delete(r.follows[followerID], followeeID)
	}
	return nil
}

func (r *MockFollowRepo) IsFollowing(ctx context.Context, followerID, followeeID string) (bool, error) {
	return r.follows[followerID] != nil && r.follows[followerID][followeeID], nil
}

func (r *MockFollowRepo) ListFollowers(ctx context.Context, userID string, limit int, cursor string) ([]*timeline.Follow, string, error) {
	return nil, "", nil
}

func (r *MockFollowRepo) ListFollowing(ctx context.Context, userID string, limit int, cursor string) ([]*timeline.Follow, string, error) {
	return nil, "", nil
}

func (r *MockFollowRepo) CountFollowers(ctx context.Context, userID string) (int, error) {
	return 0, nil
}

func (r *MockFollowRepo) CountFollowing(ctx context.Context, userID string) (int, error) {
	return 0, nil
}
