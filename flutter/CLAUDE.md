# Chirp Flutter — Quick Context for AI Agents

Краткий контекст для AI-агентов. Полная документация — в `../docs/flutter/`.

---

## Навигация по документам

| Что нужно | Файл |
|-----------|------|
| Что уже реализовано, ключевые файлы | [`../docs/flutter/FOUNDATION.md`](../docs/flutter/FOUNDATION.md) |
| Полная архитектура (стек, слои, паттерны) | [`../docs/flutter/STRUCTURE.md`](../docs/flutter/STRUCTURE.md) |
| Правила кода, нейминг, анти-паттерны | [`../docs/flutter/ARCHITECTURE_RULES.md`](../docs/flutter/ARCHITECTURE_RULES.md) |
| Как добавить новую фичу | [`../docs/flutter/HOW-TO-ADD-FEATURE.md`](../docs/flutter/HOW-TO-ADD-FEATURE.md) |
| Тесты: что покрыто, паттерны | [`../docs/flutter/TESTING.md`](../docs/flutter/TESTING.md) |
| Запуск, сборка, env vars | [`../docs/flutter/SETUP.md`](../docs/flutter/SETUP.md) |

---

## Самое важное (не читая остальное)

```
lib/
├── main.dart                        # bootstrap: BlocObserver + AppScopeHolder + ChirpApp
├── app/di/app_scope.dart            # AppScope.of(context) — глобальные зависимости
├── app/router/app_router.dart       # GoRouter + redirect по SessionState
├── core/session/session_controller.dart   # сессия: init/update/drop
├── core/result/result.dart          # sealed Result<T>: Ok / Err(Failure)
├── core/bloc/paginated_bloc.dart    # база для ВСЕХ списков с cursor
└── features/                        # пусто — фичи добавляются итеративно
```

## Команды

```bash
flutter pub get && flutter run
flutter test
flutter run --dart-define=API_URL=http://localhost:8080
```

## Добавить фичу

Читай `../docs/flutter/HOW-TO-ADD-FEATURE.md`. Порядок: `domain/ → data/ → presentation/ → подключение → тесты`.

## Критические правила

1. `domain/` — чистый Dart: нет Flutter, нет Dio, нет DTO
2. Импорт из другой фичи — только `features/x/domain/`
3. `RepositoryImpl` возвращает `Result<T>`, не бросает наружу
4. Пагинация — только через `PaginatedBloc<T>`, не своя
5. UseCase — только при оркестрации 2+ репозиториев или оптимистичных апдейтах
6. Навигация (`context.go`) — только в обработчиках экрана/WM, не в Bloc
