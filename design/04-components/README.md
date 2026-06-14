# Step 4 — Components

> Atomic дизайн: atoms → molecules → organisms.
> Каждый компонент = 1 markdown spec + 1 Figma master с variants и properties.

---

## Структура

```
04-components/
├── README.md          ← (this)
├── atoms/             ← Primitives, не composed
│   ├── avatar.md
│   ├── button.md
│   ├── icon-button.md
│   ├── input.md
│   ├── score-figure.md
│   ├── topic-tag.md
│   ├── complexity-badge.md
│   └── divider.md
├── molecules/         ← Composed of atoms
│   ├── post-card.md
│   ├── profile-header.md
│   ├── endorse-button.md
│   ├── score-row.md
│   ├── user-list-tile.md
│   ├── empty-state.md
│   └── flag-menu.md
└── organisms/         ← Composed of molecules
    ├── feed.md
    ├── composer.md
    └── search-results.md
```

---

## Component MVP scope (что в первую очередь)

### Tier 1 — Critical для Profile screen (первый MVP экран)

1. **Avatar** (atom) — нужен на Profile, Feed, Search
2. **Button** (atom) — нужен везде
3. **ScoreFigure** (atom) — главный USP визуал
4. **ProfileHeader** (molecule) — Profile

### Tier 2 — Critical для Feed screen

5. **TopicTag** (atom)
6. **ComplexityBadge** (atom)
7. **IconButton** (atom) — для actions
8. **EndorseButton** (molecule)
9. **PostCard** (molecule)
10. **Feed** (organism)

### Tier 3 — Critical для Compose screen

11. **Input** (atom)
12. **Composer** (organism)

### Tier 4 — Остальное MVP

13. Divider, ScoreRow, UserListTile, EmptyState, FlagMenu, SearchResults

---

## Spec template

Каждый component md следует одинаковой структуре:

```markdown
# <ComponentName>

**Layer:** atom | molecule | organism
**Figma:** Atom/Name (or Molecule/Name, Organism/Name)
**Status:** draft | in-figma | shipped
**Used in:** <screens>

## 1. Anatomy

ASCII diagram + parts list with tokens

## 2. Properties

| Property | Type | Default | Values |

## 3. Variants

| Variant | When | Visual diff |

## 4. States

| State | Trigger | Visual | Tokens |

## 5. Behaviour

Interactions, optimistic updates, motion

## 6. Token references

Component-tokens → semantic tokens chain

## 7. A11y

ARIA, keyboard, screen reader

## 8. Do / Don't

Visual examples or rules
```

---

## Связь с Figma

Каждому md соответствует master component в Figma:

```
Markdown               Figma
─────────────────────  ──────────────────────
atoms/avatar.md        Components / Atom / Avatar
atoms/button.md        Components / Atom / Button
molecules/post-card.md Components / Molecule / PostCard
```

См. `_ai/FIGMA-RULES.md` для convention naming и organization.

---

## Workflow создания компонента

См. `_ai/WORKFLOW.md` § 2 — Create a Component. Кратко:

1. **Read** — AGENT.md, MVP-SCOPE, tokens, существующие компоненты
2. **Plan** — anatomy, variants, properties, tokens used
3. **Execute** — md spec + Figma master
4. **Validate** — checklist tokens / a11y / anti-patterns / copy
5. **Hand off** — diff + open questions

---

## Не делаем

- ❌ Создавать компонент без mvp-scope обоснования
- ❌ Дублировать существующие atoms внутри molecules (всегда instance)
- ❌ Использовать raw hex / шрифты — только через tokens
- ❌ Component-spec без a11y секции

---

## Что дальше после Step 4

После того как Tier 1-2 готовы:

- **Step 5 — Flows & Wireframes:** sitemap, navigation, low-fi для всех 10 MVP screens
- **Step 6 — Screens:** hi-fi экраны, используют components
- **Step 7 — Handoff specs:** redlines, behavioural specs для разработчиков
