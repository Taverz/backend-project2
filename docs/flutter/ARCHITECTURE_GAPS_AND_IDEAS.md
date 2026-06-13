# Архитектурные пробелы и идеи

Сводный документ. Состоит из трёх частей:

1. **Часть I.** Реальные проблемы работы с API, которых нет в `app_api/docs/DEVELOPMENT.md` — критика собственной доки.
2. **Часть II.** Слепые зоны в четырёх архитектурных принципах (API-независимость, mock-first, UI вне приложения, per-package линтеры).
3. **Часть III.** Свежие идеи для упрощения работы команды (не повторяет I и II).

В конце — приоритизация что делать первым.

---

# Часть I. Проблемы работы с API, не упомянутые в `DEVELOPMENT.md`

Гайд был написан в духе «happy-path для нового кода». 80% времени разработчик не добавляет endpoints, а разбирается почему всё ломается. Этих сценариев в доке нет.

## 1. Расхождение swagger ↔ фикстура ↔ DTO в main не ловится

**Сценарий:** разработчик добавил поле `bio` в `UserResponseDto`, обновил mapper, прогнал тесты — всё зелёное. Но фикстуру `me_response.json` забыл обновить и swagger не тронул. В main проходит PR, в котором три источника контракта расходятся между собой. Тесты этого не показывают, потому что DTO работает на той фикстуре, которая есть.

**Что в доке не сказано:** есть только «расхождение обычно ловится тестом маппера». Это не так — тест ловит только сторону «фикстура → DTO», а не «DTO ↔ swagger».

**Решение:**
- Контракт-тест: парсит `backend/docs/swagger.json` и проверяет что у `UserResponseDto` все required-поля swagger есть. Файл `test/contract/user_dto_contract_test.dart`.
- В CI шаг: `dart run packages/app_api/tool/refresh_fixtures.dart` + проверка что `git diff fixtures/` пустой. Если не пустой — кто-то правил DTO, не прогнав фикстуры.

## 2. Версионирование API не обсуждается вообще

**Сценарий:** бэкенд выкатил `/api/v2/timeline` с другим форматом. Клиенту нужно поддерживать обе версии.

**Что в коде сейчас:** `/api/v1/auth/login` хардкодом в `AuthRemoteDataSourceDioImpl`. Версия размазана по строкам.

**Решение:**
```dart
abstract final class Endpoints {
  static const _v1 = '/api/v1';

  static const loginV1 = '$_v1/auth/login';
  static const timelineV1 = '$_v1/timeline';
}
```
Когда бэкенд опубликует v2 — заводится `AuthRemoteDataSourceV2`, отдельный DTO `AuthResponseDtoV2`. Старая v1 живёт пока её зовут. **Никогда не «обновлять v1 чтобы он стал v2».**

## 3. Schema evolution: опциональные / новые поля → краш

**Сценарий:** добавили в `register_response.json` поле `welcome_message`. Старый клиент с `final welcomeMessage = json['welcome_message'] as String` сломается на проде после того как бэк выкатит, а клиент не обновится.

В нашем коде сейчас везде `as String` без nullable. Это бомба замедленного действия.

**Решение:**
- **Правило:** новые поля приходят как nullable в Dart (`json['x'] as String?`). Через несколько релизов — переводятся в required.
- **Тест:** для каждого `*ResponseDto` — тест на «минимальный JSON» (только required-поля).

## 4. Mock-режим всегда happy-path — error-state'ы недоступны вне unit-тестов

**Сценарий:** дизайнер хочет посмотреть как выглядит экран при `401`. В `--dart-define=USE_MOCK_API=true` это сделать нельзя — Mock возвращает фикстуру всегда.

**Решение:** глобальный `MockScenario`-enum для всего mock-клиента:
```dart
enum MockScenario { happy, authInvalid, networkDown, server500 }
```
Включается через `--dart-define=MOCK_SCENARIO=auth_invalid`. Каждый Mock-DataSource смотрит на этот глобальный enum.

## 5. Файловые загрузки (multipart) пропущены полностью

**Сценарий:** добавляем аватар. `POST /api/v1/users/me/avatar` с `multipart/form-data`. Наш паттерн `RequestDto.toJson()` сюда не ложится.

**Решение, которое надо документировать:**
- `UploadAvatarRequest` — это не DTO с `toJson`, а отдельный класс с `File path` / `Uint8List bytes`.
- В DataSource: метод `uploadAvatar(File file)` принимает file, внутри собирает `FormData` от Dio.
- В фикстурах: пример response + текст с описанием формата request (multipart нельзя сериализовать в JSON).

## 6. Отмена запросов (cancel) при уходе с экрана

**Сценарий:** поиск с debounce. Пользователь набрал «foo», за 300мс ничего, набрал «bar». Запрос «foo» уже летит. Через 800мс приходит ответ на «foo» и перезатирает результат для «bar».

**Решение:**
- Опциональный `CancelToken?` в методах DataSource.
- В UseCase / Bloc — хранить ссылку на текущий токен, отменять при новом запросе.

## 7. Безопасность: токены в логах

**Сценарий:** debug-сборка с `LoggerInterceptor`. Кто-то скинул скриншот логов в Slack — там `Authorization: Bearer eyJhbGc...` с валидным токеном.

**Решение:** в `LoggerInterceptor` явная маскировка sensitive headers (`Authorization → Bearer ***`). Правило: «Любой новый header с секретом — в `_redactedHeaders`».

## 8. Идемпотентность мутаций

**Сценарий:** пользователь дважды быстро тапнул «Опубликовать твит». Bloc-guard отлавливает в большинстве случаев, но не всегда (две кнопки на разных экранах) — два твита.

**Решение:**
- Клиент генерирует `Idempotency-Key` (UUID), кладёт в header.
- Бэк хранит ключ N минут, при повторе возвращает кеш.
- Контракт с бэкендом — должен быть в swagger.

## 9. Кэш и реактивная синхронизация shared-сущностей

`app_api` не кэширует. Это должно быть **явно** в доке: «Кэш — на стороне фичи, в `Store` data-слоя владельца». Без этого кто-то попытается засунуть кэш в `AppApiClient`.

## 10. Multi-environment (dev / staging / prod)

Сейчас разрозненные dart-define флаги (`API_URL`, `SENTRY_DSN`, `USE_MOCK_API`, `MOCK_SCENARIO`). Растёт — болит.

**Решение:**
```dart
enum AppEnv { dev, staging, prod }
class AppConfig {
  AppConfig({required this.env, required this.apiUrl, required this.sentryDsn, required this.useMockApi});
  factory AppConfig.fromEnv() { /* читает все dart-define */ }
}
```

---

# Часть II. Слепые зоны в четырёх архитектурных принципах

## A. «API независим от бэка, контракт через swagger»

### A1. Контракт без процесса согласования

`refresh_fixtures.dart` имплицитно делает бэк ведущим: «что бэк отдал, то и зафиксировали». Если фронту нужно новое поле — он должен сначала договориться с бэком. Этого процесса в доке нет.

**Решение:** API change request как git-process. Любое изменение swagger — PR с двумя ревьюерами (бэк + фронт), с приложением «как меняется DTO, как меняются фикстуры».

### A2. Дрейф контракта в проде

Бэк выкатил `bio` теперь nullable вместо required — фронт не знает. Mock зелёный, прод крашится через две недели.

**Решение:** Contract-test в CI: парсит свежий `swagger.json` (через git submodule или http GET с бэка), сверяет с DTO.

### A3. Swagger в monorepo с бэком — «независимость» декларируется

Сейчас `backend/docs/swagger.json` рядом. Когда бэк отделится — нужен git submodule или импорт по URL с CI бэка.

**Решение:** уже сейчас обращаться к swagger через переменную `SWAGGER_PATH` (по умолчанию `../../backend/docs/swagger.json`, в CI можно подменить на URL).

### A4. REST-контракт ≠ полный контракт

Уведомления → WebSocket/SSE → swagger их не описывает. `AsyncAPI` — другой стандарт.

**Решение:** в app_api предусмотреть слой `lib/src/realtime/` (interface-only пока): `NotificationsStream`, mock-impl через `StreamController`, реальная impl — WebSocket-клиент.

## B. «Mock-first, проверка любым человеком»

### B1. Mock-сборка — как её получит дизайнер/QA/PM?

«Любой человек может запустить» — но не каждый умеет `flutter run --dart-define=...`. Pipeline дистрибуции mock-сборки нет.

**Решение:** три канала:
- **Web:** `flutter build web --dart-define=USE_MOCK_API=true` → GitHub Pages / Vercel. Auto-deploy на каждый merge в `main`.
- **Android:** Firebase App Distribution.
- **iOS:** TestFlight.

### B2. Mock-данные плоские — не показывают edge-case'ы

Один пользователь, нормальный email. Дизайнер не видит длинных строк, эмодзи, спецсимволов.

**Решение:** каталог сценариев данных:
- `fixtures/scenarios/empty.json`, `typical.json`, `extreme.json`, `error_401.json`, `error_500.json`
Переключатель — в qa_tools_flutter overlay.

### B3. Mock не имитирует реальные сетевые условия

Login в mock — 200мс. На slow 3G — 5 секунд. UI не тестируется.

**Решение:** в qa_tools-панели переключатель «Network profile»: fast / slow / unstable. Mock-DataSource'ы читают глобальный стейт.

### B4. Mock vs production сборка — что в бинаре?

Сейчас `MockAppApiClient` и фикстуры лежат в `app_api/lib/src/mocks/` и `fixtures/`. В release-сборку chirp всё это попадает.

**Решение:** вынести в отдельный package `app_api_mocks`. `apps/chirp` зависит от него только в `dev_dependencies` или через условный импорт.

## C. «UI разработка без приложения, AI + Figma»

### C1. Storybook содержит только примитивы — экранов фич там нет

Заявленная цель — «не доходить до страницы каждый раз». Но `LoginScreen` сейчас в storybook нет.

**Решение:** каждая фича публикует use-case'ы экранов в storybook через `fake_app_scope.dart` с `MockAppApiClient` и in-memory `SessionController`.

### C2. AI/Figma → код — нет конкретного pipeline

Реалистичный набор:
- **Figma Tokens plugin** → `tokens.json` → Style Dictionary → генерация `AppColors`/`AppTypography`.
- **AI-генератор экрана:** скармливаешь Claude/GPT скриншот + `WIDGET_GUIDELINES.md` + список виджетов ui_kit → получаешь Dart-код. Линтер ловит грубые ошибки.
- **Figma → код напрямую** (FigmaToCode, Locofy) — генерит Material, нам не подходит. Нужен либо свой генератор, либо AI-промпт.

### C3. Дизайн-токены не синхронизированы с Figma

`AppColors.primary = Color(0xFF1DA1F2)` захардкожено. Дизайнер поменял в Figma — никто не узнает.

**Решение:** Style Dictionary + ручной импорт `tokens.json` из Figma → генерация `AppColors`. Либо документировать процесс правки.

### C4. Storybook web для дизайнера — не настроен deploy

`flutter run -d chrome` локально — не помогает удалённому дизайнеру. Нужен deployed-storybook.

**Решение:** GitHub Pages + workflow на каждый PR/merge.

### C5. Pixel-diff с Figma — нет

«Эта кнопка должна быть 48px, у вас 46». Сейчас глазами.

**Решение:** golden-tests + полуавтоматический процесс «экспорт из Figma → diff».

### C6. A11y, тёмная тема, RTL — не проверяются в storybook

ThemeAddon переключает light/dark, но виджеты не пересчитывают цвета. RTL и font-scaling — никогда не проверялось.

**Решение:** widgetbook addon'ы для каждого режима + правило «новый виджет даёт screenshots всех 4 вариантов».

## D. «Разделение на пакеты для линтеров»

### D1. Per-package линтеры созданы, но не ловят главные правила

`ui_kit/analysis_options.yaml` сейчас мягкий — не запрещает `import 'package:flutter_bloc/...'`. Главное правило — только в доке, не в линтере.

**Решение:** dart-rule для запрета импортов:
- `dependency_validator` package.
- `import_lint` lint rule с регексп-паттернами.
- Свой CI-скрипт через `analyzer` API.

### D2. Зависимости между пакетами не валидируются

Что если кто-то добавит `ui_kit → app_api`? Pub разрешит.

**Решение:** скрипт в CI проверяет dependency graph против белого списка. Нарушение → CI красный.

### D3. Версии deps в pubspec'ах могут разъехаться

`dio: ^5.7.0` в app_api, `dio: ^5.9.0` в chirp.

**Решение:** workspace lock-file (есть) + правило «версии в pubspec'ах одинаковые», CI проверяет.

### D4. Тесты пакетов запускаются отдельно — нет агрегации

Нет одной команды «прогон всего workspace». Coverage по пакетам не агрегирован.

**Решение:** Makefile-таргет `test-all` или `melos`.

### D5. CI не настроен вообще — главный gap

Все правила («контракт-тест в CI», «dependency-check в CI», «deploy storybook на каждый merge») предполагают существование CI. Его нет.

**Решение:** GitHub Actions: `lint.yml`, `test.yml`, `contract.yml`, `storybook-deploy.yml`, `mock-build.yml`.

## Сквозные дыры

### S1. Документация ушла в отрыв от автоматики

Я написал ~1000+ строк гайдов. Половина — правила «не делайте X». Эти правила не проверяются ни линтером, ни CI. На ревью человек что-то пропустит.

**Принцип:** каждое правило в доке либо проверяется автоматически, либо помечается как «soft, на совесть».

### S2. Локализация (l10n)

Все строки на русском хардкодом. «Любой человек проверит» — пока он понимает русский.

**Решение:** `flutter_localizations` + ARB-файлы.

### S3. AI как первый-класс потребитель доков

`CLAUDE.md` + `feedback memory` + `WIDGET_GUIDELINES.md` дублируются. AI читает противоречие — выбирает случайно.

**Решение:** один canonical источник правил, остальные доки ссылаются.

### S4. Тёмная тема и адаптив

Виджеты ui_kit жёстко используют `AppColors.background` (light). При `darkMode` цвет не меняется.

**Решение:** `AppColors.background.of(context)` или резолв через `Theme.of`.

---

# Часть III. Свежие идеи для упрощения работы команды

Не повторяет ничего из частей I и II. Это то, что я НЕ обсуждал, но что реально ускоряет команду.

## III.1. In-app debug menu — расширение `qa_tools_flutter`

`qa_tools_flutter` сейчас даёт инспектор виджетов и сеть. Этого мало для нетехнических людей. Накладываем сверху бизнес-debug-меню (5 тапов в верхнем углу или shake-to-open):

- **Переключатель сценариев Mock** (см. II.B2).
- **Network profile** (см. II.B3).
- **Кнопка «очистить сессию»** — токены, prefs, кэши.
- **Кнопка «скопировать debug-info»** — версия билда, env, последние 50 событий Bloc, последние 20 запросов → в clipboard, тестировщик вставляет в баг-репорт.
- **Переключатель env (dev/staging/prod)** — без перезапуска приложения, если AppConfig поддерживает (см. I.10).
- **Force-set state** — Bloc'и регистрируют тестовые состояния, можно сразу прыгнуть на «экран после успешного login».

**Зачем:** тестировщик репортит баг не «не работает» а «build 1.2.3+45, dev env, MockScenario=auth_invalid, последний event LoginSubmitted, последний state LoginFailureState(NetworkFailure)». На порядок быстрее воспроизводится.

## III.2. Локальный mock-сервер через `prism` / Mockoon из swagger

Текущий `MockAppApiClient` — Mock на уровне Dart-классов. Это не тестирует:
- сетевой стек (интерсепторы, refresh, retry),
- работу с реальным HTTP (тайминги, разные content-types).

**Решение:** `prism mock backend/docs/swagger.json -p 4010` поднимает локальный mock-сервер. Команда `flutter run --dart-define=API_URL=http://localhost:4010` ходит через реальный Dio, через все интерсепторы, в localhost-сервер который возвращает данные по swagger.

**Гибрид:** `MockAppApiClient` для тестов и быстрой разработки, `prism` для интеграционного прогона. В CI прогон оба варианта.

## III.3. Типобезопасные роуты через `go_router_builder`

Сейчас `context.go(Routes.login)` — строка. Опечатка `Routes.lgoin` = runtime crash. Для роутов с параметрами (`/tweet/:id`) типизация ещё хуже.

**Решение:** `go_router_builder` codegen:
```dart
@TypedGoRoute<TweetRoute>(path: '/tweet/:id')
class TweetRoute extends GoRouteData {
  TweetRoute({required this.id});
  final String id;
}

// Использование — compile-time safe:
TweetRoute(id: tweet.id).go(context);
```
Опечатка в имени роута или параметра = ошибка компилятора, не падение в проде.

## III.4. Test data factories

Сейчас в тестах: `LoginRequestDto(email: 'a@b.com', password: 'x')`. Если поменялась сигнатура DTO — лезть в 20 тестов.

**Решение:** factory-pattern:
```dart
// test/factories/auth_factories.dart
abstract final class LoginRequestDtoFactory {
  static LoginRequestDto valid() => const LoginRequestDto(
    email: 'test@chirp.app',
    password: 'qwerty12345',
  );

  static LoginRequestDto invalidEmail() => valid().copyWith(email: 'not-email');
}
```
Тесты читаются: `final request = LoginRequestDtoFactory.valid();`. При изменении DTO — правка в одном месте.

## III.5. Error boundary widget — отлов исключений рендера

Сейчас если в `build()` бросилось исключение — белый экран. Пользователь не понимает, тестировщик не может сообщить.

**Решение:** обёртка для каждого экрана:
```dart
AppErrorBoundary(
  onError: (error, stack) => Sentry.captureException(error, stackTrace: stack),
  fallback: (error) => ErrorView(message: 'Что-то пошло не так', onRetry: ...),
  child: HomeScreen(),
);
```
Внутри `FlutterError.onError` + `ErrorWidget.builder`. Сейчас отсутствует.

## III.6. Connectivity awareness + offline outbox

Сейчас при отсутствии сети приложение шлёт запрос → 30 секунд таймаут → 401 как fallback → drop сессии. Хуже UX невозможно.

**Решение:** два слоя:
1. **`ConnectivityStream`** через `connectivity_plus` — глобальный стейт «есть ли сеть». Виджет-баннер в `Scaffold`-обёртке «нет интернета» когда offline.
2. **Outbox pattern** для мутаций: написал твит без сети → твит сохранился в local-DB как pending → отправляется автоматически когда сеть появилась. Для read-only запросов — просто показываем последний кэш.

## III.7. Architecture Decision Records (ADR)

Каждое крупное решение — отдельный markdown-файл в `docs/adr/`:

```
docs/adr/
├── 001-bloc-not-cubit.md
├── 002-ui-kit-no-material-outside.md
├── 003-mock-first-api.md
└── 004-view-model-layer.md
```

Каждый ADR: контекст, рассмотренные альтернативы, выбранное решение, последствия. Новый разработчик через полгода или AI через 100 коммитов поймёт **почему так**, а не «вот написано в `CLAUDE.md` без объяснения».

Без ADR через год правила воспринимаются как карго-культ.

## III.8. Storybook screenshots в CI с PR-комментариями

На каждый PR widgetbook собирает картинки каждого use-case, бот публикует в комментарий PR:
> 📸 Изменённые виджеты:
> - `AppButton` [before](url-old) → [after](url-new)
> - `AppTextField` (новый вариант: `with prefix`)

Дизайнер ревьюит UI прямо в GitHub без открытия storybook'а. Pixel-diff подсветит визуальные регрессии.

**Реализация:** `golden_toolkit` + `flutter test --update-goldens` + CI artifact + bot-comment.

## III.9. Pre-commit hooks через `lefthook`

`lefthook` — кроссплатформенный hook-manager (как `husky` в JS-мире). На каждый коммит:
- `dart format` изменённых файлов.
- `flutter analyze` (быстрый, без проверки workspace целиком).
- Запуск тестов только затронутых файлов.

```yaml
# lefthook.yml
pre-commit:
  parallel: true
  commands:
    format:
      glob: "**/*.dart"
      run: dart format {staged_files}
      stage_fixed: true
    analyze:
      run: flutter analyze
```

Локальная обратная связь до push — за секунды, не за 5 минут CI.

## III.10. Performance budgets и App size monitoring

Сейчас никто не знает: «PR #123 увеличил холодный запуск на 800мс» или «бандл вырос с 18MB до 27MB после добавления библиотеки X». Через год — телефоны клиентов плачут.

**Решение:**
- `flutter build apk --analyze-size` в CI на каждом merge. CI fail если бандл вырос > 5% без объяснения.
- DevTools metrics (startup time, FPS) — записываются в Firebase Performance или Sentry Performance.
- Бюджет в `CONTRIBUTING.md`: «холодный запуск < 2s, бандл < 25MB».

## III.11. Feature flags / Remote Config

Сейчас фича либо в коде и доступна всем, либо нет. Хочешь раскатывать постепенно — придётся релизить два билда.

**Решение:** Firebase Remote Config или собственный `RemoteConfigDataSource` в `app_api`:
```dart
final flag = await config.boolFlag('new_compose_screen', defaultValue: false);
if (flag) NewComposeScreen() else OldComposeScreen();
```

Применения:
- A/B-эксперименты (50% на новый UI).
- Kill switch (бэк-инцидент → выключить экран без релиза).
- Постепенный rollout (10% → 50% → 100%).
- Включение фичи только для staff-аккаунтов.

В mock-режиме `RemoteConfigDataSource` читает локальный JSON — QA переключает.

## III.12. Onboarding для нового разработчика

Сейчас новый человек открывает репо и через полчаса утопает в `CLAUDE.md`, `WIDGET_GUIDELINES.md`, ADR, memory.

**Решение:** `docs/ONBOARDING.md` — пошаговый «первый день»:
1. `flutter pub get` — что должно произойти.
2. Запусти `chirp` в mock-режиме — что увидишь.
3. Запусти `storybook` — что увидишь.
4. Сделай первое изменение: поменяй текст кнопки в `LoginScreen` — где, как, как протестировать.
5. Чек-лист перед твоим первым PR.

Не теория («у нас Bloc, потому что...»), а конкретная последовательность действий за час.

## III.13. PR template + автоматические проверки PR-метрик

`.github/pull_request_template.md` — чек-лист каждого PR (тесты, doc updated, lint clean). GitHub Action который проверяет:
- PR не больше 500 строк (иначе предлагает разбить).
- Есть тест на новую логику.
- Описание PR не пустое.
- Нет `TODO` без issue-ссылки.

## III.14. Deep links / Universal links

`chirp://tweet/42` или `https://chirp.app/tweet/42` — открыть конкретный твит из push-уведомления или из шеринга. Без настройки iOS Universal Links + Android App Links — кликабельные ссылки в SMS не открывают приложение, всегда web.

`go_router` это поддерживает, нужна конфигурация `Info.plist`, `AndroidManifest.xml` и обработчик путей.

## III.15. Snapshot CI runner для PR-сборок

На каждый PR CI собирает APK с mock-режимом, публикует в комментарий PR ссылку «потрогать сборку на устройстве». Дизайнер / PM открывает QR-код → APK на телефоне за 30 секунд → ревью без локального setup.

Через Firebase App Distribution или Diawi.

---

# Часть IV. Приоритеты — что делать первым

Топ-15 по убыванию ROI / простоты внедрения:

| # | Идея | Откуда | Почему первым |
|---|------|--------|--------------|
| 1 | CI с per-package lint + test + contract-test | II.D5, III.13 | Все правила в доке без CI = пустые. Фундамент. |
| 2 | `MockScenario` + qa_tools панель выбора | I.4, II.B2 | Открывает QA/PM/дизайнеру путь прямо сейчас. |
| 3 | Storybook экраны фич + web deploy | II.C1, II.C4 | Без этого «UI без запуска приложения» — slogan. |
| 4 | Contract-test swagger ↔ DTO | I.1, II.A2 | Защита от тихого drift'а. |
| 5 | Per-package import-restriction lint | II.D1 | Чтобы правила «ui_kit без Bloc» работали без ревью. |
| 6 | L10n setup | II.S2 | Иначе «любой человек» = русскоязычный. |
| 7 | In-app debug menu | III.1 | Тестировщик не разработчик — должен мочь сам. |
| 8 | Test data factories | III.4 | Снижает стоимость каждого нового теста. |
| 9 | Error boundary widget | III.5 | Сейчас exception = белый экран — недопустимо в QA-сборке. |
| 10 | ADR в `docs/adr/` | III.7 | Без объяснений правила превращаются в карго-культ. |
| 11 | Тёмная тема — резолв цветов от brightness | II.S4 | Когда первый дизайнер включит — будет некрасиво. |
| 12 | Lefthook pre-commit | III.9 | Локальная обратная связь за секунды, экономит CI-минуты. |
| 13 | Connectivity awareness + offline banner | III.6 | UX в метро. |
| 14 | `app_api_mocks` отдельный package | II.B4 | Чистый prod-бинар. |
| 15 | Onboarding doc | III.12 | Каждый новый человек экономит свои первые 4 часа. |

## Что НЕ нужно делать сейчас

- Codegen из swagger (`openapi_generator`) — пока endpoints < 10, ручной код проще.
- `go_router_builder` — пока роутов < 10, строки терпимы.
- Pixel-diff с Figma — пока дизайн нестабилен, бесполезно.
- Performance budgets — пока приложение маленькое.
- WebSocket / Realtime layer — пока фичи только REST.
- Feature flags — пока нет постепенного rollout (пользователей нет).
- Outbox pattern — пока нет mutation-фичей с обязательной отправкой.
- AsyncAPI — пока realtime не нужен.

Эти пункты — на дорожной карте, не на стартовой.
