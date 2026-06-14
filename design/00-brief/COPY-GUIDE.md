# Copy Guide

> Как Bable разговаривает. Конкретные правила и шаблоны для всех текстов в UI.
> Если ты пишешь label, button, error, empty state, placeholder — этот файл — твой word source-of-truth.

---

## 1. Голос

**Bable пишет как технический документ, не как маркетолог.**

| Качество | Что значит |
|----------|----------|
| **Factual** | Описываем, что есть/произошло. Не интерпретируем эмоционально |
| **Concise** | Минимум слов. Каждое слово несёт смысл |
| **Direct** | Без обиняков. Без "we noticed", "perhaps", "kindly" |
| **Honest** | Если что-то не работает — говорим прямо. Не маскируем |
| **Neutral** | Не возбуждённый, не извиняющийся, не угодливый |

### Чек-лист тона

Перед тем как утвердить любой текст, проверь:

1. Есть ли восклицательный знак? → **убрать** (кроме редких исключений в коде)
2. Есть ли emoji? → **убрать** (только в user content)
3. Извиняемся ("Sorry", "Oops")? → **переписать** на нейтральное
4. Используем "we" / "you"? → **минимизировать** (часто можно без)
5. Длиннее 6 слов? → **попробовать сократить**
6. Звучит как маркетинговая фраза? → **переписать**

---

## 2. Buttons

### Правило: глагол-первый, императив

| ❌ Не так | ✅ Так |
|---------|------|
| "Click here to save" | "Save" |
| "Submit form" | "Post" |
| "Get started!" | "Sign up" |
| "OK" | (использовать конкретный глагол: "Save", "Delete", "Continue") |
| "Cancel posting" | "Cancel" |
| "✓ Done" | "Done" |

### Шаблон

```
[Verb]                 — primary actions
[Cancel] / [Back]      — secondary
```

### Длина

- **1–2 слова** для primary actions
- **Никогда не больше 4 слов** на кнопке

### Специфика Bable

| Действие | Label |
|----------|-------|
| Post a new post | **Post** |
| Edit existing post | **Edit** |
| Delete | **Delete** (в danger variant) |
| Endorse | **Endorse** (active state — "Endorsed") |
| Unendorse | (никогда не пишем "Unendorse" — клик на active toggles) |
| Reply | **Reply** |
| Follow user | **Follow** (active state — "Following") |
| Unfollow | (similar — click on "Following" → confirm dialog) |
| Save changes | **Save** (не "Save changes") |
| Cancel | **Cancel** |
| Confirm delete | **Delete** в red variant (button-danger) |

### Disabled / Loading states

```
[Post]            ← idle
[Posting…]        ← loading (verb + ing + ellipsis)
[Post]            ← back to idle, no "Posted!" replacement
```

---

## 3. Errors

### Структура ошибки

**Что произошло + что делать (action).**

| ❌ Не так | ✅ Так |
|---------|------|
| "Oops, something went wrong!" | "Couldn't save. Retry." |
| "Error: 500" | "Server is down. Try again in a minute." |
| "Invalid input" | "Username must be 3–30 characters." |
| "Network error :(" | "No internet. Reconnect to try." |
| "Failed to fetch" | "Couldn't load posts. Refresh." |

### Шаблоны

| Тип | Шаблон |
|-----|--------|
| Validation | "<Field> must be <constraint>." (e.g. "Password must be at least 8 characters.") |
| Auth | "Wrong email or password." (без "incorrect", без "invalid credentials") |
| Network | "No internet." / "Slow connection." |
| Server | "Server error. Try again." (без 5xx codes пользователю) |
| Conflict | "<Resource> is already taken." (e.g. "Username is already taken.") |
| Rate limit | "Too many tries. Wait <duration>." |

### Errors **не** должны:

- Извиняться (`Sorry`, `Apologies`)
- Возлагать вину на пользователя (`You did X wrong`)
- Использовать восклицания (`Oops!`)
- Скрывать причину (`Something went wrong`)
- Прокручиваться (errors should be visible immediately)

---

## 4. Empty states

### Структура

**Что есть (constatation) + что можно сделать (action, optional).**

| Context | Empty message |
|---------|--------------|
| Feed (new user) | "Follow people or topics to see posts here." |
| Feed (existing user, no posts from follows) | "No new posts. Discover more people." |
| Profile (other user, no posts) | "@<user> hasn't posted yet." |
| Profile (own, no posts) | "Write your first post." |
| Notifications | "Nothing new." |
| Search (no query) | (пусто, без message — placeholder сам сообщает) |
| Search (no results) | "No posts matching '<query>'." |
| Endorsement list (no endorses) | "Be the first to endorse." (если читатель залогинен) / "No endorsements yet." (для гостя) |

### Шаблон

```
[Icon, optional]
[Title]            ← h3
[Description]      ← body, secondary, опц. с CTA-link
[CTA button]       ← опц., если есть meaningful action
```

### Empty states **не** должны:

- Шутить или быть "cute"
- Иметь восклицания
- Извиняться
- Показывать иллюстрации, не связанные с UI (animated empty state — anti-editorial)

---

## 5. Placeholders

### Правила

- Placeholder — **подсказка о содержимом**, не label
- Никогда не дублирует label
- Короткий (1–3 слова)
- Заканчивается **без точки**

### Шаблоны Bable

| Field | Placeholder |
|-------|-------------|
| Compose post | "What did you figure out?" |
| Compose reply | "Reply to @<user>" |
| Search bar | "Search Bable" |
| Email field | "you@example.com" (пример формата) |
| Password | "8+ characters" (или пусто) |
| Username | "alice" (пример) |
| Display name | "Alice Smith" |
| Bio | "Short description (optional)" |
| URL field | "https://yourdomain.com" |

### Placeholder **не** должен:

- Содержать emoji (`What's on your mind? 🐦`)
- Быть рекламным (`Discover amazing tweets!`)
- Воскликательным (`Post something!`)

---

## 6. Labels

### Правила

- Title Case или sentence case? → **sentence case** ("Email address", не "Email Address")
- Capitalized первое слово, остальные lowercase (кроме proper nouns)
- Заканчивается **без двоеточия**
- Короткий (1–3 слова)

### Шаблоны Bable

| Field | Label |
|-------|-------|
| Email | "Email" |
| Password | "Password" |
| Username | "Username" |
| Display name | "Display name" |
| Bio | "Bio" |
| Topic / Tag | "Topic" (не "Topic tag") |
| Complexity | "Complexity" |
| Post type | "Type" |
| Availability | "Availability" |

---

## 7. Success messages

В Bable success messages **редки**. Действие → silent success в большинстве случаев (optimistic UI).

| Context | Сообщение или нет? |
|---------|-------------------|
| Post created | Silent (пост появляется в feed) |
| Endorsement added | Silent (icon switches) |
| Profile saved | Silent + toast "Saved." (если в формальном settings page) |
| Password changed | Toast "Password updated." |
| Email verified | Toast "Email verified." |
| Account deleted | Redirect to logout + page "Account deleted." |

### Если показываем toast — шаблон

```
[Verb in past tense] + [optional context].

Examples:
"Saved."
"Password updated."
"Email verified."
"Profile changed."
```

### Никогда не пишем

- "Success! 🎉"
- "Awesome! Your profile is saved."
- "Great job!"
- "You're all set!"

---

## 8. Confirmation dialogs

Confirm dialog нужен **только** для необратимых действий:
- Delete post
- Delete account
- Unfollow user (только если у нас friction-mode, в MVP — без confirm для unfollow)

### Шаблон

```
[Question short, 3–6 words]
[Description, 1 sentence, что произойдёт]

[Cancel]   [Verb (red)]
```

### Примеры

| Action | Question | Description | Confirm |
|--------|----------|-------------|---------|
| Delete post | "Delete this post?" | "This can't be undone." | "Delete" (danger) |
| Delete account | "Delete your account?" | "All your posts and endorsements stay public, but unattributed. This can't be undone." | "Delete account" (danger) |

### Дефолтная фокусная кнопка — **Cancel**

В confirm dialog при открытии focused — Cancel, не destructive action. Защита от случайного Enter.

---

## 9. Specific Bable copy

### Name / username

- `@vlad` (всегда lowercase в handle, без пробелов, max 30 chars)
- Display name — как написал пользователь (e.g. "Vlad Iliev")

### Numbers и подписи

| Number | Singular | Plural | Empty |
|--------|----------|--------|-------|
| 0 | — | "No endorsements" | "Be the first" |
| 1 | "1 endorsement" | — | — |
| 2+ | — | "<N> endorsements" | — |

Same patterns:
- "<N> reply" / "<N> replies"
- "<N> follower" / "<N> followers"
- "<N> following"

### Score representation

| Context | Format |
|---------|--------|
| Profile header | "Rust 720" — topic первым, число вторым, **без других labels** |
| Inline в feed | "Rust 720" same |
| Search filter | "Rust ≥ 700" (use ≥ symbol) |
| Score explanation | "Built from <N> endorsements on <M> posts." |

### Timestamps

| Age | Format |
|-----|--------|
| < 60 seconds | "Just now" |
| 1–59 minutes | "<N>m" |
| 1–23 hours | "<N>h" |
| 1–6 days | "<N>d" |
| Last week–year | "Jun 12" (day, abbreviated month) |
| Older than year | "Jun 12, 2024" |

В post detail и hover — полный datetime: "June 12, 2026 at 14:22".

---

## 10. Forbidden phrases (полный banlist)

Не использовать **никогда**:

| ❌ Phrase | Why |
|-----------|-----|
| "Awesome" | Маркетинговое |
| "Amazing" | Маркетинговое |
| "Oops" | Дешёвое извинение |
| "Sorry, …" | (как извинение от UI) |
| "Hi there!" | Sales-стиль |
| "Welcome back, hero!" | Никаких "hero" |
| "Discover amazing…" | Marketing fluff |
| "Get started!" | Marketing fluff |
| "Sign up — it's free!" | Cringe |
| "Loading…" alone | (всегда контекстный: "Loading posts…", "Posting…") |
| "Click here" | Anti-UX |
| "Please wait" | Просьба не нужна |
| "Done!" / "Success!" | Восклицания |
| "We've sent you…" | "We" — antropomorphizing |
| "Couldn't find that page :(" | Эмодзи + ASCII |
| "Something went wrong" | Не описывает что |
| Любые `:)`, `:(`, `:D` | Ascii-emoticons |

---

## 11. Cheatsheet

- **Buttons** = глагол императив
- **Errors** = факт + действие
- **Empty** = факт + (опц.) действие
- **Placeholders** = подсказка о содержимом, без точки
- **Labels** = sentence case, короткие
- **Success** = silent или factual past tense
- **Confirm** = вопрос + последствие + default focus на Cancel
- **Score** = "Topic Number" (e.g. "Rust 720")
- **Timestamp** = относительное → абсолютное после недели
- **Никогда:** emoji в UI, восклицания, извинения, маркетинг
