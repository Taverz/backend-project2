# Chirp Flutter — CLAUDE.md

Мобильный и веб-клиент для Chirp (Twitter-клон). Бэкенд — Go в `../backend/`.

## Запуск

```bash
flutter pub get
flutter run                        # dev (эмулятор)
flutter run --dart-define=API_URL=http://localhost:8080
flutter test                       # все тесты
flutter test test/core/            # только core
```

## Архитектура

Подробная документация: `../docs/flutter/STRUCTURE.md` и `ARCHITECTURE_RULES.md`.

Кратко:
- **Clean Architecture**: `domain/ ← data/`, `presentation/ → domain/`
- **State**: `flutter_bloc` (Bloc/Cubit) + WM (Widget Model, координатор экрана)
- **DI**: InheritedWidget-скоупы: `AppScope` → `FeatureScope` → `ScreenScope`
- **Навигация**: `go_router` + `StatefulShellRoute.indexedStack`
- **HTTP**: `dio` + цепь интерсепторов (Auth → Refresh → Error → Logger)
- **Сессия**: `SessionController` в `core/session/` — единственный источник истины; не Bloc, не фича
- **Кэш**: `TweetStore` / `UserStore` в `data/store/` фичи-владельца — глобальный нормализованный кэш
- **Пагинация**: все списки наследуют `PaginatedBloc<T>`, своих реализаций нет

## Структура lib/

```
lib/
├── main.dart                    # bootstrap: BlocObserver + AppScopeHolder + ChirpApp
├── app/
│   ├── chirp_app.dart           # MaterialApp.router + theme
│   ├── di/app_scope.dart        # InheritedWidget с глобальными зависимостями
│   ├── di/app_scope_holder.dart # создаёт Dio, Session, Router, PrefsStorage
│   └── router/
│       ├── app_router.dart      # GoRouter: StatefulShellRoute + redirect по сессии
│       ├── routes.dart          # пути и имена маршрутов
│       └── session_refresh_listenable.dart
├── core/
│   ├── network/                 # DioFactory + 4 интерсептора
│   ├── session/                 # SessionController, SessionState, TokenStorage
│   ├── error/                   # Failure (sealed) + исключения
│   ├── result/                  # sealed Result<T>: Ok(value) | Err(failure)
│   ├── bloc/                    # AppBlocObserver + PaginatedBloc<T>
│   ├── wm/                      # BaseWm (контракт Widget Model)
│   ├── storage/                 # PrefsStorage (shared_preferences обёртка)
│   ├── theme/                   # AppTheme, AppColors, AppTypography
│   └── utils/                   # DateTimeX, Validators, Debouncer
├── features/                    # (пока пусто, фичи добавляются итеративно)
└── shared/
    ├── widgets/                 # Avatar, AppShell, Loading/Error/Empty/Skeleton, InfiniteScrollList
    └── extensions/context_x.dart
```

## Ключевые файлы

| Файл | Роль |
|------|------|
| `core/result/result.dart` | `Result<T>` — возвращаемый тип репозиториев |
| `core/error/failures.dart` | Иерархия `Failure` (Network/Server/Unauthorized/Validation/...) |
| `core/session/session_controller.dart` | `init()` / `update()` / `drop()` — жизненный цикл сессии |
| `core/bloc/paginated_bloc.dart` | База для всех списков с cursor |
| `app/di/app_scope.dart` | `AppScope.of(context)` — точка доступа к глобальным зависимостям |
| `app/router/app_router.dart` | GoRouter с redirect-логикой по SessionState |
| `core/network/interceptors/refresh_interceptor.dart` | Single-flight refresh (Completer) |

## Правила (кратко, полное — в ARCHITECTURE_RULES.md)

1. `domain/` — чистый Dart: нет Flutter, нет Dio, нет dto
2. Из других фич импортировать **только** `features/x/domain/`
3. `RepositoryImpl` возвращает `Result<T>`, не бросает наружу
4. Все списки с cursor — наследники `PaginatedBloc`, не своя реализация
5. Bloc → репозиторий напрямую, если один вызов; `UseCase` — только при оркестрации
6. WM — только при 2+ Bloc'ах или локальном UI-стейте; бизнес-логики в WM нет
7. Навигация в Bloc'е запрещена; Bloc эмитит состояние, экран реагирует
8. Без кодогенерации: equality → `equatable`, json → руками

## Тесты

```
test/
├── core/
│   ├── session/session_controller_test.dart   # init/update/drop, stream, listenable
│   ├── bloc/paginated_bloc_test.dart           # load, loadMore, doubleLoadMore, refresh, error
│   └── network/error_interceptor_test.dart    # 401/404/500/connection/timeout/message
└── features/<feature>/{domain,data,presentation}/
```

Запуск: `flutter test` (все) или `flutter test test/core/` (только core).

## Как добавить новую фичу

Используй скил `/flutter-feature <название>`.

## API_URL

Бэкенд запускается на `http://localhost:8080` по умолчанию.  
Переопределить: `flutter run --dart-define=API_URL=http://192.168.1.x:8080`

## Кодоген

**Не используется**: нет `freezed`, `json_serializable`, `build_runner`.  
Модели пишутся руками с `equatable`.
