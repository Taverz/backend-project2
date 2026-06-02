package middleware

import "context"

type ctxKey string

const UserIDKey ctxKey = "user_id"

// UserIDFromContext returns the authenticated user ID from context.
func UserIDFromContext(ctx context.Context) (string, bool) {
	id, ok := ctx.Value(UserIDKey).(string)
	return id, ok
}
