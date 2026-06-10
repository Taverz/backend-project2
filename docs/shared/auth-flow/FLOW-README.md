# Auth Flow — Cross-Platform

> Авторизация на всех платформах: backend, Flutter, Android, iOS, Web.

## Структура

```
docs/shared/auth-flow/
├── FLOW-README.md          ← этот файл
├── 01-REQUIREMENTS.md      ← бизнес-требования (пишет человек)
├── 02-SPEC.md              ← спецификация API (контракт для всех платформ)
├── 03-ARCHITECTURE.md      ← sequence diagrams, data flow, screen flow, model structure, widget tree
├── 04-PATTERNS.md          ← cross-platform patterns (для AI, без кода)
├── 05-VERIFICATION.md      ← тесты + curl + таблица сценариев
├── 06-UI-STATES.md         ← все UI-состояния каждого экрана (таблицы)
├── 07-TEST-CASES.md        ← тест-кейсы без кода (precondition → step → result)
└── 08-BEHAVIOR.md          ← логика работы каждого экрана (человек → утверждает → AI реализует)
```

## Как читать

1. **01-REQUIREMENTS.md** — что должна делать фича (человек → AI)
2. **02-SPEC.md** — API контракт (единый для всех платформ)
3. **03-ARCHITECTURE.md** — КАК это работает: sequence диаграммы, data flow, screen flow, widget tree, state machine (AI читает → генерирует код)
4. **04-PATTERNS.md** — платформенные паттерны: токены, auth guard, form validation, race conditions (AI читает → адаптирует под язык)
5. **05-VERIFICATION.md** — как проверить, что всё работает

## Что делает каждая платформа

| Платформа | Отвечает за |
|-----------|------------|
| Backend (Go) | Валидация, bcrypt, JWT, middleware |
| Flutter (Dart) | Формы, токены (SecureStorage), GoRouter guard |
| Android (Kotlin) | Формы, токены (EncryptedSharedPrefs), NavHost guard |
| iOS (Swift) | Формы, токены (Keychain), NavigationStack guard |
| Web (TypeScript) | Формы, токены (httpOnly cookie / localStorage), Router guard |

## Принцип

Бизнес-логика одна (валидация → bcrypt → JWT → response).
UI разный (Material, Cupertino, Web).
Хранение токенов разное (Keychain, SharedPrefs, cookie).
Паттерны одинаковые (auth state, 401→refresh, guard, form validation).
