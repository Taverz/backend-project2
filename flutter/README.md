# Chirp Flutter

Flutter-клиент для Chirp — Twitter-подобного приложения. Работает в паре с Go-бэкендом в `../backend/`.

Поддерживаемые платформы: iOS, Android, Web.

---

## Быстрый старт

```bash
flutter pub get
flutter run --dart-define=API_URL=http://localhost:8080
```

Подробнее — [`docs/flutter/SETUP.md`](../docs/flutter/SETUP.md)

---

## Документация

| Документ | Содержание |
|---------|-----------|
| [`docs/flutter/SETUP.md`](../docs/flutter/SETUP.md) | Установка, запуск, переменные окружения |
| [`docs/flutter/FOUNDATION.md`](../docs/flutter/FOUNDATION.md) | Что реализовано в фундаменте, ключевые файлы |
| [`docs/flutter/STRUCTURE.md`](../docs/flutter/STRUCTURE.md) | Полная архитектура (стек, слои, DI, маршрутизация) |
| [`docs/flutter/ARCHITECTURE_RULES.md`](../docs/flutter/ARCHITECTURE_RULES.md) | Правила написания кода, нейминг, анти-паттерны |
| [`docs/flutter/HOW-TO-ADD-FEATURE.md`](../docs/flutter/HOW-TO-ADD-FEATURE.md) | Пошаговый гайд по добавлению новой фичи |
| [`docs/flutter/TESTING.md`](../docs/flutter/TESTING.md) | Тест-стратегия, паттерны, покрытие |

---

## Архитектура (кратко)

- **Clean Architecture**: `domain/ ← data/ → presentation/`
- **State**: `flutter_bloc` (Bloc/Cubit) + Widget Model для координации
- **DI**: `InheritedWidget`-скоупы: `AppScope → FeatureScope → ScreenScope`
- **Navigation**: `go_router` + `StatefulShellRoute.indexedStack`
- **HTTP**: `dio` + интерсепторы (Auth, Refresh, Error, Logger)
- **Session**: `SessionController` — единственный источник истины о токенах
- **Pagination**: `PaginatedBloc<T>` — базовый класс для всех списков

---

## Тесты

```bash
flutter test               # все тесты
flutter test test/core/    # только инфраструктура
```

19 тестов: `SessionController`, `PaginatedBloc`, `ErrorInterceptor`.

---

## Стек

```
flutter_bloc: ^8.1.6
go_router:    ^14.6.3
dio:          ^5.7.0
equatable:    ^2.0.5
flutter_secure_storage: ^9.2.4
shared_preferences:     ^2.3.3
```

Без кодогенерации: нет `freezed`, `json_serializable`, `build_runner`.
