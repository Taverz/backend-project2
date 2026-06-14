# Button

**Layer:** atom
**Figma:** `Atom/Button`
**Status:** draft
**Used in:** Everywhere — composers, forms, modals, CTAs, navigation actions

---

## 1. Anatomy

```
┌──────────────────────────┐
│                          │
│      Button Label        │  ← text, optional leading/trailing icon
│                          │
└──────────────────────────┘
 padding-x   gap   padding-x
```

Optional with icon:

```
┌──────────────────────────┐
│   ↑   Endorse            │  ← icon + text
└──────────────────────────┘
```

Loading:

```
┌──────────────────────────┐
│      ◐ Posting…          │  ← spinner + verb+ing
└──────────────────────────┘
```

| Part | Element | Token |
|------|---------|-------|
| Container | Frame, auto-layout horizontal | varies by variant |
| Padding | Internal | `button-padding-x` (16) horizontal |
| Height | Fixed | `button-height` (40 default) |
| Border radius | All corners | `button-radius` (radius-sm = 4) |
| Label | Text | `body-bold` (16/24/600) |
| Leading icon | Phosphor, 16px | matches text colour |
| Trailing icon | Phosphor, 16px | matches text colour |
| Gap (icon ↔ text) | Auto-layout | `space-2` (8) |
| Spinner (loading) | Phosphor CircleNotch (animated) | matches text colour |

---

## 2. Properties

| Property | Type | Default | Values |
|----------|------|---------|--------|
| `variant` | variant | `primary` | `primary` / `secondary` / `text` / `danger` |
| `state` | variant | `default` | `default` / `hover` / `pressed` / `focused` / `disabled` / `loading` |
| `size` | variant | `md` | `sm` (32) / `md` (40) / `lg` (48) |
| `hasLeadingIcon` | boolean | `false` | true / false |
| `hasTrailingIcon` | boolean | `false` | true / false |
| `label` | text | `"Button"` | string |
| `leadingIcon` | instance swap | (none) | Phosphor icon master |
| `trailingIcon` | instance swap | (none) | Phosphor icon master |
| `fullWidth` | boolean | `false` | true / false (растягивается по parent) |

---

## 3. Variants

### primary

```
┌──────────────────────┐
│        Post          │   bg: accent (#C45A3D)
└──────────────────────┘   text: text-on-accent (#FFFFFF)
                           border: none
```

**Use:** Главный action на экране (Post, Sign up, Save, Confirm)
**Rule:** Один primary на экран max

### secondary

```
┌──────────────────────┐
│       Cancel          │  bg: transparent
└──────────────────────┘  text: text-primary
                          border: 1px border-default
```

**Use:** Secondary actions (Cancel, Back, Edit profile)
**Rule:** Можно несколько на экран

### text

```
       Forgot password?
       ↑ no container
```

bg: transparent, no border, text: `accent`, underline on hover

**Use:** Tertiary actions, "Cancel" в context inline
**Rule:** Где `secondary` слишком тяжело визуально

### danger

```
┌──────────────────────┐
│      Delete           │  bg: error (#A8362A)
└──────────────────────┘  text: #FFFFFF
                          border: none
```

**Use:** Destructive actions (Delete post, Delete account, Confirm logout)
**Rule:** Только в confirmation dialogs или после явного "edit mode"

---

## 4. States (по variants)

| State | primary | secondary | text | danger |
|-------|---------|-----------|------|--------|
| `default` | `accent` bg + white text | transparent + `border-default` | no bg + `accent` text | `error` bg + white |
| `hover` | `accent-hover` bg | `surface-hover` bg | underline | error-darker bg (TBD token) |
| `pressed` | `accent-hover` + scale 0.98 | `border-strong` border | scale 0.98 | error-darker + scale 0.98 |
| `focused` | + `focus-ring` outline | + `focus-ring` outline | + `focus-ring` outline | + `focus-ring-error` outline |
| `disabled` | `disabled-bg` + `disabled-text` | `disabled-border` + `disabled-text` | `disabled-text` (no bg) | same as primary disabled |
| `loading` | bg unchanged, label → "+ing", spinner shown | same | same | same |

### Focus rule

- `:focus-visible` показывает ring (keyboard navigation)
- Plain `:focus` (mouse click after) — ring **не** показываем
- Ring: 2px solid `focus-ring`, 2px offset от border

### Loading rule

- Label превращается в verb+ing form: `Post` → `Posting…`
- Spinner появляется слева (где обычно leading icon)
- `disabled` интерактивно (нельзя кликнуть), но визуально не `disabled` (тот же цвет) — пользователь видит, что button реагирует

---

## 5. Sizes

| size | height | padding-x | font | leading icon | use |
|------|:------:|:---------:|------|:------------:|-----|
| `sm` | 32 | 12 | `caption-bold` (14) | 16 | Inline buttons (in toolbars, compact cells) |
| `md` | 40 | 16 | `body-bold` (16) | 16 | **Default** — forms, dialogs, navigation |
| `lg` | 48 | 24 | `body-bold` (16) | 20 | Marketing CTA, primary action на пустом экране |

`lg` редко используется. Default — `md`.

---

## 6. Behaviour

### Click → action

Button — это trigger. Логика самого действия (POST request, open modal, navigate) — на уровне родительского компонента.

### Optimistic UI integration

Когда button запускает async action:
1. Click → state становится `loading` (spinner + verb+ing label)
2. Параллельно отправляем request
3. Если success → silent (parent UI обновляется, как описано в `01-research/positive-patterns.md` PP-7.2)
4. Если error → state возвращается в `default`, рядом или на месте показывается error message (см. `COPY-GUIDE.md` § 3)

### Никаких double clicks

После первого click button автоматически становится `disabled` (через `loading` state) — повторный click игнорируется. Это структурно, не на уровне UX-логики.

### Motion

- Hover transition: `duration-fast` (120ms), `easing-out`
- Pressed scale: 0.98 transform, `duration-fast`
- Focus ring fade: `duration-fast`
- Loading spinner: continuous 1s linear rotation
- **Не используем** bouncing / spring physics

---

## 7. Token references

| Component token | → Semantic | Used in |
|-----------------|-----------|---------|
| `button-primary-bg` | `accent` | primary variant |
| `button-primary-bg-hover` | `accent-hover` | primary hover |
| `button-primary-bg-disabled` | `disabled-bg` | primary disabled |
| `button-primary-text` | `text-on-accent` | primary |
| `button-primary-text-disabled` | `disabled-text` | primary disabled |
| `button-secondary-bg` | `transparent` | secondary |
| `button-secondary-bg-hover` | `surface-hover` | secondary hover |
| `button-secondary-text` | `text-primary` | secondary |
| `button-secondary-border` | `border-default` | secondary |
| `button-text-color` | `accent` | text variant |
| `button-text-color-hover` | `accent-hover` | text hover |
| `button-danger-bg` | `error` | danger |
| `button-danger-text` | `#FFFFFF` | danger |
| `button-focus-ring` | `focus-ring` | all variants focus |
| `button-height` | (sm:32 / md:40 / lg:48) | size |
| `button-radius` | `radius-sm` (4) | all |
| `button-padding-x` | `space-3` (12) / `space-4` (16) / `space-5` (24) | per size |

См. `03-tokens/component-tokens.md` § Buttons.

---

## 8. A11y

| Aspect | Requirement |
|--------|------------|
| Element | `<button>` always (не `<div>` с onclick) |
| Disabled | `disabled` attribute + `aria-disabled="true"` |
| Loading | `aria-busy="true"` + visible spinner |
| Icon-only | Не у этого component (см. IconButton) — у Button всегда есть text |
| Focus | Visible focus ring через `:focus-visible` |
| Keyboard | Activates with Enter и Space |
| Touch target | Min 44×44 (size sm — обернуть в 44 hit area если нужно) |
| Screen reader (loading) | "Posting, in progress" |

---

## 9. Copy guide (см. COPY-GUIDE §2)

### Rules

- Глагол императив: "Post", "Save", "Delete"
- 1–2 слова, максимум 4
- НЕ: "Click to save", "Submit", "OK"

### Bable canonical labels

| Action | Label | Variant |
|--------|-------|---------|
| Post | Post | primary |
| Save changes | Save | primary |
| Cancel | Cancel | secondary |
| Edit | Edit | secondary |
| Delete post | Delete | danger |
| Delete account | Delete account | danger |
| Sign up | Sign up | primary |
| Log in | Log in | primary |
| Log out | Log out | secondary or text |
| Follow user | Follow | primary |
| Following (toggle) | Following | secondary (active state) |
| Endorse | Endorse | (see EndorseButton — separate molecule) |
| Reply | Reply | secondary or text |

### Loading transformations

| Idle | Loading |
|------|---------|
| Post | Posting… |
| Save | Saving… |
| Delete | Deleting… |
| Sign up | Signing up… |
| Log in | Logging in… |
| Endorse | Endorsing… |

---

## 10. Do / Don't

### ✅ Do

- One primary button per screen
- Use canonical labels (Post, Save, Edit, Delete) — не reinventing copy
- Loading state — verb+ing form
- Disabled when async in flight

### ❌ Don't

- Multiple primaries на одном экране
- Don't use emoji в label
- Don't use "Click here", "Submit", "OK" labels
- Don't shadow или gradient — editorial flat
- Don't use button для navigation (use Link / NavItem)
- Don't fake-disable (visually disabled, but still clickable) — accessibility issue

---

## 11. Figma master spec

### Variants

- Variant `variant`: primary / secondary / text / danger
- Variant `state`: default / hover / pressed / focused / disabled / loading
- Variant `size`: sm / md / lg
- Boolean `hasLeadingIcon`
- Boolean `hasTrailingIcon`
- Boolean `fullWidth`
- Text property `label`
- Instance swap `leadingIcon` (Phosphor icon master)
- Instance swap `trailingIcon`

### Total variants

4 variants × 6 states × 3 sizes = **72 variant combinations**.
Это много, но Figma справляется. Можно делать постепенно — приоритет: primary × all states × md size первыми (Tier 1).

### Auto-layout

- Horizontal layout
- Gap `space-2` (8) между icon и text
- Fixed height per size
- Hug width by default, fill if `fullWidth=true`

### Component description (в Figma)

```
Button

Atom for all user-triggered actions in Bable.

Variants:
- primary — main action on screen (1 per screen rule)
- secondary — alternate actions
- text — tertiary, inline
- danger — destructive (Delete, Logout confirm)

States:
- default / hover / pressed / focused / disabled / loading

Sizes:
- sm (32) — compact toolbars
- md (40) — DEFAULT
- lg (48) — marketing CTAs, empty state primary

Copy:
- Verb-first, imperative, max 4 words
- Loading: verb + ing + ellipsis

Tokens:
button-primary-bg / -text / -focus-ring etc.

Docs: design/04-components/atoms/button.md
```

---

## 12. Open questions

- [ ] `button-danger-bg-hover` token — нужно создать (currently undefined в colours.md). Сделать `error-hover` semantic token
- [ ] Outline variant нужен? Сейчас `secondary` = outline по факту, но не назван явно. Решить — оставить `secondary` или rename
- [ ] Button group / stack — отдельный компонент или просто использование gap?
