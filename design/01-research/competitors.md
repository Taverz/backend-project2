# Competitor Teardown

> **Шаг 1.2 / Research.** Что делают конкуренты — и что мы из этого берём, а что игнорируем.
> Анализ на основе общедоступной информации об их продуктах (state on early 2026).

---

## Карта пространства

```
       Long-form content
              ▲
              │
   Dev.to ────┼──── Medium
              │
   Hashnode ──┤
              │
              │
   GitHub ────┼──── Stack Overflow
              │
              │
   Twitter ───┼──── LinkedIn
              │
              ▼
       Short-form / network
              ──────────────────►
                  Skill verification
              No                         Yes

   ┌─────────────────────────┐
   │ Bable target zone       │
   │ short-form +            │
   │ skill verification +    │
   │ network                 │
   └─────────────────────────┘
```

Никто не сидит точно в этом квадрате. LinkedIn ближе всех к network + skill, но verification фальшивая. Stack Overflow ближе всех к verification, но не social network.

---

## 1. Twitter / X

### Что хорошо
- Лёгкость публикации (frictionless compose)
- Хронологическая лента (опционально, "Following" tab)
- Threads для длинных мыслей
- Открытая платформа (не нужно регистрироваться, чтобы читать)
- Сильная виральность хороших insights

### Что плохо для IT
- Code blocks отсутствуют (workaround — carbon.now.sh screenshots)
- Threads визуально рассыпаются, теряется контекст
- Алгоритм заталкивает шум (политика, реклама, drama)
- Лайки = единственная метрика, тривиально накручиваются
- Профиль = bio + аватар, никакой структуры
- Bluechecks дискредитировали verification

### Что берём
- Frictionless compose с keyboard shortcut
- Хронологический feed (default)
- Threading через `parent_id` — но визуально решим иначе
- Permalink на пост (open by default)

### Что НЕ берём
- Алгоритмическая рекомендательная лента
- Лайки как primary metric
- Verified badges за деньги
- "For You" вкладку

---

## 2. LinkedIn

### Что хорошо
- Структурированный профиль (опыт, навыки, образование)
- Recruiter search с фильтрами
- Endorsement skills (концепция есть, но reализация плохая)
- Network effects работают

### Что плохо для IT
- Профиль = резюме, а не доказательство навыка
- Endorsements нажимаются всеми за всё (девальвация)
- Контент-лента превратилась в motivation/sales/инфлюенсеров
- Spam от рекрутеров (типовые шаблоны)
- "Open to work" badge — карьерное унижение
- Buzzword soup ("ninja", "rockstar", "growth hacker")

### Что берём
- Идея структурированного профиля (но с акцентом на доказательства, не текст)
- Recruiter view с поиском по навыкам и уровню
- Концепция endorsement (но переработанная — с весом)

### Что НЕ берём
- Анонимный endorsement "I endorse Anna for React" одним кликом
- Контент с motivation-стилем
- "Connect" уведомления как primary loop
- Premium / payed visibility
- "Influencer" типажи

---

## 3. Stack Overflow

### Что хорошо
- Репутация с механикой — голос weight зависит от reputation того, кто голосует
- Tag-based expertise (Rust badge, React badge etc.)
- Прозрачная история: видно, за что получены очки
- Anti-spam встроен на уровне механики

### Что плохо
- Только Q&A формат — нельзя писать insights / projects
- UI устарел (выглядит как 2008)
- Сообщество стало враждебным к новичкам (closed as duplicate)
- Нет social feed — only search
- Профиль = таблица tag scores, без эмоций

### Что берём
- **Weighted endorsements** — это база нашего trust model
- **Per-tag/topic reputation**, а не общая
- **История репутации**: видно, как и за что нарисовался Score
- Anti-spam через rate-limiting на основе reputation

### Что НЕ берём
- Только Q&A формат
- Гостеприимство нулевое (мы должны быть мягче)
- Closed-by-vote — у нас нет модерации сообщества пока

---

## 4. LeetCode

### Что хорошо
- Прозрачный proof-of-work (решённые задачи)
- Уровни сложности (easy/medium/hard) — простая ментальная модель
- Стрики и weekly contests дают engagement loop
- Профиль с metrics: solved, ranking, badges

### Что плохо для нашей задачи
- Только алгоритмы — не репрезентативно для real-world skill
- Геймификация навязчива (стрики, ранги)
- Не social — нельзя обсуждать или показывать insights
- Recruiter usage малый (компании используют HackerRank для интервью)

### Что берём
- **Complexity multiplier** (easy/medium/hard) для оценки сложности контента
- Простая визуализация уровня (progress bar with number)
- Идея, что **верифицируемый proof** работает лучше слов

### Что НЕ берём
- Стрики, daily challenge как primary loop
- Ranking leaderboards (соревнование вредит экспертному tone)
- Любые badges, которые ощущаются как игрушки

---

## 5. GitHub

### Что хорошо
- Proof-of-work через код (всё видно)
- Активность визуализирована (heatmap)
- Профиль показывает реальную работу
- Open by default (можно посмотреть без логина)

### Что плохо
- Heatmap не различает качество от объёма
- Stars ≠ умение
- Не social — discussions слабые
- Профиль не показывает, что ты **думаешь** про код

### Что берём
- Open profile (читается без логина)
- Activity history (но не daily heatmap — это стрик в маске)
- Связь "что человек сделал" → "что человек умеет"

### Что НЕ берём
- Daily contribution heatmap — это вариация стрика
- Stars как metric (vanity)

---

## 6. Dev.to

### Что хорошо
- Markdown с подсветкой кода работает идеально
- Tagging system (`#rust`, `#frontend`)
- Простая публикация long-form
- Inclusive community

### Что плохо
- Только long-form — нет insights / quick takes
- Профиль слабый (только posts + bio)
- Нет verification качества (хороший пост и плохой выглядят одинаково)
- Лента — chronological, без discovery по navыкам

### Что берём
- Tagging по языкам/темам как обязательное (а не опциональное)
- Inclusive tone (но более сухой — не "Hello, friend!")
- Markdown + code blocks как first-class

### Что НЕ берём
- Длинный формат как основной (мы для коротких постов)
- Эмоциональный приветственный onboarding

---

## 7. Hashnode

Похож на Dev.to, но с акцентом на personal blogs. Берём: ничего нового сверх Dev.to.

---

## 8. Polywork / Showwcase / Read.cv

### Что они пытались
- Заменить LinkedIn профилем-витриной достижений
- Tag-based activities ("shipped feature", "spoke at meetup")
- Visual portfolio формат

### Почему не взлетело
- Нет verification — любое achievement просто текст
- Нет network effect (нет сильного content loop)
- Recruiter не пришли — нечего искать

### Урок для нас
- **Профиль-витрина без верификации = красивая пустота**
- Нужен content loop (постинг → endorsement → score), иначе профиль мёртвый

---

## 9. Mastodon / Bluesky

### Что хорошо
- Хронологический feed by design
- Без алгоритма
- Дружелюбный tech-community

### Что плохо
- Фрагментация (Mastodon instances)
- Не для IT специально — общая social
- Нет skill verification

### Что берём
- Chronological feed (мы тоже так)

---

## Итог: что MVP Bable берёт

| Концепт | Откуда | Зачем |
|---------|--------|-------|
| Хронологический feed (no algo) | Twitter Following, Mastodon | Доверие, не engagement-loop |
| Weighted endorsement | Stack Overflow | Trust modelом |
| Per-topic reputation | Stack Overflow tag scores | Контекстный score |
| Complexity multiplier | LeetCode (easy/med/hard) | Качество > объём |
| Code blocks first-class | Dev.to | Минимальная адекватность для IT |
| Tagging обязательное | Dev.to + Stack Overflow | Discoverability + scoring |
| Recruiter view | LinkedIn (но переделать) | Без verification recruiter не придёт |
| Profile = доказательство | GitHub + Stack Overflow | Витрина без content = мёртвая |
| Open by default | GitHub, Twitter | Виральность hooks + indexing |

## Чего MVP Bable НЕ делает (намеренно)

| Anti-pattern | Источник | Почему отказ |
|--------------|----------|-------------|
| Алгоритмическая лента | Twitter, LinkedIn | Доверие важнее engagement |
| Реклама и premium-tier | LinkedIn | Это учебный проект, но даже коммерческое не должно |
| Bezмерные эндорсменты (one-click skills) | LinkedIn | Девальвация валюты |
| Стрики и daily-checkin | LeetCode, GitHub heatmap | Геймификация отпугнёт целевую аудиторию |
| Vanity metrics на видных местах | Twitter likes, GH stars | Score должен быть сложнее |
| Motivation/influencer контент | LinkedIn | Тон-нарушение |
| Anonymous voting | Reddit | Прозрачность важнее в trust model |
| Closed-by-community модерация | Stack Overflow | Слишком враждебно для роста |
