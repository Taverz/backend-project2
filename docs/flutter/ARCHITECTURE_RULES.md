# Chirp Flutter — Architecture Rules

Правила создания фич, нейминга и ревью. Дополняет `STRUCTURE.md`.

---

## 1. Алгоритм создания новой фичи

Пошагово, в этом порядке. Не начинать с UI.

```
Шаг 0. Определить границы
        ├── Это новая фича или часть существующей?
        ├── Какими доменными сущностями она оперирует?
        └── Она ВЛАДЕЕТ этими сущностями или ПОЛЬЗУЕТСЯ чужими?

Шаг 1. domain/ — контракты
        ├── entities: если фича владеет сущностью — создать здесь
        ├── repositories: абстрактный интерфейс (что фича умеет, без «как»)
        └── usecases: только если уже видна оркестрация (см. §5)

Шаг 2. data/ — реализация
        ├── dto: классы под JSON бэкенда, поле в поле
        ├── datasources: вызовы Dio по endpoint-константам
        ├── mappers: dto → entity (и обратно для запросов)
        ├── store: только если сущность фичи нужна другим фичам реактивно
        └── repositories: impl контракта; маппинг exception → Failure здесь

Шаг 3. presentation/ — состояние и UI
        ├── bloc / cubit: по таблице выбора (§4)
        ├── wm: только если на экране сошлись 2+ Bloc'а или есть локальный UI-стейт
        ├── scope: holder, создающий datasources/repo/usecases/Bloc'и фичи
        ├── screens: по одному файлу на маршрут
        └── widgets: куски экрана; переиспользуемое между фичами → shared/

Шаг 4. Подключение
        ├── маршрут в app/router/routes.dart + app_router.dart
        ├── ScopeHolder оборачивает builder маршрута/ветки
        └── endpoint-константы в core/network/endpoints.dart

Шаг 5. Тесты (зеркально lib/)
        ├── mappers: dto → entity на реальном JSON-примере
        ├── repository: с мок-datasource, включая маппинг ошибок
        └── bloc: bloc_test на happy path + ошибку + edge (двойной loadMore и т.п.)
```

**Минимальная фича** (один экран, одна загрузка) — это всё равно три слоя, но маленьких: 1 entity или переиспользование чужой, 1 контракт, 1 impl, 1 datasource, 1 Bloc, 1 screen. Не схлопывать слои «потому что фича маленькая» — маленькие фичи растут.

---

## 2. Что в каком слое: право / неправо

### domain/ — «что умеет фича», чистый Dart

| ✅ Можно | ❌ Нельзя |
|---------|----------|
| Entities с бизнес-полями и `equatable` | Импорт `dio`, `flutter/*`, любых dto |
| Абстрактные репозитории (`abstract interface class`) | Методы, возвращающие `Response`, `Map<String, dynamic>` |
| Usecases с реальной оркестрацией | JSON-парсинг (`fromJson` — это data) |
| Типы из `core/result`, `core/error/failures` | Знание про HTTP-коды, заголовки, пагинационные курсоры бэкенда* |
| `Stream<T>` / `Future<Result<T>>` в сигнатурах | `BuildContext`, навигация, SnackBar |

\* курсор как непрозрачный `String? cursor` в контракте — допустимо; знание его формата — нет.

**Тест чистоты:** файл из `domain/` должен компилироваться, если из проекта удалить Flutter и Dio. Если нет — что-то протекло.

### data/ — «как фича это делает»

| ✅ Можно | ❌ Нельзя |
|---------|----------|
| Dio, dto, `jsonDecode`, заголовки, коды | Импорт чего-либо из `presentation/` |
| `RepositoryImpl` ловит exceptions → `Err(Failure)` | Пробрасывать `DioException` наружу из репозитория |
| Store (in-memory кэш) для shared-сущностей | Бизнес-правила (валидация, оркестрация — это domain) |
| Mappers как чистые функции/статические методы | Возвращать dto из публичных методов репозитория |

**Правило одного выхода:** наружу из `data/` выходят только entities и `Result`. Dto и исключения умирают внутри.

### presentation/ — «как это выглядит и реагирует»

| ✅ Можно | ❌ Нельзя |
|---------|----------|
| Bloc/Cubit зовут usecase или репозиторий (контракт) | Bloc создаёт Dio / datasource / `RepositoryImpl` сам |
| WM комбинирует Bloc'и, держит `ValueNotifier` | WM зовёт репозиторий/usecase напрямую |
| Виджет читает зависимости из Scope | Виджет зовёт репозиторий, минуя Bloc |
| Навигация через `context.go/push` в обработчиках экрана/WM | Навигация внутри Bloc'а |
| `BlocListener` → SnackBar/диалог | Показ UI из Cubit'а (`showDialog` внутри Cubit) |

**Правило про навигацию:** Bloc эмитит состояние («твит создан»), экран/WM на него реагирует переходом. Bloc не знает о роутере.

### core/ vs shared/ vs feature — куда положить класс

```
Это виджет без бизнес-логики, нужный 2+ фичам?        → shared/widgets
Это утилита/инфраструктура без UI (форматтер, dio,
result, базовый Bloc)?                                 → core/
Это нужно только одной фиче?                           → внутрь фичи
Это виджет, завязанный на сущность фичи
(TweetCard, FollowButton)?                             → presentation/widgets
                                                         фичи-владельца,
                                                         другие импортируют его оттуда
```

Анти-паттерн: «положу в core, вдруг пригодится». В core попадает то, что **уже** используется из 2+ мест или является инфраструктурой по природе (network, session). Преждевременный вынос = свалка.

---

## 3. Нейминг файлов и классов

### Общие правила

- Файлы: `snake_case.dart`. Один публичный класс — один файл. Имя файла = имя класса в snake_case.
- Классы: `PascalCase`, роль класса — **суффиксом**, без сокращений кроме закреплённых (`Wm`, `Dto`).
- Приватные реализации/стейты — с `_` только внутри одного файла (части Bloc допустимо держать в `part`-файлах: `xxx_event.dart`, `xxx_state.dart`).

### Таблица суффиксов

| Роль | Класс | Файл | Пример |
|------|-------|------|--------|
| Entity | без суффикса | `tweet.dart` | `Tweet`, `UserProfile` |
| Контракт репозитория | `XxxRepository` | `tweet_repository.dart` | `TweetRepository` |
| Реализация | `XxxRepositoryImpl` | `tweet_repository_impl.dart` | `TweetRepositoryImpl` |
| Datasource | `XxxRemoteDataSource` / `XxxLocalDataSource` | `tweet_remote_datasource.dart` | `TweetRemoteDataSource` |
| DTO | `XxxDto` / `XxxRequestDto` / `XxxResponseDto` | `tweet_dto.dart` | `TweetDto`, `LoginRequestDto` |
| Mapper | `XxxMapper` | `tweet_mapper.dart` | `TweetMapper.fromDto(dto)` |
| Store | `XxxStore` | `tweet_store.dart` | `TweetStore` |
| UseCase | `ГлаголXxxUseCase` | `toggle_like_usecase.dart` | `ToggleLikeUseCase`, `PostTweetUseCase` |
| Bloc | `XxxBloc` (+Event/State) | `timeline_bloc.dart` | `TimelineBloc` |
| Cubit | `XxxCubit` | `login_form_cubit.dart` | `LoginFormCubit` |
| WM | `XxxWm` | `tweet_detail_wm.dart` | `TweetDetailWm` |
| Scope | `XxxScope` + `XxxScopeHolder` | `home_scope.dart` | `HomeScope.of(context)` |
| Экран | `XxxScreen` | `profile_screen.dart` | `ProfileScreen` |
| Виджет | по смыслу, без `Widget`-суффикса* | `tweet_card.dart` | `TweetCard`, `FollowButton` |
| Failure | `XxxFailure` | в `failures.dart` | `NetworkFailure`, `ValidationFailure` |
| Exception | `XxxException` | в `exceptions.dart` | `ApiException` |

\* исключение — конфликт с Flutter SDK: `SearchBarWidget`, т.к. `SearchBar` занят.

### Нейминг событий и состояний Bloc

События — **факт, который произошёл, с точки зрения UI/мира**, в прошедшем времени или как запрос. Не императив «сделай»:

| ✅ Хорошо | ❌ Плохо | Почему |
|----------|---------|--------|
| `TimelineRequested` | `LoadTimeline` | событие описывает «что случилось», не команду |
| `TimelineRefreshRequested` | `DoRefresh` | |
| `TimelineLoadMoreRequested` | `FetchNextPage` | |
| `LikeToggled(tweetId)` | `SetLike(true)` | UI сообщает о действии, решает Bloc |

Состояния — sealed-иерархия с именами-фактами:

```
TimelineState
├── TimelineInitial
├── TimelineLoadInProgress
├── TimelineLoadSuccess(items, hasMore, isLoadingMore)
└── TimelineLoadFailure(failure)
```

Допустима и одно-классовая модель со `status: enum {initial, loading, success, failure}` + `copyWith` — выбирается **один стиль на проект** (у нас: sealed-иерархия для Bloc, одно-классовая для простых Cubit-форм).

### Нейминг методов

| Где | Паттерн | Пример |
|-----|---------|--------|
| Repository | `get/watch/create/update/delete + сущность` | `getTimelinePage`, `watchTweet` |
| UseCase | единственный метод `call()` или `execute()` — один на проект (у нас `call`) | `toggleLikeUseCase(tweetId)` |
| WM, обработчики UI | `on + Что + Действие` | `onLikeTap`, `onScrollEnd`, `onRetryPressed` |
| Cubit, мутации | глагол | `updateQuery`, `togglePasswordVisibility` |
| Store | `put / putAll / get / watch / remove` | `tweetStore.put(tweet)` |

### Нейминг тестов

Файл: `<имя_файла>_test.dart`, зеркальный путь. Группы — по методу/сценарию, кейсы — «должен … когда …»:
`'эмитит TimelineLoadFailure, когда репозиторий вернул Err(NetworkFailure)'`.

---

## 4. Выбор инструмента состояния

```
Состояние нужно ТОЛЬКО одному виджету и оно тривиально
(открыт/закрыт, видимость пароля)?
  → setState / ValueNotifier внутри State. Не заводить Cubit ради bool.

Состояние экрана, мутации простые, событий-потока нет
(форма, фильтры, табы)?
  → Cubit.

Есть поток событий, конкуренция, transformers
(пагинация, поиск с debounce/switchMap, long-polling)?
  → Bloc. Использовать transformers (droppable для loadMore,
    restartable для поиска), а не ручные флаги.

На экране 2+ Bloc/Cubit, которым нужна координация,
или Bloc-стримы надо смешать с локальными ValueNotifier?
  → WM поверх них. Bloc'и не знают о WM и друг о друге.

Состояние нужно НЕСКОЛЬКИМ экранам/фичам
(текущий твит, профиль, сессия)?
  → НЕ глобальный Bloc. Store в data-слое владельца + watch-стримы,
    либо SessionController-подобный контроллер в core.
```

Запрещено: Bloc слушает другой Bloc напрямую (`blocA.stream.listen` внутри blocB). Связь между Bloc'ами — только через WM (на одном экране) или через store/контроллер (между экранами).

---

## 5. Когда нужен UseCase

```
Операция = один вызов одного репозитория без доп. правил?
  → Bloc зовёт репозиторий напрямую. Usecase-проброс ЗАПРЕЩЁН.

Есть хотя бы одно из:
  • 2+ репозитория/сервиса в одной операции
  • оптимистичное обновление с откатом
  • доменная валидация перед запросом
  • побочные эффекты (прогрев кэша, аналитика домена, очистка)
  → UseCase обязателен, и вся эта логика живёт ТОЛЬКО в нём
    (не дублируется в Bloc).
```

Признак нарушения на ревью: в Bloc'е появилось «сначала А, потом Б, при ошибке откатить В» — это сбежавший usecase.

---

## 6. Правила скоупов и владения

1. **Кто создал — тот диспозит.** ScopeHolder закрывает свои Bloc'и и сторы в `dispose`. WM закрывает свои Notifier'ы, подписки и эпизодические Cubit'ы. Никто не закрывает чужое.
2. **Уровень = время жизни.** Нужно всему приложению → AppScope. Нужно вкладке/ветке → FeatureScope. Нужно одному экрану → ScreenScope/State.
3. **Scope отдаёт готовые объекты,** виджеты не собирают зависимости из кусков (`AppScope.of(context).dio` в экране — нарушение; экран берёт Bloc/WM, не сырой Dio).
4. **`of(context)` — только в build/initState-фазе** виджетов и фабриках WM. Не передавать `BuildContext` в Bloc/usecase/репозиторий — никогда.
5. Новая глобальная зависимость в AppScope — повод для обсуждения на ревью, а не дефолт.

---

## 7. Анти-паттерны (немедленный reject на ревью)

| # | Симптом | Чем заменить |
|---|---------|--------------|
| 1 | `Dio`/`http` импорт в `presentation/` или `domain/` | datasource в data |
| 2 | dto в сигнатуре Bloc'а/usecase'а/контракта | mapper → entity |
| 3 | `Map<String, dynamic>` гуляет выше data-слоя | dto + entity |
| 4 | Bloc слушает Bloc | WM или store |
| 5 | `BuildContext` в Bloc/usecase | состояние + реакция на экране |
| 6 | `showDialog`/`context.go` внутри Bloc/Cubit | `BlocListener` на экране |
| 7 | Копия сущности Tweet/User в состоянии второго Bloc'а | список id + `watchTweet(id)` |
| 8 | Своя cursor-пагинация вместо `PaginatedBloc` | наследование |
| 9 | Usecase из одной строки `repo.method()` | прямой вызов репозитория |
| 10 | `try { } catch (e) { print(e); }` — проглоченная ошибка | `Result` + состояние ошибки |
| 11 | Строковый URL/route в коде фичи | `endpoints.dart` / `routes.dart` |
| 12 | Импорт `features/x/data/...` из `features/y/...` | только `features/x/domain/...` |
| 13 | Бизнес-логика в WM («если лайков > 0 …») | domain/Bloc; WM только координирует |
| 14 | Глобальный синглтон / static state / GetIt | scope-дерево |
| 15 | «Положу в core, пригодится» | в фичу; выносить при втором потребителе |

---

## 8. Чек-лист ревью новой фичи

**Структура**
- [ ] Есть все три слоя; `domain/` компилируем без Flutter/Dio (мысленный тест)
- [ ] Сущности: фича владеет своими, чужие — импорт только из `*/domain`
- [ ] Endpoint'ы и маршруты — в константах core/app

**Data**
- [ ] dto ↔ entity через mapper; dto не выходит из data
- [ ] RepositoryImpl возвращает `Result`, исключения не утекают
- [ ] Если сущность shared — мутации идут через store

**Состояние**
- [ ] Инструмент выбран по таблице §4 (нет Cubit'а ради bool, нет Bloc-to-Bloc)
- [ ] Пагинация — через `PaginatedBloc`
- [ ] Usecase'ы — только содержательные (§5)
- [ ] События названы как факты, состояния — sealed/единый стиль

**UI**
- [ ] Экран не трогает репозитории/Dio; навигация — на экране/в WM по состояниям
- [ ] Loading / Error(+Retry) / Empty / Data — все четыре состояния отрисованы
- [ ] WM (если есть) без бизнес-логики, с dispose всего созданного

**Жизненный цикл**
- [ ] ScopeHolder создаёт и диспозит зависимости фичи
- [ ] Подписки на стримы закрываются (Bloc.close / WM.dispose)

**Тесты**
- [ ] mapper на реальном JSON-фикстуре
- [ ] repository: успех + маппинг ошибки
- [ ] bloc_test: happy / failure / специфичный edge фичи

**Нейминг**
- [ ] Суффиксы и snake_case по таблице §3, файл = класс
