# Chirp Design System

> Цвета, типографика, компоненты. Единый для всех платформ.

---

## 1. Colors

### Light Theme

| Token | Hex | Usage |
|-------|-----|-------|
| Primary | `#1DA1F2` | Buttons, links, active states |
| Primary hover | `#1A91DA` | Button hover |
| Background | `#FFFFFF` | Screen background |
| Card | `#F5F5F5` | Tweet cards, list items |
| Card border | `#E1E8ED` | Card borders, dividers |
| Text primary | `#0F1419` | Main body text |
| Text secondary | `#536471` | Timestamps, captions |
| Error | `#E0245E` | Error states, delete actions |
| Success | `#00BA7C` | Success states |
| Warning | `#FFAD1F` | Warnings |

### Dark Theme

| Token | Hex | Usage |
|-------|-----|-------|
| Primary | `#1DA1F2` | Buttons, links |
| Background | `#15202B` | Screen background |
| Card | `#192734` | Tweet cards |
| Card border | `#38444D` | Borders, dividers |
| Text primary | `#E7E9EA` | Main text |
| Text secondary | `#71767B` | Timestamps, captions |
| Error | `#F4212E` | Errors |
| Overlay | `rgba(0,0,0,0.4)` | Modal backdrop |

---

## 2. Typography

| Token | Size | Weight | Line Height | Usage |
|-------|:----:|:------:|:-----------:|-------|
| h1 | 24px | 700 (Bold) | 1.2 | Screen titles |
| h2 | 20px | 700 | 1.3 | Section headers |
| body | 16px | 400 (Regular) | 1.4 | Tweet text, body content |
| body-bold | 16px | 700 | 1.4 | Usernames, emphasis |
| caption | 13px | 400 | 1.3 | Timestamps, secondary info |
| button | 15px | 600 (SemiBold) | 1.0 | Button labels |
| small | 12px | 400 | 1.3 | Character counter, helper text |

### Font Family

| Platform | Font |
|----------|------|
| Web | `Inter`, system-ui, sans-serif |
| iOS | `.SFUIText`, system |
| Android | `Roboto`, system |
| Flutter | `Inter` (custom) or system default |

---

## 3. Spacing

| Token | Pixels | Usage |
|-------|:------:|-------|
| xs | 4px | Tiny gaps |
| sm | 8px | Between icon and text |
| md | 12px | Card padding (horizontal) |
| lg | 16px | Card padding (vertical) |
| xl | 24px | Between sections |
| xxl | 32px | Screen margins |

---

## 4. Components

### TweetCard

```
┌──────────────────────────────────┐
│ [avatar] username @handle         │
│          · 2m ago                 │
│                                   │
│   Tweet body text goes here.      │
│   Up to 280 characters.           │
│                                   │
│   ♥ 5   💬 2   🔁 1   📤        │
└──────────────────────────────────┘
```

| Part | Specs |
|------|-------|
| Avatar | 48×48, circle, initials fallback (first letter of username) |
| Username | body-bold, primary text |
| Handle | caption, secondary text |
| Timestamp | caption, secondary text, relative ("2m ago", "yesterday") |
| Body | body, 1-280 chars, line-height 1.4 |
| Actions | 4 buttons: Like, Reply, Retweet, Share |
| Like icon | Heart ♥ → filled (liked) / outline (not liked) |

### Button — Primary

```
┌──────────────────────┐
│     Tweet / Log in   │
└──────────────────────┘
```

| Property | Value |
|----------|-------|
| Background | Primary (#1DA1F2) |
| Text | White, button (15px/600) |
| Border radius | 24px (fully rounded) |
| Height | 44px |
| Padding | 16px horizontal |
| Disabled | Opacity 0.5, no pointer events |

### Button — Outline (Follow)

```
┌──────────────────────┐
│     Following         │
└──────────────────────┘
```

| State | Style |
|-------|-------|
| Follow | Border primary, text primary |
| Following | Border green, text green, filled green bg on hover |
| Disabled | Hidden (own profile) |

### Input Field

```
┌──────────────────────────────────┐
│  label                           │
│ ┌──────────────────────────────┐ │
│ │ placeholder text             │ │
│ └──────────────────────────────┘ │
│  error message                   │
└──────────────────────────────────┘
```

| Property | Value |
|----------|-------|
| Height | 44px |
| Border | 1px solid border/divider |
| Border radius | 4px |
| Focus | Border primary |
| Error | Border error, error text below |

### Avatar

| Property | Value |
|----------|-------|
| Size (list) | 48×48 |
| Size (profile) | 96×96 |
| Shape | Circle |
| Fallback | First letter of username on primary bg |
| Tappable | → `/user/{id}` |

### Loading / Skeleton

| State | Element |
|-------|---------|
| List loading | 3-5 skeleton cards (grey gradient, same dimensions as TweetCard) |
| Detail loading | Skeleton block with same proportions |
| Button loading | Spinner replaces text, button disabled |

### Empty State

```
┌──────────────────────────────────┐
│                                   │
│          📭 (icon)                │
│                                   │
│   No tweets yet.                  │
│   Follow someone to see           │
│   their tweets in your feed.      │
│                                   │
│   ┌──────────────────────────┐    │
│   │     Find people          │    │
│   └──────────────────────────┘    │
│                                   │
└──────────────────────────────────┘
```

### Error State

```
┌──────────────────────────────────┐
│                                   │
│          ⚠️ (icon)                │
│                                   │
│   Something went wrong            │
│                                   │
│   ┌──────────────────────────┐    │
│   │     Try again             │    │
│   └──────────────────────────┘    │
│                                   │
└──────────────────────────────────┘
```

---

## 5. Icons

| Icon | Usage |
|------|-------|
| ♥ / ❤️ | Like (unliked / liked) |
| 💬 | Reply |
| 🔁 | Retweet |
| 📤 | Share |
| 👤 | Profile, user |
| 🔍 | Search |
| 🔔 | Notifications |
| ✏️ | New tweet (FAB) |
| ✕ | Close modal |
| ⚙️ | Settings |

Use platform-native icons where available (SF Symbols on iOS, Material Icons on Android).
