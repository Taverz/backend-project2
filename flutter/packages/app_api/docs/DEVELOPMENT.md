# app_api — работа с API

Гайд по обновлению контракта и поддержке фикстур.
Краткий обзор пакета — в [`../README.md`](../README.md). Общие правила Flutter-монорепо — в [`../../../CLAUDE.md`](../../../CLAUDE.md).

> **TL;DR**
> - Новый endpoint: фикстуры → DTO → DataSource (interface + Dio-impl) → Mock → регистрация в `AppApiClient` + `MockAppApiClient` → barrel → запись в `tool/refresh_fixtures.dart`.
> - `*_request.json` редактируется руками, `*_response.json` обновляется через `dart run tool/refresh_fixtures.dart`.
> - Codegen из swagger пока **не подключён** — все datasource'ы написаны вручную. Когда подключим — это будет `openapi_generator`/`swagger_parser`, а не chopper (см. раздел «Codegen»).

---

## Принципы

1. **`app_api` — реализация swagger-контракта, а не зеркало конкретного бэкенда.** Какая платформа у сервера — нерелевантно.
2. **Mock-first.** `--dart-define=USE_MOCK_API=true` подключает `MockAppApiClient`; в этом режиме приложение должно работать без поднятого бэка. Любой новый endpoint обязан иметь mock-имплементацию.
3. **DTO и фикстуры синхронны.** `*_response.json` — это пример ответа, который реально приходит; DTO — типизированное зеркало этих ключей. Если бэкенд поменял форму — нужно обновить **и** фикстуру **и** DTO (расхождение обычно ловится тестом маппера).

---

## Структура

```
packages/app_api/
├── fixtures/                          # эталонные JSON request/response
│   └── <feature>/<endpoint>_{request,response}.json
├── lib/
│   ├── app_api.dart                   # barrel — что экспортируется наружу
│   └── src/
│       ├── client/app_api_client.dart # фасад
│       ├── datasources/               # XxxRemoteDataSource (interface) + Dio-impl
│       ├── dto/                       # *RequestDto, *ResponseDto
│       ├── fixtures/fixture_loader.dart
│       └── mocks/                     # Mock-DataSource'ы + MockAppApiClient
├── test/                              # тесты Mock-импла и FixtureLoader
├── tool/refresh_fixtures.dart         # CLI для перезаписи fixtures с живого бэка
└── docs/DEVELOPMENT.md                # этот файл
```

---

## Добавление нового endpoint

Пример: `GET /api/v1/users/me`.

### 1. Положи фикстуры

Обе нужны — request даже если пустой:

```jsonc
// fixtures/profile/me_request.json
{}

// fixtures/profile/me_response.json
{
  "id": "u-1",
  "username": "nikita",
  "email": "nikita@chirp.app",
  "display_name": "Nikita",
  "bio": "",
  "created_at": "2026-06-13T10:00:00Z"
}
```

Зарегистрируй директорию в `pubspec.yaml`:

```yaml
flutter:
  assets:
    - fixtures/auth/
    - fixtures/profile/   # ← новая строка
```

### 2. DTO

Поле в поле с JSON. Никаких freezed:

```dart
// lib/src/dto/user_response_dto.dart
class UserResponseDto {
  const UserResponseDto({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.bio,
    required this.createdAt,
  });

  final String id;
  final String username;
  final String email;
  final String displayName;
  final String bio;
  final String createdAt;

  factory UserResponseDto.fromJson(Map<String, dynamic> json) =>
      UserResponseDto(
        id: json['id'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        displayName: json['display_name'] as String,
        bio: json['bio'] as String,
        createdAt: json['created_at'] as String,
      );
}
```

### 3. DataSource — interface + Dio-impl

```dart
// lib/src/datasources/profile_remote_datasource.dart
abstract interface class ProfileRemoteDataSource {
  Future<UserResponseDto> getMe();
}

class ProfileRemoteDataSourceDioImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceDioImpl(this._dio);
  final Dio _dio;

  @override
  Future<UserResponseDto> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/users/me');
    return UserResponseDto.fromJson(response.data!);
  }
}
```

### 4. Mock

```dart
// lib/src/mocks/mock_profile_remote_datasource.dart
class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  const MockProfileRemoteDataSource({this.latency = const Duration(milliseconds: 200)});
  final Duration latency;

  @override
  Future<UserResponseDto> getMe() async {
    await Future<void>.delayed(latency);
    final json = await FixtureLoader.loadJson('profile/me_response.json');
    return UserResponseDto.fromJson(json);
  }
}
```

### 5. Регистрация в `AppApiClient` + `MockAppApiClient`

```dart
// lib/src/client/app_api_client.dart
abstract interface class AppApiClient {
  AuthRemoteDataSource get auth;
  ProfileRemoteDataSource get profile;          // ← добавили
}

class AppApiClientImpl implements AppApiClient {
  AppApiClientImpl({required Dio dio})
    : auth = AuthRemoteDataSourceDioImpl(dio),
      profile = ProfileRemoteDataSourceDioImpl(dio);

  @override final AuthRemoteDataSource auth;
  @override final ProfileRemoteDataSource profile;
}
```

И аналогично в `MockAppApiClient`.

### 6. Экспорт из barrel

```dart
// lib/app_api.dart
export 'src/datasources/profile_remote_datasource.dart';
export 'src/dto/user_response_dto.dart';
export 'src/mocks/mock_profile_remote_datasource.dart';
```

### 7. Зарегистрируй в `refresh_fixtures.dart`

```dart
const _endpoints = <Endpoint>[
  // ...
  Endpoint(
    fixturePath: 'profile/me',
    method: 'GET',
    url: '/api/v1/users/me',
    needsAuth: true,
  ),
];
```

### 8. Тесты

- В `packages/app_api/test/` — что Mock возвращает данные из фикстуры.
- В фиче-потребителе — mapper-тест, грузит фикстуру через `FixtureLoader.loadJson('profile/me_response.json')`.

### Чек-лист

- [ ] `*_request.json` и `*_response.json` лежат в `fixtures/<feature>/`
- [ ] Директория зарегистрирована в `pubspec.yaml`
- [ ] DTO с `fromJson`, ключи совпадают с JSON
- [ ] DataSource: interface + Dio-impl
- [ ] Mock-DataSource через `FixtureLoader`
- [ ] DataSource добавлен в `AppApiClient` И `MockAppApiClient`
- [ ] Экспорт из `lib/app_api.dart`
- [ ] Endpoint зарегистрирован в `tool/refresh_fixtures.dart`
- [ ] `flutter analyze` чист, тесты зелёные

---

## Обновление существующего endpoint

Сценарий: бэкенд поменял форму ответа.

1. Обнови фикстуру через скрипт (см. ниже), не руками.
2. Поправь DTO — добавь/переименуй поля. Тест маппера провалится при расхождении — это и есть страховка.
3. Поправь mapper в фиче-потребителе (`features/<feature>/data/mappers/`).
4. Если изменение протекает в entity — поправь entity.
5. Прогон: `flutter test` + `flutter run --dart-define=USE_MOCK_API=true` для проверки оффлайн-режима.

---

## Обновление JSON-фикстур

| Файл | Кто редактирует | Когда |
|------|----------------|-------|
| `<endpoint>_request.json` | разработчик руками | при изменении контракта request'а |
| `<endpoint>_response.json` | `tool/refresh_fixtures.dart` | после любых правок ответа на бэке |

**Почему request руками, а response скриптом:**
Request — это пример «эталонного входа» (какие данные мы шлём для happy-path). Response — реальный выход сервера; копировать его руками = источник дрейфа контракта.

### Запуск скрипта

```bash
# Из корня монорепо
dart run packages/app_api/tool/refresh_fixtures.dart --api-url=http://localhost:8080

# Только конкретные эндпоинты
dart run packages/app_api/tool/refresh_fixtures.dart --only=auth/login,profile/me
```

`git diff fixtures/` — точное изменение формы.

### Защищённые endpoint'ы

В `tool/refresh_fixtures.dart` пометь `needsAuth: true`. Скрипт сначала логинится через `fixtures/auth/login_request.json`, берёт `access_token` из ответа, и для всех остальных вызовов подставляет `Authorization: Bearer ...`.

### Несколько сценариев на один endpoint (паттерн, пока не используется)

Если для теста нужны разные варианты ответа (happy-path + 401 + 500), заводи именованные фикстуры:

```
fixtures/auth/
├── login_request.json
├── login_request_invalid.json           # для теста валидации
├── login_response.json
└── login_response_unauthorized.json     # для repo-теста на 401
```

`FixtureLoader.loadJson('auth/login_response_unauthorized.json')` грузит так же. В `refresh_fixtures.dart` каждый именованный сценарий — отдельный `Endpoint`. Сейчас такого нет в проекте — этот паттерн добавится, когда понадобится первый failure-сценарий.

---

## Codegen из swagger — текущее состояние и план

### Сейчас: ручной код

Все DataSource'ы написаны вручную (interface + Dio-impl). Для текущего размера API (≈5 endpoints) это нормально.

### Кодогенерация — два разных слоя

Часто путают. Различай:

| Инструмент | Что генерирует | Из чего |
|-----------|---------------|--------|
| `chopper` + `chopper_generator` | имплементацию HTTP-методов (POST/GET) | из аннотаций в Dart-коде, которые пишешь сам |
| `openapi_generator` (CLI) / `swagger_parser` (pub.dev) | DTO, API-клиент, базовые datasource'ы целиком | из `swagger.json` / `openapi.yaml` |

**Chopper НЕ читает swagger.** Он избавляет от ручного `dio.post(...)`, но интерфейсы с аннотациями всё равно пишутся руками.

### Какой путь когда выбирать

```
Сколько endpoint'ов в API?
├── < 10 → ручной код (текущая ситуация — OK)
├── 10–50 → chopper (меньше boilerplate в DataSourceDioImpl)
└── > 50 или swagger меняется часто → openapi_generator/swagger_parser
                                       (полная синхронизация со swagger,
                                        но генерится «коробочный» код)
```

### Если переходим на chopper

Цена перехода: переписать все интерсепторы (`apps/chirp/lib/core/network/interceptors/`) под `chopper.Interceptor` — они сейчас под Dio. Это отдельный PR до миграции datasource'ов. Контракт `XxxRemoteDataSource` при переходе не меняется — фичи правок не получают.

### Если переходим на openapi_generator

Затрагивает структуру пакета:
- DTO и DataSource переезжают в `lib/src/generated/` (генерируются).
- `app_api.dart` экспортит сгенерированные классы.
- Mock и Fixture-инфраструктура остаются ручными.
- В CI добавляется шаг `openapi-generator generate -i backend/docs/swagger.json -g dart-dio`.

Минусы: требует Java/Docker, теряем control над интерсепторами, генерится много кода для редактирования.

### Решение на сейчас

Пока endpoints мало — ручной код. Триггер для миграции: 10+ endpoints **или** регулярные изменения swagger без кодовых изменений на бэке. Тогда возвращаемся к этому разделу и принимаем решение.

---

## Mock-first: разработка без бэкенда

`--dart-define=USE_MOCK_API=true` подключает `MockAppApiClient` (см. `apps/chirp/lib/app/di/app_scope.dart`).

Требования к Mock-DataSource:

1. **Happy-path обязательно** — без него фича в mock-режиме не запускается.
2. **Имитация задержки** (`Future.delayed`, дефолт 200мс). Без задержки UI-состояния `isSubmitting` не успевают отрендериться.
3. **Не падать молча.** Если фикстура не найдена — `FixtureLoader` бросает; пройди mock-режим хотя бы раз руками перед PR.

### Failure-сценарии — паттерн (пока не реализован)

Когда понадобится в фиче тестировать UI на error-state, добавь опциональный параметр в Mock:

```dart
// Пока в коде нет; шаблон для будущих фич.
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  const MockAuthRemoteDataSource({
    this.latency = const Duration(milliseconds: 200),
    this.simulateLoginFailure = false,
  });
  final Duration latency;
  final bool simulateLoginFailure;

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    await Future<void>.delayed(latency);
    if (simulateLoginFailure) throw const UnauthorizedException();
    final json = await FixtureLoader.loadJson('auth/login_response.json');
    return AuthResponseDto.fromJson(json);
  }
}
```

В Storybook или dev-режиме передаёшь `simulateLoginFailure: true` — проверяешь error-state.

---

## Тестирование

| Что | Где | Как |
|-----|-----|-----|
| DTO ↔ JSON | в фиче, `mapper_test.dart` | `FixtureLoader.loadJson(...)` → `fromJson` → entity |
| Mock возвращает данные | `app_api/test/` | прямой вызов `MockXxxRemoteDataSource.method(...)` |
| Repository маппит ошибки в `Failure` | в фиче, `repository_test.dart` | мокается datasource (mocktail), `thenThrow(ApiException(...))`, `expect(...throwsA(isA<Failure>()))` |
| End-to-end через mock | в фиче, widget_test | прогон UI с подменённым `AppApiClient = MockAppApiClient()` |

**Не тестируем:** Dio-impl напрямую (интеграционный тест с реальным бэком).

---

## Что разрешено импортировать в app_api

| Импорт | Где разрешено |
|--------|--------------|
| `dart:async`, `dart:convert`, `dart:io` | везде; `dart:io` — в `FixtureLoader` для fallback вне Flutter binding |
| `package:dio/dio.dart` | `datasources/*_dio_impl.dart`, `client/app_api_client.dart` |
| `package:flutter/services.dart` | `FixtureLoader` (для `rootBundle`) |
| `package:equatable/equatable.dart` | DTO, если нужно equality |
| `package:flutter/widgets.dart` / `material.dart` | **нет** — это транспортный пакет, не UI |
| `package:flutter_bloc/...` и подобные state-manager'ы | **нет** |
| Импорт из `apps/chirp/...` | **нет**, обратная зависимость |

---

## Анти-паттерны

| Симптом | Как исправить |
|---------|--------------|
| `_response.json` отредактирован руками | прогнать `tool/refresh_fixtures.dart --only=...` |
| DTO с вычисляемыми геттерами / бизнес-логикой | вынеси в entity/mapper |
| `AppApiClient` отдаётся в screens или ViewModels | `AppScope` создаёт `Repository`, отдаёт его наружу; api — приватный detail |
| DataSource зовёт другой DataSource | как правило не нужно (это оркестрация — место для UseCase). Исключения (batch-операции в рамках одного endpoint'а) — через ревью |
| Mock возвращает захардкоженный JSON в коде, не из фикстуры | source of truth = файл в `fixtures/` |
| Слово «Service» в `app_api` | переименовать в `RemoteDataSource` |
| `app_api` импортирует UI-фреймворк (`widgets`/`material`) | удалить; app_api — транспорт и контракт, не UI |
| Поле `Map<String, dynamic>` в DTO | разверни в типизированные поля или вложенный DTO |
| Mock без `latency` | добавь `Future.delayed`, иначе UI-состояния пропадают |
