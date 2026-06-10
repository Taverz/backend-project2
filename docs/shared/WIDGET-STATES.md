# Widget States

> Состояния всех переиспользуемых UI-компонентов.
> Единые для всех платформ (Flutter, Android, iOS, Web).
> Без кода. AI читает → реализует одинаково на каждой платформе.

---

## 1. Button

| # | State | Trigger | Visual | Behaviour |
|---|-------|---------|--------|-----------|
| 1.1 | **enabled** | Экран загружен | Primary bg (#1DA1F2), white text, radius=24px, height=44px | Tap → onSubmit |
| 1.2 | **disabled** | Форма невалидна / поле пусто | Opacity 0.5, grey, no pointer | Tap ignored |
| 1.3 | **loading** | Tap, запрос отправлен | Spinner вместо текста, disabled | Tap ignored |
| 1.4 | **with-icon** | Кнопка + иконка | Icon слева, 4px gap, текст справа | Same as enabled |
| 1.5 | **hover** (web only) | Cursor on button | Slightly darker bg (#1A91DA) | — |
| 1.6 | **pressed** | Tap start | Slightly darker bg, scale 0.98 | — |

**Variants:**

```
Primary:  bg=#1DA1F2, text=white     — "Log in", "Sign up", "Tweet"
Outline:  border=#1DA1F2, text=#1DA1F2 — "Follow" / "Following" (green when active)
Text:     no bg, text=#1DA1F2         — "Cancel", link-style
Danger:   bg=#E0245E, text=white      — "Delete", "Log out" (confirm)
```

**Platform mapping:**

| Concept | Flutter | Android Compose | SwiftUI | Web (Tailwind) |
|---------|--------|----------------|---------|----------------|
| Primary | `ElevatedButton` | `Button` | `Button` | `<button class="bg-primary ...">` |
| Outline | `OutlinedButton` | `OutlinedButton` | `Button.bordered` | `<button class="border-primary ...">` |
| Text | `TextButton` | `TextButton` | `Button.plain` | `<button class="text-primary ...">` |
| Loading | `style: disabled` + child=spinner | `enabled = false` + icon | `disabled` + ProgressView | `disabled` + spinner span |
| Disabled | `onPressed: null` | `enabled = false` | `.disabled(true)` | `:disabled` pseudo |

---

## 2. InputField

| # | State | Trigger | Visual | Error message |
|---|-------|---------|--------|--------------|
| 2.1 | **default** | Экран загружен | Border=#E1E8ED, radius=4px, height=44px, placeholder grey | Нет |
| 2.2 | **focused** | Tap on field | Border=#1DA1F2, label moves up (float) | Нет |
| 2.3 | **filled** | User typed | Border=#E1E8ED, text visible | Нет |
| 2.4 | **error** | Validation failed / server 400 | Border=#E0245E, error text below (12px, #E0245E) | Да |
| 2.5 | **disabled** | Form submitting | Opacity 0.5, not editable | — |
| 2.6 | **with-counter** | Username field | Small counter bottom-right: "7/30" | — |
| 2.7 | **password** | Password field | Obscured text, eye icon toggle | — |

**Error timing:**

| Когда | Что показать |
|-------|-------------|
| onBlur (validation) | Inline: красный border + текст ошибки под полем |
| onType (after error) | Сбросить красный border, оставить нейтральным |
| onSubmit (client) | Подсветить все поля с ошибками |
| onSubmit (server 400) | Подсветить конкретное поле из detail |
| onSubmit (server 409) | Подсветить email/username + "already taken" |

---

## 3. TweetCard

```
┌──────────────────────────────────────────┐
│ [Avatar 48x48]  username              ··· │
│                 @handle   · 2m ago        │
│                                          │
│   Tweet body text goes here.              │
│   Up to 280 characters.                   │
│                                          │
│   ♥ 5    💬 2    🔁 1    📤             │
└──────────────────────────────────────────┘
```

| # | State | Trigger | Visual | Interaction |
|---|-------|---------|--------|-------------|
| 3.1 | **default** | Loaded | Full card, all elements visible | Tap → /tweet/{id} |
| 3.2 | **loading** | Fetching | Skeleton: grey gradient blocks (same dimensions) | None |
| 3.3 | **error** | Load failed | Error icon + "Couldn't load tweet" + Retry | Retry tap → reload |
| 3.4 | **liked** | Tap like | Heart icon filled (❤️ red), count +1 | Tap → unlike |
| 3.5 | **unliked** | Tap unlike | Heart icon outlined (♡), count -1 | Tap → like |
| 3.6 | **deleting** | Tap delete | Card fade out (opacity 0→1→0) | — |
| 3.7 | **with-image** | Tweet has media | Image below body, 16:9 ratio | Tap → fullscreen |

**Like optimistic update:**

```
1. User taps like
2. UI: heart → filled INSTANTLY, count +1
3. Async: POST /tweets/{id}/like
   ├── 200 → done
   └── 500 → UI: heart → outline, count -1, toast "Like failed"
```

**Avatar in TweetCard:**

| Part | Spec |
|------|------|
| Size | 48×48 |
| Shape | Circle |
| Image | Load async, show initials until loaded |
| Initials | First letter of username, white on primary bg |
| Fallback | If load fails → keep initials |
| Tap | Navigate to /user/{id} |

---

## 4. Avatar

| # | State | Trigger | Visual |
|---|-------|---------|--------|
| 4.1 | **with-image** | Image loaded | Circle, 48×48 (list) or 96×96 (profile) |
| 4.2 | **initials** | No image / loading | Circle, primary bg (#1DA1F2), white letter |
| 4.3 | **loading** | Image fetching | Circle, grey skeleton |
| 4.4 | **error** | Image load failed | Keep initials fallback, no retry |

---

## 5. Loading / Skeleton

| # | Variant | When | Visual |
|---|---------|------|--------|
| 5.1 | **card-skeleton** | List loading | 3-5 grey gradient blocks mimicking TweetCard layout |
| 5.2 | **detail-skeleton** | Detail loading | Full-screen grey blocks (avatar + body + actions) |
| 5.3 | **button-spinner** | Button loading | Circular indicator, replaces button text |
| 5.4 | **page-spinner** | Full page load | Centered circular indicator |
| 5.5 | **pulse** | Background refresh | Any skeleton pulses opacity 0.3→1.0 (2s loop) |

---

## 6. Error / Empty

| # | Component | Visual | Action |
|---|-----------|--------|--------|
| 6.1 | **ErrorView** | ⚠️ icon, "Something went wrong", Retry button | Retry → reload |
| 6.2 | **EmptyView** | 📭 icon, message, optional CTA | CTA → navigate |
| 6.3 | **OfflineBanner** | Yellow bar top: "No internet connection" | Auto-hide when online |
| 6.4 | **Toast** | Small popup bottom, 3s auto-dismiss | — |

**Empty messages by screen:**

| Screen | Icon | Message | CTA |
|--------|------|---------|-----|
| Home timeline | 📭 | "No tweets yet. Follow someone to see their tweets." | "Find people" → /search |
| Notifications | 🔕 | "No notifications yet" | — |
| Search | 🔍 | "Search Chirp" (before typing) | — |
| Followers | 👤 | "No followers yet" | — |
| Tweet replies | 💬 | "No replies yet" | — |

---

## 7. TabBar / Bottom Navigation

| State | Visual | Active indicator |
|-------|--------|-----------------|
| inactive | Icon outline, grey text | — |
| active | Icon filled, primary (#1DA1F2) | Line/underline (web) or icon fill |
| badge | Unread count bubble, red (#E0245E) | Number or dot |
| disabled | Hidden (tab not available) | — |

**Tabs (mobile):**

| Tab | Icon | Badge |
|-----|------|-------|
| Home | 🏠 / house | — |
| Search | 🔍 / magnifyingglass | — |
| Notifications | 🔔 / bell | Unread count |
| Profile | 👤 / person | — |

---

## 8. Follow Button (специфичный)

| # | State | Visual | Behaviour |
|---|-------|--------|-----------|
| 8.1 | **follow** | Outline: border=#1DA1F2, text=#1DA1F2, "Follow" | Tap → POST /users/{id}/follow |
| 8.2 | **following** | Filled: bg=green, text=white, "Following" | Tap → confirm → DELETE /users/{id}/follow |
| 8.3 | **pending** | Disabled: grey, spinner | После tap, до ответа сервера |
| 8.4 | **hidden** | Not rendered | Own profile (нельзя подписаться на себя) |

**Optimistic update:**

```
1. Tap "Follow"
2. UI: button → "Following" (green) INSTANTLY
3. Async: POST /users/{id}/follow
   ├── 200 → done
   └── 500 → UI: button → "Follow" (outline), toast "Follow failed"
```

---

## 9. Notification Tile

| Part | Spec |
|------|------|
| Icon | ❤️ (like), 👤 (follow), 💬 (reply) |
| Text | "{actor} liked your tweet" / "{actor} followed you" |
| Timestamp | Relative: "2m ago", "yesterday", "June 5" |
| Unread | Bold text, slightly different bg |
| Read | Normal weight, same bg |
| Tap | Mark read + navigate to relevant content |

---

## 10. Таблица: какие состояния у каких компонентов

| Компонент | default | loading | error | empty | disabled | active | hover (web) |
|-----------|:-------:|:-------:|:-----:|:-----:|:--------:|:------:|:-----------:|
| Button | ✅ | ✅ spinner | ❌ | ❌ | ✅ opacity | ✅ | ✅ darker |
| InputField | ✅ | ❌ | ✅ border | ❌ | ✅ opacity | ✅ focus | ❌ |
| TweetCard | ✅ | ✅ skeleton | ✅ retry | ❌ | ❌ | ✅ liked | ✅ web hover |
| Avatar | ✅ image | ✅ skeleton | ✅ initials | ❌ | ❌ | ❌ | ❌ |
| FollowButton | ✅ follow | ✅ pending | ❌ | ❌ | ❌ | ✅ following | ✅ |
| NotificationTile | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ unread | ✅ |
| TabBar | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ active | ❌ |
| Image | ✅ loaded | ✅ skeleton | ✅ fallback | ❌ | ❌ | ❌ | ❌ |
