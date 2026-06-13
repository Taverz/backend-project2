# 🐦 Chirp — Vault

Точка входа в Obsidian-vault проекта Chirp. Здесь собрана вся документация — флаттер, бэкенд, архитектурные ADR.

---

## Карта документации

### Flutter

- [[Flutter — CLAUDE.md|🎯 CLAUDE.md — главные правила Flutter-монорепо]]
- [[Project Docs/flutter/FOUNDATION|FOUNDATION — что уже реализовано]]
- [[Project Docs/flutter/ARCHITECTURE_RULES|ARCHITECTURE_RULES — правила кода]]
- [[Project Docs/flutter/HOW-TO-ADD-FEATURE|HOW-TO-ADD-FEATURE — как добавить фичу]]
- [[Project Docs/flutter/TESTING|TESTING — паттерны тестов]]
- [[Project Docs/flutter/ARCHITECTURE_GAPS_AND_IDEAS|ARCHITECTURE_GAPS_AND_IDEAS — пробелы и roadmap]]
- [[Project Docs/flutter/SETUP|SETUP — env vars и команды]]
- [[Project Docs/flutter/STRUCTURE|STRUCTURE — структура папок]]

### Пакеты

#### `packages/app_api`
- [[app_api — README|README — что это и зачем]]
- [[app_api Docs/DEVELOPMENT|DEVELOPMENT — как добавить endpoint, обновить фикстуры, codegen]]

#### `packages/ui_kit`
- [[ui_kit — README|README — обзор]]
- [[ui_kit Docs/WIDGET_GUIDELINES|WIDGET_GUIDELINES — правила построения виджетов]]
- [[ui_kit Docs/MAINTENANCE|MAINTENANCE — как обновлять]]

### Backend / общий

- [[Project — README|Project README]]

---

## Установленные плагины

| Плагин | Назначение |
|--------|-----------|
| **Notebook Navigator** | Двухпанельный файловый навигатор (заменяет дефолтный explorer) — слева папки, справа заметки |
| **VaultAI** | AI-чат по vault через Gemini API (нужен Gemini API key в настройках плагина) |

Чтобы активировать плагины при первом запуске:

1. Открыть vault в Obsidian (`File → Open vault` → выбрать папку `obsidian/`).
2. На запрос «Trust author and enable plugins?» — нажать **Trust**.
3. `Settings → Community plugins` → убедиться что **Notebook Navigator** и **VaultAI** включены.
4. Для VaultAI: `Settings → VaultAI` → ввести Gemini API key (получить на https://aistudio.google.com/apikey).

---

## Где живёт документация

```
backend-project2/
├── README.md                              ← общий README проекта
├── docs/flutter/                          ← основная Flutter-документация
├── flutter/CLAUDE.md                      ← правила для AI и людей
├── flutter/packages/app_api/
│   ├── README.md
│   └── docs/DEVELOPMENT.md                ← как работать с API
└── flutter/packages/ui_kit/
    ├── README.md
    └── docs/
        ├── WIDGET_GUIDELINES.md           ← правила построения виджетов
        └── MAINTENANCE.md                 ← обслуживание UI-kit
```

В vault через symlink-папки `Project Docs/`, `app_api Docs/`, `ui_kit Docs/` весь этот контент доступен из Obsidian без дублирования.
