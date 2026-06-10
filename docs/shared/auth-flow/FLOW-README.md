# Auth Flow — Cross-Platform

> Авторизация на всех платформах: backend, Flutter, Android, iOS, Web.

## Структура

```
docs/shared/auth-flow/
├── FLOW-README.md          ← этот файл
├── 01-REQUIREMENTS.md      ← бизнес-требования
├── 02-SPEC.md              ← кроссплатформенная спецификация
├── 03-CODE.md              ← код на каждой платформе
└── 04-VERIFICATION.md      ← верификация (тесты + curl)
```

## Что делает каждая платформа

| Платформа | Отвечает за |
|-----------|------------|
| Backend (Go) | Валидация, bcrypt, JWT, middleware |
| Flutter (Dart) | Формы, токены (SecureStorage), GoRouter guard |
| Android (Kotlin) | Формы, токены (EncryptedSharedPrefs), NavHost guard |
| iOS (Swift) | Формы, токены (Keychain), NavigationStack guard |
| Web (TypeScript) | Формы, токены (httpOnly cookie / localStorage), Router guard |

**Ключевое:** бизнес-логика одна (валидация → bcrypt → JWT → response).
UI разный (Material, Cupertino, Web). Хранение токенов разное (SharedPrefs, Keychain, cookie).
