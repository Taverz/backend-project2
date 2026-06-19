# Molecules

> Composed of atoms. Каждый molecule = composition + own state.
> Spec template и общий workflow — см. `../README.md`.

---

## Запланированные molecules (MVP)

Порядок по приоритету (см. `../README.md` § Component MVP scope):

| # | Component | Atoms used | Used on screen | Status |
|---|-----------|------------|----------------|--------|
| 1 | **ProfileHeader** | Avatar, Button, ScoreRow | Profile | ⬜ draft |
| 2 | **EndorseButton** | IconButton, ScoreFigure | Feed, Post detail | ⬜ draft |
| 3 | **PostCard** | Avatar, TopicTag, ComplexityBadge, IconButton, EndorseButton | Feed, Profile, Search | ⬜ draft |
| 4 | **ScoreRow** | ScoreFigure, TopicTag | Profile, Recruiter view | ⬜ draft |
| 5 | **UserListTile** | Avatar, Button, ScoreRow (compact) | Search, Followers | ⬜ draft |
| 6 | **EmptyState** | (text + Button) | Везде, где empty | ⬜ draft |
| 7 | **FlagMenu** | IconButton, divider | Post actions | ⬜ draft |

---

## Правила molecules

1. **Только instance атомов.** Не пересоздавать button/avatar внутри molecule.
2. **Свой state — только если он не выводится из props.** Иначе stateless.
3. **Token chain:** atom-tokens → molecule-tokens (если нужны) → semantic.
4. **A11y — labelled group.** Каждый интерактивный atom внутри получает свой
   `aria-label`; группа имеет `role`/`aria-labelledby` где уместно.
5. **Не делать "композицию ради композиции"** — molecule оправдан, только если
   он переиспользуется на ≥ 2 экранах ИЛИ инкапсулирует нетривиальное
   взаимодействие (optimistic update, swipe, expand).

---

## Связь с Figma

```
Markdown                       Figma
─────────────────────────────  ────────────────────────────────
molecules/post-card.md         Components / Molecule / PostCard
molecules/profile-header.md    Components / Molecule / ProfileHeader
```

См. `../../_ai/FIGMA-RULES.md`.

---

## Что дальше

После Tier 2 molecules (PostCard, EndorseButton, ProfileHeader) переходим к
**organisms** — Feed, Composer, SearchResults.
