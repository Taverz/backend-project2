# Widget States

> Состояния всех переиспользуемых UI-компонентов.
> Единые для всех платформ (Flutter, Android, iOS, Web).
> Без кода. AI читает → реализует одинаково на каждой платформе.

---

## 1. Button

| # | State | Trigger | Visual | Behaviour |
|---|-------|---------|--------|-----------|
| 1.1 | **enabled** | Экран загружен | `button-primary-bg`, `text-on-accent`, `radius-sm`, height 40 | Tap → onSubmit |
| 1.2 | **disabled** | Форма невалидна / поле пусто | `button-primary-bg-disabled`, `text-disabled`, no pointer | Tap ignored |
| 1.3 | **loading** | Tap, запрос отправлен | Spinner вместо текста, disabled | Tap ignored |
| 1.4 | **with-icon** | Кнопка + иконка | UiIcon слева, `space-2` gap, текст справа | Same as enabled |
| 1.5 | **hover** (web only) | Cursor on button | `button-primary-bg-hover` | — |
| 1.6 | **pressed** | Tap start | `button-primary-bg-pressed`, scale 0.98 | — |
| 1.7 | **focused** | Keyboard focus | `focus-ring` 2px outline + 2px offset | — |

**Variants:**

```
Primary:    bg=accent, text=text-on-accent      — "Log in", "Sign up", "Tweet"
Secondary:  bg=transparent, border=border-default, text=text-primary — "Cancel"
Text:       no bg, text=accent                  — link-style
Danger:     bg=error, text=text-on-accent       — "Delete", "Log out" (confirm)
```

Полная цепочка токенов — `design/03-tokens/semantic-mappings.md §1`.

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
| 2.1 | **default** | Экран загружен | Border `border-default`, `radius-sm`, height 40, placeholder `text-muted` | Нет |
| 2.2 | **focused** | Tap on field | Border `input-border-focused` (= accent), label floats up, focus-ring | Нет |
| 2.3 | **filled** | User typed | Border `border-default`, text `text-primary` | Нет |
| 2.4 | **error** | Validation failed / server 400 | Border `error`, error text below (`caption`, `error`) | Да |
| 2.5 | **disabled** | Form submitting | `input-bg-disabled`, `text-disabled`, not editable | — |
| 2.6 | **with-counter** | Username field | Small counter bottom-right: "7/30", `text-muted` | — |
| 2.7 | **password** | Password field | Obscured text, UiIcon (Eye/EyeSlash) toggle справа | — |

Полная цепочка токенов — `design/03-tokens/semantic-mappings.md §2`.

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
│ [Avatar 40]   username  @handle · 2m     │
│               More menu (DotsThree)  ··· │
│                                          │
│   Tweet body text goes here.              │
│   Up to 280 characters.                   │
│                                          │
│   Heart 5   ChatText 2   ArrowsClockwise │
│                          Share           │
└──────────────────────────────────────────┘
```

Все иконки — Phosphor Regular (см. `design/03-tokens/icons.md`).
Никаких emoji в UI chrome.

| # | State | Trigger | Visual | Interaction |
|---|-------|---------|--------|-------------|
| 3.1 | **default** | Loaded | Full card, `post-card-bg`, all elements visible | Tap → /tweet/{id} |
| 3.2 | **loading** | Fetching | Skeleton: warm gradient blocks (same dimensions) | None |
| 3.3 | **error** | Load failed | Error icon + "Couldn't load tweet" + Retry | Retry tap → reload |
| 3.4 | **liked** | Tap like | Phosphor `Heart` filled (`accent`), count +1 | Tap → unlike |
| 3.5 | **unliked** | Tap unlike | Phosphor `Heart` outlined (`text-secondary`), count -1 | Tap → like |
| 3.6 | **deleting** | Tap delete | Card fade out (opacity 1→0) | — |
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
| Size | `avatar-size-md` (40) |
| Shape | `radius-full` |
| Image | Load async, show initials until loaded |
| Initials | First letter of username, `text-on-accent` on hash-based fallback colour |
| Fallback | If load fails → keep initials |
| Tap | Navigate to /user/{id} |

---

## 4. Avatar

| # | State | Trigger | Visual |
|---|-------|---------|--------|
| 4.1 | **with-image** | Image loaded | Circle, `avatar-size-md` (40, list) или `avatar-size-xl` (96, profile) |
| 4.2 | **initials** | No image / loading | Circle, hash-based fallback bg (см. avatar.md), `text-on-accent` letter |
| 4.3 | **loading** | Image fetching | Circle, `surface-sunken` skeleton |
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

Иконки — Phosphor (см. `design/03-tokens/icons.md`). Никаких emoji в UI chrome.

| Screen | Phosphor icon | Message | CTA |
|--------|---------------|---------|-----|
| Home timeline | `Tray` | "No tweets yet. Follow someone to see their tweets." | "Find people" → /search |
| Notifications | `BellSlash` | "No notifications yet" | — |
| Search | `MagnifyingGlass` | "Search Chirp" (before typing) | — |
| Followers | `Users` | "No followers yet" | — |
| Tweet replies | `ChatText` | "No replies yet" | — |

---

## 7. TabBar / Bottom Navigation

| State | Visual | Active indicator |
|-------|--------|-----------------|
| inactive | Icon outline, `nav-icon-default` (= `text-muted`), label `nav-label-default` | — |
| active | Icon filled (Phosphor Bold weight), `nav-icon-active` (= `text-primary`) | `nav-active-indicator` (`accent` underline или dot) |
| badge | Unread count bubble, `error` bg | Number или dot |
| disabled | Hidden (tab not available) | — |

**Tabs (mobile):**

Иконки — только Phosphor (см. `design/03-tokens/icons.md §3 Navigation`).

| Tab | Phosphor icon | Badge |
|-----|---------------|-------|
| Home | `House` | — |
| Search | `MagnifyingGlass` | — |
| Notifications | `Bell` / `Bell` (Bold weight when active) | Unread count |
| Profile | `User` | — |

---

## 8. Follow Button (специфичный)

| # | State | Visual | Behaviour |
|---|-------|--------|-----------|
| 8.1 | **follow** | Secondary variant: `border-default`, `text-primary`, label "Follow" | Tap → POST /users/{id}/follow |
| 8.2 | **following** | Primary variant: `accent` bg, `text-on-accent`, label "Following" | Tap → confirm → DELETE /users/{id}/follow |
| 8.3 | **pending** | Disabled: `disabled-bg`, spinner | После tap, до ответа сервера |
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
| Icon | Phosphor `Heart` (like), `UserPlus` (follow), `ChatText` (reply) |
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
