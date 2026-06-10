CREATE TABLE likes (
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tweet_id   UUID NOT NULL REFERENCES tweets(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, tweet_id)
);

CREATE INDEX idx_likes_tweet ON likes(tweet_id);
CREATE INDEX idx_likes_user ON likes(user_id);
