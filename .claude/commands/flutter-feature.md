# /flutter-feature

Создаёт новую Flutter-фичу для проекта Chirp по строгим архитектурным правилам.

## Контекст проекта

Архитектура описана в `docs/flutter/STRUCTURE.md` и `docs/flutter/ARCHITECTURE_RULES.md`.

Кратко:
- Clean Architecture: `domain/` → `data/` → `presentation/`
- State: `flutter_bloc` (Bloc/Cubit) + WM (Widget Model)
- DI: InheritedWidget-скоупы (AppScope → FeatureScope → ScreenScope)
- Навигация: `go_router`
- HTTP: `dio` + интерсепторы
- Результат: `Result<T>` из `core/result/result.dart`
- Ошибки: `Failure` sealed из `core/error/failures.dart`
- Пагинация: **обязательно** наследовать `PaginatedBloc<T>`, не своя реализация
- Без кодогенерации: нет `freezed`, нет `json_serializable`

## Шаги создания фичи (строго в этом порядке)

### Шаг 0. Определи границы
- Фича ВЛАДЕЕТ своими сущностями, или ИСПОЛЬЗУЕТ чужие?
- Если использует чужие → импортировать ТОЛЬКО `features/x/domain/`
- Если владеет → создать entities в своём `domain/`

### Шаг 1. domain/
```
features/<name>/domain/
├── entities/           # entity без суффикса (Tweet, UserProfile, ...)
├── repositories/       # abstract interface class XxxRepository
└── usecases/           # только при оркестрации 2+ репозиториев/правил
```
- `domain/` — чистый Dart: никаких `import 'package:dio/...`, `package:flutter/...`
- RepositoryImpl возвращает `Future<Result<T>>` в сигнатурах через Stream/Result

### Шаг 2. data/
```
features/<name>/data/
├── datasources/        # XxxRemoteDataSource — только Dio-вызовы
├── dto/                # XxxDto — json-поля бэкенда; DTO не выходит из data
├── mappers/            # XxxMapper.fromDto(), .toRequest() — чистые функции
├── store/              # XxxStore — только если сущность нужна другим фичам реактивно
└── repositories/       # XxxRepositoryImpl: try/catch → Result, маппинг здесь
```

### Шаг 3. presentation/
```
features/<name>/presentation/
├── scope/              # XxxScope (InheritedWidget) + XxxScopeHolder (StatefulWidget)
├── bloc/               # XxxBloc + XxxEvent + XxxState (sealed)
│                       # или XxxCubit (если нет event-потока)
├── wm/                 # XxxWm : BaseWm — только при 2+ Bloc'ах или локальном UI-стейте
├── screens/            # XxxScreen — один файл на маршрут
└── widgets/            # куски UI фичи
```

### Шаг 4. Подключение
- Маршрут в `lib/app/router/routes.dart` + `lib/app/router/app_router.dart`
- Endpoint в `lib/core/network/endpoints.dart`
- ScopeHolder оборачивает builder ветки/маршрута

### Шаг 5. Тесты
```
test/features/<name>/
├── domain/             # если есть domain-логика
├── data/               # mapper_test.dart (реальный JSON), repository_test.dart (мок datasource)
└── presentation/       # bloc_test.dart (bloc_test пакет): happy path, failure, edge
```

## Нейминг (обязательно)

| Роль | Суффикс | Пример |
|------|---------|--------|
| Entity | — | `Tweet` |
| Repository контракт | `XxxRepository` | `TweetRepository` |
| Repository impl | `XxxRepositoryImpl` | `TweetRepositoryImpl` |
| Datasource | `XxxRemoteDataSource` | `TweetRemoteDataSource` |
| DTO | `XxxDto` | `TweetDto` |
| Mapper | `XxxMapper` | `TweetMapper` |
| UseCase | `ГлаголXxxUseCase` | `ToggleLikeUseCase` |
| Bloc | `XxxBloc` | `TimelineBloc` |
| Cubit | `XxxCubit` | `LoginFormCubit` |
| WM | `XxxWm` | `TweetDetailWm` |
| Scope | `XxxScope` + `XxxScopeHolder` | `HomeScope` |
| Screen | `XxxScreen` | `ProfileScreen` |

События Bloc: факт в прошедшем/инфинитиве (`TimelineRequested`, не `LoadTimeline`).  
Состояния: sealed-иерархия (`TimelineInitial`, `TimelineLoadInProgress`, `TimelineLoadSuccess`, `TimelineLoadFailure`).

## Стоп-список (reject на ревью)

1. `import 'package:dio/...'` в `domain/` или `presentation/`
2. DTO в сигнатуре Bloc'а, usecase'а, репозитория
3. `Map<String, dynamic>` выше data-слоя
4. Bloc слушает другой Bloc напрямую
5. `BuildContext` в Bloc/usecase
6. `context.go/push` или `showDialog` внутри Bloc/Cubit
7. Копия сущности Tweet/User в состоянии второго Bloc'а → использовать `watchTweet(id)`
8. Своя cursor-пагинация вместо `PaginatedBloc`
9. UseCase из одной строки `repo.method()` — прямой вызов репозитория
10. `import 'features/x/data/...'` из другой фичи → только `domain/`

## Выбор инструмента состояния

```
Один вызов репозитория, без правил     → Bloc вызывает репозиторий напрямую
Форма, фильтры, простые мутации       → Cubit
Пагинация, поиск с debounce           → Bloc (extends PaginatedBloc<T>)
2+ Bloc'а на экране / локальный стейт → WM поверх них
```

## Задание (заполни перед выполнением)

Фича: **$ARGUMENTS**

Перед началом:
1. Прочитай `docs/flutter/STRUCTURE.md` и `docs/flutter/ARCHITECTURE_RULES.md`
2. Определи, какими сущностями владеет фича
3. Создай файлы в порядке шагов 1–5
4. После создания запусти `flutter test test/features/<name>/`
