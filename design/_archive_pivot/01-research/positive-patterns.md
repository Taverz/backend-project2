# Positive Patterns

> Обратная сторона `anti-patterns.md`. Это **позитивные правила**, которые должны быть выполнены на каждом экране.
> Anti-patterns говорят "не делай так". Positive patterns говорят "делай вот так".
> Каждый экран проверяется по обоим спискам.

---

## Категория 1: Signal-first design

### PP-1.1 — Каждое число объяснимо
- Score `Rust 720` → клик → explanation page
- Endorsement count `14` → клик → list with endorsers + их scores
- **Test:** покажи UI новичку, спроси "что значит каждое число?" — должен ответить за 10 сек

### PP-1.2 — Score контекстен
- Никогда не показываем "Score 720", только "Rust 720"
- В feed/profile видны топ-3 темы пользователя
- **Test:** Vlad смотрит на профиль — за 5 сек видит, в чём этот человек силён

### PP-1.3 — Endorser идентичность видна
- Под каждым endorsement видно: avatar + username + score эндорсящего по этой теме
- Никаких "12 likes" без раскрытия
- **Test:** Marina не доверяет числу — она доверяет именам и их Scores

---

## Категория 2: Quiet UI

### PP-2.1 — Иконки линейные, монохромные
- Lucide / SF Symbols / Material Outlined
- Никаких 3D / gradient / emoji в UI chrome
- Color только для status (error red, success green) и primary actions
- **Test:** скриншот в grayscale — UI не теряет читаемость

### PP-2.2 — Тип-driven design
- Hierarchy через шрифт (size + weight), не через цвет / box / shadow
- Card border 1px, не shadows
- **Test:** видим UI — глаз сначала идёт к контенту, потом к chrome

### PP-2.3 — Одна акцент-color
- Brand color используется только для **одного** primary action на экране
- Не для links + buttons + icons + highlights одновременно
- **Test:** считаем accent-color spots на экране — должно быть ≤ 3

---

## Категория 3: Frictionless contribution

### PP-3.1 — Compose доступен с любого экрана
- Keyboard shortcut (Cmd/Ctrl+N) или FAB или composer-в-feed
- Без перехода на отдельный route в idle case
- **Test:** Marina залогинилась, видит идею — сколько кликов до compose? Должно быть 1.

### PP-3.2 — Compose минималистичен
- 1 текстовое поле, 1 toggle "code block", 1 dropdown темы, 1 dropdown сложности
- Без preview/draft/scheduling в первый паш
- **Test:** showcompose новичку — он понимает, что сделать, без объяснений

### PP-3.3 — Опубликованный пост сразу видим
- Optimistic UI: пост появляется в feed мгновенно
- Если ошибка — пост остаётся (отметка "retry"), не пропадает
- **Test:** Marina postит, scroll вверх — видит свой post первым

---

## Категория 4: Reading experience

### PP-4.1 — Code blocks first-class
- Подсветка синтаксиса 15+ языков (через Tree-sitter / Shiki)
- Copy button на code block
- Поддержка inline `code` через backticks
- **Test:** Vlad копирует snippet из поста — сработало с 1-го клика

### PP-4.2 — Plain text без активного "украшения"
- Не превращаем `#tag` в hyperlinks внутри body — только в metadata
- Не парсим markdown за пределами code blocks (MVP)
- **Test:** что написал юзер — то и показывается, без сюрпризов

### PP-4.3 — Hierarchy в посте
- Author + meta компактно сверху
- Body — центральный элемент, наибольший шрифт
- Actions — внизу, secondary visual weight
- **Test:** скан поста за 1 сек — глаз идёт по author → body → actions

---

## Категория 5: Discoverability

### PP-5.1 — Search обнаружим (видимая кнопка / bottom tab)
- Не зарытая в menu
- Recruiter mode = search-first UI
- **Test:** Anna открывает Bable — на главном экране есть путь к search ≤ 1 клик

### PP-5.2 — Tags / topics как обязательные
- Compose не даёт publish без topic-tag
- Каждый пост связан с темой (по которой выводится Score)
- **Test:** Marina пишет пост — UI заставляет выбрать тему до publish

### PP-5.3 — Profile открывается по shareable URL
- `bable.io/u/marina` (или `bable.io/marina`)
- OG card с avatar + top scores + bio при шеринге
- Без auth wall
- **Test:** копируешь URL — открывается в incognito без login

---

## Категория 6: Trust signals

### PP-6.1 — Каждое action имеет undo
- Endorse → 5 сек undo toast
- Post → edit window 5 минут после publish
- Delete → confirm modal (необратимая операция)
- **Test:** Marina случайно тыкнула endorse — может отменить

### PP-6.2 — Errors объяснимы и actionable
- "Couldn't save. Network error. [Retry]" (объясняем + action)
- Не "Oh no, something went wrong" (нет action)
- Не "Error: 503" (не объяснено)
- **Test:** error в UI — пользователь знает, что делать дальше

### PP-6.3 — Никаких dark patterns
- Confirm dialog с двумя кнопками — обе одинакового размера, цвет различает action (red — destructive)
- Никаких "Cancel" заголовков на confirm
- Никаких "Continue with ads" толстым + "No thanks" мелким
- **Test:** confirm dialog — оба варианта одинаково доступны

---

## Категория 7: Performance perception

### PP-7.1 — Skeleton, не spinner
- Showing structure beats showing wait
- Skeleton имитирует layout content (avatar + 2 lines + actions)
- **Test:** при loading юзер видит, **что** будет, а не "ждёт"

### PP-7.2 — Optimistic updates на всё
- Endorse → mgновенный feedback (icon switch)
- Post → мгновенное добавление в feed
- Follow → instant button state change
- **Test:** action → 0ms visual response

### PP-7.3 — Lazy load images
- Avatar 48px = 96px source max
- Не загружаем avatar'ы вне viewport
- **Test:** mobile data scroll feed — < 100kb на screen

---

## Категория 8: Honest communication

### PP-8.1 — Tone neutral, factual
- "Posted." not "Awesome! 🎉"
- "No results" not "Oops, nothing here :("
- "Logged out" not "See you soon, hero!"
- **Test:** прочитай UI вслух — звучит как тех-документация

### PP-8.2 — Honesty в empty states
- "No tweets yet. Follow someone or write your first post."
- Не "Discover amazing tweets!" (когда их нет)
- **Test:** empty state — описывает реальную ситуацию, предлагает реальное действие

### PP-8.3 — Visible status of background ops
- Indexing — "Posting..." видно до confirm
- Pending endorsement during network blip — "Endorsing..."
- Sync issues — "Connection slow. Trying..."
- **Test:** Marina не должна не понимать состояние своего action

---

## Категория 9: Recruiter-developer mutual respect

### PP-9.1 — Outreach UI требует context
- При outreach обязательное поле "Reference to candidate's post / score"
- Нельзя написать без ссылки на конкретный signal
- **Test:** Anna хочет написать Marina — UI требует указать, какой её пост / score побудил написать

### PP-9.2 — Public response rate recruiter'а
- В профиле recruiter'а: "Response rate 47% (last 30 days)"
- Кандидат видит, прежде чем читать outreach
- **Test:** Marina получила outreach от Anna — открыла её профиль, увидела response rate

### PP-9.3 — Cooldown между outreach к одному кандидату
- Recruiter не может писать одному человеку чаще 1 раза в 30 дней
- **Test:** Maxim пытается шлёпать шаблоны — система блокирует

---

## Категория 10: Onboarding (когда сделаем)

### PP-10.1 — Onboarding короткий
- ≤ 4 шага: email + username + 1-3 topic'а интересов + первый импорт follow'ов
- Без skill-self-assessment quiz (Score выводится из контента)
- **Test:** новый юзер → 60 секунд → готов читать feed

### PP-10.2 — Без force "make your first post"
- Lurker имеет право lurkать
- Подсказка про compose через 7 дней, если 0 постов (раз, без давления)
- **Test:** Anna читает 2 недели без постинга — Bable не давит уведомлениями

### PP-10.3 — Empty feed решён cohort-style
- При регистрации с 0 follow'ов — feed показывает top posts последней недели в выбранных topic'ах
- Не показываем "Welcome! Follow people!" — показываем контент
- **Test:** новый юзер сразу видит реальный контент, не туториал

---

## Чек-лист для каждого экрана

При работе над любым экраном — пройти по 30 PP пунктам выше. Если ≥ 1 нарушен → переделываем.

Грубо:
1. Числа объяснимы? (PP-1.1, 1.2)
2. Endorsement идентичность видна? (PP-1.3)
3. Иконки линейные, без emoji в chrome? (PP-2.1)
4. Hierarchy через типографику, не через цвет? (PP-2.2)
5. Compose доступен в 1 клик? (PP-3.1)
6. Optimistic updates? (PP-3.3, 7.2)
7. Code blocks работают? (PP-4.1)
8. Tags обязательные? (PP-5.2)
9. URL shareable? (PP-5.3)
10. Errors объяснимы и actionable? (PP-6.2)
11. Skeleton вместо spinner? (PP-7.1)
12. Tone neutral? (PP-8.1)
13. Outreach с context (если recruiter)? (PP-9.1)
