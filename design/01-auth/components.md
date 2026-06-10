# Components — Auth Feature

> Виджеты, используемые на экранах авторизации.

---

## Component: PrimaryButton

**Figma component name:** `Button/Primary`
**Usage:** "Log in", "Sign up"

### Specs

| Property | Value |
|----------|-------|
| Height | 44px |
| Border radius | 24px (fully rounded) |
| Padding horizontal | 16px |
| Background | Primary (#1DA1F2) |
| Text | White, Button text style (15px/600) |

### States

| # | State | Figma variant | Visual |
|---|-------|---------------|--------|
| 1 | **enabled** | `Button/Primary/Enabled` | Primary bg, white text |
| 2 | **disabled** | `Button/Primary/Disabled` | Opacity 0.5 |
| 3 | **loading** | `Button/Primary/Loading` | Spinner вместо текста, disabled |
| 4 | **hover** (web) | `Button/Primary/Hover` | Darker bg (#1A91DA) |

### Layout

```
┌──────────────────────────────────┐
│          Log in / Sign up         │
└──────────────────────────────────┘
         ↑ text centered
```

---

## Component: InputField

**Figma component name:** `InputField`
**Usage:** Email, Password, Username, Search

### Specs

| Property | Value |
|----------|-------|
| Height | 44px |
| Border radius | 4px |
| Border | 1px solid, default: Card border (#E1E8ED / #38444D) |
| Background | Transparent |
| Text | Body text style (16px/400) |
| Placeholder | Text secondary (#536471 / #71767B) |
| Padding horizontal | 12px |

### States

| # | State | Figma variant | Visual |
|---|-------|---------------|--------|
| 1 | **default** | `InputField/Default` | Border=card border, placeholder visible |
| 2 | **focused** | `InputField/Focused` | Border=Primary (#1DA1F2) |
| 3 | **filled** | `InputField/Filled` | Border=card border, text visible |
| 4 | **error** | `InputField/Error` | Border=Error (#E0245E), inline error below |
| 5 | **disabled** | `InputField/Disabled` | Opacity 0.5 |

### Variants

| Variant | Figma component | Extra |
|---------|----------------|-------|
| Text | `InputField/Text` | — |
| Password | `InputField/Password` | Eye icon right, obscured text |
| With counter | `InputField/Counter` | Counter right: "7/30" |

### Password eye toggle

```
┌──────────────────────────────────┐
│  Password                   👁   │
└──────────────────────────────────┘
                            ↑ icon
                            state: visible / hidden
```

### Error state

```
┌──────────────────────────────────┐
│  email@example.com               │  ← border=#E0245E
└──────────────────────────────────┘
   Enter a valid email address       ← caption (12px), Error color
   ↑ inline error
```

---

## Component: Avatar

**Figma component name:** `Avatar`
**Usage:** User profile picture, TweetCard author

### Specs

| Property | List size | Profile size |
|----------|:---------:|:------------:|
| Size | 48×48 | 96×96 |
| Shape | Circle (50% radius) | Circle |
| Fallback | Primary bg, white first letter | Same |

### States

| # | State | Figma variant | Visual |
|---|-------|---------------|--------|
| 1 | **with-image** | `Avatar/Image` | Photo, circle clip |
| 2 | **initials** | `Avatar/Initials` | Primary bg, "A" white letter |
| 3 | **loading** | `Avatar/Loading` | Grey skeleton circle |

---

## Component: Toast

**Figma component name:** `Toast`
**Usage:** Error notifications, success notifications

### Specs

| Property | Value |
|----------|-------|
| Position | Bottom of screen, centered |
| Padding | 12px horizontal, 8px vertical |
| Border radius | 8px |
| Background | Dark overlay (rgba(0,0,0,0.9)) |
| Text | White, caption (13px) |
| Auto-dismiss | 3 seconds |

### States

| # | State | Visual |
|---|-------|--------|
| 1 | **shown** | Dark bar, white text |
| 2 | **hidden** | Not rendered |

### Types

```
┌──────────────────────────────────────┐
│  Invalid email or password            │  ← error toast
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  No internet connection               │
└──────────────────────────────────────┘
```

---

## Component: Link

**Figma component name:** `Link`
**Usage:** "Sign up", "Log in", "Forgot password"

### Specs

| Property | Value |
|----------|-------|
| Text | Caption (13px/400) |
| Color | Primary (#1DA1F2) |
| Hover (web) | Underline |

### Layout

```
Don't have an account?   Sign up
    ↑ grey (#71767B)     ↑ primary, tappable
```

---

## Component: ErrorView

**Figma component name:** `ErrorView`
**Usage:** Full-screen error with retry

### Layout

```
┌──────────────────────────────────┐
│                                  │
│                                  │
│            ⚠️                     │  ← icon, 48×48
│                                  │
│     Something went wrong          │  ← h2 (20px)
│                                  │
│  ┌──────────────────────────┐    │
│  │       Try again          │    │  ← PrimaryButton
│  └──────────────────────────┘    │
│                                  │
│                                  │
└──────────────────────────────────┘
```
