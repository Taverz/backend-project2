# app_api

Контракт API Chirp: типизированные DataSource'ы поверх swagger-описания + Dio-реализация + mock-реализация. Пакет не знает ни про какой конкретный бэкенд — он зеркалит swagger.

📖 **Документация для контрибьюторов** — [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md): как добавить endpoint, обновить фикстуры, мигрировать на chopper-кодоген.

## Структура

```
lib/src/
├── client/app_api_client.dart      # фасад: AppApiClient + AppApiClientImpl(dio)
├── dto/                            # AuthResponseDto / LoginRequestDto / RegisterRequestDto
├── services/                       # AuthService (interface) + AuthServiceDioImpl
├── mocks/                          # MockAppApiClient + MockAuthService
└── fixtures/                       # FixtureLoader (грузит JSON из fixtures/)

fixtures/
└── auth/
    ├── login_request.json
    ├── login_response.json
    ├── register_request.json
    └── register_response.json
```

## Контракт: JSON-фикстуры

Каждый запрос API имеет два JSON-файла в `fixtures/<feature>/`: `<name>_request.json` и `<name>_response.json`. Это **один источник** для трёх потребителей:

1. **Тесты** мапперов и репозиториев — `FixtureLoader.loadJson('auth/login_response.json')`. Гарантия: тест работает на реальной форме ответа бэкенда, не на придуманном JSON.
2. **Mock-клиент** (`MockAuthService`) для оффлайн-разработки — возвращает фикстуру вместо HTTP-вызова. Включается в `AppScope`:
   ```bash
   flutter run --dart-define=USE_MOCK_API=true
   ```
3. **Живая документация контракта** — фикстуры лежат в git, ревьюер PR'а видит как изменилась форма ответа вместе с кодом, без отдельного шага «обновить swagger».

## Как добавить новый эндпоинт

1. Положи реальные JSON-примеры в `fixtures/<feature>/<endpoint>_{request,response}.json`.
2. Объяви DTO в `lib/src/dto/<endpoint>_*_dto.dart` (поля = ключи JSON).
3. Добавь метод в `lib/src/services/<feature>_service.dart` (interface + Dio-impl).
4. Добавь метод в `MockXxxService` — возвращает `FixtureLoader.loadJson(...)`.
5. Зарегистрируй `fixtures/<feature>/` в `pubspec.yaml` под `flutter.assets`.
6. Напиши тест маппера, в нём грузи фикстуру через `FixtureLoader`.
7. Добавь `Endpoint(...)` в `tool/refresh_fixtures.dart` чтобы скрипт мог обновить фикстуру с живого бэка.

## Обновление фикстур с живого бэкенда

`fixtures/<endpoint>_request.json` — **эталонный вход**, редактируется руками (это твой контракт).
`fixtures/<endpoint>_response.json` — перезаписывается реальным ответом бэка через CLI-скрипт:

```bash
# Из корня монорепо (или из packages/app_api/)
dart run packages/app_api/tool/refresh_fixtures.dart \
  --api-url=http://localhost:8080

# Только конкретные эндпоинты
dart run packages/app_api/tool/refresh_fixtures.dart \
  --only=auth/login,auth/register
```

Скрипт:
1. Для каждого `Endpoint` берёт `<name>_request.json` как тело запроса.
2. Делает HTTP-вызов к `--api-url + endpoint.url`.
3. Перезаписывает `<name>_response.json` отформатированным ответом (jsonDecode → JsonEncoder с indent).
4. Для защищённых ручек (`needsAuth: true`) сначала логинится через `auth/login` и переиспользует access-token.

После прогона делаешь `git diff fixtures/` — видно, как изменилась форма ответа, ревью одной командой.

## Использование

```dart
// Реальный клиент
final api = AppApiClientImpl(dio: dio);
final tokens = await api.auth.login(LoginRequestDto(...));

// Mock-клиент (например, в AppScope при USE_MOCK_API=true)
final api = const MockAppApiClient();
```
