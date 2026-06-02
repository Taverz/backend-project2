CREATE TABLE tweets (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id  UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body       VARCHAR(280) NOT NULL,
    parent_id  UUID         REFERENCES tweets(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_tweets_author_id ON tweets(author_id);
CREATE INDEX idx_tweets_created_at ON tweets(created_at DESC);
