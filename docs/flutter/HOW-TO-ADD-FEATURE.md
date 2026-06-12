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
Запрещено: `import 'package:dio/...`, `import 'package:flutter/...`, DTO-типы, `Map<String, dynamic>`.

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
- DTO не выходит из `data/` — наружу только entities и `Result<T>`
- `RepositoryImpl` не пробрасывает исключения, возвращает `Err(failure)`
- Новые URL → только через `core/network/endpoints.dart`

**Маппинг исключений в Failure** (шаблон для `RepositoryImpl`):
```dart
Future<Result<Tweet>> getById(String id) async {
  try {
    final dto = await _dataSource.getTweet(id);
    return Ok(TweetMapper.fromDto(dto));
  } on UnauthorizedException {
    return const Err(UnauthorizedFailure());
  } on ApiException catch (e) {
    if (e.statusCode == 404) return const Err(NotFoundFailure());
    return Err(ServerFailure(statusCode: e.statusCode));
  } on NetworkException {
    return const Err(NetworkFailure());
  } catch (_) {
    return const Err(UnknownFailure());
  }
}
```

---

## Шаг 3. presentation/ — состояние и UI

```
features/<name>/presentation/
├── scope/
│   └── <name>_scope.dart         # XxxScope (InheritedWidget) + XxxScopeHolder
├── bloc/                         # или cubit/
│   ├── <name>_bloc.dart
│   ├── <name>_event.dart
│   └── <name>_state.dart
├── wm/                           # только при 2+ Bloc'ах или локальном UI-стейте
│   └── <name>_wm.dart
├── screens/
│   └── <name>_screen.dart
└── widgets/
    └── <name>_tile.dart          # переиспользуемые куски UI фичи
```

### Выбор инструмента состояния

```
Один bool (открыт/закрыт)?              → setState / ValueNotifier
Форма, фильтры, простые мутации?        → Cubit
Пагинация, поиск с debounce/switchMap?  → Bloc, extends PaginatedBloc<T>
2+ Bloc'а на экране / локальный стейт?  → WM поверх них
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

```dart
class HomeScopeHolder extends StatefulWidget { ... }

class _HomeScopeHolderState extends State<HomeScopeHolder> {
  late final TimelineBloc _timelineBloc;

  @override
  void initState() {
    super.initState();
    final appScope = AppScope.of(context);
    _timelineBloc = TimelineBloc(TimelineRepositoryImpl(
      TimelineRemoteDataSource(appScope.dio),
      appScope.tweetStore,  // после добавления TweetStore в AppScope
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
- [ ] Три слоя есть; `domain/` чистый (без Flutter/Dio)
- [ ] Фича владеет своими сущностями, чужие — только через `*/domain/`
- [ ] Endpoint'ы и маршруты — в константах

### Data
- [ ] DTO ↔ entity через mapper; DTO не выходит из `data/`
- [ ] `RepositoryImpl` возвращает `Result`, исключения не утекают
- [ ] Shared-сущности идут через store

### Состояние
- [ ] Инструмент выбран по таблице выше
- [ ] Пагинация — через `PaginatedBloc`
- [ ] UseCase'ы содержательные (не пустые пробросы)
- [ ] События — факты, состояния — sealed

### UI
- [ ] Экран не трогает repo/Dio напрямую
- [ ] Навигация — на экране/в WM по событиям Bloc'а
- [ ] Все 4 состояния: Loading / Error(+Retry) / Empty / Data

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
| Bloc слушает другой Bloc | WM или store |
| `BuildContext` в Bloc/usecase | состояние + реакция на экране |
| `context.go/showDialog` в Bloc | `BlocListener` на экране |
| Своя cursor-пагинация | `extends PaginatedBloc<T>` |
| UseCase = `repo.method()` | прямой вызов из Bloc |
| `import 'features/x/data/...'` из другой фичи | только `features/x/domain/` |
| Глобальный static / GetIt | scope-дерево |
