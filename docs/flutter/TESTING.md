# Chirp Flutter — Testing

Стратегия тестирования, что покрыто, как писать новые тесты.

---

## Запуск

```bash
flutter test                          # всё
flutter test test/core/               # только инфраструктура
flutter test test/features/<name>/    # конкретная фича
flutter test --coverage               # с lcov-отчётом
```

---

## Структура test/

```
test/
├── core/
│   ├── session/
│   │   └── session_controller_test.dart
│   ├── bloc/
│   │   └── paginated_bloc_test.dart
│   └── network/
│       └── error_interceptor_test.dart
└── features/
    └── <feature>/
        ├── domain/          # если есть доменная логика (редко)
        ├── data/
        │   ├── <name>_mapper_test.dart
        │   └── <name>_repository_test.dart
        └── presentation/
            └── <name>_bloc_test.dart
```

Тесты зеркалят `lib/` — тот же путь, суффикс `_test.dart`.

---

## Текущее покрытие (core)

### session_controller_test.dart — 5 тестов

| Тест | Что проверяет |
|------|--------------|
| `init — токены есть` | `SessionAuthenticated` с правильным токеном |
| `init — токенов нет` | `SessionUnauthenticated` |
| `update` | сохраняет в storage, переходит в `Authenticated` |
| `drop` | очищает storage, переходит в `Unauthenticated` |
| `listenable` | `ValueNotifier` обновляется синхронно |
| `stream` | `stream.take(3).toList()` получает 3 перехода: init→update→drop |

Мок: `MockTokenStorage extends Mock implements TokenStorage` (mocktail).

**Паттерн stream-теста** — важно начинать слушать ДО триггера действий:
```dart
final eventsFuture = controller.stream.take(3).toList();
await controller.init();
await controller.update(...);
await controller.drop();
final states = await eventsFuture;
```

### paginated_bloc_test.dart — 6 тестов

| Тест | Что проверяет |
|------|--------------|
| `Requested` | isLoading → items + cursor + hasMore |
| `LoadMore` | добавляет к существующему списку |
| `двойной LoadMore` | droppable: второй игнорируется пока идёт первый |
| `Failure` | `hasError == true`, `failure == NetworkFailure` |
| `Refresh` | сбрасывает items, загружает заново с cursor = null |
| `nextCursor == null` | `hasMore == false` |

Конкретный Bloc для тестов:
```dart
class _TestBloc extends PaginatedBloc<String> {
  _TestBloc(this._fetcher);
  final PageResult<String> Function(String?) _fetcher;

  @override
  PageResult<String> fetchPage(String? cursor) => _fetcher(cursor);
}
```

### error_interceptor_test.dart — 7 тестов

| Тест | Что проверяет |
|------|--------------|
| `401` | → `UnauthorizedException` |
| `404` | → `ApiException(statusCode: 404)` |
| `500` | → `ApiException(statusCode: 500)` |
| `connectionError` | → `NetworkException` |
| `receiveTimeout` | → `NetworkException` |
| `тело с полем error` | message берётся из `body['error']` |
| `cancel` | пропускается через `next()`, не `reject()` |

**Паттерн прямого тестирования interceptor** — без запуска Dio pipeline:
```dart
class _CapturingHandler extends ErrorInterceptorHandler {
  DioException? rejected;

  @override
  void reject(DioException error, {bool callFollowingErrorInterceptor = false}) {
    rejected = error;
  }

  @override
  void next(DioException err) { ... }
}

test('401 → UnauthorizedException', () {
  final handler = _CapturingHandler();
  interceptor.onError(_makeError(statusCode: 401), handler);
  expect(handler.rejected?.error, isA<UnauthorizedException>());
});
```

Прямой вызов `onError()` лучше, чем тест через Dio pipeline: порядок обработки ошибок в цепи Dio зависит от версии и не является предметом нашего теста.

---

## Обязательные тесты для каждой фичи

Минимум при добавлении новой фичи:

### data/mapper_test.dart

```dart
test('fromDto создаёт корректный entity из реального JSON', () {
  final dto = TweetDto.fromJson(jsonDecode(kTweetJson));
  final entity = TweetMapper.fromDto(dto);
  expect(entity.id, '123');
  expect(entity.body, 'Hello world');
  // ...
});
```

Использовать реальный JSON-пример из Swagger, не выдуманный. Это страхует от рассинхронизации с бэкендом.

### data/repository_test.dart

```dart
test('возвращает Ok<Tweet> при успехе datasource', () async {
  when(() => mockDataSource.getTweet('123')).thenAnswer((_) async => tweetDto);
  final result = await repository.getById('123');
  expect(result, isA<Ok<Tweet>>());
});

test('возвращает Err<NetworkFailure> при NetworkException', () async {
  when(() => mockDataSource.getTweet('123')).thenThrow(const NetworkException());
  final result = await repository.getById('123');
  expect(result, isA<Err<Tweet>>());
  expect((result as Err).failure, isA<NetworkFailure>());
});
```

### presentation/bloc_test.dart

```dart
blocTest<TimelineBloc, PaginatedState<TweetId>>(
  'загружает timeline при Requested',
  build: () => TimelineBloc(mockRepository),
  act: (bloc) => bloc.add(const PaginatedRequested()),
  expect: () => [
    isA<PaginatedState<TweetId>>().having((s) => s.isLoading, 'loading', true),
    isA<PaginatedState<TweetId>>().having((s) => s.items.length, 'items', greaterThan(0)),
  ],
);
```

---

## Инструменты

| Пакет | Использование |
|-------|--------------|
| `flutter_test` | базовый тест-раннер |
| `bloc_test` | `blocTest<Bloc, State>(build, act, expect)` |
| `mocktail` | `class Mock extends Mock implements X` + `when(() => ...).thenAnswer(...)` |

### Пример мока с mocktail

```dart
class MockTweetRepository extends Mock implements TweetRepository {}

setUp(() {
  mockRepo = MockTweetRepository();
  // Для методов с named params нужно registerFallbackValue:
  registerFallbackValue(const NetworkFailure());
});

when(() => mockRepo.getTimeline(cursor: any(named: 'cursor')))
    .thenAnswer((_) async => const Ok((items: [], nextCursor: null)));
```

---

## Чего не тестируем

- Виджеты — только если есть сложная логика рендера (используй `testWidgets` + `WidgetTester`)
- Простые getter'ы и константы
- Код фреймворка (Dio, GoRouter, flutter_bloc) — они протестированы авторами

---

## Запуск CI (будущее)

```yaml
# Пример GitHub Actions
- run: flutter pub get
- run: flutter analyze
- run: flutter test --coverage
```
