# Designer + AI — Flow

> Как дизайнер ставит AI задачу на дизайн в Figma, и по каким критериям дизайн ревьюится.
> Этот файл — короткий навигатор. Конкретные шаблоны и правила — в связанных документах.

---

## Где что лежит

| Если хочешь… | Открой |
|--------------|--------|
| Готовый промт "нарисуй экран" | `docs/PROMPT-TEMPLATES.md §7` |
| Готовый промт "создай компонент" | `docs/PROMPT-TEMPLATES.md §8` |
| Готовый промт "сделай ревью дизайна" | `docs/PROMPT-TEMPLATES.md §9` |
| Готовый промт "Figma → Flutter код" | `docs/PROMPT-TEMPLATES.md §10` |
| Список всех экранов и состояний | `docs/shared/SCREENS.md` + `docs/shared/WIDGET-STATES.md` |
| Канон визуальной системы (цвета, шрифты, отступы) | `design/03-tokens/` |
| Список компонентов | `design/04-components/README.md` |
| Контракт naming Figma↔code | `docs/shared/DESIGN-CONTRACT.md` |
| Pipeline AI-агента и пошаговые процедуры | `design/_ai/WORKFLOW.md` |
| Identity и границы AI-дизайнера | `design/_ai/AGENT.md` |
| Правила работы в Figma (pages, frames, variants) | `design/_ai/FIGMA-RULES.md` |
| Контекст-карта "что читать для какой задачи" | `design/_ai/CONTEXT-MAP.md` |

---

## Минимальные входные данные для дизайн-задачи

Чтобы AI нарисовал экран без галлюцинаций, у него должно быть на руках (или должен прочитать):

1. **Имя экрана из `docs/shared/SCREENS.md`** — что именно рисуем.
2. **Список обязательных состояний** — `docs/shared/WIDGET-STATES.md` + `docs/shared/DESIGN-CONTRACT.md §4`.
3. **Поведение и порядок элементов** — спека фичи, например `docs/shared/auth-flow/08-BEHAVIOR.md`.
4. **Канон токенов** — `design/03-tokens/colours.md`, `typography.md`, `spacing.md`, `icons.md`.
5. **Канон компонентов** — `design/04-components/` (что уже существует).
6. **Контракт naming** — `docs/shared/DESIGN-CONTRACT.md §1` (layer names = code class names).

Без любого из этого — AI спрашивает или фиксирует open question, не выдумывает.

---

## Чеклист ревью дизайн-результата

После того как AI вернул frame'ы, дизайнер сверяет:

### Layout и композиция
- Порядок элементов совпадает со спекой поведения?
- Размер экрана = mobile 390×844 (или web 1440 по запросу)?
- Auto-layout везде; нет absolute positioning без причины?
- Padding/Gap кратны 4 и идут через `space-N` токены?

### Дизайн-система
- Все цвета — Figma styles из `design/03-tokens/colours.md` (semantic слой)?
- Все шрифты — text styles из `design/03-tokens/typography.md`?
- Все радиусы — из шкалы `radius-xs/sm/md/lg/full`?
- Иконки — только Phosphor Regular из `design/03-tokens/icons.md` vocabulary?
- Никакого raw hex (`#1DA1F2`, `#FFFFFF` и т.п.)?

### Состояния
- Все обязательные states (Default / Loading / Empty / Error / LoadingMore если список)?
- Каждое состояние — отдельный frame в одной Page?

### Контент
- Кнопки — глагол в императиве?
- Empty/Error — факт + действие, без маркетинга?
- Без emoji в UI chrome?
- Без банлист-фраз ("Welcome back!", "Get started!", "Awesome!")?

### Компоненты
- Все интерактивные элементы — instances из `design/04-components/`?
- Никаких detached instances?
- Naming совпадает с `docs/shared/DESIGN-CONTRACT.md §1`?

### A11y
- Контраст body на surface проходит AA (см. `colours.md §7`)?
- Touch targets ≥ 44×44 на mobile?
- Focus rings указаны для primary CTA?

---

## Чего AI стабильно НЕ делает хорошо (всегда перепроверяй)

| Слепая зона | Что проверять |
|-------------|--------------|
| Округление отступов | 15px вместо 16 — лови глазами, либо инструментом |
| Контраст в обеих темах | Light и dark отдельно проверь токеном-инструментом |
| Переполнение контента | Username 30 символов / tweet 280 символов — что произойдёт? |
| Состояния, не описанные явно | AI не нарисует, что не упомянуто — добавь в задачу |
| Анимации | AI не описывает motion, если в задаче не указано — см. `motion.md` |
| Pivot-наследие | AI может случайно вспомнить `Endorse`/`Score`/`Expertise` — это сигнал отвергнуть |
| Material/Twitter палитра | `#1DA1F2`, `Icons.favorite` — устаревшие примеры, не пускать в результат |

---

## Связь со старой версией

Этот файл раньше содержал детальный промт для `LoginScreen` с Twitter-палитрой (#1DA1F2) и
устаревшей структурой DESIGN-SYSTEM.md. Промты переехали в **`docs/PROMPT-TEMPLATES.md`**
с актуальными ссылками на каноны. Используй его — не legacy примеры.
