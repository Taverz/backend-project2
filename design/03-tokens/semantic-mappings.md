# Semantic Mappings

> Сквозная таблица **primitive → semantic → component** для каждого
> компонента. Источник истины по конкретным значениям — `colours.md`,
> `typography.md`, `spacing.md`, `radius-elevation.md`. Источник по
> component-уровню — `component-tokens.md`. Этот файл — read-only
> срез, чтобы видеть всю цепочку в одном месте.

---

## Как читать

```
PRIMITIVE       — фиксированный hex / px, не зависит от темы
SEMANTIC        — ссылка на primitive, может отличаться light vs dark
COMPONENT       — ссылка на semantic, имя в формате <component>-<part>-<state>
USED IN         — конкретные компоненты, которые потребляют этот component-token
```

Колонка `LIGHT` показывает разрешённый hex в light-теме (для быстрого
sanity-check). `DARK` — для тёмной. Подробнее — в `colours.md` §5 и §6.

---

## 1. Button

| Component | Semantic | Primitive (light) | Primitive (dark) | Used in |
|-----------|----------|-------------------|-------------------|---------|
| `button-primary-bg` | `accent` | `terra-500` (#C45A3D) | `terra-500` | All primary CTAs |
| `button-primary-bg-hover` | `accent-hover` | `terra-600` (#A84B30) | `terra-400` (#D77456) | hover |
| `button-primary-bg-pressed` | `accent-hover` | `terra-600` | `terra-400` | active |
| `button-primary-bg-disabled` | `disabled-bg` | `warm-100` (#F4EFE8) | `warm-800` (#2A2421) | disabled |
| `button-primary-text` | `text-on-accent` | `#FFFFFF` | `#FFFFFF` | label |
| `button-primary-text-disabled` | `disabled-text` | `warm-400` (#A8A095) | `#5C544B` | disabled label |
| `button-primary-border` | `transparent` | — | — | always |
| `button-primary-focus-ring` | `focus-ring` | `terra-500` @ 0.50 α | `terra-500` @ 0.60 α | focus-visible |
| `button-secondary-bg` | `transparent` | — | — | default |
| `button-secondary-bg-hover` | `surface-hover` | `terra-50` (#FCF1ED) | `#241F1B` | hover |
| `button-secondary-text` | `text-primary` | `ink` (#1A1614) | `#EBE5DC` | label |
| `button-secondary-border` | `border-default` | `warm-300` (#D7CFC2) | `warm-700` (#3D3530) | always |
| `button-text-bg` | `transparent` | — | — | always |
| `button-text-color` | `accent` | `terra-500` | `terra-500` | label |
| `button-text-color-hover` | `accent-hover` | `terra-600` | `terra-400` | hover |
| `button-danger-bg` | `error` | `brick-500` (#A8362A) | `brick-400` (#C04032) | destructive |
| `button-danger-text` | — | `#FFFFFF` | `#FFFFFF` | destructive |

Дополнительно: `button-height = 40 / 32 / 48`, `button-radius = radius-sm (4)`,
`button-padding-x = space-4 (16)`.

---

## 2. Input

| Component | Semantic | Primitive (light) | Primitive (dark) | Used in |
|-----------|----------|-------------------|-------------------|---------|
| `input-bg` | `surface-elevated` | `#FDFAF5` | `warm-800` | default |
| `input-bg-disabled` | `disabled-bg` | `warm-100` | `warm-800` | disabled |
| `input-border` | `border-default` | `warm-300` | `warm-700` | default |
| `input-border-hover` | `border-strong` | `warm-600` (#5C544B) | `warm-500` (#7C746A) | hover |
| `input-border-focused` | `accent` | `terra-500` | `terra-500` | focus |
| `input-border-error` | `error` | `brick-500` | `brick-400` | invalid |
| `input-text` | `text-primary` | `ink` | `#EBE5DC` | value |
| `input-placeholder` | `text-muted` | `warm-500` | `warm-500` | empty state |
| `input-text-disabled` | `disabled-text` | `warm-400` | `#5C544B` | disabled |
| `input-focus-ring` | `focus-ring` | `terra-500` @ 0.50 α | `terra-500` @ 0.60 α | focus-visible |
| `input-focus-ring-error` | `focus-ring-error` | `error` @ 0.50 α | `error` @ 0.60 α | invalid + focus |
| `input-label-color` | `text-secondary` | `warm-600` | `#9B8F80` | above input |
| `input-helper-color` | `text-secondary` | `warm-600` | `#9B8F80` | below input |
| `input-error-color` | `error` | `brick-500` | `brick-400` | error message |

Дополнительно: `input-height = 40 / 32`, `input-radius = radius-sm (4)`,
`input-padding-x = space-3 (12)`.

---

## 3. Card

| Component | Semantic | Primitive (light) | Primitive (dark) | Used in |
|-----------|----------|-------------------|-------------------|---------|
| `card-bg` | `surface-elevated` | `#FDFAF5` | `warm-800` | all cards |
| `card-bg-hover` | `surface-hover` | `terra-50` | `#241F1B` | tappable cards |
| `card-border` | `border-subtle` | `warm-200` (#E8E0D4) | `warm-800` | always |
| `card-divider` | `border-subtle` | `warm-200` | `warm-800` | separator |

`card-border-width = 1px`, `card-radius = 0 (editorial flat)`,
`card-padding-y = space-5 (24)`, `card-padding-x = space-4 (16)`.

---

## 4. Avatar

| Component | Semantic | Primitive (light) | Primitive (dark) | Used in |
|-----------|----------|-------------------|-------------------|---------|
| `avatar-bg-fallback` | `accent` (или hash-based) | см. note ниже | см. note ниже | если нет фото |
| `avatar-text-fallback` | `text-on-accent` | `#FFFFFF` | `#FFFFFF` | initial letter |
| `avatar-border` | `transparent` | — | — | default |

**Hash-based fallback colours** (детерминированно от username):
`warm-600`, `terra-500`, `forest-500`, `ochre-500`, `brick-500`,
`#3D3530`. См. `04-components/atoms/avatar.md` § "fallback".

Размеры: `avatar-size-sm/md/lg/xl = 24 / 40 / 64 / 96`,
`avatar-radius = radius-full`.

---

## 5. PostCard (molecule, planned)

| Component | Semantic | Primitive (light) | Primitive (dark) | Used in |
|-----------|----------|-------------------|-------------------|---------|
| `post-card-bg` | `surface-elevated` | `#FDFAF5` | `warm-800` | feed, profile |
| `post-card-bg-hover` | `surface-hover` | `terra-50` | `#241F1B` | tappable |
| `post-card-divider` | `border-subtle` | `warm-200` | `warm-800` | между постами |
| `post-card-author-name` | `text-primary` + `body-bold` | `ink` | `#EBE5DC` | username |
| `post-card-author-handle` | `text-secondary` + `caption` | `warm-600` | `#9B8F80` | @handle |
| `post-card-timestamp` | `text-secondary` + `caption` | `warm-600` | `#9B8F80` | "2m ago" |
| `post-card-body-color` | `text-primary` + `body-lg` | `ink` | `#EBE5DC` | post text |
| `post-card-actions-color-default` | `text-secondary` | `warm-600` | `#9B8F80` | action row |
| `post-card-actions-color-active` | `accent` | `terra-500` | `terra-500` | liked / replied |

`post-card-padding-y = space-5 (24)` на content pages,
`space-4 (16)` в feed. `post-card-padding-x = space-4 (16)`.
`post-card-actions-gap = space-5 (24)`.

---

## 6. Navigation (bottom tab bar / side rail)

| Component | Semantic | Primitive (light) | Primitive (dark) | Used in |
|-----------|----------|-------------------|-------------------|---------|
| `nav-bg` | `surface` | `warm-50` (#FAF7F2) | `warm-900` (#1A1714) | nav background |
| `nav-border` | `border-subtle` | `warm-200` | `warm-800` | 1px top border |
| `nav-icon-default` | `text-muted` | `warm-500` | `warm-500` | inactive icons |
| `nav-icon-active` | `text-primary` | `ink` | `#EBE5DC` | active icon |
| `nav-label-default` | `text-muted` | `warm-500` | `warm-500` | inactive label |
| `nav-label-active` | `text-primary` | `ink` | `#EBE5DC` | active label |
| `nav-active-indicator` | `accent` | `terra-500` | `terra-500` | underline/dot |

`nav-icon-size = 20`, `nav-height = 56`, `nav-padding-x = space-4 (16)`.

---

## 7. Modal / Dialog

| Component | Semantic | Primitive (light) | Primitive (dark) | Used in |
|-----------|----------|-------------------|-------------------|---------|
| `modal-bg` | `surface-elevated` | `#FDFAF5` | `warm-800` | dialog body |
| `modal-border` | `border-default` | `warm-300` | `warm-700` | 1px (dark) |
| `modal-backdrop` | `overlay-soft` | rgba(26,22,20,0.30) | rgba(0,0,0,0.50) | scrim |
| `modal-shadow` | `elevation-2` | — (light only) | — | depth |

`modal-radius = radius-sm (4)`, `modal-padding = space-6 (32)`,
`modal-max-width = 480`, `modal-z = z-modal (2000)`.

---

## 8. Toast / Snackbar

| Component | Semantic | Primitive (light) | Primitive (dark) | Used in |
|-----------|----------|-------------------|-------------------|---------|
| `toast-bg` | `surface-elevated` | `#FDFAF5` | `warm-800` | body |
| `toast-border` | `border-default` | `warm-300` | `warm-700` | always |
| `toast-text` | `text-primary` | `ink` | `#EBE5DC` | message |
| `toast-shadow` | `elevation-2` | — | — | depth |

`toast-radius = radius-sm (4)`, `toast-padding-y = space-3 (12)`,
`toast-padding-x = space-4 (16)`, `toast-z = z-toast (3000)`,
`toast-duration-ms = 4000 / 8000 (critical)`.

---

## 9. Empty State

| Component | Semantic | Primitive (light) | Primitive (dark) | Used in |
|-----------|----------|-------------------|-------------------|---------|
| `empty-bg` | `surface` | `warm-50` | `warm-900` | container |
| `empty-icon-color` | `text-muted` | `warm-500` | `warm-500` | hint icon |
| `empty-title` | `text-primary` + `h3` | `ink` | `#EBE5DC` | headline |
| `empty-description` | `text-secondary` + `body` | `warm-600` | `#9B8F80` | copy |

`empty-icon-size = 32`, `empty-padding-y = space-9 (96)`,
`empty-padding-x = space-4 (16)`, `empty-content-gap = space-4 (16)`.

---

## 10. Tag / Topic chip (если используется)

| Component | Semantic | Primitive (light) | Primitive (dark) | Used in |
|-----------|----------|-------------------|-------------------|---------|
| `tag-bg` | `surface-sunken` | `warm-100` | `warm-950` | default |
| `tag-text` | `text-secondary` | `warm-600` | `#9B8F80` | default |
| `tag-bg-active` | `accent-soft` | `terra-100` (#F8DDD2) | `#3A201A` | selected |
| `tag-text-active` | `accent` | `terra-500` | `terra-500` | selected |

`tag-padding-y = space-1 (4)`, `tag-padding-x = space-2 (8)`,
`tag-radius = radius-xs (2)`, `tag-gap = space-2 (8)`.

---

## 11. Status badges

| Component | Semantic | Primitive (light) | Primitive (dark) | Used in |
|-----------|----------|-------------------|-------------------|---------|
| `complexity-easy-bg` | `success-soft` | `forest-100` | `#1F2E24` | difficulty |
| `complexity-easy-text` | `success` | `forest-500` | `#5A8C66` | difficulty |
| `complexity-medium-bg` | `warning-soft` | `ochre-100` | `#2D2316` | difficulty |
| `complexity-medium-text` | `warning` | `ochre-500` | `#D49946` | difficulty |
| `complexity-hard-bg` | `error-soft` | `brick-100` | `#2E1814` | difficulty |
| `complexity-hard-text` | `error` | `brick-500` | `brick-400` | difficulty |

`complexity-font = caption-bold`, `complexity-radius = radius-xs (2)`.

---

## Service-tokens (cross-component)

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `selection-bg` | `terra-200` | `terra-800` | выделенный текст |
| `selection-text` | `text-primary` | `text-primary` | контраст |
| `hover-overlay` | rgba(26,22,20,0.04) | rgba(255,247,236,0.05) | universal hover |
| `pressed-overlay` | rgba(26,22,20,0.08) | — | universal pressed |
| `scrollbar-thumb` | `warm-300` | `warm-700` | scrollbars |
| `highlight-bg` | `ochre-100` | `#3A2F1D` | search match |

---

## Принципы

1. **Компонент никогда не ссылается на primitive напрямую.** Только
   через `component-token → semantic → primitive`.
2. **Semantic появляется до component-token.** Если для нового
   состояния нет semantic — сначала добавь в `colours.md`, потом
   привязывай component.
3. **Один component-token = одна semantic.** Не комбинируем
   (никаких "accent + 0.1 opacity" в этом слое — это уровень semantic).
4. **Add a row to this table when adding a component-token.** Этот
   документ должен оставаться полным срезом.
5. **Magic value запрещён.** Если в спеке компонента появилось
   значение без token — добавь token.

---

## Когда обновлять этот файл

- Новый component-token в `component-tokens.md` → строка сюда.
- Изменилась цепочка `semantic → primitive` в `colours.md` → колонки
  `Primitive (light/dark)` пересчитываются.
- Удалён component-token → удалить строку.

Тест-задача (для будущего): script `tools/validate-token-mappings.sh`
парсит `component-tokens.md` и сверяет с этим файлом. Расхождение →
fail.
