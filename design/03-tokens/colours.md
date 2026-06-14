# Colour Tokens

> Editorial calm palette. Тёплая, бумажная база + terra cotta акцент.
> Двухслойная архитектура: **primitives** (точные hex) → **semantic** (использование).
> Компоненты используют только semantic. Primitives никогда не вставляются в UI напрямую.

---

## 1. Архитектура токенов

```
primitive  → стабильный hex, не зависит от темы
              warm-100, warm-900, terra-500, ink-900, ...

semantic   → ссылка на primitive, зависит от темы
              surface, surface-elevated, text, text-muted, accent, ...

component  → ссылка на semantic
              button-primary-bg = accent
              card-bg = surface-elevated
```

Правило: если нужен новый цвет в UI — сначала ищем semantic. Нет — добавляем semantic. Не вешаем primitive напрямую в компонент.

---

## 2. Primitives — Warm neutrals (paper)

База Editorial — **тёплая нейтральная бумага**, не чистая серая шкала.

| Token | Hex | OkLCH (approx) | Use |
|-------|-----|---------------|-----|
| `warm-50` | `#FAF7F2` | L 97 C 0.01 H 80 | Lightest surface (page bg light) |
| `warm-100` | `#F4EFE8` | L 94 C 0.013 H 78 | Elevated surface, dividers light |
| `warm-200` | `#E8E0D4` | L 88 C 0.018 H 75 | Borders muted |
| `warm-300` | `#D7CFC2` | L 82 C 0.023 H 72 | Borders default |
| `warm-400` | `#A8A095` | L 67 C 0.018 H 75 | Text disabled |
| `warm-500` | `#7C746A` | L 50 C 0.018 H 70 | Text muted (light) |
| `warm-600` | `#5C544B` | L 38 C 0.018 H 65 | Text secondary (light) |
| `warm-700` | `#3D3530` | L 25 C 0.018 H 50 | — |
| `warm-800` | `#2A2421` | L 17 C 0.018 H 45 | Surface dark elevated |
| `warm-900` | `#1A1714` | L 11 C 0.018 H 45 | Page bg dark |
| `warm-950` | `#0F0D0B` | L 6 C 0.013 H 45 | Deepest dark |
| `ink` | `#1A1614` | L 11 C 0.015 H 40 | Text primary on light bg |
| `paper` | `#FAF7F2` | L 97 C 0.01 H 80 | Default light surface (alias warm-50) |

Не используем pure black/white. Тёплый ink/paper создаёт editorial feel.

---

## 3. Primitives — Terra cotta (accent)

Brand accent shade, ramp 50→900.

| Token | Hex | Use |
|-------|-----|-----|
| `terra-50` | `#FCF1ED` | Bg tint (hover surface accent) |
| `terra-100` | `#F8DDD2` | Subtle tint background |
| `terra-200` | `#F0BAA5` | Hover/light variant |
| `terra-300` | `#E69478` | — |
| `terra-400` | `#D77456` | — |
| `terra-500` | `#C45A3D` | **Brand accent — primary** |
| `terra-600` | `#A84B30` | Hover/pressed |
| `terra-700` | `#8A3D27` | — |
| `terra-800` | `#6B2F1F` | Dark-mode accent (smaller surface area) |
| `terra-900` | `#4D2418` | — |

Точный hue centered around `C ≈ 0.13, H ≈ 35` в OkLCH.

---

## 4. Primitives — Status colours

Все muted под editorial. Не яркие, не неоновые.

### Forest (success)
| Token | Hex | Use |
|-------|-----|-----|
| `forest-100` | `#E0EAE2` | Success bg tint |
| `forest-500` | `#3C6E47` | Success text/icon |
| `forest-700` | `#26452D` | Success dark |

### Brick (error)
| Token | Hex | Use |
|-------|-----|-----|
| `brick-100` | `#F1D8D4` | Error bg tint |
| `brick-500` | `#A8362A` | Error text/icon (light) |
| `brick-400` | `#C04032` | Error text (dark) |
| `brick-700` | `#6B201A` | Error dark |

Brick намеренно отличается от Terra (которая accent), чтобы errors не путались с primary actions.

### Ochre (warning)
| Token | Hex | Use |
|-------|-----|-----|
| `ochre-100` | `#F4E8D0` | Warning bg tint |
| `ochre-500` | `#B07A1F` | Warning text/icon |
| `ochre-700` | `#704C10` | Warning dark |

---

## 5. Semantic — Light theme (default)

| Semantic token | Primitive | Purpose |
|----------------|-----------|---------|
| `surface` | `warm-50` (#FAF7F2) | Page background |
| `surface-elevated` | `#FDFAF5` (warm white, не pure) | Card/composer/modal bg |
| `surface-sunken` | `warm-100` (#F4EFE8) | Code block bg, inset areas |
| `surface-hover` | `terra-50` (#FCF1ED) | Hover state on tappable rows |
| `surface-accent-soft` | `terra-100` (#F8DDD2) | Subtle highlight (e.g. own post in feed) |
| `border-subtle` | `warm-200` (#E8E0D4) | Card edges, dividers |
| `border-default` | `warm-300` (#D7CFC2) | Input borders, separators |
| `border-strong` | `warm-600` (#5C544B) | Focus rings (subtle), emphasized borders |
| `text-primary` | `ink` (#1A1614) | Body, headlines |
| `text-secondary` | `warm-600` (#5C544B) | Captions, timestamps, metadata |
| `text-muted` | `warm-500` (#7C746A) | Placeholders, disabled text |
| `text-disabled` | `warm-400` (#A8A095) | Disabled button text |
| `text-on-accent` | `#FFFFFF` | Text on terra-500 button |
| `accent` | `terra-500` (#C45A3D) | Primary CTA, links, focus accent |
| `accent-hover` | `terra-600` (#A84B30) | Hover state of accent |
| `accent-soft` | `terra-100` (#F8DDD2) | Accent tint bg (e.g. tag chips) |
| `success` | `forest-500` (#3C6E47) | Success icons, text |
| `success-soft` | `forest-100` (#E0EAE2) | Success bg tint |
| `error` | `brick-500` (#A8362A) | Error icons, text |
| `error-soft` | `brick-100` (#F1D8D4) | Error bg tint |
| `warning` | `ochre-500` (#B07A1F) | Warning icons |
| `warning-soft` | `ochre-100` (#F4E8D0) | Warning bg tint |
| `focus-ring` | `terra-500` (#C45A3D) at 40% opacity | Focus outline (2px) |

---

## 6. Semantic — Dark theme

Dark остаётся editorial, но через тёплые тёмные тона, не чёрный.

| Semantic token | Primitive | Purpose |
|----------------|-----------|---------|
| `surface` | `warm-900` (#1A1714) | Page background |
| `surface-elevated` | `warm-800` (#2A2421) | Card/composer bg |
| `surface-sunken` | `warm-950` (#0F0D0B) | Code block bg |
| `surface-hover` | `#241F1B` (warm-850 derived) | Hover on tappable rows |
| `surface-accent-soft` | `#3A201A` (terra mix dark) | Subtle accent surface |
| `border-subtle` | `warm-800` (#2A2421) | Dividers |
| `border-default` | `warm-700` (#3D3530) | Default borders |
| `border-strong` | `warm-500` (#7C746A) | Emphasized borders |
| `text-primary` | `#EBE5DC` | Body, headlines (warm off-white) |
| `text-secondary` | `#9B8F80` | Captions, metadata |
| `text-muted` | `warm-500` (#7C746A) | Placeholders |
| `text-disabled` | `#5C544B` | Disabled |
| `text-on-accent` | `#FFFFFF` | Text on terra-500 |
| `accent` | `terra-500` (#C45A3D) | Same accent — works on both |
| `accent-hover` | `terra-400` (#D77456) | Hover дark — lighter |
| `accent-soft` | `#3A1F18` (terra-mix-dark) | Subtle accent bg |
| `success` | `#5A8C66` (forest-500 lighter) | |
| `success-soft` | `#1F2E24` | |
| `error` | `#C04032` (brick-400) | |
| `error-soft` | `#2E1814` | |
| `warning` | `#D49946` (ochre-500 lighter) | |
| `warning-soft` | `#2D2316` | |
| `focus-ring` | `terra-500` at 50% opacity | |

---

## 6.5 Semantic — System / Interaction tokens

Эти токены **не привязаны к theme напрямую** — некоторые имеют разные значения для light/dark, другие универсальны.

### Selection (text)

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `selection-bg` | `terra-200` (#F0BAA5) | `terra-800` (#6B2F1F) | Background выделенного текста |
| `selection-text` | `text-primary` | `text-primary` | Цвет выделенного текста (контрастный) |

### Overlay / Scrim

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `overlay-soft` | `rgba(26,22,20,0.30)` | `rgba(0,0,0,0.50)` | Backdrop modal/dialog |
| `overlay-strong` | `rgba(26,22,20,0.50)` | `rgba(0,0,0,0.70)` | Backdrop critical actions |

### Focus

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `focus-ring` | `terra-500` at 0.50 alpha | `terra-500` at 0.60 alpha | Focus outline (2px outline + 2px offset) |
| `focus-ring-error` | `error` at 0.50 alpha | `error` at 0.60 alpha | Focus outline на invalid field |

`focus-visible` стейт всегда показывает ring. `focus` без visible — не показываем (keyboard-only via `:focus-visible`).

### Disabled

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `disabled-bg` | `warm-100` | `warm-800` | Background disabled control |
| `disabled-border` | `warm-200` | `warm-700` | Border disabled |
| `disabled-text` | `warm-400` | `#5C544B` | Text disabled (alias text-disabled) |

### Scrollbar

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `scrollbar-thumb` | `warm-300` | `warm-700` | Полоса прокрутки |
| `scrollbar-thumb-hover` | `warm-600` | `warm-500` | Hover |
| `scrollbar-track` | `transparent` | `transparent` | Background дорожки |

### Search highlight

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `highlight-bg` | `ochre-100` (#F4E8D0) | `#3A2F1D` | Background для search match |
| `highlight-text` | `text-primary` | `text-primary` | Цвет текста match'а |

### Hover tints (overlay)

Универсальный overlay используется когда hover нужен поверх любого surface:

| Token | Value | Use |
|-------|-------|-----|
| `hover-overlay` | `rgba(26,22,20,0.04)` | Light theme hover |
| `hover-overlay-dark` | `rgba(255,247,236,0.05)` | Dark theme hover |
| `pressed-overlay` | `rgba(26,22,20,0.08)` | Active/pressed state |

---

## 6.6 Opacity Scale

| Token | Value | Use |
|-------|:-----:|-----|
| `opacity-0` | 0 | Hidden but layoutable |
| `opacity-disabled` | 0.40 | Disabled UI elements |
| `opacity-muted` | 0.60 | Subordinated content |
| `opacity-hover` | 0.04 | Subtle hover overlay |
| `opacity-pressed` | 0.08 | Active/pressed overlay |
| `opacity-overlay-soft` | 0.30 | Modal backdrop |
| `opacity-overlay-strong` | 0.50 | Critical modal backdrop |
| `opacity-full` | 1 | Default |

Используем эти значения для **любых** прозрачностей. Никаких magic 0.45, 0.62, 0.13.

---

## 6.7 Z-index / Layers

| Token | Value | Use |
|-------|:-----:|-----|
| `z-base` | 0 | Default content |
| `z-sticky` | 100 | Sticky header / scroll-pinned elements |
| `z-dropdown` | 1000 | Dropdown menus, popovers |
| `z-modal-backdrop` | 1900 | Modal backdrop overlay |
| `z-modal` | 2000 | Modal dialog content |
| `z-toast` | 3000 | Toast/snackbar notifications |
| `z-tooltip` | 4000 | Tooltips (всегда поверх всего) |
| `z-max` | 9999 | Emergency (debug, dev-only) |

Между уровнями оставлен запас (100, 1000, 1900, 2000, ...) — для будущих элементов без переписывания всех значений.

---

## 7. Contrast verification

WCAG 2.2 targets: AA = 4.5:1 для normal text, 3:1 для large/icons. AAA = 7:1.

| Pair | Light contrast | Dark contrast | Status |
|------|:--------------:|:-------------:|:------:|
| `text-primary` on `surface` | 14.8 : 1 | 13.2 : 1 | AAA ✅ |
| `text-secondary` on `surface` | 6.1 : 1 | 4.8 : 1 | AA ✅ |
| `text-muted` on `surface` | 4.6 : 1 | 4.0 : 1 | AA / AA borderline |
| `text-on-accent` on `accent` | 4.9 : 1 | 4.9 : 1 | AA ✅ |
| `accent` on `surface` (link) | 4.6 : 1 | 5.2 : 1 | AA ✅ |
| `error` on `surface` | 5.4 : 1 | 5.1 : 1 | AA ✅ |
| `border-default` on `surface` | ~1.4 : 1 | ~1.4 : 1 | по PRINCIPLES 3:1 не достигнут для границ. **Решение:** focus и interactive borders используют `border-strong` (3:1+) |

Note: значения approximate, реальная верификация — через Figma/Stark в дизайн-инструменте.

---

## 8. Применение в компонентах

| Component | Token use |
|-----------|-----------|
| **Page bg** | `surface` |
| **PostCard bg** | `surface-elevated` |
| **PostCard border** | `border-subtle` |
| **PostCard hover** | `surface-hover` |
| **Username** | `text-primary` |
| **Score number** | `text-primary` (но bold serif) |
| **Score label "React"** | `text-secondary` |
| **Timestamp** | `text-secondary` |
| **Endorse button (default)** | `border-default` outline, `text-secondary` text |
| **Endorse button (active)** | `accent-soft` bg, `accent` text/icon |
| **Primary CTA "Post"** | `accent` bg, `text-on-accent` text |
| **Code block** | `surface-sunken` bg, `text-primary` text, mono font |
| **Inline `code`** | `surface-sunken` bg, `text-primary` text |
| **Focus ring** | `focus-ring` 2px outline + 2px offset |
| **Error message** | `error` text, `error-soft` bg в alert |
| **Tag chip** | `surface-sunken` bg, `text-secondary` text |
| **Topic tag в посте** | text-only с `text-secondary` (без chip background) |
| **Score badge на profile card** | `accent-soft` bg, `accent` text (только избирательно — top-3 scores) |

---

## 9. Что **не** используем

- ❌ Pure black `#000` / pure white `#FFF` (для основных surface — у нас warm)
- ❌ Gradient backgrounds (editorial flat)
- ❌ Drop shadows (используем border 1px + spacing)
- ❌ Цвет как primary signal — type weight/size hierarchies first
- ❌ Многоцветные UI элементы (no rainbow tags)
- ❌ Material Design palette (purple/teal/etc) — конфликтует с editorial

---

## 10. Cheatsheet

Запомнить три правила:

1. **`text-primary` — для важного.** Имена, headlines, числа Score. Не для подписей.
2. **`accent` редко.** Один на экран — primary CTA. Plus link inline.
3. **`error/warning/success` — только статусные сообщения.** Не для decoration.

Если возникает вопрос "какой это цвет?" — он, скорее всего, `text-primary` или `text-secondary`. Большинство UI — это эти два цвета на `surface`.
