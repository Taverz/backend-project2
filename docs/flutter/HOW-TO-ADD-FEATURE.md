# Chirp Flutter — How to Add a Feature

Пошаговый процесс добавления новой фичи. Порядок шагов не произвольный — он следует из правила «domain не знает о data, data не знает о presentation».

Полные правила и мотивация — в `ARCHITECTURE_RULES.md`.

---

## Шаг 0. Определи границы фичи

Перед написанием кода ответь на три вопроса:

**1. Это новая фича или часть существующей?**
> Пример: «показ твита на экране профиля» — это не новая фича, это экран внутри `features/profile/`.

**2. Какими сущностями оперирует фича?**
> Пример: фича `home` оперирует `Tweet` — но не владеет им. Владелец `Tweet` — `features/tweet/`.

**3. Фича ВЛАДЕЕТ этими сущностями или ИСПОЛЬЗУЕТ чужие?**

| Ситуация | Действие |
|----------|---------|
| Фича вводит новую сущность | создать `entities/` в своём `domain/` |
| Фича использует чужую сущность | импортировать только `features/owner/domain/` |

---

## Шаг 1. domain/ — контракты

```
features/<name>/domain/
├── entities/
│   └── <name>.dart              # Entity: поля + equatable, без логики UI/HTTP
├── repositories/
│   └── <name>_repository.dart   # abstract interface class XxxRepository
└── usecases/                    # только если есть оркестрация
    └── do_something_usecase.dart
```

**Проверка чистоты domain/**: файлы должны компилироваться без Flutter и Dio.  
Запрещено: `import 'package:dio/...`, `import 'package:flutter/...`, DTO-типы, `Map<String, dynamic>`, `Result<T>` (его нет).

**Контракты возвращают `Future<T>` и бросают `Failure` при ошибке** (`Failure implements Exception`). Никакого `Result<T>` / `Ok` / `Err`.

**UseCase нужен, если есть хотя бы одно из:**
- 2+ репозитория в одной операции
- оптимистичное обновление с откатом
- валидация перед запросом
- побочные эффекты (прогрев кэша, аналитика)

Пустой проброс `call() => repo.method()` — не UseCase, просто убери прослойку.

---

## Шаг 2. data/ — реализация

```
features/<name>/data/
├── datasources/
│   └── <name>_remote_datasource.dart  # только Dio-вызовы по Endpoints.*
├── dto/
│   └── <name>_dto.dart                # JSON-поля бэкенда; не покидает data/
├── mappers/
│   └── <name>_mapper.dart             # static fromDto() / toRequest()
├── store/                             # только если сущность нужна другим фичам реактивно
│   └── <name>_store.dart
└── repositories/
    └── <name>_repository_impl.dart    # try/catch → Result, маппинг exception→Failure здесь
```

**Правила:**
- DTO не выходит из `data/` — наружу только entities (через return) и `Failure` (через throw)
- `RepositoryImpl` ловит инфраструктурные исключения и **бросает `Failure`**. Никаких `Result<T>`.
- Новые URL → только через `core/network/endpoints.dart`

**Маппинг исключений в Failure** (шаблон для `RepositoryImpl`):
```dart
Future<Tweet> getById(String id) async {
  try {
    final dto = await _dataSource.getTweet(id);
    return TweetMapper.fromDto(dto);
  } on UnauthorizedException {
    throw const UnauthorizedFailure();
  } on ApiException catch (e) {
    if (e.statusCode == 404) throw const NotFoundFailure();
    throw ServerFailure(statusCode: e.statusCode);
  } on NetworkException {
    throw const NetworkFailure();
  }
}
```

Bloc-caller обрабатывает так:
```dart
try {
  final tweet = await _repository.getById(id);
  emit(TweetLoadSuccess(tweet));
} on Failure catch (failure) {
  emit(TweetLoadFailure(failure));
} catch (_) {
  emit(const TweetLoadFailure(UnknownFailure()));
}
```

---

## Шаг 3. presentation/ — состояние и UI

```
features/<name>/presentation/
├── scope/
│   └── <name>_scope.dart         # XxxScope (InheritedWidget) + XxxScopeHolder
├── bloc/                         # ТОЛЬКО если есть внешний вызов (API/БД/сервис)
│   └── <name>_bloc.dart          # события/состояния в том же файле или part-файлы
├── mixins/                       # переиспользуемая UI-логика (валидация форм и т.п.)
│   └── <name>_form_validation_mixin.dart
├── wm/                           # только при 2+ Bloc'ах или сложной координации
│   └── <name>_wm.dart
├── screens/
│   └── <name>_screen.dart
└── widgets/
    └── <name>_tile.dart          # переиспользуемые куски UI фичи
```

### Выбор инструмента состояния

Принцип: **Bloc — только для внешнего I/O.** Cubit на проекте не используем. Локальный UI-стейт — в виджете.

```
Локальный стейт виджета (текст инпута, видимость пароля, errorText
поля, флаг шагa визарда)?
  → StatefulWidget + TextEditingController + ValueNotifier.
    Логику валидации — в миксин, подмешиваемый в State.

Есть вызов API/БД/сервиса (login, fetchTimeline, sendTweet)?
  → Bloc с sealed-состояниями (XxxInitial/InProgress/Success/Failure).
    Bloc держит только статус операции, не локальный UI-стейт формы.

Пагинация?
  → extends PaginatedBloc<T>.

2+ Bloc'а на экране?
  → WM поверх них.
```

### Именование событий и состояний Bloc

События — факт, а не команда:
```dart
// ✅
class TimelineRequested extends PaginatedEvent {}
class LikeToggled extends XxxEvent { final String tweetId; }

// ❌
class LoadTimeline extends XxxEvent {}
class SetLike extends XxxEvent { final bool value; }
```

Состояния — sealed-иерархия:
```dart
sealed class XxxState extends Equatable {}
final class XxxInitial extends XxxState {}
final class XxxLoadInProgress extends XxxState {}
final class XxxLoadSuccess extends XxxState { final List<Tweet> items; ... }
final class XxxLoadFailure extends XxxState { final Failure failure; }
```

### ScopeHolder — шаблон

DI создаётся в `initState` через `AppScope.read(context)` (lookup без подписки, разрешён в `initState`). `didChangeDependencies` для DI не используем.

```dart
class HomeScopeHolder extends StatefulWidget { ... }

class _HomeScopeHolderState extends State<HomeScopeHolder> {
  late final TimelineBloc _timelineBloc;

  @override
  void initState() {
    super.initState();
    final appScope = AppScope.read(context);  // lookup без подписки
    _timelineBloc = TimelineBloc(TimelineRepositoryImpl(
      TimelineRemoteDataSource(appScope.dio),
    ));
  }

  @override
  void dispose() {
    _timelineBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HomeScope(
    timelineBloc: _timelineBloc,
    child: widget.child,
  );
}
```

---

## Шаг 4. Подключение в app/

**Добавь маршрут** в `lib/app/router/routes.dart`:
```dart
static const home = '/home';
```

**Подключи в** `lib/app/router/app_router.dart` — оберни builder ветки в `ScopeHolder`:
```dart
StatefulShellBranch(routes: [
  GoRoute(
    path: Routes.home,
    builder: (_, state) => const HomeScopeHolder(child: HomeScreen()),
  ),
]),
```

**Добавь endpoint** в `lib/core/network/endpoints.dart`:
```dart
static const timeline = '$_base/timeline';
```

---

## Шаг 5. Тесты

Минимальный набор для каждой фичи:

```bash
test/features/<name>/
├── data/
│   ├── <name>_mapper_test.dart      # dto → entity на реальном JSON
│   └── <name>_repository_test.dart  # Ok + Err(NetworkFailure) + Err(NotFoundFailure)
└── presentation/
    └── <name>_bloc_test.dart        # happy path + failure + специфичный edge
```

Подробнее о паттернах тестирования — в `TESTING.md`.

---

## Чек-лист перед merge

### Структура
- [ ] Три слоя есть; `domain/` чистый (без Flutter/Dio/Result)
- [ ] Фича владеет своими сущностями, чужие — только через `*/domain/`
- [ ] Endpoint'ы и маршруты — в константах

### Data
- [ ] DTO ↔ entity через mapper; DTO не выходит из `data/`
- [ ] `RepositoryImpl` ловит инфраструктурные исключения и **бросает `Failure`**, никакого `Result`
- [ ] Shared-сущности идут через store

### Состояние
- [ ] Bloc есть только там, где есть внешний вызов (нет Bloc'а под чистую форму)
- [ ] Cubit'ов нет
- [ ] Локальный стейт формы — в `StatefulWidget` через `ValueNotifier` + миксин
- [ ] Пагинация — через `PaginatedBloc`
- [ ] UseCase'ы содержательные (не пустые пробросы)
- [ ] События — факты, состояния — sealed
- [ ] Bloc ловит `Failure` через `try/catch on Failure`

### UI
- [ ] Экран не трогает repo/Dio напрямую
- [ ] Навигация — на экране/в WM по событиям Bloc'а
- [ ] Все 4 состояния: Loading / Error(+Retry) / Empty / Data
- [ ] DI в ScopeHolder создаётся в `initState` через `AppScope.read(context)`

### Тесты
- [ ] mapper_test на реальном JSON
- [ ] repository_test: success + минимум один error path
- [ ] bloc_test: happy + failure + специфичный edge фичи

---

## Анти-паттерны (немедленный reject)

| Симптом | Как исправить |
|---------|--------------|
| `import 'package:dio/...'` в `domain/` или `presentation/` | перенести в datasource |
| DTO в сигнатуре Bloc'а | прогнать через mapper → entity |
| `Map<String, dynamic>` выше data | DTO + entity |
| `Result<T>` / `Ok` / `Err` где угодно | `throw Failure` + `try/catch on Failure` |
| `Cubit` где угодно | Bloc (если внешнее I/O) или виджет+ValueNotifier+миксин |
| Bloc под чистую форму без внешнего вызова | виджет+ValueNotifier+миксин |
| Bloc слушает другой Bloc | WM или store |
| `BuildContext` в Bloc/usecase | состояние + реакция на экране |
| `context.go/showDialog` в Bloc | `BlocListener` на экране |
| Своя cursor-пагинация | `extends PaginatedBloc<T>` |
| UseCase = `repo.method()` | прямой вызов из Bloc |
| `import 'features/x/data/...'` из другой фичи | только `features/x/domain/` |
| Глобальный static / GetIt | scope-дерево |
| DI в `didChangeDependencies` ScopeHolder'а | `initState` + `AppScope.read(context)` |
