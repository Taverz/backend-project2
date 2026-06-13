# Chirp Flutter — Testing

Стратегия тестирования, что покрыто, как писать новые тесты.

---

## Запуск

```bash
flutter test                          # всё
flutter test test/unit/               # только unit + widget тесты (без моков)
flutter test test/mock/               # только mock-тесты (mocktail)
flutter test test/features/<name>/    # конкретная фича
flutter test --coverage               # с lcov-отчётом
```

---

## Структура test/

Тесты делятся на два типа по наличию моков:

```
test/
├── unit/                            # чистые тесты — без моков, без реальных зависимостей
│   ├── core/
│   │   ├── bloc/paginated_bloc_test.dart
│   │   ├── error/failures_test.dart
│   │   ├── network/error_interceptor_test.dart
│   │   ├── result/result_test.dart
│   │   └── utils/
│   │       ├── date_format_test.dart
│   │       ├── debouncer_test.dart
│   │       └── validators_test.dart
│   └── shared/
│       └── widgets/                 # widget-тесты (testWidgets, без моков)
│           ├── error_view_test.dart
│           ├── empty_view_test.dart
│           └── infinite_scroll_list_test.dart
├── mock/                            # тесты с mocktail-моками
│   └── core/
│       ├── network/
│       │   ├── auth_interceptor_test.dart
│       │   └── refresh_interceptor_test.dart
│       └── session/
│           └── session_controller_test.dart
└── features/                        # добавляются вместе с фичами
    └── <feature>/
        ├── unit/
        │   ├── <name>_mapper_test.dart
        │   └── <name>_bloc_test.dart
        └── mock/
            └── <name>_repository_test.dart
```

### Критерий разделения

| Папка | Содержит | Использует |
|-------|---------|-----------|
| `unit/` | чистые Dart-тесты и widget-тесты | `flutter_test`, `bloc_test` |
| `mock/` | тесты с мок-зависимостями | `mocktail`, `flutter_test` |

---

## Текущее покрытие

### unit/core/ — актуально по `flutter test` (на 2026-06-13: 115 тестов всего)

| Файл | Тестов | Что проверяет |
|------|--------|--------------|
| `result_test.dart` | 11 | `Ok`/`Err`, `isOk/isErr`, `fold`, `valueOrThrow`, типобезопасность |
| `failures_test.dart` | 10 | equality (equatable), sealed hierarchy, exhaustive switch |
| `error_interceptor_test.dart` | 9 | 401/404/500/connection/receive/send/connectionTimeout/message/unknown |
| `paginated_bloc_test.dart` | 7 | load, loadMore, droppable, error+isLoading, refresh+failure clear, noMore, LoadMore guard |
| `validators_test.dart` | 13 | email/password/username — валидные, невалидные, границы |
| `date_format_test.dart` | 11 | секунды/минуты/часы/дни, все 7 граничных значений |
| `debouncer_test.dart` | 5 | delay, cancel, dispose, sequential calls |

### unit/shared/widgets/ — 16 тестов

| Файл | Тестов | Что проверяет |
|------|--------|--------------|
| `error_view_test.dart` | 6 | message, иконка, retry button, tap, center |
| `empty_view_test.dart` | 4 | message, default/custom icon, center |
| `infinite_scroll_list_test.dart` | 6 | render, loading indicator, empty, hasMore guard, isLoadingMore guard, **позитивный триггер** |

### mock/core/ — 18 тестов

| Файл | Тестов | Что проверяет |
|------|--------|--------------|
| `session_controller_test.dart` | 6 | init/update/drop + stream + listenable |
| `auth_interceptor_test.dart` | 5 | Bearer header: Unknown/Unauth/Auth, update, не трогает чужие заголовки |
| `refresh_interceptor_test.dart` | 7 | non-401 passthrough, self-refresh drop, успешный retry, failed drop, unauth session, **single-flight concurrent**, повтор после завершения |

**Итого: 76 тестов** (`test/unit/` + `test/mock/`)

---

## Ключевые паттерны

### Mock с mocktail (test/mock/)

```dart
class MockTokenStorage extends Mock implements TokenStorage {}

setUp(() {
  storage = MockTokenStorage();
  when(() => storage.read()).thenAnswer((_) async => null);
});

verify(() => storage.clear()).called(1);
```

### Stream-тест: подписка до действий

```dart
// Правильно: Future создаётся ДО того как события эмитятся
final eventsFuture = controller.stream.take(3).toList();
await controller.init();
await controller.update(accessToken: 'a', refreshToken: 'r');
await controller.drop();
final states = await eventsFuture;
```

### Capturing handler для interceptors (без запуска Dio pipeline)

```dart
class _CapturingHandler extends ErrorInterceptorHandler {
  DioException? rejected;

  @override
  void reject(DioException error, {bool callFollowingErrorInterceptor = false}) {
    rejected = error;
  }
}

test('401 → UnauthorizedException', () {
  final handler = _CapturingHandler();
  interceptor.onError(_makeError(statusCode: 401), handler);
  expect(handler.rejected?.error, isA<UnauthorizedException>());
});
```

### droppable-тест: ждать завершения фетча внутри act

```dart
act: (bloc) async {
  bloc.add(const PaginatedRequested());
  await Future.delayed(const Duration(milliseconds: 20));
  bloc.add(const PaginatedLoadMoreRequested());
  bloc.add(const PaginatedLoadMoreRequested()); // dropped
  // Ждём завершения фетча — иначе blocTest закончит сбор стейтов раньше
  await Future.delayed(const Duration(milliseconds: 200));
},
```

---

## Обязательные тесты для каждой фичи

```
test/features/<name>/
├── unit/
│   ├── <name>_mapper_test.dart      # dto → entity на реальном JSON-фикстуре
│   └── <name>_bloc_test.dart        # happy path + failure + edge
└── mock/
    └── <name>_repository_test.dart  # Ok + Err(NetworkFailure) + Err(NotFoundFailure)
```

### Mapper — пример

```dart
test('fromDto создаёт корректный entity из реального JSON', () {
  final dto = TweetDto.fromJson(jsonDecode(kTweetJson)); // реальный JSON из Swagger
  final entity = TweetMapper.fromDto(dto);
  expect(entity.id, '123');
  expect(entity.body, 'Hello world');
});
```

### Repository — пример

`RepositoryImpl` бросает `Failure` (никакого `Result<T>`). Тест проверяет через `throwsA`:

```dart
test('бросает NetworkFailure при NetworkException', () {
  when(() => mockDataSource.getTweet('123')).thenThrow(const NetworkException());
  expect(
    () => repository.getById('123'),
    throwsA(isA<NetworkFailure>()),
  );
});

test('возвращает Tweet при успехе', () async {
  when(() => mockDataSource.getTweet('123')).thenAnswer((_) async => kTweetDto);
  final tweet = await repository.getById('123');
  expect(tweet.id, '123');
});
```

### Bloc — пример

UseCase / repo бросает `Failure` — Bloc эмитит `XxxFailure` state. Мок настраиваем через `thenThrow`:

```dart
blocTest<LoginBloc, LoginState>(
  'usecase бросает Failure → FailureState',
  build: () {
    when(() => useCase(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(const ValidationFailure('boom'));
    return LoginBloc(useCase);
  },
  act: (bloc) => bloc.add(const LoginSubmitted(email: 'e@e.com', password: 'pass1234')),
  expect: () => [
    isA<LoginInProgress>(),
    isA<LoginFailureState>().having((s) => s.failure, 'failure', isA<ValidationFailure>()),
  ],
);
```

---

## Чего не тестируем

- Простые getter'ы и константы
- Flutter/Dio/go_router framework-код
- Код фреймворка внутри сторонних пакетов
