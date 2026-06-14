# Radius & Elevation

> Editorial calm = минимум закруглений и минимум теней. Hierarchy через borders и spacing, не через elevation.

---

## Radius

| Token | px | Use |
|-------|:--:|-----|
| `radius-none` | 0 | Default for most surfaces |
| `radius-xs` | 2 | Inline `code`, tag chips |
| `radius-sm` | 4 | Buttons, inputs |
| `radius-md` | 8 | Modals, dropdown panels |
| `radius-lg` | 12 | Reserved (rare, e.g. image previews) |
| `radius-full` | 9999 | Avatars (circle), pill badges |

### Rules

- **Cards: `radius-none` или `radius-xs`** (2px). Editorial cards чаще прямоугольные.
- **Buttons: `radius-sm`** (4px) — мягко, но без playful pill shape.
- **Avatars: `radius-full`** (circle).
- **Code blocks: `radius-xs`** (2px) — едва видно, не "rounded box".
- **Modals: `radius-md`** (8px) — единственное место с заметным radius.

---

## Borders

| Token | Width | Color | Use |
|-------|:-----:|-------|-----|
| `border-hairline` | 1px | `border-subtle` | Dividers between cards, list items |
| `border-default` | 1px | `border-default` | Inputs, buttons, card edges |
| `border-strong` | 1px | `border-strong` | Focus rings, emphasized borders |
| `border-accent` | 1px | `accent` | Active states (selected tab, focused field) |

### Rules

- **Никаких 2px+ borders в normal state.** 1px достаточно везде.
- **Focus = 2px outline** (за пределами 1px border, не вместо). Outline отдельно через CSS `outline`, не через border.
- **Divider в feed = 1px hairline под каждой PostCard**, не border-radius'ом отделяем.

---

## Elevation (Shadows)

В editorial calm **избегаем shadows**. Hierarchy через:
1. Background colour (surface vs surface-elevated)
2. Border (1px)
3. Spacing (generous)

| Token | Shadow | Use |
|-------|--------|-----|
| `elevation-0` | none | **Default** — flat |
| `elevation-1` | `0 1px 2px rgba(26,22,20,0.05)` | Subtle (popover hint) |
| `elevation-2` | `0 4px 12px rgba(26,22,20,0.08)` | Modals, dropdowns |
| `elevation-3` | `0 12px 32px rgba(26,22,20,0.12)` | Reserved (rare, e.g. command palette) |

### Rules

- **Default: `elevation-0`.** Никаких shadows.
- **Cards: НЕ используют shadow.** Хотим card → используем `surface-elevated` (отличный bg) + `border-hairline`.
- **Modal: `elevation-2`** — единственное обычное место с shadow.
- **Dropdown: `elevation-2`** — same.
- **Popover hints / tooltips: `elevation-1`.**

### Dark mode shadows

В dark — shadows почти не видны. Усиливаем border вместо shadow:

```
Light modal: bg surface-elevated + elevation-2 shadow
Dark modal:  bg surface-elevated + border-default (1px)
```

---

## Что **не** используем

- ❌ Inset shadows
- ❌ Coloured shadows (purple glow, etc.)
- ❌ Soft 24px blur shadows (too SaaS-y)
- ❌ Cards с border-radius > 8
- ❌ Multiple shadow layers (`box-shadow: A, B, C`)
- ❌ Borders > 1px в normal state
