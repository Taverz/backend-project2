# Design Folder Structure

> Папка для дизайнера. Содержит всё, что нужно AI для генерации Figma-дизайна.

---

## Структура

```
design/
├── project-overview.md        ← Что за проект, платформы, аудитория, тон
├── tokens.md                  ← Цвета, типографика, отступы, иконки
│
├── 01-auth/                   ← Фича: Авторизация
│   ├── README.md              ← Экраны: Splash, Login, Register
│   └── components.md          ← Компоненты: Button, InputField, Avatar, Toast, Link, ErrorView
│
├── 02-home/                   ← Фича: Лента (TODO)
│   ├── README.md
│   └── components.md
│
├── 03-tweet/                  ← Фича: Твиты (TODO)
│   ├── README.md
│   └── components.md
│
├── 04-profile/                ← Фича: Профиль (TODO)
│   ├── README.md
│   └── components.md
│
├── 05-notifications/          ← Фича: Уведомления (TODO)
│   ├── README.md
│   └── components.md
│
├── 06-search/                 ← Фича: Поиск (TODO)
│   ├── README.md
│   └── components.md
│
└── shared/                    ← Переиспользуемые компоненты (TODO)
    ├── tweet-card.md
    ├── follow-button.md
    ├── timeline-list.md
    └── tab-bar.md
```

## Как добавлять новую фичу

1. Создать папку `design/{NN}-{feature-name}/`
2. Создать `README.md` — все экраны фичи с layout и состояними
3. Создать `components.md` — все виджеты, уникальные для этой фичи
4. Если новый общий компонент — добавить в `design/shared/`

## Как AI использует эту папку

```
AI получает задачу: "Нарисуй LoginScreen"

1. Читает design/project-overview.md     → контекст
2. Читает design/tokens.md               → цвета, шрифты, иконки
3. Читает design/01-auth/README.md       → layout и состояния
4. Читает design/01-auth/components.md   → Button, InputField specs

→ Генерирует Figma frame
  LoginScreen × 7 состояний
  Все компоненты из Design System
```

## Как дизайнер ревьюит

```
1. Открыть Figma-дизайн, сгенерированный AI
2. Сверить с design/01-auth/README.md:
   - Порядок элементов совпадает?
   - Все состояния есть?
   - Текст ошибок правильный?
3. Сверить с design/tokens.md:
   - Цвета совпадают?
   - Шрифты совпадают?
   - Отступы совпадают?
4. Сверить с design/01-auth/components.md:
   - Button использован Primary, не Outline?
   - InputField с правильными variants?
```
