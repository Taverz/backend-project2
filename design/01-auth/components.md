# Components — Auth Feature

> Виджеты, используемые на экранах авторизации.
> Конкретные значения цветов/шрифтов/отступов — через semantic-токены из
> `design/03-tokens/`. Никаких raw hex здесь.

---

## Component: PrimaryButton

**Figma component name:** `Atom/Button` (variant `primary`)
**Usage:** "Log in", "Sign up"

### Specs

| Property | Token |
|----------|-------|
| Height | `button-height` default (40) |
| Border radius | `button-radius` = `radius-sm` (4) |
| Padding horizontal | `button-padding-x` = `space-4` (16) |
| Background | `button-primary-bg` = `accent` |
| Text | `text-on-accent`, `button` text style |

### States

| # | State | Figma variant | Visual |
|---|-------|---------------|--------|
| 1 | **enabled** | `Atom/Button/Primary/Default` | `button-primary-bg`, `text-on-accent` |
| 2 | **disabled** | `Atom/Button/Primary/Disabled` | `button-primary-bg-disabled`, `text-disabled` |
| 3 | **loading** | `Atom/Button/Primary/Loading` | Spinner вместо текста, disabled |
| 4 | **hover** (web) | `Atom/Button/Primary/Hover` | `button-primary-bg-hover` |
| 5 | **pressed** | `Atom/Button/Primary/Pressed` | `button-primary-bg-pressed` |
| 6 | **focused** | `Atom/Button/Primary/Focused` | `focus-ring` 2px outline |

Полная цепочка — `design/03-tokens/semantic-mappings.md §1`.

### Layout

```
┌──────────────────────────────────┐
│          Log in / Sign up         │
└──────────────────────────────────┘
         ↑ text centered, button label
```

---

## Component: InputField

**Figma component name:** `Atom/Input`
**Usage:** Email, Password, Username, Search

### Specs

| Property | Token |
|----------|-------|
| Height | `input-height` default (40) |
| Border radius | `input-radius` = `radius-sm` (4) |
| Border (default) | 1px `border-default` |
| Background | `input-bg` = `surface-elevated` |
| Text | `text-primary`, `body` style |
| Placeholder | `text-muted` |
| Padding horizontal | `input-padding-x` = `space-3` (12) |

### States

| # | State | Figma variant | Visual |
|---|-------|---------------|--------|
| 1 | **default** | `Atom/Input/Default` | Border `border-default`, placeholder `text-muted` |
| 2 | **focused** | `Atom/Input/Focused` | Border `accent`, `focus-ring` outline |
| 3 | **filled** | `Atom/Input/Filled` | Border `border-default`, value `text-primary` |
| 4 | **error** | `Atom/Input/Error` | Border `error`, inline error message below |
| 5 | **disabled** | `Atom/Input/Disabled` | `input-bg-disabled`, `text-disabled` |

Полная цепочка — `design/03-tokens/semantic-mappings.md §2`.

### Variants

| Variant | Figma component | Extra |
|---------|----------------|-------|
| Text | `Atom/Input/Text` | — |
| Password | `Atom/Input/Password` | Phosphor `Eye` / `EyeSlash` toggle справа, obscured text |
| With counter | `Atom/Input/Counter` | Counter right: "7/30", `text-muted` |

### Password eye toggle

```
┌──────────────────────────────────┐
│  Password                  [Eye] │  ← Phosphor Eye / EyeSlash icon
└──────────────────────────────────┘
                            ↑ UiIcon, size sm
                            state: visible / hidden
```

### Error state

```
┌──────────────────────────────────┐
│  email@example.com               │  ← border=error
└──────────────────────────────────┘
   Enter a valid email address       ← caption, color=error
   ↑ inline error
```

---

## Component: Avatar

**Figma component name:** `Atom/Avatar`
**Usage:** User profile picture, TweetCard author

### Specs

| Property | List | Profile |
|----------|:----:|:-------:|
| Size | `avatar-size-md` (40) | `avatar-size-xl` (96) |
| Shape | `radius-full` | `radius-full` |
| Fallback bg | Hash-based из {warm-600, terra-500, forest-500, ochre-500, brick-500, warm-700} |
| Fallback text | First letter of username, `text-on-accent`, Inter 600 |

### States

| # | State | Figma variant | Visual |
|---|-------|---------------|--------|
| 1 | **with-image** | `Atom/Avatar/Image` | Photo, circle clip |
| 2 | **initials** | `Atom/Avatar/Initials` | Hash-based bg, letter |
| 3 | **loading** | `Atom/Avatar/Loading` | `surface-sunken` skeleton circle |

Полная цепочка — `design/03-tokens/semantic-mappings.md §4`.

---

## Component: Toast

**Figma component name:** `Molecule/Toast`
**Usage:** Error / success / info notifications

### Specs

| Property | Token |
|----------|-------|
| Position | Bottom of screen, centered, `space-4` (16) от края |
| Padding | `toast-padding-x/y` = `space-4` / `space-3` (16/12) |
| Border radius | `toast-radius` = `radius-sm` (4) |
| Background | `toast-bg` = `surface-elevated` |
| Border | 1px `border-default` |
| Text | `toast-text` = `text-primary`, `body` style |
| Shadow | `elevation-2` (light only) |
| Auto-dismiss | `toast-duration-ms` (4000 default / 8000 critical) |
| z-index | `z-toast` (3000) |

### States

| # | State | Visual |
|---|-------|--------|
| 1 | **shown** | `surface-elevated` bg, `text-primary`, border `border-default` |
| 2 | **hidden** | Not rendered |

### Types

```
┌──────────────────────────────────────┐
│  Invalid email or password            │  ← error toast (XCircle icon, error color)
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  No internet connection               │  ← warning toast (Warning icon, warning color)
└──────────────────────────────────────┘
```

Иконки — Phosphor (`XCircle`, `Warning`, `CheckCircle`, `Info`), цвет по статусу.
Никаких emoji.

---

## Component: Link

**Figma component name:** `Atom/Link`
**Usage:** "Sign up", "Log in", "Forgot password"

### Specs

| Property | Token |
|----------|-------|
| Text style | `caption` (default) или `body` (по контексту) |
| Color | `accent` |
| Color (hover, web) | `accent-hover` + `text-decoration: underline` |
| Color (visited) | `accent` (не меняем) |
| Focus | `focus-ring` 2px outline |

### Layout

```
Don't have an account?   Sign up
    ↑ text-secondary      ↑ accent, tappable
```

---

## Component: ErrorView

**Figma component name:** `Molecule/ErrorView`
**Usage:** Full-screen error с retry

### Specs

| Property | Token |
|----------|-------|
| Container bg | `surface` |
| Padding | `empty-padding-y/x` = `space-9 / space-4` (96/16) |
| Icon size | `icon-xl` (32) |
| Icon color | `text-muted` (или `error` для destructive) |
| Title | `text-primary`, `h3` |
| Description | `text-secondary`, `body` |
| Gap между блоками | `empty-content-gap` = `space-4` (16) |
| Retry button | `Atom/Button` primary variant |

### Layout

```
┌──────────────────────────────────┐
│                                  │
│         [XCircle icon]           │  ← Phosphor XCircle, icon-xl, text-muted
│                                  │
│     Something went wrong          │  ← h3, text-primary
│     Please check your connection  │  ← body, text-secondary
│                                  │
│  ┌──────────────────────────┐    │
│  │       Try again          │    │  ← PrimaryButton
│  └──────────────────────────┘    │
│                                  │
└──────────────────────────────────┘
```

Никаких emoji (⚠️), только Phosphor `XCircle` / `Warning` / `WifiX`.

---

## Связанные документы

- `design/03-tokens/colours.md` §5-6 — semantic tokens
- `design/03-tokens/typography.md` — type scale
- `design/03-tokens/semantic-mappings.md` — полная цепочка для каждого компонента
- `design/04-components/atoms/avatar.md`, `button.md` — общие atom specs
- `docs/shared/DESIGN-CONTRACT.md` — naming convention Figma↔code
- `docs/flutter/ICON-STRATEGY.md` — как иконки попадают в код
