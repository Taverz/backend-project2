.PHONY: get format format-check analyze fix test test-unit test-mock test-coverage \
        run run-web build-web build-apk build-ios clean doctor ci watch-analyze

FLUTTER   := flutter
DART      := dart
LIB       := lib
TEST_UNIT := test/unit
TEST_MOCK := test/mock
TEST_INT  := integration_test

# ── Зависимости ───────────────────────────────────────────────────────────────

## Установить зависимости
get:
	$(FLUTTER) pub get

## Обновить зависимости
upgrade:
	$(FLUTTER) pub upgrade

# ── Форматирование ────────────────────────────────────────────────────────────

## Применить dart format к lib/ и test/
format:
	$(DART) format $(LIB) test

## Проверить форматирование (не изменяет файлы, выходит с ошибкой если есть нарушения)
format-check:
	$(DART) format --output=none --set-exit-if-changed $(LIB) test

# ── Статический анализ ────────────────────────────────────────────────────────

## Запустить dart analyze
analyze:
	$(DART) analyze $(LIB) test

## Применить автоисправления от dart fix
fix:
	$(DART) fix --apply $(LIB)

# ── Тесты ─────────────────────────────────────────────────────────────────────

## Все тесты (unit + mock)
test:
	$(FLUTTER) test $(TEST_UNIT) $(TEST_MOCK)

## Только unit-тесты (без моков)
test-unit:
	$(FLUTTER) test $(TEST_UNIT)

## Только mock-тесты (с mocktail)
test-mock:
	$(FLUTTER) test $(TEST_MOCK)

## Тесты конкретной фичи: make test-feature FEATURE=auth
test-feature:
	$(FLUTTER) test test/features/$(FEATURE)

## Тесты с покрытием (генерирует coverage/lcov.info)
test-coverage:
	$(FLUTTER) test $(TEST_UNIT) $(TEST_MOCK) --coverage
	@echo "Coverage report: coverage/lcov.info"

## Интеграционные тесты (требует запущенного устройства/эмулятора)
test-integration:
	$(FLUTTER) test $(TEST_INT)

# ── CI Pipeline ───────────────────────────────────────────────────────────────

## Полный CI: format-check → analyze → test (для GitHub Actions / pre-push hook)
ci: format-check analyze test
	@echo ""
	@echo "✓ CI passed: format, analyze, tests"

# ── Запуск ────────────────────────────────────────────────────────────────────

## Запустить приложение на устройстве по умолчанию
run:
	$(FLUTTER) run --dart-define=API_URL=http://localhost:8080

## Запустить в браузере
run-web:
	$(FLUTTER) run -d chrome --dart-define=API_URL=http://localhost:8080

## Запустить на iOS-симуляторе
run-ios:
	$(FLUTTER) run -d ios --dart-define=API_URL=http://localhost:8080

## Запустить на Android-эмуляторе
run-android:
	$(FLUTTER) run -d android --dart-define=API_URL=http://localhost:8080

## Запустить в режиме profile (производительность)
run-profile:
	$(FLUTTER) run --profile --dart-define=API_URL=http://localhost:8080

# ── Сборка ────────────────────────────────────────────────────────────────────

API_URL ?= https://api.chirp.example.com

## Собрать web (production)
build-web:
	$(FLUTTER) build web --dart-define=API_URL=$(API_URL)

## Собрать Android APK (release)
build-apk:
	$(FLUTTER) build apk --release --dart-define=API_URL=$(API_URL)

## Собрать Android App Bundle (для Play Store)
build-aab:
	$(FLUTTER) build appbundle --release --dart-define=API_URL=$(API_URL)

## Собрать iOS (без подписи, для проверки)
build-ios:
	$(FLUTTER) build ios --no-codesign --dart-define=API_URL=$(API_URL)

# ── Утилиты ───────────────────────────────────────────────────────────────────

## Очистить артефакты сборки
clean:
	$(FLUTTER) clean

## Полная переинициализация (clean + get)
reset: clean get

## flutter doctor — диагностика окружения
doctor:
	$(FLUTTER) doctor -v

## Показать outdated зависимости
outdated:
	$(FLUTTER) pub outdated

## Генерация кода (если понадобится build_runner в будущем)
gen:
	$(DART) run build_runner build --delete-conflicting-outputs

## Непрерывный анализ при изменении файлов
watch-analyze:
	$(FLUTTER) analyze --watch

## Показать список всех доступных команд
help:
	@echo ""
	@echo "Chirp Flutter — доступные команды:"
	@echo ""
	@grep -E '^## ' Makefile | sed 's/## /  make /' | sed 's/: /\t\t/'
	@echo ""
