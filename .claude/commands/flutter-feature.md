# /flutter-feature

Создаёт новую Flutter-фичу для проекта Chirp строго по архитектурным правилам.

## Перед началом

Прочитай эти файлы — они содержат всё необходимое:
- `docs/flutter/HOW-TO-ADD-FEATURE.md` — пошаговый процесс (domain → data → presentation → подключение → тесты)
- `docs/flutter/ARCHITECTURE_RULES.md` — нейминг, правила per-layer, анти-паттерны
- `docs/flutter/FOUNDATION.md` — что уже реализовано (core/, shared/, app/)
- `docs/flutter/TESTING.md` — паттерны тестирования

## Задание

Фича: **$ARGUMENTS**

## Процесс

1. Определи границы: фича ВЛАДЕЕТ сущностями или ИСПОЛЬЗУЕТ чужие?
2. Создавай слои строго в порядке: `domain/ → data/ → presentation/ → подключение → тесты`
3. После создания запусти: `flutter test test/features/<name>/`
4. Проверь чек-лист из `HOW-TO-ADD-FEATURE.md` перед завершением

## Стоп-правила (не нарушать)

- `domain/` — никаких `import 'package:dio/...` или `package:flutter/...`
- DTO не выходит из `data/`
- Импорт из другой фичи — только `features/x/domain/`
- Пагинация — только `extends PaginatedBloc<T>`
- UseCase — только при оркестрации (не пустой проброс)
- Навигация — только в обработчиках экрана/WM, не в Bloc
