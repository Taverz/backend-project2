# Chirp Flutter Monorepo — Quick Context for AI Agents

Краткий контекст для AI-агентов. Полная документация — в `../docs/flutter/`.

---

## Структура монорепо (pubspec workspaces)

```
flutter/
├── pubspec.yaml                  # root, секция `workspace:`
├── apps/
│   ├── chirp/                    # основное мобильное приложение
│   │   ├── lib/{app, core, features}/
│   │   └── test/
│   └── storybook/                # widgetbook — каталог UI-компонентов
│       └── lib/{main.dart, use_cases/}
└── packages/
    ├── app_api/                  # HTTP-клиент: интерфейсы сервисов + Dio-impl
    │   └── lib/src/{dto, services, client}/
    └── ui_kit/                   # дизайн-система: темы, иконки, виджеты
        └── lib/{theme, icons, widgets, extensions}/
```

Каждый member-пакет имеет `resolution: workspace` и подключается через `path:`-зависимость. Один `flutter pub get` в корне резолвит всё.

## Навигация по документам

| Что нужно | Файл |
|-----------|------|
| Что уже реализовано | [`../docs/flutter/FOUNDATION.md`](../docs/flutter/FOUNDATION.md) |
| Правила кода, нейминг, анти-паттерны | [`../docs/flutter/ARCHITECTURE_RULES.md`](../docs/flutter/ARCHITECTURE_RULES.md) |
| Как добавить новую фичу | [`../docs/flutter/HOW-TO-ADD-FEATURE.md`](../docs/flutter/HOW-TO-ADD-FEATURE.md) |
| Тесты | [`../docs/flutter/TESTING.md`](../docs/flutter/TESTING.md) |
| Архитектурные пробелы, roadmap, идеи | [`../docs/flutter/ARCHITECTURE_GAPS_AND_IDEAS.md`](../docs/flutter/ARCHITECTURE_GAPS_AND_IDEAS.md) |
| Работа с API (контракт, фикстуры, codegen) | [`packages/app_api/docs/DEVELOPMENT.md`](packages/app_api/docs/DEVELOPMENT.md) |
| Правила построения виджетов ui_kit | [`packages/ui_kit/docs/WIDGET_GUIDELINES.md`](packages/ui_kit/docs/WIDGET_GUIDELINES.md) |

## Команды

```bash
cd flutter
flutter pub get                                 # резолвит весь workspace

# Приложение Chirp
cd apps/chirp && flutter run --dart-define=API_URL=http://localhost:8080

# Storybook (UI-каталог)
cd apps/storybook && flutter run

# Тесты
flutter test apps/chirp
flutter test packages/ui_kit
flutter test packages/app_api
```

## Критические правила

1. `domain/` — чистый Dart: нет Flutter/Dio/DTO/Result.
2. Импорт из другой фичи — только через `features/x/domain/`.
3. **Никакого `Result<T>`** — ошибки через `try/catch`. `RepositoryImpl` ловит инфраструктурные исключения и бросает `Failure` (`implements Exception`).
4. **Никакого `Cubit`**. Bloc — только для внешнего I/O. Локальный стейт формы — в `StatefulWidget` через `ValueNotifier` + миксин.
5. **Между Bloc и UI — слой `XxxViewModel`**: интерфейс с `ValueListenable<XxxViewState> get state` + методы-команды (`submit`, `refresh`, ...). Экраны импортируют только VM и `XxxViewState`, ни одного импорта `flutter_bloc` в `screens/` нет. Смена state-manager переписывает только impl `BlocXxxViewModel`. `XxxViewState` — plain Dart-объект.
6. **`flutter_bloc` живёт только в `presentation/bloc/` и `view_models/`-impl** (BlocXxxViewModel). UI читает state через `ValueListenableBuilder<XxxViewState>`.
7. **`BlocProvider`/`BlocListener` НЕ используем.** Side-effects (snackbar на failure) — в `XxxScopeHolder` через `vm.state.addListener(...)`.
8. **Material нельзя кроме `Scaffold`** в экранах. `TextField` оборачивается в `AppTextField` из ui_kit. Все остальные UI-примитивы (`AppButton`, `AppAppBar`, `AppIcon`, `AppLoader`, `AppSnackBar`, `AppTextButton`) — из `package:ui_kit/ui_kit.dart`.
9. **Иконки — через flutter_gen**: SVG в `packages/ui_kit/assets/icons/`, доступ через `AppIcons.<name>` (под капотом `Assets.icons.<name>` от flutter_gen). `AppIcon` отрисовывает `SvgGenImage` через `colorFilter`.
10. **`AppScope` владеет всеми repositories и usecases проекта.** Фичи берут готовые (`AppScope.read(context).loginUseCase`). `Dio`/`AppApiClient` — приватные детали внутри `_AppScopeHolderState`, наружу не отдаются. Каждая новая фича добавляет свои поля в `AppScope` и инициализацию в `_initAsync()`. В `XxxScopeHolder.initState` создаются только Bloc/VM — не репо/usecase (они уже готовы).

## Слои и термины

```
RemoteDataSource (app_api)  →  Repository (фича)  →  UseCase (фича)
   ↑                            ↑                     ↑
   контракт API                  маппинг ошибок         оркестрация (если нужна)
   живёт в AppApiClient.xxx      try/catch → throw      repo + session и т.п.
                                  Failure
```

- В `app_api` нет «Services» — есть **`XxxRemoteDataSource`** (interface) + `XxxRemoteDataSourceDioImpl` + `MockXxxRemoteDataSource`.
- Фича не оборачивает datasource ещё раз. `AppScope` создаёт `XxxRepositoryImpl(api.xxx)` напрямую.
- `app_api` не знает ни про какой бэкенд — он зеркалит swagger-контракт. В комментариях/доках не писать «Go-бэкенд» или «Python-бэкенд».
- Mock-first: `--dart-define=USE_MOCK_API=true` подключает `MockAppApiClient` (все datasource'ы → фикстуры).

## Per-package analysis_options

- Корневой `flutter/analysis_options.yaml` — базовый набор (single quotes, trailing commas, strict-casts).
- `packages/app_api/analysis_options.yaml` — исключает `tool/` (CLI-скрипт).
- `packages/ui_kit/analysis_options.yaml` — исключает `lib/gen/` (flutter_gen вывод).
- `apps/storybook/analysis_options.yaml` — мягче для use-case demos.
- `packages/qa_tools_flutter/analysis_options.yaml` — собственный (форк вендора).
- `apps/chirp/analysis_options.yaml` — самый строгий (основное приложение).
11. Пагинация — только `extends PaginatedBloc<T>`.
12. UseCase — только при оркестрации 2+ сервисов (например, repo + SessionController).
13. Навигация (`context.go`) — на экране, не в Bloc/VM.
14. DI в ScopeHolder — `initState` + `AppScope.read(context)` (lookup без подписки).
15. **Sentry инициализируется через `SentrySetup.bootstrap(runApp)`** в `main.dart`; ничего другого в `main.dart` нет.
16. **Debug-overlay через `qa_tools_flutter` (`FlutterLens`)** — обёртка `MaterialApp.router` в `ChirpApp`. Включается только в `kDebugMode`.
17. **Для каждого endpoint API — JSON-фикстуры `request`+`response` в `packages/app_api/fixtures/<feature>/`.** Используются: (а) тестами через `FixtureLoader.loadJson(...)`, (б) `MockAppApiClient` для оффлайн-режима (`--dart-define=USE_MOCK_API=true`), (в) как документация контракта в git. Подробности — `packages/app_api/README.md`.
18. **`fixtures/<endpoint>_response.json` обновляются с живого бэка** через `dart run packages/app_api/tool/refresh_fixtures.dart --api-url=... [--only=auth/login]`. `<endpoint>_request.json` редактируется руками — это эталонный вход. Новые ручки регистрировать в `_endpoints` каталоге скрипта.
19. **Storybook (`apps/storybook`) обёрнут в `FlutterLens` так же, как chirp** — debug-инспектор виджетов ui_kit доступен без основного приложения.

## Порядок в файлах Bloc/класса

- В `xxx_bloc.dart`: сначала `class XxxBloc`, потом `// ── States ──`, потом `// ── Events ──`.
- В классах: конструктор → final-поля → `@override`-методы → private `_method`.

## Что лежит где

- `apps/chirp/lib/core/` — session, network (Dio + интерсепторы), error/failures, bloc/paginated_bloc, storage, utils.
- `apps/chirp/lib/features/auth/` — фича Auth. Образец для следующих фич.
- `packages/ui_kit/` — `AppColors`, `AppTypography`, `AppTheme`, `AppButton`, `AppTextField`, `AppIcon`, `AppLoader`, `AppAppBar`, `AppSnackBar`, `AppIcons` каталог, `ErrorView`, `EmptyView`, `Avatar`, `LoadingView`, `Skeleton`, `InfiniteScrollList`, `ContextX` extension.
- `packages/app_api/` — `AppApiClient` фасад, `AuthService` (interface + Dio-impl), DTO `AuthResponseDto`/`LoginRequestDto`/`RegisterRequestDto`.
- `apps/storybook/` — widgetbook с use-cases для всех UI-примитивов.
