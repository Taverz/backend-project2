# Step 2 — Strategy & Moodboard

> Позиционирование, финальный scope, и выбор визуального направления.

## Артефакты

| Файл | Что внутри |
|------|-----------|
| [`POSITIONING.md`](POSITIONING.md) | One-liner, value matrix, 3 brand pillars, дифференциация vs всех конкурентов |
| [`MVP-SCOPE.md`](MVP-SCOPE.md) | 47 фич в scope, выкладка by category, post-MVP, never. Каждая фича обоснована JTBD или pillar |
| [`visual-directions.md`](visual-directions.md) | 3 направления (Terminal Brutalism / Editorial Calm / Modernized Forum) — выбор за тобой |

## Ключевые решения

### Позиционирование

> **Bable — социальная сеть для разработчиков, где экспертность подтверждена peer-эндорсментами с весом.**

3 brand pillars: **Peer-verified · Signal over noise · Transparent by design**

### MVP — 47 фич, ~10 экранов

Auth (4) · Profile (7) · Posts (8) · Endorsement (5) · Feed (6) · Follow (3) · Search (5) · Notifications (5) · Roles (4) · Moderation (2)

Backend существующий (Twitter-like Go) **потребует переделки**:
- Tweet → Post с type/complexity/topic_tag
- Like → Endorsement с weighted calc
- User: role + availability
- Score: per-topic + decay job
- Search: + filters

### Визуальное направление — выбор

Три варианта на столе. Я рекомендую **A: Terminal Brutalism**, но решение за тобой.

## Что дальше

После выбора направления:
- Step 3 — Design Tokens (выводим из выбранного направления)
- Step 4 — Components
- Step 5 — Flows & Wireframes
- Step 6 — Screens
