# Chirp Docs — критический анализ

> Чего не хватает, что можно улучшить, что лишнее.

---

## 1. Что пропущено: widget states

Да, UI-состояния экранов есть. Но **компоненты** (Button, InputField, TweetCard) — нет.
А у них свои состояния, которые должны быть одинаковы на всех платформах:

**Button:** enabled, disabled, loading (spinner), with-icon, full-width
**InputField:** default, focused, filled, error, disabled, with-counter
**TweetCard:** default, liked, with-image, loading (skeleton), error
**Avatar:** with-image, initials-fallback, loading, offline

Это надо добавить.

**Следствие:** без этого AI на каждой платформе реализует кнопки по-разному.
На Flutter будет `ElevatedButton`, на iOS — свой кастом, на Web — `<button>` с Tailwind.
А визуально они должны быть одинаковы.

---

## 2. Чего не хватает в документации (глобально)

### 2.1. Error recovery / Retry patterns

Сейчас ошибки описаны (ERRORS.md), но **что делать после ошибки** — нет.

| Сценарий | Что описано | Чего не хватает |
|----------|------------|----------------|
| Твит создан, но 500 при fan-out | — | Fan-out упал → твит создан, но не в ленте подписчиков. Retry? Откат? |
| Пользователь лайкнул, 500 | — | Лайк не сохранился. Показать ошибку? Убрать лайк из UI? |
| Сетевой таймаут при создании твита | — | Твит мог создаться на сервере. Retry → 409? |

**Решение:** для каждой мутации описать recovery strategy.

### 2.2. Optimistic updates

Сейчас все запросы — request → wait → response → update UI.
Для Like и Follow это слишком медленно.

**Пример:** пользователь tap Like → сердечко должно закраситься **мгновенно**,
а запрос идёт в фоне. Если запрос упал — вернуть как было.

В документации нет ни слова про optimistic updates. Нигде.

### 2.3. Race conditions (кроме auth)

Race condition для auth описан (3 параллельных 401 → 1 refresh).
Но есть другие:

- **Double tap Follow:** пользователь быстро тыкнул 2 раза → 2 POST /follow
  Решение: disable кнопку после первого tap
- **Like → refresh → like:** пользователь лайкнул, pull-to-refresh,
  лайк исчез (потому что данные с сервера перезаписали UI)
  Решение: merge server data with local state
- **Create tweet → network error → retry:** если backend создал твит,
  а клиент не получил ответ → retry создаст дубликат
  Решение: idempotency key

### 2.4. Offline mode

Ничего не сказано про офлайн. А надо бы:

| Connectivity | Что можно делать |
|-------------|----------------|
| Online | Всё |
| Offline (no internet) | Просматривать закешированную ленту |
| Offline (no internet) | Нельзя создать твит (показать "No internet") |
| Offline → Online | Авто-рефреш ленты |

### 2.5. Image loading states

Твиты с картинками (будущее) — нужны состояния:

```
Image.loading() → skeleton placeholder
Image.loaded()  → показать картинку
Image.error()   → fallback иконка + retry
```

### 2.6. Push notifications

Когда backend отправляет уведомление, клиент должен:
1. Получить push (FCM / APNs)
2. Показать notification в system tray
3. При tap → открыть нужный экран (/tweet/{id} или /user/{id})

Этого нет нигде в документации.

### 2.7. Deep linking

Ссылки типа `chirp://tweet/{id}` или `https://chirp.app/tweet/{id}`:
- Из push notification → открыть TweetDetailScreen
- Из браузера → открыть Web версию

---

## 3. Организационные проблемы

### 3.1. Документы-примеры vs реальные документы

`docs/examples/follow-timeline/` — это примеры flow.
`docs/shared/auth-flow/` — это реальная документация фичи.

Но follow-timeline — существующая фича. Почему её docs не в `shared/`?
Несоответствие: auth-flow в shared/, а follow-timeline в examples/.

**Надо:** либо перенести follow-timeline в shared/ с тем же форматом (7 файлов),
либо признать examples/ устаревшими.

### 3.2. Нет cross-reference между файлами

DESIGN-SYSTEM.md определяет `primary = #1DA1F2`.
DESIGN-CONTRACT.md ссылается на DESIGN-SYSTEM.md — это хорошо.
Но ERRORS.md не ссылается на Design System, API.md не ссылается на ERRORS.md.

**Надо:** в каждом файле в начале список связанных файлов.

### 3.3. Нет версионирования

API изменился? Надо обновить API.md, ERRORS.md, FEATURES.md, flow-документы.
Как узнать, что всё обновил? Нет чеклиста.

**Решение:** добавить в SOUL.md секцию "Last updated" для каждого shared-файла.

### 3.4. Нет review checklist для самих доков

Код ревьюим. А доки? Кто проверяет, что после изменения API.md
обновились все flow-документы?

---

## 4. Структура auth-flow — что ещё можно добавить

Сейчас 7 файлов. Если довести до идеала:

| # | Файл | Сейчас | Нужно |
|---|------|--------|-------|
| 1 | 01-REQUIREMENTS.md | ✅ | — |
| 2 | 02-SPEC.md | ✅ | — |
| 3 | 03-ARCHITECTURE.md | ✅ | + sequence для register + refresh |
| 4 | 04-PATTERNS.md | ✅ | + offline pattern, + optimistic update pattern |
| 5 | 05-VERIFICATION.md | ✅ | — |
| 6 | 06-UI-STATES.md | ✅ | Экранные состояния есть |
| 7 | 07-TEST-CASES.md | ✅ | + тесты на offline, + тесты на race conditions |
| 8 | — | ❌ | **Widget states** (Button, InputField, Avatar) |

---

## 5. Итог: что реально сделать

Из всего этого **самое нужное** (по убыванию):

1. **Widget states** — Button, InputField, TweetCard, Avatar — состояния для каждой платформы
2. **Optimistic update pattern** для Like и Follow — в PATTERNS.md
3. **Error recovery** для мутаций — в ERRORS.md

Остальное (offline, push, deep linking) — полезно, но не критично для MVP.

Хочешь, добавлю widget states прямо сейчас?
