# Step 1 — Research

> Что мы узнали про пользователей, конкурентов и рынок перед тем, как идти к moodboard и дизайн-системе.

## Артефакты этого шага

| Файл | Что внутри |
|------|-----------|
| [`personas.md`](personas.md) | 3 синтетические персоны: Marina (mid dev), Vlad (senior dev), Anna (recruiter) — с целями, frustrations, tech habits |
| [`anti-personas.md`](anti-personas.md) | **Кому Bable НЕ для:** Greg (LinkedIn influencer), Maxim (mass-source recruiter), Tim (CV inflation junior), Lurker, Drama-seeker. Как закрываем by design |
| [`competitors.md`](competitors.md) | Teardown 9 конкурентов (Twitter, LinkedIn, Stack Overflow, LeetCode, GitHub, Dev.to, Hashnode, Polywork, Mastodon). Что берём, что НЕ берём |
| [`jtbd.md`](jtbd.md) | Jobs To Be Done: 9 dev jobs, 6 recruiter jobs, 3 cross-cutting. С маркерами MVP / Post-MVP / Reject и связкой job→feature |
| [`switch-triggers.md`](switch-triggers.md) | **Что заставит уйти с Twitter/LinkedIn на Bable** + cold-start strategy (как seedим первую когорту) |
| [`anti-patterns.md`](anti-patterns.md) | 20 anti-patterns, которые мы сознательно НЕ повторяем (с конкретными примерами и заменами) |
| [`positive-patterns.md`](positive-patterns.md) | **Обратная сторона:** 30 позитивных правил для каждого экрана. Чек-лист в конце |

## Ключевые выводы (для следующего шага)

### Tone
- Серьёзный, технический, без emoji в UI
- Density как у Linear / HN, не как у Airbnb
- Type-driven design, минимум хрома

### Trust model
- Weighted endorsement (Stack Overflow style)
- Per-topic score, не global
- Каждое число explainable

### Главный конфликт продукта
- Devs боятся, что Bable станет LinkedIn 2.0 (spam, motivation, fake skills)
- Recruiters боятся, что Bable не даст результата (мало кандидатов / низкое качество данных)
- **Решение:** anti-spam by design + score-driven discovery

### Что MVP должен дать
1. Compose без friction (J-DEV-1)
2. Public profile с per-topic scores (J-DEV-2, J-REC-2)
3. Weighted endorsements с прозрачным explanation (J-DEV-3, J-CROSS-2)
4. Chronological feed по подпискам и тегам (J-DEV-4)
5. Recruiter search по навыкам и уровню (J-REC-1)
6. Public read без логина (J-CROSS-1)

### Что MVP не должен делать
- Стрики, бейджи, рейтинги
- Алгоритмическая лента
- Messaging (отложено — нужны anti-spam механики)
- Длинные статьи (отложено — фокус на коротком формате)
- Self-declared skills, follower count на первом плане

## Что дальше

**Шаг 2 — Strategy & Moodboard:**
- Sharpened positioning (одна фраза)
- 2-3 визуальных направления (минимализм / editorial / playful)
- Выбор одного с обоснованием
- Reference screens, type mood, colour mood
