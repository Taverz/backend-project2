package search

type SearchResult struct {
	TweetID   string
	AuthorID  string
	Body      string
	Score     float64
	CreatedAt string
}
