# Chirp — Design System Overview

> Концептуальный индекс визуальной системы. Все конкретные значения — в `design/03-tokens/`.
> Этот файл — точка входа для людей и AI, которым нужно понять, **где живёт что**.

---

## 1. Где живёт канон

| Что | Где | Тип |
|-----|-----|-----|
| **Цвета** (primitives + semantic + dark) | `design/03-tokens/colours.md` | Канон |
| **Типографика** (scale, fonts, weights) | `design/03-tokens/typography.md` | Канон |
| **Spacing** (4-base scale) | `design/03-tokens/spacing.md` | Канон |
| **Radius / elevation** | `design/03-tokens/radius-elevation.md` | Канон |
| **Motion** (duration, easing) | `design/03-tokens/motion.md` | Канон |
| **Иконки** (Phosphor, sizes, vocabulary) | `design/03-tokens/icons.md` | Канон |
| **Code theme** (syntax highlighting) | `design/03-tokens/code-theme.md` | Канон |
| **Component tokens** (button-bg, card-radius…) | `design/03-tokens/component-tokens.md` | Канон |
| **Mapping primitive→semantic→component** | `design/03-tokens/semantic-mappings.md` | Канон |
| **Атомарные компоненты** (Avatar, Button, ...) | `design/04-components/atoms/` | Канон |
| **Молекулы** (TweetCard, ProfileHeader, ...) | `design/04-components/molecules/` | Канон |
| **Naming + screen states + Figma↔code** | `docs/shared/DESIGN-CONTRACT.md` | Канон |
| **Список экранов** | `docs/shared/SCREENS.md` | Канон |
| **Состояния виджетов** | `docs/shared/WIDGET-STATES.md` | Канон |
| **Иконки во Flutter** | `docs/flutter/ICON-STRATEGY.md` | Канон |

---

## 2. Концепция айдентики

**Editorial calm.**

- База — тёплая бумажная (warm-50 / warm-100), не чисто-белая.
- Акцент — terra cotta (`terra-500` = #C45A3D). Один accent CTA на экран.
- Шрифты — serif для headlines, Inter для body, JetBrains Mono для code.
- Иконки — Phosphor Regular 1.5px. Никаких emoji в UI chrome.
- Плоский визуал — иерархия через bg + 1px border, **не через shadows**.
- Light by default, full dark theme поддерживается.

Подробное обоснование и палитра — `design/03-tokens/colours.md`.

---

## 3. Архитектура токенов

Три слоя, компонент ссылается только на component-token:

```
primitive   ← фиксированный hex / px, не зависит от темы
  ↓
semantic    ← ссылка на primitive, зависит от темы
  ↓
component   ← ссылка на semantic, имя вида <component>-<part>-<state>
  ↓
component implementation (Figma master или Dart widget)
```

Полная цепочка для каждого компонента — `design/03-tokens/semantic-mappings.md`.

---

## 4. Продуктовые компоненты MVP

Имена должны совпадать в Figma и коде (см. `docs/shared/DESIGN-CONTRACT.md §1`).

| Component | Layer | Где спека | Используется на |
|-----------|-------|-----------|------------------|
| Avatar | atom | `design/04-components/atoms/avatar.md` | везде |
| Button | atom | `design/04-components/atoms/button.md` | везде |
| Input | atom | TODO | Auth, Compose, Settings |
| IconButton | atom | TODO | Tweet actions, nav |
| TopBar | atom | TODO | все экраны |
| TweetCard | molecule | TODO (Tier 2 в `design/04-components/README.md`) | Timeline, Profile, Search, Tweet detail |
| ProfileHeader | molecule | TODO | Profile |
| BottomTabBar | molecule | TODO | главные экраны |
| EmptyState | molecule | TODO | везде, где empty |
| Timeline | organism | TODO | Home |
| Composer | organism | TODO | Compose |

Tier-приоритеты — `design/04-components/README.md`.

---

## 5. Что в этом файле НЕТ

- Конкретные hex / px / шрифты — берёшь из `design/03-tokens/`.
- Анатомия TweetCard — будет в `design/04-components/molecules/tweet-card.md`, когда напишем.
- Полный contract между Figma и code — `docs/shared/DESIGN-CONTRACT.md`.
- Промт-шаблоны для AI — `docs/PROMPT-TEMPLATES.md`.
- Workflow design-работы — `design/_ai/WORKFLOW.md`.

---

## 6. История

Исторически в этом файле жил конкретный токен-стек с Twitter-палитрой (`#1DA1F2`).
Он заменён каноническим `design/03-tokens/` (editorial calm).
Любой образец c `#1DA1F2`, который попадётся в legacy-документах
(например `docs/DESIGNER-AI-FLOW.md` §3) — устаревший пример, не использовать.
