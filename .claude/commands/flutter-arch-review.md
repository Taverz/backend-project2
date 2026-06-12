# /flutter-arch-review

Проверяет Flutter-код на соответствие архитектурным правилам Chirp.

## Контекст

Правила описаны в `docs/flutter/ARCHITECTURE_RULES.md`. Анти-паттерны — там же, §7.

## Цель проверки

$ARGUMENTS

## Автоматические проверки

Выполни последовательно:

```bash
# 1. domain/ не содержит Flutter/Dio/DTO
grep -rn "package:dio\|package:flutter\|Dto\|Map<String, dynamic>" flutter/lib/features/*/domain/ 2>/dev/null

# 2. DTO не выходит из data/
grep -rn "Dto" flutter/lib/features/*/presentation/ flutter/lib/features/*/domain/ 2>/dev/null

# 3. Нет cross-feature импортов из data/
grep -rn "features/.*/data/" flutter/lib/features/ 2>/dev/null

# 4. Bloc не слушает Bloc
grep -rn "\.stream\.listen" flutter/lib/features/*/presentation/bloc/ flutter/lib/features/*/presentation/cubit/ 2>/dev/null

# 5. BuildContext/навигация не в Bloc
grep -rn "BuildContext\|context\.go\|context\.push\|showDialog" flutter/lib/features/*/presentation/bloc/ flutter/lib/features/*/domain/ flutter/lib/features/*/data/ 2>/dev/null

# 6. Нет своей cursor-пагинации без PaginatedBloc
grep -rn "cursor" flutter/lib/features/*/presentation/bloc/ 2>/dev/null | grep -v "PaginatedBloc\|paginated_bloc\|extends\|super"

# 7. RepositoryImpl не пробрасывает исключения
grep -rn "^[[:space:]]*throw\|^[[:space:]]*rethrow" flutter/lib/features/*/data/repositories/ 2>/dev/null

# 8. Нет GetIt / глобальных синглтонов
grep -rn "GetIt\|\.instance\b\|static.*singleton" flutter/lib/ 2>/dev/null | grep -v "test\|\.md"
```

## Ручная проверка

- UseCase'ы: есть ли оркестрация или это пустой проброс?
- WM: нет ли бизнес-логики (условий на доменных данных)?
- Каждый экран: есть ли все 4 состояния (Loading, Error+Retry, Empty, Data)?

## Формат отчёта

```
## Результаты архитектурного ревью

### ✅ Проверено — нарушений нет
- ...

### ⚠️ Нарушения
- [путь/файл.dart:N] описание → как исправить

### ℹ️ Требует ручной проверки
- ...
```
