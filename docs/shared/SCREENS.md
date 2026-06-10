# Chirp Screens

> Экранная карта. Единая для всех платформ.
> Что видит пользователь, какие состояния, какие действия.

---

## Screen: Splash

| | |
|---|---|
| Route | `/` |
| Auth | — |
| Platforms | mobile |

**Purpose:** Проверить JWT при запуске.

| State | What to show |
|-------|-------------|
| Loading | Логотип Chirp + spinner |
| Has token | Redirect → `/home` |
| No token | Redirect → `/login` |

---

## Screen: Login

| | |
|---|---|
| Route | `/login` |
| Auth | Public |
| Platforms | mobile, web |

**Elements:**
1. Logo/header: "Welcome to Chirp"
2. Email field (keyboard: email)
3. Password field (obscured)
4. "Log in" button — primary, full-width
5. "Don't have an account? Sign up" link → `/register`

| State | What to show |
|-------|-------------|
| Default | Empty form |
| Validating | Inline errors under fields (e.g. "Invalid email format") |
| Loading | Button disabled + spinner |
| Error | Toast/alert: "Invalid email or password" |
| Success | Redirect → `/home` |

**Actions:**
- Submit → POST /auth/login
- Tap "Sign up" → push `/register`

---

## Screen: Register

| | |
|---|---|
| Route | `/register` |
| Auth | Public |
| Platforms | mobile, web |

**Elements:**
1. Username field (3-30 chars, a-z, 0-9, _)
2. Email field
3. Password field (8-72 chars)
4. "Sign up" button
5. "Already have an account? Log in" link → `/login`

| State | What to show |
|-------|-------------|
| Default | Empty form |
| Validation | Inline errors: "Username already taken", "Password too short" |
| Loading | Button disabled + spinner |
| Error | "Email already registered" highlight on email field |
| Success | Redirect → `/home` |

---

## Screen: Home Timeline

| | |
|---|---|
| Route | `/home` |
| Auth | 🔒 Requires JWT |
| Platforms | mobile (bottom tab #1), web (main column) |

**Elements:**
1. Top bar: "Chirp" text + avatar icon (→ `/user/{me}`)
2. Tweet list: бесконечный скролл (ScrollController)
3. Tweet card: avatar | username + body + timestamp + actions
4. FAB: "New Tweet" → push `/create`
5. Bottom tab bar: Home, Search, Notifications, Profile

| State | What to show |
|-------|-------------|
| Loading | Skeleton cards (3-5 placeholders) |
| Empty | "No tweets yet. Follow someone to see tweets in your feed." + "Find people" CTA |
| Error | "Something went wrong" + Retry button |
| Data | Tweet cards |
| Loading more | Activity indicator at list bottom |
| Pull to refresh | Refresh indicator |

**Actions:**
| Action | Result |
|--------|--------|
| Tap tweet card | Push `/tweet/{id}` |
| Tap avatar in tweet | Push `/user/{id}` |
| Tap like icon | POST /tweets/{id}/like → toggle fill |
| Tap FAB | Push `/create` |
| Pull down | Refresh (GET /timeline/home) |
| Scroll to bottom | Load more (cursor-based) |

---

## Screen: Tweet Detail

| | |
|---|---|
| Route | `/tweet/{id}` |
| Auth | Public read, 🔒 for actions |
| Platforms | mobile (push), web (modal/push) |

**Elements:**
1. Author avatar + username + timestamp
2. Tweet body (1-280 chars)
3. Action bar: Like count + button, Reply button
4. Replies list (parent_id = this tweet)

| State | What to show |
|-------|-------------|
| Loading | Skeleton |
| Error | "Tweet not found" |
| Data | Tweet + replies |

---

## Screen: Create Tweet

| | |
|---|---|
| Route | `/create` |
| Auth | 🔒 |
| Platforms | mobile (modal), web (modal) |

**Elements:**
1. User avatar + text area (multiline, 280 max)
2. Character counter (280 - length, red when < 20)
3. "Tweet" button (disabled when empty, enabled when 1-280)
4. Close/X to dismiss

| State | What to show |
|-------|-------------|
| Empty | Placeholder: "What's happening?" |
| Typing | Counter updates, button active |
| Over limit | Counter red, button disabled |
| Submitting | Button disabled + spinner |
| Error | "Failed to post. Try again." |
| Success | Pop + tweet appears in timeline |

---

## Screen: Profile

| | |
|---|---|
| Route | `/user/{id}` |
| Auth | Public read |
| Platforms | mobile (push or tab #4 if own), web |

**Elements:**
1. Header: avatar (large), username, display_name, bio
2. Stats: Tweets count, Following count, Followers count (tappable)
3. Follow/Unfollow button (if not own profile)
4. Tab: Tweets | Likes (if own profile)
5. Tweet list by this user

| State | What to show |
|-------|-------------|
| Loading | Skeleton |
| Error | "User not found" |
| Own profile | "Edit profile" button |
| Other profile | Follow/Unfollow button |
| Following toggle | Button → "Following" (filled) / "Follow" (outlined) |

---

## Screen: Followers / Following

| | |
|---|---|
| Routes | `/user/{id}/followers`, `/user/{id}/following` |
| Auth | Public |
| Platforms | push |

**Elements:** User list with avatar + username + Follow button.

---

## Screen: Notifications

| | |
|---|---|
| Route | `/notifications` |
| Auth | 🔒 |
| Platforms | mobile (bottom tab #3), web |

**Elements:**
1. Notification list
2. Notification tile: icon (❤️ like, 👤 follow) + text + timestamp
3. Tap notification → navigate to relevant content

| State | What to show |
|-------|-------------|
| Loading | Skeleton |
| Empty | "No notifications yet" |
| Data | Notifications list |
| Unread badge | Badge on bottom tab (unread count) |

**Notification types:**
- ❤️ `{actor} liked your tweet`
- 👤 `{actor} followed you`
- 💬 `{actor} replied to your tweet`

---

## Screen: Search

| | |
|---|---|
| Route | `/search` |
| Auth | Public |
| Platforms | mobile (bottom tab #2), web |

**Elements:**
1. Search bar (auto-focus)
2. Results list: tweet cards

| State | What to show |
|-------|-------------|
| Empty query | Placeholder: "Search Chirp" |
| Typing | Debounce 300ms → GET /tweets/search?q=... |
| Loading | Spinner |
| No results | "No tweets found for '{query}'" |
| Results | Tweet cards with highlighted search term |
