# Chirp Errors

> Все ошибки API. HTTP-статус → detail → реакция клиента.
> Один источник правды для всех платформ.

---

## Auth

| HTTP | Domain Error | detail | Client reaction |
|:----:|-------------|--------|----------------|
| 401 | — | missing authorization header | Redirect to `/login` |
| 401 | — | invalid or expired token | Try refresh token → if fails → `/login` |
| 401 | ErrInvalidCredentials | invalid email or password | Show "Invalid email or password" |

## Registration

| HTTP | Domain Error | detail | Client reaction |
|:----:|-------------|--------|----------------|
| 400 | ErrUsernameTooShort | username: must be at least 3 characters | Inline error under username field |
| 400 | ErrUsernameTooLong | username: must be at most 30 characters | Inline error under username field |
| 400 | ErrUsernameInvalid | username: only letters, digits, and underscores allowed | Inline error under username field |
| 400 | ErrEmailEmpty | email: must not be empty | Inline error under email field |
| 400 | ErrEmailInvalid | email: invalid format | Inline error under email field |
| 400 | ErrPasswordTooShort | password: must be at least 8 characters | Inline error under password field |
| 400 | ErrPasswordTooLong | password: must be at most 72 characters | Inline error under password field |
| 409 | ErrEmailTaken | email already registered | Highlight email field, show "Email already registered" |
| 409 | ErrUsernameTaken | username already taken | Highlight username field, show "Username already taken" |

## Tweet

| HTTP | Domain Error | detail | Client reaction |
|:----:|-------------|--------|----------------|
| 400 | ErrBodyEmpty | tweet body: must not be empty | Disable Tweet button |
| 400 | ErrBodyTooLong | tweet body: must be at most 280 characters | Show counter in red, disable Tweet button |
| 400 | — | parent tweet not found | Show "The tweet you're replying to was deleted" |
| 403 | ErrNotOwner | you can only delete your own tweets | Hide delete button for other users' tweets |
| 404 | ErrTweetNotFound | tweet not found | Show "Tweet not found" screen |
| 413 | — | payload too large | Show "File too large" (when media upload added) |

## Follow

| HTTP | Domain Error | detail | Client reaction |
|:----:|-------------|--------|----------------|
| 400 | ErrCannotFollowSelf | cannot follow yourself | Disable Follow button on own profile (always hidden) |
| 404 | — | user not found | Show "User not found" screen |

## General

| HTTP | title | Client reaction |
|:----:|-------|----------------|
| 400 | Bad Request | Show first validation error |
| 401 | Unauthorized | Redirect to `/login` |
| 403 | Forbidden | Hide action that caused this |
| 404 | Not Found | Show "Not found" screen |
| 409 | Conflict | Show conflict message |
| 413 | Payload Too Large | Show size limit message |
| 429 | Too Many Requests | Show "Please slow down" + retry after |
| 500 | Internal Server Error | Show "Something went wrong" + Retry button |

---

## Client-side validation (same rules as backend)

| Field | Rule | Error message |
|-------|------|---------------|
| username | 3-30 chars, a-z, 0-9, _ | "Username must be 3-30 characters (letters, digits, underscores)" |
| email | Valid email format | "Enter a valid email address" |
| password | 8-72 chars | "Password must be at least 8 characters" |
| tweet body | 1-280 chars | "Tweet must be 1-280 characters" |

Validate on blur. Block submit until valid.
