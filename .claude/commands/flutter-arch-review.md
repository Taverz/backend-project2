# /flutter-arch-review

Проверяет Flutter-код на соответствие архитектурным правилам Chirp.

## Что проверять

Запусти последовательно каждую проверку и выведи нарушения с указанием файла и строки.

### 1. Чистота domain/

```bash
grep -rn "package:dio" lib/features/*/domain/ 2>/dev/null
grep -rn "package:flutter" lib/features/*/domain/ 2>/dev/null
grep -rn "Dto" lib/features/*/domain/ 2>/dev/null
grep -rn "Map<String, dynamic>" lib/features/*/domain/ 2>/dev/null
```

Нарушение если что-то найдено. `domain/` — чистый Dart без Flutter/Dio/DTO.

### 2. DTO не выходит из data/

```bash
grep -rn "Dto" lib/features/*/presentation/ 2>/dev/null
grep -rn "Dto" lib/features/*/domain/ 2>/dev/null
```

### 3. Нет cross-feature импортов из data/

```bash
# Ищем импорты вида features/X/data/ из features/Y/
grep -rn "features/.*/data/" lib/features/ 2>/dev/null | grep -v "^lib/features/\([^/]*\)/.*features/\1/"
```

Разрешено импортировать только `features/x/domain/` из другой фичи.

### 4. Bloc не слушает другой Bloc

```bash
grep -rn "\.stream\.listen" lib/features/*/presentation/bloc/ 2>/dev/null
grep -rn "\.stream\.listen" lib/features/*/presentation/cubit/ 2>/dev/null
```

### 5. BuildContext не попадает в Bloc/Usecase/Repository

```bash
grep -rn "BuildContext" lib/features/*/domain/ 2>/dev/null
grep -rn "BuildContext" lib/features/*/data/ 2>/dev/null
grep -rn "BuildContext" lib/features/*/presentation/bloc/ 2>/dev/null
grep -rn "context\.go\|context\.push\|showDialog" lib/features/*/presentation/bloc/ 2>/dev/null
grep -rn "context\.go\|context\.push\|showDialog" lib/features/*/presentation/cubit/ 2>/dev/null
```

### 6. Пагинация через PaginatedBloc

```bash
# Ищем Bloc'и со своей cursor-логикой (cursor без PaginatedBloc)
grep -rn "cursor" lib/features/*/presentation/bloc/ 2>/dev/null | grep -v "PaginatedBloc\|paginated_bloc"
```

### 7. UseCase не пустой проброс

```bash
grep -rn "call\|execute" lib/features/*/domain/usecases/ 2>/dev/null
```

Вручную проверь, что usecase содержит оркестрацию (2+ репозитория, откат, валидация), а не просто `return repo.method()`.

### 8. RepositoryImpl возвращает Result, не бросает

```bash
grep -rn "throw\|rethrow" lib/features/*/data/repositories/ 2>/dev/null
```

### 9. Нейминг файлов

```bash
# Все файлы должны быть snake_case.dart
find lib/features/ -name "*.dart" | grep -v "^[a-z0-9_/]*\.dart$" 2>/dev/null
```

### 10. Глобальные синглтоны / GetIt

```bash
grep -rn "GetIt\|get_it\|singleton\|instance\b" lib/ 2>/dev/null | grep -v "test\|CLAUDE\|\.md"
```

## Отчёт

После проверки выведи:

```
## Результаты архитектурного ревью

### ✅ Проверено без нарушений
- ...

### ⚠️ Нарушения
- [файл:строка] описание нарушения → как исправить

### ℹ️ Требует ручной проверки
- UseCase'ы (убедись, что есть оркестрация)
- WM (убедись, что нет бизнес-логики)
```

## Цель проверки

$ARGUMENTS
