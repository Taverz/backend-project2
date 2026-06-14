# Step 3 — Design Tokens

> Primitives и semantic tokens. Все компоненты используют только эти токены.
> Editorial calm: warm paper base, terra cotta accent, classic serif + Inter + JetBrains Mono.

## Артефакты

| Файл | Что внутри |
|------|-----------|
| [`colours.md`](colours.md) | Primitives (warm neutrals, terra, status) + semantic (light + dark) + contrast verification |
| [`typography.md`](typography.md) | 3 семейства, 12-уровневая type scale, правила serif/sans/mono |
| [`spacing.md`](spacing.md) | 4-base scale, container widths, editorial/recruiter modes |
| [`radius-elevation.md`](radius-elevation.md) | Radius (минимум), borders, elevation (почти нет shadows) |
| [`motion.md`](motion.md) | Duration, easing, reduced-motion, forbidden animations |
| [`icons.md`](icons.md) | Phosphor icons, canonical vocabulary, sizes, colours |
| [`code-theme.md`](code-theme.md) | Syntax highlighting palette для code blocks (light + dark) |
| [`component-tokens.md`](component-tokens.md) | **Промежуточный слой** между semantic и компонентом. Button, Input, Card, Avatar, PostCard, Score, Tag, и др. |

## Принципы tokens

1. **Primitive → Semantic → Component.** Компонент никогда не использует primitive напрямую.
2. **Light by default, dark fully supported.** Обе темы выводятся из одной системы semantic tokens.
3. **WCAG 2.2 AA на text.** Verified.
4. **No magic values.** Если значение не в токене — добавляем токен или используем близкий.

## Что готово для следующего шага

После tokens можем строить **components** (atomic):
- Avatar, Button, Input, ScoreBadge, TopicTag, ComplexityBadge
- Затем molecules: PostCard, ProfileHeader, EndorsementList
- Затем organisms: Feed, Search, ProfileScreen

## Open questions

- **Шрифты загружаем self-host или CDN?** — решим на implementation
- **Точные `OkLCH` значения для primitives** — нужна верификация в Figma c proper colour profile
- **Recruiter density mode tokens** — спецификация может появиться, когда будем строить recruiter screens
