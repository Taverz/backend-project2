# Chosen Direction — Editorial Calm

> Зафиксированный выбор. Все дальнейшие решения (tokens, components, screens) строятся вокруг этого.

---

## Что выбрано

**Editorial Calm** — Bable выглядит как тех-журнал, не tech-dashboard.

| Параметр | Значение |
|----------|----------|
| Reference family | Read.cv, Stripe Press, Pitch, PostHog blog |
| Density | Low–medium (воздух важен) |
| Typography mood | Serif headlines + sans UI |
| Colour mood | Muted, тёплый base |
| Iconography | Линейные, монохромные (Lucide / Phosphor / Heroicons outline) |
| Decoration | Minimal — divider lines, generous whitespace, no shadows beyond 1px |

---

## Что это значит для следующих шагов

### Pluses
- **Уникальность.** Никто из конкурентов так не выглядит для dev-аудитории
- **Pillar 3 (transparent).** Generous whitespace дышит — каждое число видно
- **Уважение к содержанию.** Серьёзный технический пост получает серьёзное оформление

### Risks, которые надо закрыть осознанно

| Risk | Как закрываем |
|------|--------------|
| **Density penalty** — меньше постов на экран | Принимаем — Pillar 2 (signal>noise). Лучше 3 хороших поста, чем 8 окей |
| **Anna (recruiter) — *"красиво, но не утилитарно"*** | Recruiter view получит специальный density mode (compact list view) — это сделаем явно |
| **Dark mode default vs light editorial** | Editorial calm требует **light by default**. Pересматриваем PRINCIPLES: dark **доступен**, но не default. Меняем стратегию. |
| **Serif для tech** — может выглядеть out of place для code | Serif **только** для headlines, body — sans, code — mono. Чёткое разделение |
| **Junior'ы могут не воспринять** | Junior — не primary user (см. personas). Приняли. |

---

## Решения (зафиксированы)

| # | Решение | Значение |
|---|---------|----------|
| Q1 | **Default theme** | **Light** by default; dark доступен через settings/system |
| Q2 | **Serif family** | **Classic serif** — Source Serif Pro (free Adobe) или Charter (system) для headlines |
| Q3 | **Accent colour** | **Terra cotta** — базовый hue `~#C45A3D`, точная шкала в `03-tokens/colours.md` |
| Q4 | **Recruiter mode** | Same tokens, compact density через layout + spacing overrides |

### Implications

- `PRINCIPLES.md §1` уточнён: tone editorial, но без emoji в UI остаётся
- `PRINCIPLES.md` "dark by default" — **снято**. Theme не principle, а UX-решение
- `PRINCIPLES.md §6 density` остаётся, но editorial mode даёт **больше воздуха** на content-страницах, **меньше** на listing-страницах для recruiter
- Шрифты: 2 free-источника (Source Serif Pro + Inter + JetBrains Mono) — нет лицензионных рисков

---

## Что **не** меняется (зафиксировано в brief / principles)

Эти решения уже приняты, не пересматриваем:

- **Tone of voice** — neutral, factual, no emoji в UI
- **256 char limit** на post
- **Weighted endorsement формула** — без изменений
- **Hierarchy через типографику, не через цвет**
- **A11y WCAG 2.2 AA** — обязательно
- **Performance budget** — обязательно

---

## Что дальше

После ответов на Q1–Q4 → **Step 3 — Design Tokens** в `design/03-tokens/`:
- `colours.md` — primitives + semantic + light/dark pair
- `typography.md` — type scale, font stacks, кейсы
- `spacing.md` — scale + rules применения
- `radius-elevation.md` — radius, borders, elevation (минимум для editorial)
- `motion.md` — durations, easings, reduced-motion
- `icons.md` — set, размеры, правила
