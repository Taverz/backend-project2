CREATE TABLE timeline (
    recipient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tweet_id     UUID NOT NULL REFERENCES tweets(id) ON DELETE CASCADE,
    author_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    scored_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (recipient_id, tweet_id)
);

CREATE INDEX idx_timeline_recipient ON timeline(recipient_id, scored_at DESC);
