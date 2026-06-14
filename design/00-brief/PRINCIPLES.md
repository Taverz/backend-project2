# Bable Principles

> Расширенные принципы продукта. Каждый принцип = одно правило + пример "так" и "не так".
> Это фильтр для каждого UX-решения. Если что-то не соответствует — переделываем.

---

## 1. Tone of voice (как Bable разговаривает)

### Принцип
Bable пишет как технический документ, не как маркетолог. Точно, кратко, без эмоций. Восклицательные знаки только в коде пользователя, не в UI.

### Как это звучит

**Так (Bable):**
- `Posted.`
- `Couldn't save. Retry.`
- `No posts yet.`
- `What did you figure out?`
- `Endorsed by 14 people, including 3 with React ≥ 700.`

**Не так (LinkedIn / Twitter):**
- `Awesome! 🎉 Your post is live!`
- `Oh no, something went wrong 😢`
- `Welcome back, hero! Ready to inspire today?`
- `What's on your mind?`
- `❤️ 247 people loved this!`

### Правила
- Восклицания → точки
- Эмодзи в UI → отсутствуют (контент пользователя — на его вкус)
- Сленг → отсутствует
- Объяснения "почему" в errors > "вежливые" overlays
- Тебя не зовут "hero", "ninja", "rockstar" — тебя зовут по username

### Test
Прочитай вслух любой текст в UI. Если звучит как речь продавца — переделай.

---

## 2. Accessibility (a11y)

### Принцип
Доступность — не feature, а минимум. WCAG 2.2 AA в MVP, AAA где не противоречит density.

### Конкретно

| Аспект | Стандарт |
|--------|----------|
| Контраст body text | ≥ 7:1 (AAA) на dark + light |
| Контраст secondary text | ≥ 4.5:1 (AA) |
| Контраст interactive elements | ≥ 3:1 для границ/иконок |
| Touch targets | ≥ 44×44pt (Apple HIG), 48×48dp (Android) |
| Keyboard navigation | Все действия достижимы клавиатурой (web) |
| Focus indicators | Видимые, не убираются `outline: none` |
| Screen reader | Все iconography имеет accessible label |
| Motion | `prefers-reduced-motion` отключает все ненужные анимации |
| Cognitive | Нет flashing/blinking. Время на действие не ограничено (кроме session timeout) |
| Code blocks | Подсветка не единственный сигнал — синтаксис читается без цвета (грейскейл-тест) |

### Test
- Скриншот любого экрана в grayscale → информация понятна?
- Tab-навигация на web → можно дойти до любого действия?
- VoiceOver / TalkBack произносит экран осмысленно?

---

## 3. Privacy & Data

### Принцип
Минимум сбора данных. Максимум прозрачности о том, что собираем. Пользователь — не товар.

### Что собираем
- Email (для логина и нотификаций)
- Username (публично)
- Содержимое постов (публично по умолчанию)
- Endorsement actions (публично)
- IP / device для security / rate-limiting (хранится 30 дней)

### Что **НЕ** собираем
- Адресная книга
- Местоположение
- Behavior tracking на сторонних сайтах
- Persistent fingerprinting
- "What you read but didn't post" — нет analytics на reading patterns

### Прозрачность
- В settings → "Your data" — показывает всё, что мы знаем о пользователе
- Экспорт всех данных в JSON по запросу
- Удаление аккаунта = удаление content + аноним для endorsements (не каскадим, иначе чужой score просядет)

### Реклама
- Нет рекламы в MVP
- Если когда-нибудь — то не таргетированная по поведению, только по contextual (tag = react → реклама React-курса)

---

## 4. Content Moderation

### Принцип
Bable — про техническую экспертность, не про общение в общем смысле. Поэтому модерация ориентирована на качество контента и анти-токсичность.

### Правила контента
- **Топик-релевантность.** Пост без технических тегов — допустим, но не индексируется в search. Пост, маркированный `rust`, но про политику — flag/remove.
- **Без harassment.** Атака на личность, не на код / тезис — ban (повторно — permanent).
- **Без NSFW.** Bable — рабочий tool. Сделано осознанно: visible NSFW = неудобно открыть на работе.
- **Без AI-spam.** Поток сгенерированного GPT'ом контента "tips for React" обнуляется. Сложно автоматизировать, но baseline через rate-limit и репутацию.

### Механика модерации (MVP)
- Self-moderation через **flag** на пост / профиль
- Высокая репутация по теме = больший вес в flagging (как endorsement, но в обратную сторону)
- Модератор-человек разбирает spike flags (в MVP — основатель)
- Никаких "community closes by vote" в Stack Overflow стиле — слишком враждебно

### Что важно для UX
- Flag-кнопка должна быть видна, но не навязчива (… menu в посте)
- После flag — короткий confirm "Thanks. We'll review."
- Не показываем banned контент с "[REMOVED]" — просто исчезает
- Banned users не видны в search, но их посты остаются (если не отдельно зафлажены)

---

## 5. Performance

### Принцип
Tech-аудитория замечает задержки. Bable должен быть быстрее, чем Twitter / LinkedIn. Это конкурентное преимущество.

### Budget (mobile, average device)

| Метрика | Target | Hard limit |
|---------|--------|-----------|
| Cold start to interactive | < 1.5s | 3s |
| Feed first paint | < 800ms | 2s |
| Compose → Post → Confirm | < 500ms | 1s |
| Like / Endorse → visual response | < 50ms (optimistic) | — |
| Search keystroke → results | < 300ms (debounced) | 800ms |
| Profile load | < 800ms | 2s |

### Правила дизайна
- **Optimistic UI на каждое действие** (endorse, follow, post). Сетевые задержки скрыты.
- **Skeleton, не spinner.** Пользователь видит структуру, пока грузятся данные.
- **Image lazy-load + размер.** Avatar 48px = max 96px источник, не 2048.
- **Анимации ≤ 200ms.** Кроме редких "оправданных" (например, like burst — 350ms).
- **Нет blocking modals на старте.** Splash → home, разрешения позже в контексте.

### Anti-pattern: "загрузка ради красоты"
Не загружаем намеренно медленно, чтобы показать loader. Каждый ms задержки — потерянное доверие.

---

## 6. Density vs Air

### Принцип
Bable — плотный UI. Density как у Linear / HN. Не Apple Health, не Airbnb.

### Конкретно
- Spacing scale: 4 / 8 / 12 / 16 / 24 (не 8 / 16 / 24 / 32 / 48)
- Padding на TweetCard: 12px vertical (не 24)
- Список постов на экран mobile: 4-5 (не 2-3 с big art)
- Заголовки h1: 24px (не 36)

### Когда воздух нужен
- Пустые состояния (empty / error) — центрируем, оставляем воздух
- Onboarding — единичный, важный момент
- Composer — фокус, минимум вокруг

### Test
Сравни любой экран с Twitter / Linear / Vercel:
- Если ближе к Twitter (free space) — переделай плотнее
- Если ближе к Linear (плотно) — ок

---

## 7. Trust by transparency

### Принцип
Каждое число в UI должно быть **кликабельно и объяснимо**. Никаких "magical" метрик.

### Применение
- Score `React 720` → клик → показывает: кем эндорсили, какие посты, формула в человеческом языке
- Endorsement count `14` → клик → список людей с их Scores
- "Recommended for you" — не используем (см. anti-pattern про алгоритм)
- "Trending" — если когда-то будет, только по объективному signal'у (objective endorsements per hour), с explanation page

### Test
Покажи UI новому пользователю. Спроси: "что значит каждое число на экране?" Если не могут ответить за 10 секунд — UI не объясняет.

---

## 8. Mobile-first, but not mobile-only

### Принцип
Primary platform — Flutter Mobile. Web позже. Но дизайн-система должна работать на обеих сразу.

### Правила
- Все компоненты тестируются на mobile-viewport первыми
- Hover-стейты — только дополнение, основная логика без них
- Recruiter view — изначально продумываем на desktop, но MVP можно только mobile
- Tokens (spacing, colors, type) — одинаковые на mobile и web

---

## 9. Internationalization

### Принцип
MVP — English only. Архитектура готова к i18n с первого дня.

### Конкретно
- Все строки в UI — через i18n keys (`auth.login.title`, не "Log in")
- Даты, числа — через locale-aware formatters
- RTL не поддерживается в MVP, но структура layout позволит включить
- Дополнительные языки — после MVP, начиная с русского и испанского

### Что **не** делаем в MVP
- Machine translation постов
- Локализованный feed (показываем все языки, фильтруем тегами)

---

## 10. AI as collaborator, not generator

### Принцип
AI помогает строить продукт (генерирует экраны по нашим правилам). AI **не** заменяет product thinking.

### Применение в нашем процессе
- AI читает все documents в `design/` для контекста
- AI не выдумывает компоненты — использует только те, что в `design-system/`
- AI не предлагает фичи в `out of scope MVP` (см. brief)
- При генерации экрана AI указывает, какие правила/токены применил

### Test
Сгенерированный AI экран должен пройти 7-й принцип: каждое число на нём объяснимо со ссылкой на конкретное правило в `design/`.

---

## Itog

10 принципов — это минимум, который покрывает дыры. Если что-то не покрыто:
- **Безопасность контента → §4**
- **Доступность → §2**
- **Голос интерфейса → §1**
- **Производительность → §5**
- **Дизайн-плотность → §6**
- **Прозрачность метрик → §7**

Каждое design / code решение проверяется по этим 10 пунктам. Если хоть один нарушен — переделываем.
