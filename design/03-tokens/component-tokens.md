# Component Tokens

> Промежуточный слой между **semantic** tokens и **компонентами**.
> Цель: компонент НЕ ссылается на semantic напрямую. Он ссылается на component-token, который ссылается на semantic.
> Это даёт возможность поменять, например, цвет всех кнопок одной правкой `button-primary-bg`, не трогая semantic.

---

## Зачем этот слой

Без component-tokens:
```
Button → accent (semantic)
Link → accent (semantic)
ActiveTab → accent (semantic)
IconActive → accent (semantic)
```
Когда дизайнер скажет "давайте у link будет другой цвет, чтобы не путался с button" — придётся менять не `accent`, а искать **каждое** место. Нет точки контроля.

С component-tokens:
```
button-primary-bg → accent
link-color → accent
tab-active-color → accent
icon-active-color → accent
```
Если link нужен другой цвет — меняем только `link-color → text-primary`. Никакого ripple effect.

---

## Архитектура

```
primitive  (warm-500, terra-500, ink, …)
   ↓
semantic   (surface, text-primary, accent, border-default, …)
   ↓
component  (button-primary-bg, post-card-bg, score-figure-color, …)  ← этот слой
   ↓
component implementation
```

---

## Component tokens — Buttons

| Token | → Semantic |
|-------|-----------|
| `button-primary-bg` | `accent` |
| `button-primary-bg-hover` | `accent-hover` |
| `button-primary-bg-pressed` | `accent-hover` |
| `button-primary-bg-disabled` | `disabled-bg` |
| `button-primary-text` | `text-on-accent` |
| `button-primary-text-disabled` | `disabled-text` |
| `button-primary-border` | `transparent` |
| `button-primary-focus-ring` | `focus-ring` |
| `button-secondary-bg` | `transparent` |
| `button-secondary-bg-hover` | `surface-hover` |
| `button-secondary-text` | `text-primary` |
| `button-secondary-border` | `border-default` |
| `button-text-bg` | `transparent` |
| `button-text-color` | `accent` |
| `button-text-color-hover` | `accent-hover` |
| `button-danger-bg` | `error` |
| `button-danger-text` | `#FFFFFF` |
| `button-height` | 40 (default) / 32 (compact) / 48 (large) |
| `button-radius` | `radius-sm` (4) |
| `button-padding-x` | `space-4` (16) |

---

## Component tokens — Inputs

| Token | → Semantic |
|-------|-----------|
| `input-bg` | `surface-elevated` |
| `input-bg-disabled` | `disabled-bg` |
| `input-border` | `border-default` |
| `input-border-hover` | `border-strong` |
| `input-border-focused` | `accent` |
| `input-border-error` | `error` |
| `input-text` | `text-primary` |
| `input-placeholder` | `text-muted` |
| `input-text-disabled` | `disabled-text` |
| `input-focus-ring` | `focus-ring` |
| `input-focus-ring-error` | `focus-ring-error` |
| `input-height` | 40 (default) / 32 (compact) |
| `input-radius` | `radius-sm` (4) |
| `input-padding-x` | `space-3` (12) |
| `input-label-color` | `text-secondary` |
| `input-helper-color` | `text-secondary` |
| `input-error-color` | `error` |

---

## Component tokens — Cards

| Token | → Semantic |
|-------|-----------|
| `card-bg` | `surface-elevated` |
| `card-bg-hover` | `surface-hover` |
| `card-border` | `border-subtle` |
| `card-border-width` | 1px |
| `card-radius` | `radius-none` (0) — editorial flat |
| `card-padding-y` | `space-5` (24) |
| `card-padding-x` | `space-4` (16) |
| `card-divider` | `border-subtle` |

---

## Component tokens — Avatar

| Token | → Semantic |
|-------|-----------|
| `avatar-bg-fallback` | `accent` (default) или см. note ниже |
| `avatar-text-fallback` | `text-on-accent` |
| `avatar-border` | `transparent` |
| `avatar-size-sm` | 24 |
| `avatar-size-md` | 40 |
| `avatar-size-lg` | 64 |
| `avatar-size-xl` | 96 (profile header) |
| `avatar-radius` | `radius-full` |
| `avatar-font` | `body-bold` (для md и больше), `caption-bold` (для sm) |

**Avatar fallback colour:** детерминированно от username (hash → один из 6 цветов из warm/terra/forest/ochre/brick/indigo). См. `04-components/avatar.md` для функции.

---

## Component tokens — PostCard

| Token | → Semantic |
|-------|-----------|
| `post-card-bg` | `surface-elevated` |
| `post-card-bg-hover` | `surface-hover` |
| `post-card-divider` | `border-subtle` (между постами в feed) |
| `post-card-padding-y` | `space-5` (24) на content pages, `space-4` (16) в feed |
| `post-card-padding-x` | `space-4` (16) |
| `post-card-author-name` | `text-primary`, font `body-bold` |
| `post-card-author-handle` | `text-secondary`, font `caption` |
| `post-card-timestamp` | `text-secondary`, font `caption` |
| `post-card-body` | `text-primary`, font `body-lg` |
| `post-card-body-color` | `text-primary` |
| `post-card-actions-color-default` | `text-secondary` |
| `post-card-actions-color-active` | `accent` |
| `post-card-actions-gap` | `space-5` (24) между кнопками |

---

## Component tokens — Score Display

| Token | → Semantic |
|-------|-----------|
| `score-figure-color` | `text-primary` |
| `score-figure-font` | `serif-figure` (32/40, mobile 28/36) |
| `score-figure-feature` | `font-variant-numeric: tabular-nums` |
| `score-topic-color` | `text-secondary` |
| `score-topic-font` | `body` (16/24) |
| `score-row-gap-y` | `space-2` (8) между строками |
| `score-badge-bg` | `accent-soft` (для inline badges в feed) |
| `score-badge-text` | `accent` |
| `score-badge-font` | `caption-bold` |
| `score-badge-padding` | `space-1` (4) vertical / `space-2` (8) horizontal |
| `score-badge-radius` | `radius-xs` (2) |

---

## Component tokens — Topic Tag (chip)

| Token | → Semantic |
|-------|-----------|
| `tag-bg` | `surface-sunken` |
| `tag-text` | `text-secondary` |
| `tag-bg-active` | `accent-soft` |
| `tag-text-active` | `accent` |
| `tag-font` | `caption` |
| `tag-padding-y` | `space-1` (4) |
| `tag-padding-x` | `space-2` (8) |
| `tag-radius` | `radius-xs` (2) |
| `tag-gap` | `space-2` (8) между tags |

---

## Component tokens — Complexity Badge

| Token | → Semantic |
|-------|-----------|
| `complexity-easy-bg` | `success-soft` |
| `complexity-easy-text` | `success` |
| `complexity-medium-bg` | `warning-soft` |
| `complexity-medium-text` | `warning` |
| `complexity-hard-bg` | `error-soft` |
| `complexity-hard-text` | `error` |
| `complexity-font` | `caption-bold` |
| `complexity-radius` | `radius-xs` (2) |

Note: единственное место с status-coloured badges в Bable. Не дублировать pattern в других tags.

---

## Component tokens — Navigation

| Token | → Semantic |
|-------|-----------|
| `nav-bg` | `surface` |
| `nav-border` | `border-subtle` (1px top border for bottom tab bar) |
| `nav-icon-default` | `text-muted` |
| `nav-icon-active` | `text-primary` |
| `nav-label-default` | `text-muted` |
| `nav-label-active` | `text-primary` |
| `nav-active-indicator` | `accent` (1px underline или dot — TBD в component spec) |
| `nav-icon-size` | 20 |
| `nav-height` | 56 (bottom mobile) |
| `nav-padding-x` | `space-4` (16) |

---

## Component tokens — Modal / Dialog

| Token | → Semantic |
|-------|-----------|
| `modal-bg` | `surface-elevated` |
| `modal-border` | `border-default` (1px, виден в dark) |
| `modal-radius` | `radius-sm` (4) — был `radius-md` 8, но editorial требует мягче |
| `modal-padding` | `space-6` (32) |
| `modal-max-width` | 480 |
| `modal-backdrop` | `overlay-soft` |
| `modal-shadow` | `elevation-2` (только light theme) |
| `modal-z` | `z-modal` |

---

## Component tokens — Toast / Snackbar

| Token | → Semantic |
|-------|-----------|
| `toast-bg` | `surface-elevated` |
| `toast-border` | `border-default` |
| `toast-text` | `text-primary` |
| `toast-radius` | `radius-sm` (4) |
| `toast-padding-y` | `space-3` (12) |
| `toast-padding-x` | `space-4` (16) |
| `toast-shadow` | `elevation-2` |
| `toast-z` | `z-toast` |
| `toast-duration-ms` | 4000 (default), 8000 (critical errors) |

---

## Component tokens — Empty State

| Token | → Semantic |
|-------|-----------|
| `empty-bg` | `surface` |
| `empty-icon-color` | `text-muted` |
| `empty-icon-size` | 32 |
| `empty-title` | `text-primary`, font `h3` |
| `empty-description` | `text-secondary`, font `body` |
| `empty-padding-y` | `space-9` (96) |
| `empty-padding-x` | `space-4` (16) |
| `empty-content-gap` | `space-4` (16) между icon → title → description → CTA |

---

## Component tokens — Endorsement

| Token | → Semantic |
|-------|-----------|
| `endorse-icon-default` | `text-secondary` |
| `endorse-icon-active` | `accent` |
| `endorse-count-color` | `text-secondary` |
| `endorse-count-font` | `caption` |
| `endorse-button-gap` | `space-1` (4) между иконкой и числом |
| `endorse-active-scale-burst` | 1.1 (peak, 200ms) |

---

## Что **не** в этом слое

- Layout (padding страниц целиком) — это semantic spacing/container
- Animation timings — это `motion.md` tokens используются напрямую
- Typography variants — компонент использует typography tokens напрямую (`body`, `h2`) — не плодим `post-body-font: body`

Component tokens — только **цвета**, **размеры компонентов**, **специфические radius/padding**.

---

## Правила

1. **Компонент не ссылается на semantic напрямую.** Всегда через component-token.
   - ❌ `<Button bg={tokens.accent}>` — плохо
   - ✅ `<Button bg={tokens.buttonPrimaryBg}>` — хорошо

2. **Component-token = одна semantic.** Не комбинируем здесь.
   - ❌ `card-bg: accent + 0.1 opacity` — это semantic уровень
   - ✅ `card-bg: surface-elevated`

3. **Если нет component-token, добавляем сюда.** Не оставляем magic value в компоненте.

4. **Naming: `<component>-<part>-<state>`.**
   - `button-primary-bg-hover`
   - `input-border-focused`
   - `post-card-actions-color-active`
