package postgres

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/nikitakovalevtaverz/chirp/internal/domain/tweet"
)

// TweetRepo implements port.TweetRepository with PostgreSQL.
type TweetRepo struct {
	pool *Pool
}

// NewTweetRepo creates a TweetRepo.
func NewTweetRepo(pool *Pool) *TweetRepo {
	return &TweetRepo{pool: pool}
}

func (r *TweetRepo) Create(ctx context.Context, t *tweet.Tweet) error {
	const q = `INSERT INTO tweets (id, author_id, body, parent_id, created_at, updated_at)
		VALUES ($1, $2, $3, NULLIF($4, ''), $5, $6)`
	now := time.Now().UTC()
	t.CreatedAt = now
	t.UpdatedAt = now
	_, err := r.pool.Exec(ctx, q,
		t.ID, t.AuthorID, t.Body, t.ParentID, t.CreatedAt, t.UpdatedAt,
	)
	return err
}

func (r *TweetRepo) GetByID(ctx context.Context, id string) (*tweet.Tweet, error) {
	const q = `SELECT id, author_id, body, COALESCE(parent_id, ''), created_at, updated_at
		FROM tweets WHERE id = $1`
	var t tweet.Tweet
	err := r.pool.QueryRow(ctx, q, id).Scan(
		&t.ID, &t.AuthorID, &t.Body, &t.ParentID, &t.CreatedAt, &t.UpdatedAt,
	)
	if err != nil {
		if isNoRows(err) {
			return nil, nil
		}
		return nil, err
	}
	return &t, nil
}

func (r *TweetRepo) ListByAuthor(ctx context.Context, authorID string, limit int, cursor string) ([]*tweet.Tweet, string, error) {
	if limit <= 0 || limit > 50 {
		limit = 20
	}

	var rows pgx.Rows
	var err error
	if cursor == "" {
		const q = `SELECT id, author_id, body, COALESCE(parent_id, ''), created_at, updated_at
			FROM tweets WHERE author_id = $1 ORDER BY created_at DESC, id DESC LIMIT $2`
		rows, err = r.pool.Query(ctx, q, authorID, limit+1)
	} else {
		const q = `SELECT id, author_id, body, COALESCE(parent_id, ''), created_at, updated_at
			FROM tweets WHERE author_id = $1 AND (created_at, id) < (
				SELECT created_at, id FROM tweets WHERE id = $2
			) ORDER BY created_at DESC, id DESC LIMIT $3`
		rows, err = r.pool.Query(ctx, q, authorID, cursor, limit+1)
	}
	if err != nil {
		return nil, "", err
	}
	defer rows.Close()

	var tweets []*tweet.Tweet
	for rows.Next() {
		var t tweet.Tweet
		if err := rows.Scan(&t.ID, &t.AuthorID, &t.Body, &t.ParentID, &t.CreatedAt, &t.UpdatedAt); err != nil {
			return nil, "", err
		}
		tweets = append(tweets, &t)
	}

	nextCursor := ""
	if len(tweets) > limit {
		nextCursor = tweets[limit-1].ID
		tweets = tweets[:limit]
	}

	return tweets, nextCursor, nil
}

func (r *TweetRepo) Delete(ctx context.Context, id string) error {
	const q = `DELETE FROM tweets WHERE id = $1`
	_, err := r.pool.Exec(ctx, q, id)
	return err
}
