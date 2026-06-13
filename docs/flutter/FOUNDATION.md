# Chirp Flutter — Foundation

Что фактически реализовано в слое `flutter/` (дата: 2026-06-13).  
Архитектурный план и правила — в `STRUCTURE.md` и `ARCHITECTURE_RULES.md`.

---

## Статус

| Слой | Статус | Путь |
|------|--------|------|
| `core/network` | ✅ готово | `lib/core/network/` |
| `core/session` | ✅ готово | `lib/core/session/` |
| `core/error` | ✅ готово | `lib/core/error/` |
| `core/bloc` | ✅ готово | `lib/core/bloc/` |
| `core/wm` | ✅ готово | `lib/core/wm/` |
| `core/theme` | ✅ готово | `lib/core/theme/` |
| `core/storage` | ✅ готово | `lib/core/storage/` |
| `core/utils` | ✅ готово | `lib/core/utils/` |
| `app/` | ✅ готово | `lib/app/` |
| `shared/` | ✅ готово | `lib/shared/` |
| `features/auth/` | ✅ готово | `lib/features/auth/` — login + register |

---

## Реализованные файлы

### core/network

| Файл | Что делает |
|------|-----------|
| `dio_factory.dart` | Собирает `Dio` с базовым URL и цепочкой интерсепторов |
| `endpoints.dart` | Все URL-константы (`abstract final class`) |
| `interceptors/auth_interceptor.dart` | Добавляет `Authorization: Bearer <token>` из `SessionController` |
| `interceptors/refresh_interceptor.dart` | Single-flight refresh при 401: один `Completer`, остальные 401 ждут |
| `interceptors/error_interceptor.dart` | `DioException` → `ApiException` / `NetworkException` / `UnauthorizedException` |
| `interceptors/logger_interceptor.dart` | `debugPrint` запросов/ответов в debug-режиме |

Порядок интерсепторов в `DioFactory`: `Logger → Error → Auth → Refresh`.

### core/session

| Файл | Что делает |
|------|-----------|
| `session_state.dart` | `sealed class SessionState`: `Unknown / Authenticated / Unauthenticated` |
| `token_storage.dart` | Обёртка над `FlutterSecureStorage`: `read / write / clear` |
| `session_controller.dart` | Единственный источник истины о сессии: `init() / update() / drop()` |

`SessionController` отдаёт `ValueListenable<SessionState>` (для GoRouter) и `Stream<SessionState>` (для подписчиков). Не является Bloc'ом и не зависит от Flutter widgets — тестируется как чистый Dart.

### core/error

| Файл | Что делает |
|------|-----------|
| `exceptions.dart` | Инфраструктурные исключения: `ApiException`, `NetworkException`, `UnauthorizedException` |
| `failures.dart` | Доменные ошибки: `sealed Failure implements Exception` → `NetworkFailure / ServerFailure / UnauthorizedFailure / ValidationFailure / NotFoundFailure / UnknownFailure` |

`Failure` бросается через `throw` — `RepositoryImpl` ловит инфраструктурные исключения (`ApiException`, `NetworkException`, `UnauthorizedException`) и пробрасывает `Failure`. Никакого `Result<T>` в проекте нет — caller'ы (Bloc / UseCase) ловят через `try/catch`.

### core/bloc

| Файл | Что делает |
|------|-----------|
| `app_bloc_observer.dart` | Логирует смены состояний и ошибки Bloc'ов в debug-режиме |
| `paginated_bloc.dart` | Абстрактный `PaginatedBloc<T>`: cursor-пагинация, droppable loadMore, refresh |

`PaginatedBloc<T>` — наследники реализуют один метод `fetchPage(cursor)` (возвращает `({List<T> items, String? nextCursor})`, при ошибке — `throw Failure`). База ловит исключения и эмитит `failure`-стейт.

Начальное состояние: `PaginatedState<T>()` (не `const PaginatedState()` — иначе тип инфeрится как `Never`).

### core/wm

| Файл | Что делает |
|------|-----------|
| `base_wm.dart` | Контракт Widget Model: `init() / dispose()`, управление `StreamSubscription` |

WM — координатор экрана, не бизнес-логика. Создаётся в `initState`, диспозится в `dispose`.

### core/theme

| Файл | Что делает |
|------|-----------|
| `app_colors.dart` | Константы цветов (brand, neutrals, semantic), светлая и тёмная тема |
| `app_typography.dart` | Стили текста (`headline1/2`, `body1/2`, `label`, `button`) |
| `app_theme.dart` | `AppTheme.light()` / `AppTheme.dark()` — `ThemeData` с Material 3 |

### core/storage / core/utils

| Файл | Что делает |
|------|-----------|
| `prefs_storage.dart` | Обёртка `SharedPreferences`: `getString/Bool/setString/setBool/remove` |
| `date_format.dart` | `DateTime.toRelativeString()` — «5м», «2ч», «3д» |
| `validators.dart` | `Validators.email / password / username` → `String?` для Form |
| `debouncer.dart` | `Debouncer(duration).call(fn)` — откладывает вызов, отменяет предыдущий |

### app/

| Файл | Что делает |
|------|-----------|
| `chirp_app.dart` | `MaterialApp.router` с темой и GoRouter из `AppScope` |
| `di/app_scope.dart` | `AppScope extends InheritedWidget`: `session, dio, prefs, router`. Два lookup'а: `of(context)` (с подпиской, в build/didChangeDependencies) и `read(context)` (без подписки, для `initState`) |
| `di/app_scope_holder.dart` | `StatefulWidget`: инициализирует всё асинхронно, отдаёт `AppScope` |
| `router/routes.dart` | Все пути как константы (`abstract final class Routes`) |
| `router/app_router.dart` | GoRouter: `StatefulShellRoute.indexedStack` + redirect по `SessionState` |
| `router/session_refresh_listenable.dart` | `SessionController.stream` → `ChangeNotifier` для `refreshListenable` |

Redirect-матрица:

| SessionState | Приватный путь | Публичный путь (`/login`, `/register`) |
|---|---|---|
| `Unknown` | → `/` (splash) | → `/` (splash) |
| `Unauthenticated` | → `/login` | остаётся |
| `Authenticated` | остаётся | → `/home` |

### shared/

| Файл | Что делает |
|------|-----------|
| `widgets/app_shell.dart` | `StatefulShellRoute` каркас с `NavigationBar` (Home/Search/Notifications/Profile) |
| `widgets/avatar.dart` | `CircleAvatar` с `NetworkImage` или инициалами |
| `widgets/loading_view.dart` | `CircularProgressIndicator.adaptive()` по центру |
| `widgets/error_view.dart` | Иконка ошибки + текст + кнопка «Повторить» |
| `widgets/empty_view.dart` | Иконка + текст для пустого состояния |
| `widgets/skeleton.dart` | Анимированный placeholder с `FadeTransition` |
| `widgets/infinite_scroll_list.dart` | Generic `ListView` с авто-триггером `onLoadMore` за 200px до конца |
| `extensions/context_x.dart` | `context.theme / colors / textTheme / showSnackBar` |

### features/auth/

Первая фича — login + register.

| Слой | Файлы | Что делает |
|------|-------|-----------|
| domain | `entities/auth_tokens.dart`, `repositories/auth_repository.dart`, `usecases/{login,register}_usecase.dart` | Контракт + UseCase'ы (оркестрация repo + `SessionController.update()`) |
| data | `dto/`, `mappers/`, `datasources/auth_remote_datasource.dart`, `repositories/auth_repository_impl.dart` | Dio-вызовы, маппинг exception→Failure через `throw` |
| presentation | `bloc/{login,register}_bloc.dart`, `mixins/auth_form_validation_mixin.dart`, `scope/auth_scope.dart`, `screens/{login,register}_screen.dart` | Bloc только для submit. Локальный стейт формы — в `StatefulWidget` через `ValueNotifier`, валидация — через миксин. DI в `AuthScopeHolder.initState` через `AppScope.read(context)` |

---

## Точка входа (main.dart)

```dart
void main() {
  Bloc.observer = AppBlocObserver();
  runApp(AppScopeHolder(child: ChirpApp()));
}
```

`AppScopeHolder` асинхронно создаёт `TokenStorage`, `SessionController`, `SharedPreferences`, `Dio`, `GoRouter`, вызывает `session.init()`, затем рендерит `AppScope` с `ChirpApp`.

---

## Зависимости (pubspec.yaml)

```yaml
dependencies:
  flutter_bloc: ^8.1.6      # state management
  equatable: ^2.0.5         # equality без кодогена
  go_router: ^14.6.3        # навигация
  dio: ^5.7.0               # HTTP
  flutter_secure_storage: ^9.2.4  # хранение токенов
  shared_preferences: ^2.3.3

dev_dependencies:
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
  flutter_lints: ^4.0.0
```

Нет `freezed`, `json_serializable`, `build_runner`. Модели — руками с `equatable`.

---

## Известные тонкости

1. **`PaginatedState<T>()` не `const`** — `const PaginatedState()` создаёт `PaginatedState<Never>`, что ломает `copyWith` при первом `loadMore`. Начальное состояние всегда `PaginatedState<T>()`.

2. **Single-flight refresh** — `RefreshInterceptor` держит один `Completer<bool>`. Все 401 во время выполнения refresh ждут его результата. Refresh self-request (путь `/auth/refresh`) не рефрешится — сразу вызывает `session.drop()`.

3. **Stream vs listenable** — `SessionController` отдаёт оба. GoRouter использует `ValueListenable` через `SessionRefreshListenable`; фичи-потребители слушают `Stream<SessionState>`.

4. **`AppScopeHolder` рендерит `SizedBox.shrink()`** пока не закончена async-инициализация — это нормально, `GoRouter` покажет splash (`/`) пока `SessionState == Unknown`.
