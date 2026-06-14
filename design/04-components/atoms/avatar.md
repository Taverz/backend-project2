# Avatar

**Layer:** atom
**Figma:** `Atom/Avatar`
**Status:** draft
**Used in:** PostCard, ProfileHeader, UserListTile, NotificationTile, Composer, navigation

---

## 1. Anatomy

```
┌──────────┐
│          │
│    V     │   ← initial fallback (warm-coloured bg + paper letter)
│          │
└──────────┘
   circle, size variant

или с фото:

┌──────────┐
│          │
│ [photo]  │   ← img clipped to circle
│          │
└──────────┘
```

| Part | Element | Token |
|------|---------|-------|
| Container | Circle frame | `avatar-radius` (radius-full) |
| Fallback bg | Solid fill | computed colour (см. §4) |
| Initial letter | Text, centered | `avatar-text-fallback` |
| Photo | Image fill, cover | — |
| Border (optional) | 1px (только в specific contexts) | `border-subtle` |

---

## 2. Properties

| Property | Type | Default | Values |
|----------|------|---------|--------|
| `size` | variant | `md` | `sm` (24) / `md` (40) / `lg` (64) / `xl` (96) |
| `hasImage` | boolean | `false` | true / false |
| `username` | text | `"V"` | string (используется для fallback color + initial) |
| `imageUrl` | text | empty | URL для image fill |
| `withBorder` | boolean | `false` | true / false |

---

## 3. Variants (size matrix)

| size | px | Font | Use case |
|------|:--:|------|----------|
| `sm` | 24 | `caption-bold` (14) | Notifications inline, mentions |
| `md` | 40 | `body-bold` (16) | Feed PostCard, UserListTile |
| `lg` | 64 | `h3` (22) | Recruiter results card |
| `xl` | 96 | `h2` (28) | ProfileHeader |

---

## 4. Fallback colour function

Когда `hasImage = false` — bg colour детерминированно выводится из username, чтобы один человек всегда имел один цвет.

### Алгоритм

```
1. Возьми username (lowercase, trim)
2. Хеш через FNV-1a (или просто sum chars % len палитры)
3. index = hash mod 6
4. Используй один из 6 цветов (см. ниже)
5. Initial letter = первый character username, uppercase
```

### Палитра (6 fallback colours)

| Index | Colour | Hex (light) | Hex (dark) |
|-------|--------|------------|-----------|
| 0 | terra | `terra-500` (#C45A3D) | `terra-400` (#D77456) |
| 1 | forest | `forest-500` (#3C6E47) | `#5A8C66` |
| 2 | ochre | `ochre-500` (#B07A1F) | `#D49946` |
| 3 | indigo | `#3B3E8C` | `#9DA0E8` |
| 4 | brick | `brick-500` (#A8362A) | `#C04032` |
| 5 | warm-deep | `warm-700` (#3D3530) | `warm-300` (#D7CFC2) |

**Text colour:** всегда `text-on-accent` (#FFFFFF) или соответствующий on-dark. Контраст проверен для каждой пары.

### Пример

```
"vlad"   → fnv("vlad") = 0xA7... mod 6 = 1 → forest bg
"marina" → fnv("marina") = 0x4B... mod 6 = 3 → indigo bg
"anna"   → mod 6 = 0 → terra bg
```

---

## 5. States

Avatar — atom, минимум состояний.

| State | Trigger | Visual |
|-------|---------|--------|
| `default` | Loaded | Photo или initial fallback |
| `loading` | Image fetching | Skeleton circle (`disabled-bg` fill) |
| `error` | Image fail | Fallback на initial (тот же что и `hasImage=false`) |

Hover, pressed — не нужны (avatar — это статичный визуал). Если кликабельная (например, → profile) — wrap'им в IconButton или Link, эти состояния там.

---

## 6. Behaviour

### Click → navigate

Avatar часто tap'абельный (→ `/u/{username}`). Поведение:
- В feed PostCard — avatar tap → push profile
- В ProfileHeader — avatar НЕ кликабелен (you're already here)
- В UserListTile — avatar tap → profile

Это поведение — на уровне **родительского** компонента, не Avatar самой. Avatar — только визуал.

### Image loading

- Lazy load images (вне viewport не грузим)
- Source: 2× density (для retina) — avatar 40 = source 80×80
- WebP/AVIF при поддержке, JPEG fallback
- Image fail → silent fallback на initial, без retry, без error indicator

---

## 7. Token references

| Component token | → Semantic | → Primitive |
|----------------|-----------|-------------|
| `avatar-radius` | `radius-full` | 9999 |
| `avatar-text-fallback` | `text-on-accent` | `#FFFFFF` |
| `avatar-bg-fallback` (per username) | one of 6 palette colours | various |
| `avatar-border` | `border-subtle` | `warm-200` / `warm-800` |
| `avatar-size-sm` | — | 24 |
| `avatar-size-md` | — | 40 |
| `avatar-size-lg` | — | 64 |
| `avatar-size-xl` | — | 96 |

См. `03-tokens/component-tokens.md` § Avatar.

---

## 8. A11y

| Aspect | Requirement |
|--------|------------|
| Alt text (with image) | `<img alt="<display_name>" />` |
| Alt text (fallback) | `<div role="img" aria-label="<display_name>">V</div>` |
| Touch target | Если кликабельная — оборачиваем в 44×44 hit area (avatar 24 = + invisible padding) |
| Colour contrast | Fallback letter on bg — verified ≥ 4.5:1 |
| Focus | Если кликабельная — focus ring через wrapping IconButton/Link |

### Screen reader

- Image avatar → "Vlad Iliev, avatar"
- Fallback → "V" не озвучивается, читает только display_name через aria-label

---

## 9. Do / Don't

### ✅ Do

- Use `xl` size **только** в ProfileHeader. Везде иначе — слишком акцентно
- Always set username (даже при `hasImage = true`) — fallback нужен на случай ошибки
- Use consistent fallback algorithm — иначе один человек = разные цвета в разных местах

### ❌ Don't

- Don't put icon (User) instead of initial — это безличностно
- Don't use random colour for fallback — детерминированно от username
- Don't show border by default — только в специфических контекстах (например, на photo collage)
- Don't show online/offline status dot — у нас нет presence в MVP
- Don't animate avatar entrance — простая загрузка изображения

---

## 10. Figma master spec

### Variants

- Variant property `size`: `sm` / `md` / `lg` / `xl`
- Variant property `hasImage`: `true` / `false`
- Component property `username`: text instance (для динамического fallback letter)
- Component property `imageUrl`: text instance (или instance swap для photo source)

### Total variants

4 sizes × 2 hasImage = **8 variants**

### Auto-layout

- Single frame, fixed dimensions per size
- Center-aligned content (image fill или letter)
- Letter is sub-element with `align: center / center`

### Component description (в Figma)

```
Avatar

Atom representing a user picture or fallback initial.
6-colour fallback palette derived from username hash.

Sizes:
- sm (24) — inline mentions
- md (40) — feed, list tiles
- lg (64) — recruiter results
- xl (96) — profile header

Properties:
- size: variant
- hasImage: variant (toggles between photo and fallback)
- username: text (drives initial letter)
- imageUrl: text (photo source)
- withBorder: not yet variant — use sparingly

Tokens:
avatar-radius (radius-full), avatar-text-fallback (text-on-accent),
6 fallback colours from terra/forest/ochre/indigo/brick/warm

Docs: design/04-components/atoms/avatar.md
```

---

## 11. Open questions

- [ ] Online indicator (presence dot) — добавляем когда-нибудь? Default — нет
- [ ] Group avatar (overlapping) — пока не нужен в MVP, добавим если понадобится в notifications "X and 3 others endorsed"
- [ ] Verified checkmark — нет verification в Bable (см. `01-research/anti-patterns.md` AP-5.1)
