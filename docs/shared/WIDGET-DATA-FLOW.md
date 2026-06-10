# Screen Composition — Widget Tree + Data Mapping

> Каждый экран разбит на виджеты. Для каждого виджета указано:
> какой API endpoint его питает, какие поля откуда берутся,
> как трансформируются перед отображением.
>
> Формат: Screen → Widget Tree → API Data → Model → UI Model → Widget Prop

---

## 1. HomeScreen

### Widget tree

```
HomeScreen
├── TopBar
│   ├── Text("Chirp")
│   └── Avatar(size=32)  ─── GET /users/me → user → profile link
│
├── TimelineList
│   ├── TweetCard (×N, paginated)
│   │   ├── Row
│   │   │   ├── Avatar(size=48)
│   │   │   └── Column
│   │   │       ├── Row
│   │   │       │   ├── Text(username)   ← bold
│   │   │       │   └── Text(timestamp)  ← grey, relative
│   │   │       └── Text(body)           ← 1-280 chars
│   │   └── ActionBar
│   │       ├── LikeButton(active, count)
│   │       ├── ReplyButton(count)
│   │       ├── RetweetButton(count)
│   │       └── ShareButton
│   └── LoadingSkeleton (while loading)
│
├── EmptyState (when timeline empty)
├── ErrorView (on error)
└── FAB("+") → push /create
```

### Data flow

```
GET /timeline/home
  ↓
[
  {
    "tweet_id": "550e8400-e29b-41d4-a716-446655440000",
    "body": "Hello world!",
    "author_id": "660e8400-e29b-41d4-a716-446655440001",
    "author_username": "alice",
    "author_display_name": "Alice",
    "like_count": 42,
    "liked_by_me": false,
    "reply_count": 3,
    "scored_at": "2025-06-11T10:00:00Z"
  }
]
  ↓
DataModel
  ↓  transform()
UIModel
  ↓
Widgets
```

### Model transformation

| API field | DataModel | UI transformation | Widget prop |
|-----------|-----------|-------------------|-------------|
| `tweet_id` | `tweetId: String` | — | Key, onTap → `/tweet/{id}` |
| `body` | `body: String` | — | `TweetCard.bodyText` |
| `author_id` | `authorId: String` | — | onAvatarTap → `/user/{id}` |
| `author_username` | `authorUsername: String` | — | `Text(username)` bold |
| `author_display_name` | `authorDisplayName: String` | fallback to username if empty | Tooltip / subtitle |
| `like_count` | `likeCount: Int` | — | `LikeButton.count` |
| `liked_by_me` | `likedByMe: Bool` | → `likeActive: Bool` | `LikeButton.active` |
| `reply_count` | `replyCount: Int` | — | `ReplyButton.count` |
| `scored_at` | `scoredAt: DateTime` | → `"2m ago"` / `"yesterday"` / `"Jun 5"` | `Text(timestamp)` grey |

### UIModel

```
TimelineEntry {
  tweetId: String
  body: String
  authorId: String
  authorUsername: String
  timestampLabel: String    ← computed: "2m ago", "yesterday", "Jun 5"
  likeCount: Int
  likeActive: Bool          ← from liked_by_me
  replyCount: Int
}
```

### States

| Widget | States | Source |
|--------|--------|--------|
| TimelineList | loading → empty → data → error | API response |
| TweetCard | default, liked, with-image | WIDGET-STATES.md |
| LikeButton | inactive → active, optimistic | local + API |
| Avatar | loading → image → initials | WIDGET-STATES.md |

---

## 2. LoginScreen

### Widget tree

```
LoginScreen
├── Column (centered)
│   ├── Logo("Welcome to Chirp")
│   ├── LoginForm
│   │   ├── InputField(email)
│   │   │   ├── states: default → focused → filled → error
│   │   │   └── validates: onBlur → format check
│   │   ├── InputField(password)
│   │   │   ├── states: default → focused → filled → error
│   │   │   └── obscure: true, toggle eye icon
│   │   └── Button("Log in")
│   │       ├── states: enabled → disabled → loading
│   │       └── onTap → POST /auth/login
│   └── Link("Don't have an account? Sign up")
```

### Data flow

```
POST /auth/login {email, password}
  ↓
{
  "user": {
    "id": "uuid", "username": "alice", "email": "alice@test.com",
    "display_name": "Alice", "bio": "", "created_at": "2025-06-11T10:00:00Z"
  },
  "access_token": "eyJ...",
  "refresh_token": "eyJ..."
}
  ↓
AuthDataModel
  ├── UserDataModel { id, username, email, displayName, bio, createdAt }
  └── TokenPair { accessToken, refreshToken }
      ↓
AuthService.saveTokens()
AuthState = authenticated(user)
      ↓
Navigate /home
```

### Model transformation

| API field | DataModel | UI transformation | Destination |
|-----------|-----------|-------------------|-------------|
| `user.id` | `userId: String` | — | AuthState |
| `user.username` | `username: String` | — | AuthState |
| `user.email` | `email: String` | — | AuthState (not displayed) |
| `access_token` | `accessToken: String` | — | SecureStorage |
| `refresh_token` | `refreshToken: String` | — | SecureStorage |

### States

| Widget | States | Когда |
|--------|--------|-------|
| InputField(email) | default, focused, filled, error(400) | onBlur, onServerError |
| InputField(password) | default, focused, filled, error | onBlur |
| Button | enabled, disabled(empty), loading(submitting) | form state |
| Error toast | shown(hidden) | 401 response |

---

## 3. RegisterScreen

### Widget tree

```
RegisterScreen
├── Column (centered)
│   ├── Text("Create your account")
│   ├── RegisterForm
│   │   ├── InputField(username)
│   │   │   ├── counter: "7/30" (grey → yellow → red)
│   │   │   └── validates: 3-30, a-z0-9_, onBlur
│   │   ├── InputField(email)
│   │   │   └── validates: format, onBlur
│   │   ├── InputField(password)
│   │   │   ├── strength: weak/medium/strong (optional)
│   │   │   └── validates: 8+ chars, onBlur
│   │   └── Button("Sign up")
│   │       └── onTap → POST /auth/register
│   └── Link("Already have an account? Log in")
```

### Data flow

```
POST /auth/register {username, email, password}
  ↓
  ┣━ 201 → same as login → save tokens → navigate /home
  ┣━ 400 → inline error под конкретным полем
  ┣━ 409 → "email already registered" → highlight email
  ┣━ 409 → "username already taken" → highlight username
  ┣━ 500 → ErrorView + Retry
  ┗━ network error → toast
```

---

## 4. ProfileScreen

### Widget tree

```
ProfileScreen
├── ProfileHeader
│   ├── Avatar(size=96)
│   ├── Text(displayName)      ← bold, 20px
│   ├── Text(@username)         ← grey, 14px
│   ├── Text(bio)               ← 16px, multi-line
│   ├── Text("Joined June 2025") ← from created_at
│   └── FollowButton
│       ├── states: follow → following → pending → hidden(self)
│       └── optimistic: мгновенное переключение
│
├── StatsRow
│   ├── Stat("Tweets", count)   ← tappable → scroll to tweets
│   ├── Stat("Following", count) ← tappable → /user/{id}/following
│   └── Stat("Followers", count) ← tappable → /user/{id}/followers
│
└── TweetTabView
    ├── Tab("Tweets")  ← selected by default
    └── Tab("Likes")   ← only visible if own profile
        └── TimelineList (same as HomeScreen, but user's tweets)
```

### Data flow

```
GET /users/{id}
  ↓
{
  "id": "uuid",
  "username": "alice",
  "display_name": "Alice",
  "bio": "Just chirping",
  "created_at": "2025-01-01T00:00:00Z",
  "followers_count": 42,
  "following_count": 15,
  "tweets_count": 128
}
  ↓
ProfileDataModel
  ↓  transform()
UIModel
  ↓
Widgets
```

### Model transformation

| API field | DataModel | UI transformation | Widget prop |
|-----------|-----------|-------------------|-------------|
| `id` | `userId: String` | — | — |
| `username` | `username: String` | prefix: "@" | `Text("@alice")` |
| `display_name` | `displayName: String` | fallback: username if empty | `Text("Alice")` bold |
| `bio` | `bio: String` | — | `Text("Just chirping")` |
| `created_at` | `createdAt: DateTime` | → "Joined June 2025" | `Text("Joined June 2025")` |
| `followers_count` | `followersCount: Int` | format: "42" or "1.2K" | `Stat("Followers", 42)` |
| `following_count` | `followingCount: Int` | — | `Stat("Following", 15)` |
| `tweets_count` | `tweetsCount: Int` | — | `Stat("Tweets", 128)` |

---

## 5. FollowersScreen / FollowingScreen

### Widget tree

```
FollowersScreen
├── TopBar("Followers")
└── UserList
    └── UserRow (×N, paginated)
        ├── Avatar(size=48)
        ├── Column
        │   ├── Text(username)     ← bold
        │   └── Text(displayName)  ← grey, optional
        └── FollowButton
            └── states: follow → following → hidden(self)
```

### Data flow

```
GET /users/{id}/followers?limit=20&cursor=...
  ↓
{
  "data": [
    {
      "id": "uuid",
      "username": "bob",
      "display_name": "Bob",
      "is_following_by_me": false,
      "created_at": "2025-06-01T00:00:00Z"
    }
  ],
  "next_cursor": "...",
  "has_more": true,
  "total": 42
}
```

### Model transformation

| API field | DataModel | UI transformation | Widget prop |
|-----------|-----------|-------------------|-------------|
| `id` | `userId: String` | — | onTap → `/user/{id}` |
| `username` | `username: String` | — | Text(bold) |
| `display_name` | `displayName: String` | fallback: username | Text(grey) |
| `is_following_by_me` | `isFollowing: Bool` | → `followActive: Bool` | FollowButton state |
| `created_at` | `createdAt: DateTime` | "Jun 1, 2025" | Subtitle (optional) |

---

## 6. NotificationsScreen

### Widget tree

```
NotificationsScreen
├── TopBar("Notifications")
└── NotificationList
    └── NotificationTile (×N, paginated)
        ├── Icon(❤️ / 👤 / 💬)  ← from Type
        ├── Column
        │   ├── RichText: "{ActorUsername} liked your tweet"
        │   └── Text(timestamp)        ← relative
        └── UnreadDot (if !Read)
```

### Data flow

```
GET /notifications?limit=20&cursor=...
  ↓
{
  "data": [
    {
      "ID": "uuid",
      "Type": "like",
      "ActorID": "uuid",
      "ActorUsername": "alice",
      "TweetID": "uuid",
      "Read": false,
      "CreatedAt": "2025-06-11T10:00:00Z"
    }
  ],
  "next_cursor": "...",
  "has_more": false,
  "unread": 5
}
```

### Model transformation

| API field | DataModel | UI transformation | Widget prop |
|-----------|-----------|-------------------|-------------|
| `Type` | `type: String` | → icon: like=❤️, follow=👤, reply=💬 | Icon |
| `ActorUsername` | `actorUsername: String` | `"{actorUsername} liked your tweet"` | RichText |
| `Read` | `read: Bool` | → `unread: Bool` | UnreadDot visibility |
| `CreatedAt` | `createdAt: DateTime` | → "2m ago" | Text(grey) |

---

## 7. FollowButton (cross-screen widget)

Этот виджет используется на ProfileScreen, FollowersScreen, UserRow — везде одинаковая логика.

### States

```
FollowButton
├── follow        ← пользователь НЕ подписан
│   └── visual: outline, border=#1DA1F2, text="Follow"
├── following     ← пользователь подписан
│   └── visual: filled, bg=green, text="Following"
├── pending       ← запрос в процессе (optimistic)
│   └── visual: disabled, spinner
└── hidden        ← свой профиль (нельзя подписаться на себя)
    └── visual: not rendered
```

### Data flow

```
[initial]
  GET /users/{id}/followers → is_following_by_me: false
    → FollowButton.state = follow
  
[tap → optimistic]
  FollowButton.state = pending (мгновенно)
  AuthState.check = isOwnProfile?
    ┣━ own → hidden
    ┗━ not own → POST /users/{id}/follow
        ┣━ 204 → FollowButton.state = following
        ┗━ 500 → FollowButton.state = follow + toast "Follow failed"
```

---

## 8. Data transformation rules

### Timestamps

| Input | Format | Когда |
|-------|--------|-------|
| `2025-06-11T10:00:00Z` | "1m ago" | < 60 min |
| `2025-06-11T08:00:00Z` | "2h ago" | < 24h |
| `2025-06-10T10:00:00Z` | "yesterday" | 24-48h |
| `2025-06-05T10:00:00Z` | "Jun 5" | this year |
| `2024-12-01T10:00:00Z` | "Dec 1, 2024" | previous years |
| `2025-01-01T00:00:00Z` | "Joined January 2025" | profile (month + year) |

### Numbers

| Input | Output | Когда |
|-------|--------|-------|
| 5 | "5" | < 1000 |
| 1234 | "1.2K" | >= 1000 |
| 1000000 | "1M" | >= 1000000 |

### Usernames

| Input | Output | Где |
|-------|--------|-----|
| "alice" | "@alice" | Profile header, search results |
| "alice" | "alice" (bold) | TweetCard, notifications |

### Display name fallback

```
if display_name != null && display_name != "":
    show display_name
else:
    show username  // fallback
```

---

## 9. Сводная таблица: API endpoint → Widgets

| Endpoint | Data feeds into widgets |
|----------|------------------------|
| POST /auth/register | — (AuthState, SaveTokens → permanent) |
| POST /auth/login | — (AuthState, SaveTokens → permanent) |
| GET /users/me | UserMenu, AuthState |
| GET /users/{id} | ProfileHeader, StatsRow, FollowButton |
| GET /timeline/home | TweetCard × N |
| GET /tweets/{id} | TweetDetailScreen |
| GET /users/{id}/tweets | TweetCard × N |
| POST /tweets/{id}/like | LikeButton (optimistic update) |
| DELETE /tweets/{id}/like | LikeButton |
| POST /users/{id}/follow | FollowButton (optimistic) |
| DELETE /users/{id}/follow | FollowButton |
| GET /users/{id}/followers | UserRow × N + FollowButton |
| GET /users/{id}/following | UserRow × N + FollowButton |
| GET /timeline/home | TweetCard × N |
| GET /notifications | NotificationTile × N |
| POST /notifications/{id}/read | NotificationTile (unread dot → hidden) |
| GET /tweets/search?q= | TweetCard × N |
