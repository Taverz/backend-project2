# Chirp Obsidian Vault

Документация проекта Chirp как Obsidian vault. Все `.md`-файлы проекта — `docs/flutter/`, `CLAUDE.md`, `packages/*/docs/` — подключены через symlinks, чтобы не дублировать контент.

## Открыть в Obsidian

```
File → Open vault → Open folder as vault → выбрать backend-project2/obsidian
```

При первом запуске Obsidian спросит «Trust author and enable plugins?» — нажать **Trust** (плагины уже скачаны в `.obsidian/plugins/`).

## Что внутри

| Объект | Что это |
|--------|---------|
| `Welcome.md` | Точка входа vault'а — карта всей документации |
| `Project Docs/` → `../docs/` | Symlink на проектную документацию |
| `Flutter — CLAUDE.md` → `../flutter/CLAUDE.md` | Главные правила Flutter-части |
| `app_api Docs/` → `../flutter/packages/app_api/docs/` | Документация API-пакета |
| `ui_kit Docs/` → `../flutter/packages/ui_kit/docs/` | Документация UI-kit |
| `.obsidian/plugins/notebook-navigator/` | Двухпанельный файл-навигатор |
| `.obsidian/plugins/vault-ai/` | AI-чат через Gemini API |

## Подключённые плагины

### Notebook Navigator (`johansan/notebook-navigator` v3.1.2)

Заменяет стандартный file explorer на двух-панельный (слева папки/теги, справа список заметок). Похоже на Apple Notes / Bear / Evernote.

После активации — переключить горячими клавишами `Cmd+Shift+E` или из command palette `Notebook Navigator: Open Navigator`.

### VaultAI (`0xneobyte/VaultAI` v1.0.11)

AI-чат с возможностью спрашивать про содержимое vault через Google Gemini API.

**Требует API key:**
1. Получить ключ на https://aistudio.google.com/apikey (бесплатный tier есть)
2. `Settings → Community plugins → VaultAI → Settings`
3. Вставить ключ в поле «Gemini API Key»

Использование: открыть чат через command palette `VaultAI: Open Chat`.

## Обновление плагинов

Плагины скачаны как файлы (`main.js`, `manifest.json`, `styles.css`) — Obsidian **не обновит их автоматически** из community store, потому что они не были установлены через UI.

Для обновления:
- **Через Obsidian:** `Settings → Community plugins` → найти плагин в Browse → Install (перезапишет файлы свежей версией, дальше будет обновляться сам).
- **Вручную:** скачать новый release с GitHub в `.obsidian/plugins/<id>/` и перезагрузить Obsidian.

## Что НЕ коммитится

См. `.gitignore` в этой папке — исключены workspace state файлы (меняются при каждом открытии).
