# Icon Tokens

> Один набор, линейный, монохромный. Никаких emoji в UI chrome.

---

## Icon set

**Phosphor Icons** (Regular weight) — рекомендуется для editorial calm.

| Свойство | Значение |
|----------|----------|
| Set | Phosphor Icons (https://phosphoricons.com) |
| Weight | **Regular** (1.5px stroke) для default |
| License | MIT — free, open-source |
| Coverage | 7000+ иконок, обновляется регулярно |

### Почему Phosphor (а не Lucide / Heroicons)

- Phosphor имеет чуть-более-organic curves — лучше для editorial mood
- Regular weight 1.5px stroke — соответствует serif headlines (не слишком thin)
- Хорошо смотрится при разных размерах
- Есть `Phosphor Duotone` weight для редких случаев (использовать с осторожностью)

**Fallback:** Lucide, если Phosphor недоступен для платформы.

---

## Sizes

| Token | px | Use |
|-------|:--:|-----|
| `icon-xs` | 12 | Inline в metadata, tag labels |
| `icon-sm` | 16 | Buttons, input adornments, action icons |
| `icon-md` | 20 | Navigation, primary actions in toolbar |
| `icon-lg` | 24 | Empty state hints, larger contexts |
| `icon-xl` | 32 | Empty state main icon, error views |
| `icon-xxl` | 48 | Onboarding illustrations (if any) |

### Default

- В навигации (top bar, side rail): **`icon-md` (20)**
- В posts actions row: **`icon-sm` (16)**
- Inline metadata: **`icon-xs` (12)**

---

## Colors

Иконки используют те же color tokens, что и текст. **Никогда никаких decorative coloured icons.**

| Context | Color token |
|---------|-------------|
| Default | `text-secondary` |
| Active / hover | `text-primary` |
| Primary action (CTA icon) | `text-on-accent` (на accent bg) или `accent` (стандалоне) |
| Inactive in nav | `text-muted` |
| Active in nav | `text-primary` |
| Error icon | `error` |
| Success icon | `success` |
| Warning icon | `warning` |

---

## Canonical icon vocabulary

Каждое действие в Bable использует **одну и ту же иконку** через всё UI. Не путаем.

### Actions

| Action | Phosphor name | Visual |
|--------|--------------|--------|
| Endorse | `ArrowFatUp` (regular) | ⌃ (up-pointing arrow) |
| Reply | `ChatText` | speech bubble |
| Share | `Share` | share node graph |
| More menu | `DotsThree` | … horizontal |
| Edit | `PencilSimple` | pencil |
| Delete | `Trash` | trash bin |
| Flag | `Flag` | flag |
| Copy | `Copy` | copy stack |

### Navigation

| Concept | Phosphor name | Visual |
|---------|--------------|--------|
| Feed / Home | `House` | house outline |
| Discover / Search | `MagnifyingGlass` | magnifier |
| Notifications | `Bell` | bell |
| Profile | `User` | person silhouette |
| Compose | `PencilLine` | pencil w/ line (for "write") |

### Content meta

| Concept | Phosphor name |
|---------|--------------|
| Code block | `Code` |
| Tag / Topic | `Tag` |
| Time / Date | `Clock` (only when contextually unclear) |
| Link | `LinkSimple` |

### Status

| Concept | Phosphor name | Color |
|---------|--------------|-------|
| Success | `CheckCircle` | `success` |
| Error | `XCircle` | `error` |
| Warning | `Warning` | `warning` |
| Info | `Info` | `text-secondary` |

### UI controls

| Concept | Phosphor name |
|---------|--------------|
| Close | `X` |
| Chevron expand/collapse | `CaretDown` / `CaretUp` |
| Chevron next/back | `CaretRight` / `CaretLeft` |
| Eye (password show) | `Eye` |
| Eye off | `EyeSlash` |
| Settings | `Gear` |

---

## Правила использования

### 1. Один смысл — одна иконка

`Bell` = notifications. Не используем `Bell` где-либо ещё.
`Trash` = delete. Не для archive (для archive — `Archive`).

### 2. Иконка + текст, не только иконка (там, где не очевидно)

**Так:** `[⌃ 14 endorsements]` — иконка + текст
**Не так:** `[⌃ 14]` — только иконка с числом

**Исключения:** в густо-плотных UI (recruiter mode rows) допустимо без подписи **если** иконка из canonical list и hover показывает tooltip.

### 3. Размер согласован с context

| Context | Size |
|---------|:----:|
| Navigation rail | 20 |
| Post actions | 16 |
| Inline in text | 12 |
| Empty state hint | 32 |

### 4. Никаких emoji в UI chrome

Меню, кнопки, навигация — **только** Phosphor icons. Emoji разрешён в:
- Контент пост (написал пользователь)
- Display name / username (написал пользователь)

**Никогда:**
- В placeholder
- В empty state messages
- В button labels
- В nav labels

### 5. Stroke weight не меняется

Все иконки **Regular** (1.5px). Не миксуем `Thin`, `Bold`, `Duotone` в одном UI.

Исключение: `Phosphor Bold` weight можем использовать **только** для **selected** state в навигации (см. tab-bar component).

---

## Avatar fallback

Аватарка пользователя без фото — **не иконка**, а первая буква username:

```
┌─────┐
│  V  │   ← warm-600 bg, paper text, Inter 600
└─────┘
```

Никаких `User` icon вместо отсутствующей аватарки — это безличностно.

---

## Что **не** используем

- ❌ Emoji в UI chrome
- ❌ 3D / gradient / coloured иконки
- ❌ Multiple icon sets смешанные
- ❌ Animated иконки (кроме endorse swap, см. motion.md)
- ❌ Pixel-perfect razrazорения < 16 (мелкие иконки нечитаемы)
- ❌ Декоративные illustrations в normal UI (только в onboarding/empty states sparingly)
