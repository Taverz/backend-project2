# Chirp Flutter — Setup

Как запустить проект с нуля.

---

## Требования

| Инструмент | Версия |
|-----------|--------|
| Flutter | ≥ 3.29 (stable) |
| Dart | ≥ 3.7 (включён в Flutter) |
| Go backend | запущен на `localhost:8080` для полной работы |

Проверить версию: `flutter --version`

---

## Установка

```bash
cd flutter/
flutter pub get
```

---

## Запуск

```bash
# Эмулятор / устройство (по умолчанию бэкенд на localhost:8080)
flutter run

# Другой адрес бэкенда
flutter run --dart-define=API_URL=http://192.168.1.100:8080

# Конкретная платформа
flutter run -d chrome          # web
flutter run -d ios             # iOS-симулятор
flutter run -d emulator-5554   # Android-эмулятор
```

---

## Тесты

```bash
flutter test                        # все тесты
flutter test test/core/             # только core
flutter test test/features/auth/    # конкретная фича
flutter test --coverage             # с покрытием
```

---

## Сборка

```bash
flutter build web                   # веб
flutter build apk                   # Android APK
flutter build ios --no-codesign     # iOS (без подписи, для проверки)
```

---

## Переменные окружения

Передаются через `--dart-define`:

| Переменная | По умолчанию | Описание |
|-----------|-------------|---------|
| `API_URL` | `http://localhost:8080` | Базовый URL бэкенда (любая реализация swagger-контракта) |

Пример для prod-сборки:
```bash
flutter build web --dart-define=API_URL=https://api.chirp.example.com
```

---

## Запуск бэкенда

Backend живёт в `../backend/`. Быстрый старт:

```bash
cd ../backend
make run         # или: go run ./cmd/server
```

Swagger-документация API: `http://localhost:8080/swagger/index.html`

---

## Структура проекта

```
backend-project2/
├── backend/          # Go API (phase 1 — готово)
├── flutter/          # Flutter client (этот проект)
│   ├── lib/          # исходный код
│   ├── test/         # тесты
│   ├── pubspec.yaml
│   └── CLAUDE.md     # быстрый контекст для AI-агентов
└── docs/
    └── flutter/      # документация
        ├── SETUP.md             # этот файл
        ├── FOUNDATION.md        # что реализовано в фундаменте
        ├── STRUCTURE.md         # полная архитектура
        ├── ARCHITECTURE_RULES.md # правила и ревью
        ├── TESTING.md           # стратегия тестирования
        └── HOW-TO-ADD-FEATURE.md # пошаговый гайд по добавлению фичи
```
