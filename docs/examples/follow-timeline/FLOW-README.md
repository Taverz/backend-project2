# Flow Demo: Follow + Timeline Module

> Демонстрация полного цикла разработки с AI для социальной механики.

## Структура

```
docs/examples/follow-timeline/
├── FLOW-README.md              ← этот файл
├── 01-REQUIREMENTS.md          ← Шаг 1: бизнес-требования (3–10 строк)
├── 02-SPEC.md                  ← Шаг 2: AI → техническая спецификация
├── 03-CODE.md                  ← Шаг 3: AI → код (15 файлов, ~400 строк)
└── 04-VERIFICATION.md          ← Шаг 4: тесты + curl
```

## Факты о фиче

| Метрика | Значение |
|---------|----------|
| Файлов | 15 Go файлов + 4 SQL миграции |
| Строк кода | ~400 |
| Use case'ов | 6 (Follow, Unfollow, ListFollowers, ListFollowing, FanOut, HomeTimeline) |
| Эндпоинтов | 5 |
| Ключевое решение | Fan-out on write (не on read) |
| Время генерации AI | ~3 минуты |
| Время проверки человеком | ~15 минут |
