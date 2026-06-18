# Components. Buttons

**Figma:** `Components / Button documentation`
**Status:** draft
**Label:** Основные кнопки приложения

---

## State Basic

### Default (Basic)

| Attribute | Value |
|-----------|-------|
| Variant | `primary` |
| State | `default` |
| Size | `md` |

```
┌──────────────────────┐
│        Button         │
└──────────────────────┘
```

### Loader (Basic)

| Attribute | Value |
|-----------|-------|
| Variant | `primary` |
| State | `loading` |
| Size | `md` |

Spinner + verb+ing label:

```
┌──────────────────────────┐
│   ◐   Posting…           │
└──────────────────────────┘
```

### Left Icon (Basic)

| Attribute | Value |
|-----------|-------|
| Variant | `primary` |
| State | `default` |
| Size | `md` |
| hasLeadingIcon | `true` |

```
┌────────────────────────────────┐
│   ↑   Button                   │
└────────────────────────────────┘
```

### Right Icon (Basic)

| Attribute | Value |
|-----------|-------|
| Variant | `primary` |
| State | `default` |
| Size | `md` |
| hasTrailingIcon | `true` |

```
┌────────────────────────────────┐
│   Button              ↑        │
└────────────────────────────────┘
```

---

## State Medium

### Default (Medium)

Same as Basic but with `size=md` applied explicitly. See Basic defaults.

### Loader (Medium)

Same as Basic Loader with `size=md`.

### Left Icon (Medium)

Same as Basic Left Icon with `size=md`.

### Right Icon (Medium)

Same as Basic Right Icon with `size=md`.

---

## State Small

### Default (Small)

| Attribute | Value |
|-----------|-------|
| Variant | `primary` |
| State | `default` |
| Size | `sm` |

Compact 32px height button for inline/toolbar use.

### Loader (Small)

Loading state with `size=sm` (32px height).

### Left Icon (Small)

Leading icon with `size=sm`.

### Right Icon (Small)

Trailing icon with `size=sm`.

---

## Construction

### Element

**Label:** Button Primary/Basic

| Attribute | Value |
|-----------|-------|
| Direction | Horizontal |
| Alignment | Center, Center |
| Horizontal resizing | Hug |
| Vertical resizing | Fixed |
| Items spacing | 8 |
| Padding | 0, 16, 0, 16 |
| Corner radius | 4 |
| X | 0 |
| Y | 0 |

### Artwork

Visual diagram of `Button Primary/Basic` with annotations:

1. **Button label** — text content, font `body-bold` (Inter Bold 16px)
2. **Button Titlecase** — text transform (sentence case)
3. **Icon left** — leading Phosphor icon (16px), optional via `hasLeadingIcon`
4. **Icon right** — trailing Phosphor icon (16px), optional via `hasTrailingIcon`

```
     ┌─── Button Titlecase ───┐
     │                        │
     ↓                        │
  ┌──┴─────────────────────┐  │
  │  ↑   Button            │──┘
  └──┬─────────────────────┘  ↑
     │                        │
     └──── Icon left ─────────┘
     └──────── Icon right ────┘
```

---

## Related

- [Full Button spec → button.md](./button.md)
- [Design tokens → 03-tokens/component-tokens.md](../../03-tokens/component-tokens.md)
- [Copy guide → COPY-GUIDE.md](../../COPY-GUIDE.md)
