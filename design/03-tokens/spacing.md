# Spacing Tokens

> 4-base scale. Editorial разрешает большие отступы на content-страницах, но не безразмерно.

---

## Scale

| Token | px | Use |
|-------|:--:|-----|
| `space-0` | 0 | Reset/none |
| `space-1` | 4 | Icon ↔ text adjacent, badge inner |
| `space-2` | 8 | Tight groups, between related fields |
| `space-3` | 12 | Compact card padding, small gaps |
| `space-4` | 16 | **Default** padding/gap |
| `space-5` | 24 | Section gap inside card |
| `space-6` | 32 | Between cards, between sections |
| `space-7` | 48 | Major section separation |
| `space-8` | 64 | Page header to content |
| `space-9` | 96 | Above/below display headings, hero areas |
| `space-10` | 128 | Empty state padding, max separation |

---

## Container widths

| Token | Max width | Use |
|-------|:---------:|-----|
| `container-prose` | 640 | Single post detail, profile, reading-focused pages |
| `container-feed` | 720 | Feed (slightly wider) |
| `container-recruiter` | 1280 | Recruiter search results (table-like) |
| `container-wide` | 1440 | Marketing page max |

Mobile: full-width with `space-4` horizontal padding.

---

## Применение

### Content pages (Editorial mode)

| Element | Spacing |
|---------|---------|
| Page horizontal padding | mobile `space-4`, desktop auto (centered container) |
| Top of page → first content | `space-7` (48px) |
| Between sections | `space-6` (32px) |
| Inside card padding | `space-5` (24px) vertical, `space-4` (16px) horizontal |
| Between paragraphs | `space-3` (12px) |
| Body line spacing | См. typography (line-height 1.5-1.6) |

### Listing pages (Feed, Search)

| Element | Spacing |
|---------|---------|
| Between feed items | `space-4` (16px) (умеренная плотность) |
| Inside PostCard | `space-4` padding |
| Avatar ↔ content | `space-3` (12px) |
| Between metadata items (· separator) | `space-2` (8px) |
| Actions row top margin | `space-3` (12px) |

### Recruiter mode (compact)

| Element | Spacing |
|---------|---------|
| Between rows | `space-2` (8px) |
| Row vertical padding | `space-2` (8px) |
| Row horizontal padding | `space-4` (16px) |
| Avatar ↔ name | `space-2` (8px) |
| Filter sidebar gap | `space-3` (12px) |

---

## Правила

1. **Default — `space-4` (16px).** Если не уверен, ставь 16.
2. **Multiples of 4 only.** Никаких 14, 18, 22, 30.
3. **Vertical rhythm = `space-4` (16px) baseline.** Большинство переходов кратны 16.
4. **Editorial mode = +1 step.** Где Twitter поставит 16, мы ставим 24. Где Twitter — 24, мы — 32.
5. **Recruiter mode = −1 step** от editorial.

---

## Что **не** используем

- ❌ 5px, 10px, 15px (не кратно 4)
- ❌ Margin collapsing (используем flex/grid gap)
- ❌ Negative margins (за редкими исключениями для overlap)
- ❌ Inline styles на отдельные элементы — всё через токены
