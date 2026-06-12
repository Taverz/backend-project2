# Chirp Flutter — Project Structure

---

## Stack

| Слой | Выбор |
|-------|-------|
| Платформа | Flutter 3.x (web + mobile) |
| State management | `flutter_bloc` (Bloc / Cubit) |
| Координация на экране | WM (Widget Model) на `ValueNotifier` + `Stream` |
| Сессия (auth-состояние) | `SessionController` — чистый Dart, `Stream` + `ValueNotifier`, живёт в core |
| DI / Scope | `InheritedWidget`-скоупы (AppScope → FeatureScope → ScreenScope) |
| Навигация | `go_router` + `StatefulShellRoute.indexedStack` |
| HTTP | `dio` + интерсепторы (auth, single-flight refresh, logger, error mapping) |
| Хранилище токенов | `flutter_secure_storage` |
| Настройки | `shared_preferences` |
| Модели | Ручные `fromJson` / `toJson`, equality через `equatable` |
| Кодоген | **отсутствует** — без freezed, json_serializable, build_runner |
| Линтер | `flutter_lints` |

---

## pubspec.yaml (ключевые зависимости)

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_bloc: ^8.1
  equatable: ^2.0

  go_router: ^14.0

  dio: ^5.4

  flutter_secure_storage: ^9.0
  shared_preferences: ^2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1
  mocktail: ^1.0
  flutter_lints: ^4.0
```

---

## Ключевые архитектурные решения

### 1. Сессия — это инфраструктура, а не фича

`SessionController` живёт в `core/session/`. Это чистый Dart-класс без зависимостей от Flutter и Bloc:

- хранит/читает токены через `TokenStorage` (обёртка над secure storage);
- отдаёт `ValueListenable<SessionState>` (authenticated / unauthenticated / unknown) и `Stream<SessionState>`;
- единственная точка, которая умеет «разлогинить» приложение.

Кто на него подписан:

| Потребитель | Зачем |
|-------------|-------|
| `go_router.refreshListenable` | redirect на `/login` при разлогине — без участия Bloc. Реализовано через `SessionRefreshListenable`, подписывающийся на `session.stream` |
| `RefreshInterceptor` (dio) | читает/обновляет токены, при провале refresh вызывает `session.drop()` |
| `AuthBloc` (фича auth) | слушает сессию, чтобы отрисовывать UI логина; **не является** источником истины |

Это разрывает цикл «AuthBloc → Dio → AuthBloc» из v1: цепочка теперь линейная
`Dio → SessionController ← AuthBloc`, и app-слой не зависит от presentation фичи.

### 2. Single-flight refresh

`RefreshInterceptor` держит один shared `Future<bool>` (Completer):

```
401 пришёл (err.error is UnauthorizedException — выставляется ErrorInterceptor'ом)
  ├── path == /auth/refresh → session.drop() → next(err)
  └── иначе: refresh уже идёт?
        ├── да  → await тот же Completer.future, потом retry
        └── нет → стартуем refresh, все последующие 401 ждут его
              refresh упал → session.drop() → router сам уводит на /login
              refresh успешен → dio.fetch(originalRequest) → resolve
```

**Важно:** `RefreshInterceptor` определяет 401 не по HTTP-статусу, а по типу `UnauthorizedException` в `err.error`. Этот тип выставляется `ErrorInterceptor`, который должен стоять в цепи ДО `RefreshInterceptor`. Порядок в `DioFactory`: `Logger → Error → Auth → Refresh`.

Никаких конкурирующих refresh-запросов и затирания токенов.

### 3. Фича-владелец домена + правило импортов между фичами

Сущности `Tweet` и `User` нужны нескольким фичам. Вместо дублирования вводится понятие **фичи-владельца**:

- `features/tweet/` владеет доменом твита (`Tweet`, `TweetRepository`);
- `features/profile/` владеет доменом пользователя (`UserProfile`, `UserRepository`);
- `features/auth/` владеет `AuthTokens` и сценариями входа.

**Правило:** фича может импортировать из другой фичи **только `domain/`** (entities + контракты репозиториев). Импорт чужих `data/` и `presentation/` запрещён.

```
home ──► tweet/domain          (лента состоит из твитов)
search ──► tweet/domain, profile/domain
notifications ──► tweet/domain, profile/domain
tweet ──► profile/domain       (автор твита)
```

Граф направленный и без циклов; владельцы доменов (`tweet`, `profile`) не зависят ни от кого, кроме core.

### 4. Реактивный TweetStore — синхронизация между экранами

Проблема: лайк на экране деталей должен мгновенно отразиться в ленте, профиле и результатах поиска.

Решение — in-memory нормализованный кэш в data-слое фичи-владельца:

```
features/tweet/data/store/tweet_store.dart
```

- `Map<TweetId, Tweet>` + broadcast `Stream<Tweet>` изменений;
- `TweetRepositoryImpl` — единственный, кто пишет в стор (после любого fetch / like / repost / delete);
- контракт в domain расширен: `Stream<Tweet> watchTweet(TweetId id)` и `Stream<TweetChange> get changes`.

Как этим пользуются другие фичи:

| Экран | Поведение |
|-------|-----------|
| Лента (`TimelineBloc`) | держит список **id**, карточка подписывается на `watchTweet(id)` |
| Детали (`TweetDetailBloc`) | `watchTweet(id)` + догрузка треда |
| Профиль / поиск | то же: списки id + точечные подписки |

Лайк где угодно → repository обновляет стор → все подписчики получают новый `Tweet`. Никакой шины событий между Bloc'ами, никаких ручных «обнови соседний экран».

Аналогично (легче) — `UserStore` в `profile/data/store/` для счётчиков подписок.

### 5. Переиспользуемая пагинация

`core/bloc/paginated_bloc.dart` — абстрактный `PaginatedBloc<T>`:

- состояние: `items`, `cursor`, `hasMore`, `isLoadingMore`, `error`;
- события: `Requested`, `LoadMoreRequested`, `RefreshRequested`;
- защита от двойного `loadMore`, от `loadMore` во время refresh;
- наследник реализует один метод — `fetchPage(cursor)`.

Наследники: `TimelineBloc`, `FollowersBloc`, `FollowingBloc`, `SearchTweetsBloc`, `NotificationsBloc`, `UserTweetsBloc`. Cursor-логика написана один раз.

### 6. Usecase'ы — только там, где есть логика

Правило вместо церемонии:

- **Bloc → repository напрямую**, если операция = один вызов репозитория (load timeline, get profile);
- **Usecase обязателен**, если есть оркестрация: несколько репозиториев, валидация, побочные эффекты. Примеры: `LoginUseCase` (auth API → сохранить токены → прогреть профиль), `PostTweetUseCase` (создать → положить в стор → инвалидировать черновик), `ToggleLikeUseCase` (оптимистичное обновление стора → запрос → откат при ошибке).

Это убирает пустые пробросы `call() => repo.method()` из v1, но сохраняет место для бизнес-правил.

### 7. Трёхуровневые скоупы с явным жизненным циклом

| Scope | Живёт | Содержит | Кто создаёт/диспозит |
|-------|-------|----------|----------------------|
| `AppScope` | всё приложение | Dio, SessionController, PrefsStorage, GoRouter — сейчас. TweetStore, UserStore, репозитории-владельцы — добавляются по мере реализации фич | `AppScopeHolder` (StatefulWidget над MaterialApp) |
| `FeatureScope` | пока активна ветка/маршрут фичи | datasources фичи, её репозитории, usecase'ы, долгоживущие Bloc'и фичи (TimelineBloc) | `XxxScopeHolder` — обёртка builder'а ветки `StatefulShellRoute` или страницы |
| `ScreenScope` (опционально) | один экран | WM экрана, эпизодические Cubit'ы (LikeCubit, форма) | `StatefulWidget` экрана |

Репозитории-владельцы (`TweetRepository`, `UserRepository`) подняты в `AppScope` сознательно: их сторы — глобальный кэш, нужный всем фичам.

Доступ: `AppScope.of(context)`, `HomeScope.of(context)` — статические методы, под капотом `dependOnInheritedWidgetOfExactType`. Никаких сервис-локаторов.

### 8. Контракт WM

`core/wm/base_wm.dart` задаёт жёсткий контракт:

- **Создание:** экран — это `StatefulWidget`; в `initState` создаётся WM фабрикой `XxxWm(context)` — фабрика сама достаёт зависимости из скоупов. Виджеты получают WM через локальный `ScreenScope` либо конструктором.
- **Жизненный цикл:** `init()` в `initState`, `dispose()` в `dispose` — WM закрывает свои `ValueNotifier`, подписки на стримы и **эпизодические** Cubit'ы, которые он создал сам. Bloc'и из FeatureScope WM не закрывает — не он владелец.
- **Что внутри:** ссылки на Bloc'и, локальные `ValueNotifier` (скролл, фокус, видимость FAB), комбинирование стримов нескольких Bloc'ов в derived-состояние для виджета, методы-обработчики UI-событий (`onLikeTap`, `onScrollEnd` → транслируются в события Bloc'ов).
- **Чего внутри нет:** бизнес-логики, вызовов репозиториев/usecase'ов напрямую, навигации мимо роутера.
- **Когда WM не нужен:** на экране один Bloc и нет локального стейта → обычный `BlocBuilder`, без церемоний.
- **Тестирование:** WM — чистый Dart-класс, зависимости приходят через конструктор у фабрики → юнит-тестится с мок-Bloc'ами без виджет-окружения.

---

## Структура каталогов

```
chirp-flutter/
├── lib/
│   ├── main.dart                              # bootstrap: BlocObserver, runApp(AppScopeHolder())
│   │
│   ├── app/                                   # composition root
│   │   ├── chirp_app.dart                     # MaterialApp.router + theme
│   │   ├── di/
│   │   │   ├── app_scope.dart                 # InheritedWidget с глобальными зависимостями
│   │   │   └── app_scope_holder.dart          # создаёт Dio, Session, сторы, репозитории-владельцы
│   │   └── router/
│   │       ├── app_router.dart                # GoRouter: StatefulShellRoute + redirect
│   │       ├── routes.dart                    # пути и имена маршрутов
│   │       └── session_refresh_listenable.dart # SessionController → Listenable для router
│   │
│   ├── core/                                  # фундамент; не знает о фичах
│   │   ├── network/
│   │   │   ├── dio_factory.dart
│   │   │   ├── endpoints.dart
│   │   │   └── interceptors/
│   │   │       ├── auth_interceptor.dart      # Bearer из SessionController
│   │   │       ├── refresh_interceptor.dart   # single-flight refresh, queue ожидающих
│   │   │       ├── error_interceptor.dart     # DioException → ApiException/NetworkException
│   │   │       └── logger_interceptor.dart
│   │   ├── session/
│   │   │   ├── session_controller.dart        # состояние сессии, drop(), update(tokens)
│   │   │   ├── session_state.dart             # sealed: unknown / authenticated / unauthenticated
│   │   │   └── token_storage.dart             # обёртка secure storage
│   │   ├── error/
│   │   │   ├── exceptions.dart                # инфраструктурные: Api/Network/Unauthorized
│   │   │   └── failures.dart                  # доменные: sealed Failure (network, validation, notFound, unknown)
│   │   ├── result/
│   │   │   └── result.dart                    # sealed Result<T>: Ok(value) / Err(Failure)
│   │   ├── bloc/
│   │   │   ├── app_bloc_observer.dart
│   │   │   └── paginated_bloc.dart            # база для всех списков с cursor
│   │   ├── wm/
│   │   │   └── base_wm.dart                   # контракт WM: init/dispose, helpers
│   │   ├── storage/
│   │   │   └── prefs_storage.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_typography.dart
│   │   └── utils/
│   │       ├── date_format.dart
│   │       ├── validators.dart
│   │       └── debouncer.dart
│   │
│   ├── features/
│   │   │
│   │   ├── tweet/                             # ВЛАДЕЛЕЦ домена Tweet
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── tweet.dart
│   │   │   │   │   └── tweet_change.dart      # liked / created / deleted / updated
│   │   │   │   ├── repositories/
│   │   │   │   │   └── tweet_repository.dart  # CRUD + watchTweet(id) + changes
│   │   │   │   └── usecases/
│   │   │   │       ├── post_tweet_usecase.dart
│   │   │   │       └── toggle_like_usecase.dart   # оптимистичный апдейт + откат
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── tweet_remote_datasource.dart
│   │   │   │   ├── dto/
│   │   │   │   │   ├── tweet_dto.dart
│   │   │   │   │   └── page_dto.dart
│   │   │   │   ├── mappers/
│   │   │   │   │   └── tweet_mapper.dart
│   │   │   │   ├── store/
│   │   │   │   │   └── tweet_store.dart       # нормализованный кэш + broadcast stream
│   │   │   │   └── repositories/
│   │   │   │       └── tweet_repository_impl.dart # пишет в store, читает сквозь него
│   │   │   └── presentation/
│   │   │       ├── scope/
│   │   │       │   └── tweet_scope.dart
│   │   │       ├── bloc/
│   │   │       │   └── tweet_detail_bloc.dart # твит + тред ответов
│   │   │       ├── cubit/
│   │   │       │   ├── like_cubit.dart
│   │   │       │   └── composer_cubit.dart    # текст, лимит символов, черновик
│   │   │       ├── wm/
│   │   │       │   └── tweet_detail_wm.dart   # DetailBloc + LikeCubit + ComposerCubit
│   │   │       ├── screens/
│   │   │       │   ├── tweet_detail_screen.dart
│   │   │       │   └── create_tweet_screen.dart
│   │   │       └── widgets/
│   │   │           ├── tweet_card.dart        # подписан на watchTweet(id); переиспользуется лентой/поиском/профилем
│   │   │           ├── tweet_actions.dart
│   │   │           └── tweet_body.dart
│   │   │
│   │   ├── profile/                           # ВЛАДЕЛЕЦ домена User
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_profile.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── user_repository.dart   # profile, follow, watchUser(id)
│   │   │   │   └── usecases/
│   │   │   │       └── toggle_follow_usecase.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/…
│   │   │   │   ├── dto/…
│   │   │   │   ├── mappers/…
│   │   │   │   ├── store/
│   │   │   │   │   └── user_store.dart
│   │   │   │   └── repositories/…
│   │   │   └── presentation/
│   │   │       ├── scope/profile_scope.dart
│   │   │       ├── bloc/
│   │   │       │   ├── profile_bloc.dart
│   │   │       │   ├── user_tweets_bloc.dart  # extends PaginatedBloc<TweetId>
│   │   │       │   ├── followers_bloc.dart    # extends PaginatedBloc<UserProfile>
│   │   │       │   └── following_bloc.dart
│   │   │       ├── wm/
│   │   │       │   └── profile_wm.dart        # ProfileBloc + UserTweetsBloc + session (свой/чужой)
│   │   │       ├── screens/
│   │   │       │   ├── profile_screen.dart
│   │   │       │   ├── followers_screen.dart
│   │   │       │   └── following_screen.dart
│   │   │       └── widgets/
│   │   │           ├── profile_header.dart
│   │   │           ├── follow_button.dart
│   │   │           └── stats_row.dart
│   │   │
│   │   ├── auth/                              # сценарии входа; сессией НЕ владеет
│   │   │   ├── domain/
│   │   │   │   ├── entities/auth_tokens.dart
│   │   │   │   ├── repositories/auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart     # API → session.update → прогрев профиля
│   │   │   │       ├── register_usecase.dart
│   │   │   │       └── logout_usecase.dart    # API revoke → session.drop()
│   │   │   ├── data/
│   │   │   │   ├── datasources/auth_remote_datasource.dart
│   │   │   │   ├── dto/…
│   │   │   │   └── repositories/auth_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── scope/auth_scope.dart
│   │   │       ├── cubit/
│   │   │       │   ├── login_form_cubit.dart
│   │   │       │   └── register_form_cubit.dart
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   └── register_screen.dart
│   │   │       └── widgets/
│   │   │           ├── login_form.dart
│   │   │           └── register_form.dart
│   │   │
│   │   ├── home/                              # лента; зависит от tweet/domain
│   │   │   ├── domain/
│   │   │   │   └── repositories/
│   │   │   │       └── timeline_repository.dart  # отдаёт страницы TweetId (твиты — через TweetStore)
│   │   │   ├── data/
│   │   │   │   ├── datasources/timeline_remote_datasource.dart
│   │   │   │   └── repositories/timeline_repository_impl.dart # складывает твиты в TweetStore, наружу — id
│   │   │   └── presentation/
│   │   │       ├── scope/home_scope.dart
│   │   │       ├── bloc/
│   │   │       │   └── timeline_bloc.dart     # extends PaginatedBloc<TweetId>
│   │   │       ├── wm/
│   │   │       │   └── home_wm.dart           # TimelineBloc + scroll-to-top + FAB visibility
│   │   │       ├── screens/home_screen.dart
│   │   │       └── widgets/timeline_list.dart # рендерит tweet/widgets/tweet_card по id
│   │   │
│   │   ├── notifications/
│   │   │   ├── domain/…                       # Notification entity — своя
│   │   │   ├── data/…
│   │   │   └── presentation/
│   │   │       ├── bloc/notifications_bloc.dart  # extends PaginatedBloc<AppNotification>
│   │   │       ├── screens/notifications_screen.dart
│   │   │       └── widgets/notification_tile.dart
│   │   │
│   │   └── search/                            # зависит от tweet/domain и profile/domain
│   │       ├── domain/
│   │       │   └── repositories/search_repository.dart
│   │       ├── data/…
│   │       └── presentation/
│   │           ├── scope/search_scope.dart
│   │           ├── bloc/
│   │           │   ├── search_tweets_bloc.dart   # extends PaginatedBloc<TweetId>
│   │           │   └── search_users_bloc.dart
│   │           ├── cubit/search_query_cubit.dart # текст + debounce + активная вкладка
│   │           ├── wm/
│   │           │   └── search_wm.dart            # QueryCubit → дёргает оба Bloc'а
│   │           ├── screens/search_screen.dart
│   │           └── widgets/
│   │               ├── search_bar_widget.dart
│   │               └── search_results.dart
│   │
│   └── shared/                                # UI kit; без бизнес-логики
│       ├── widgets/
│       │   ├── avatar.dart
│       │   ├── app_shell.dart                 # каркас StatefulShellRoute + bottom bar
│       │   ├── loading_view.dart
│       │   ├── skeleton.dart
│       │   ├── error_view.dart
│       │   ├── empty_view.dart
│       │   └── infinite_scroll_list.dart      # generic: items + onLoadMore + hasMore
│       └── extensions/
│           └── context_x.dart
│
├── test/                                      # зеркалит lib/
│   ├── core/
│   │   ├── network/                           # interceptors: single-flight refresh!
│   │   ├── session/
│   │   └── bloc/                              # PaginatedBloc edge cases
│   ├── features/
│   │   └── <feature>/{domain,data,presentation}/
│   └── shared/
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## Граф зависимостей

```
                    ┌─────────────────────────────┐
                    │            app/             │  composition root
                    │  (знает всё, его не знает   │
                    │         никто)              │
                    └──────────────┬──────────────┘
                                   │
        ┌──────────┬───────────────┼────────────┬─────────────┐
        ▼          ▼               ▼            ▼             ▼
     auth       home            tweet        profile    notifications, search
        │          │               │            │             │
        │          └──► tweet/domain ◄──────────┼─────────────┤
        │                          │            │             │
        │                          └──► profile/domain ◄──────┘
        │
        ▼
   ┌─────────────────────────────────────────────────────────┐
   │                         core/                           │
   │   network · session · error · result · bloc · wm · …    │
   └─────────────────────────────────────────────────────────┘
                                   ▲
                              shared/ (UI kit)
```

Правила:
1. `core` не импортирует ничего из `features`, `shared`, `app`.
2. `shared` импортирует только `core` (темы, утилиты).
3. Фича импортирует: свой код, `core`, `shared`, и **только `domain/`** других фич.
4. `app` — единственное место, где разрешено знать обо всех фичах сразу (сборка скоупов и роутера).
5. Внутри фичи: `presentation → domain ← data`; `domain` не импортирует Dio, Flutter widgets, dto.

---

## Маршрутизация

- `StatefulShellRoute.indexedStack` с ветками: Home / Search / Notifications / Profile — состояние и скролл каждой вкладки сохраняются при переключении.
- `refreshListenable: SessionRefreshListenable(sessionController)` — редирект реагирует на сессию напрямую, минуя Bloc.
- `redirect`: `unknown` → splash; `unauthenticated` + приватный путь → `/login`; `authenticated` + `/login|/register` → `/home`.
- Поверх shell: `/tweet/:id`, `/create`, `/user/:id`, `/user/:id/followers`, `/user/:id/following` (full-screen поверх табов).
- FeatureScopeHolder'ы оборачивают builder'ы веток — зависимости вкладки создаются при первом входе и живут вместе с веткой.

---

## Поток ошибок

| Уровень | Поведение |
|---------|-----------|
| `error_interceptor` | `DioException` → типизированные `ApiException` / `NetworkException` |
| `refresh_interceptor` | 401 → single-flight refresh → retry; провал → `session.drop()` |
| datasource | бросает исключения как есть |
| repository | `try/catch` → `Result<T>` (`Ok` / `Err(Failure)`); маппинг exception → Failure в одном месте |
| usecase | оркестрация; оптимистичные апдейты делают откат стора при `Err` |
| bloc | `Err(failure)` → состояние ошибки с человекочитаемым сообщением |
| wm / screen | `BlocBuilder` → `ErrorView` (полноэкранная), `BlocListener` → `SnackBar` (точечная) |
| router | реагирует только на `SessionState`, не на ошибки Bloc'ов |

---

## Соглашения (чек-лист ревью)

1. Экран не дёргает Dio/datasource — только Bloc/Cubit → (usecase|repository).
2. `domain/` чистый: ни Flutter, ни dio, ни dto.
3. DTO ↔ Entity только через mappers; DTO не покидает `data/`.
4. Импорт чужой фичи — только её `domain/`.
5. Любой список с cursor — наследник `PaginatedBloc`, не своя реализация.
6. Сущности с кэшем (Tweet, User) читаются виджетами через `watch*` стримы репозитория, а не копируются в состояния нескольких Bloc'ов.
7. Usecase создаётся только при наличии оркестрации/правил; пустые пробросы запрещены.
8. WM появляется при 2+ Bloc'ах или локальном UI-стейте; бизнес-логики в WM нет.
9. Владение = ответственность за dispose: Scope диспозит свои Bloc'и/сторы, WM — свои Notifier'ы/подписки/эпизодические Cubit'ы.
10. Мутации твита — оптимистичные: store обновляется до ответа сервера, откат при ошибке (в usecase).
11. Без кодогенерации и freezed; equality — `equatable`, json — руками.
12. Тесты зеркалят `lib/`; обязательные: single-flight refresh, `PaginatedBloc` (двойной loadMore, refresh во время loadMore), откат оптимистичного лайка, redirect-матрица роутера.
