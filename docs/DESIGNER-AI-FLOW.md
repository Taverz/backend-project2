# Дизайнер + AI: как подготовить документацию для генерации дизайна

> Какие файлы нужны дизайнеру, чтобы попросить AI нарисовать дизайн в Figma,
> и по каким критериям этот дизайн ревьюить.

---

## 1. Что AI должен сгенерировать

AI получает задачу: «Нарисуй экран LoginScreen в Figma».
AI должен создать:

- Frame экрана (390×844 — iPhone 14 размер)
- Все элементы: поля, кнопки, текст
- Правильные цвета, шрифты, отступы
- Все состояния (loading, error, success)
- Auto-layout между элементами
- Компоненты (Button, InputField — не «с нуля», а из Design System)

---

## 2. Какие файлы нужны AI для генерации дизайна

| # | Файл | Что AI из него берёт | Без этого файла |
|---|------|---------------------|-----------------|
| 1 | **SCREENS.md** | Список экранов, какие элементы на каждом, порядок | AI не знает, что есть LoginScreen, RegisterScreen, HomeScreen |
| 2 | **WIDGET-DATA-FLOW.md** | Widget tree: иерархия элементов, вложенность | AI сделает плоский экран без группировки (avatar рядом с body, а не в строке) |
| 3 | **DESIGN-SYSTEM.md** | Цвета (primary, background, error), шрифты (body 16px, h1 24px), компоненты (Button radius 24px, InputField height 44px) | AI придумает свои цвета и шрифты |
| 4 | **WIDGET-STATES.md** | Состояния каждого компонента: Button disabled/loading, InputField error/focused | AI сделает только default-состояние |
| 5 | **08-BEHAVIOR.md** | Расположение элементов (email сверху, password снизу), логика потока | AI может перепутать порядок полей |
| 6 | **DESIGN-CONTRACT.md** | Иконки (названия, размер 24×24, currentColor), экспорт SVG | AI использует эмодзи вместо иконок |
| 7 | **SCREENS.md (раздел States)** | Что показывать в каждом состоянии: Skeleton для loading, "No tweets yet" для empty | AI не нарисует empty state |

---

## 3. Промпт для AI: «Нарисуй дизайн LoginScreen»

```
Входные документы:
- DESIGN-SYSTEM.md (цвета, шрифты, отступы)
- SCREENS.md (LoginScreen раздел)
- WIDGET-DATA-FLOW.md (LoginScreen widget tree)
- WIDGET-STATES.md (Button, InputField состояния)
- 08-BEHAVIOR.md (LoginScreen логика)
- DESIGN-CONTRACT.md (иконки)

Задача: Создай Figma-дизайн для LoginScreen.

Figma frame: iPhone 14 (390×844)
Style: Dark mode (тёмная тема)

Элементы сверху вниз:
1. Центрированный логотип с текстом "Welcome to Chirp"
   - h1 (24px), white, центрировано
   - margin-bottom: 32px

2. Поле email
   - InputField компонент
   - placeholder: "Email"
   - keyboard type: email
   - margin-bottom: 16px

3. Поле password
   - InputField компонент
   - placeholder: "Password"
   - obscured (****)
   - eye toggle icon справа
   - margin-bottom: 24px

4. Кнопка "Log in"
   - PrimaryButton компонент
   - full-width
   - disabled когда поля пустые

5. Ссылка "Don't have an account? Sign up"
   - caption (13px), grey
   - "Sign up" — primary color (#1DA1F2)

6. Состояния (отдельными фреймами):
   - Default: пустые поля, enabled кнопка
   - Error: email красный border + "Enter a valid email address"
   - Loading: spinner в кнопке, поля disabled

Auto-layout:
- Все элементы в Column, центрированы
- Padding: 32px по бокам
- Gap между элементами: по margin-bottom

Иконки:
- eye toggle: ic_eye.svg (из DESIGN-CONTRACT.md)
- Ссылайся на компоненты из Design System, не создавай новые
```

---

## 4. Чеклист ревью для дизайнера

После того как AI нарисовал дизайн, дизайнер проверяет:

### 4.1. Layout и композиция

| Проверка | Критерий | Источник |
|----------|----------|----------|
| Порядок элементов | Email → Password → Button → Link? | 08-BEHAVIOR.md |
| Отступы | 32px по краям, 16px между полями? | DESIGN-SYSTEM.md (spacing) |
| Выравнивание | Всё по центру? | 08-BEHAVIOR.md |
| Размер экрана | 390×844? | Промпт |

### 4.2. Дизайн-система

| Проверка | Критерий | Источник |
|----------|----------|----------|
| Цвета | Primary = #1DA1F2, Background = #15202B? | DESIGN-SYSTEM.md |
| Шрифты | body = 16px, h1 = 24px, caption = 13px? | DESIGN-SYSTEM.md |
| Кнопка | Radius = 24px, Height = 44px? | DESIGN-SYSTEM.md |
| Поля ввода | Height = 44px, Border = 1px solid? | DESIGN-SYSTEM.md |
| Иконки | 24×24, currentColor? | DESIGN-CONTRACT.md |

### 4.3. Состояния

| Проверка | Критерий | Источник |
|----------|----------|----------|
| Все ли состояния есть | Default, Error, Loading? | 06-UI-STATES.md |
| Error state | Email красный border + inline error? | 06-UI-STATES.md |
| Loading state | Spinner в кнопке, поля disabled? | 06-UI-STATES.md |
| Disabled state | Кнопка opacity 0.5? | WIDGET-STATES.md |

### 4.4. Контент

| Проверка | Критерий | Источник |
|----------|----------|----------|
| Placeholder | Email / Password? | 08-BEHAVIOR.md |
| Button text | "Log in", не "Login" или "Sign in"? | 08-BEHAVIOR.md |
| Error message | "Enter a valid email address", не "Invalid format"? | ERRORS.md |

### 4.5. Компоненты

| Проверка | Критерий | Источник |
|----------|----------|----------|
| Компонент или сырой фрейм | AI использовал компоненты из Design System? | DESIGN-CONTRACT.md |
| Variants | Button Primary, а не Outline? | WIDGET-STATES.md |
| Auto-layout | Всё через Auto Layout? | DESIGN-CONTRACT.md |

---

## 5. Какие документы должны быть у дизайнера (минимальный набор)

Чтобы AI нарисовал дизайн, дизайнер должен предоставить AI **4 файла**:

```
designer-input/
├── 01-SCREENS-LAYOUT.md    ← что где находится (виджет-три + расположение)
├── 02-DESIGN-SYSTEM.md     ← цвета, шрифты, компоненты
├── 03-STATES.md            ← все состояния каждого экрана
└── 04-BEHAVIOR.md          ← логика, порядок элементов
```

Если этих файлов нет — AI нарисует "что-то похожее на Twitter", но:

- Цвета будут не те (AI выберет #000000 вместо #15202B)
- Кнопки будут квадратные (AI не знает про radius 24px)
- Не будет empty state (AI нарисует только данные)
- Порядок полей может быть не тот (Password сверху Email)

---

## 6. Что AI НЕ может сделать и должен проверить дизайнер

| Что AI делает плохо | Что проверяет дизайнер |
|---------------------|----------------------|
| Отступы между элементами | Правильные ли gap (16px vs 24px?) |
| Выравнивание текста | Не съехал ли текст влево, когда должен быть по центру |
| Цвета в разных темах | Light и Dark theme — одинаковые ли токены |
| Переполнение контента | Что будет, если username = 30 символов? |
| Accessibility | Контрастность, размер tap-target (min 44×44) |
| Анимации/переходы | Нет в документации → AI их не сделает |
| Pixel-perfect | AI округляет отступы (15px вместо 16px) |
| Иерархия компонентов | Button создан с нуля, а не из Design System |

---

## 7. Шаблон: задача дизайнеру для AI

```
## TASK-DESIGN-123: LoginScreen дизайн

### Входные данные
- SCREENS.md → LoginScreen
- DESIGN-SYSTEM.md → цвета, шрифты, компоненты
- WIDGET-DATA-FLOW.md → LoginScreen widget tree
- WIDGET-STATES.md → состояния Button, InputField
- 08-BEHAVIOR.md → логика и порядок элементов

### Формат
- Figma file: chirp-auth.fig
- Frame: iPhone 14 (390×844)
- Theme: Dark mode

### Что сделать
Создать Figma-дизайн LoginScreen с состояниями:
1. Default — пустая форма
2. Field error — невалидный email
3. Loading — spinner в кнопке
4. Error — 401 toast

Все компоненты — из Design System (не создавать новые).
```

---

## 8. Итог: минимальный набор для дизайнера

| Файл | Зачем | Кто заполняет |
|------|-------|---------------|
| **SCREENS.md** | Список экранов, элементы, состояния | Аналитик + AI |
| **WIDGET-DATA-FLOW.md** | Widget tree, иерархия, вложенность | Аналитик + AI |
| **DESIGN-SYSTEM.md** | 🎨 **Критично**: цвета, шрифты, отступы, компоненты | Дизайнер (без него AI придумает сам) |
| **WIDGET-STATES.md** | Состояния компонентов (Button enabled/disabled/loading) | Аналитик + AI |
| **08-BEHAVIOR.md** | Логика, порядок элементов, business rules | Аналитик + AI |
| **ERRORS.md** | Сообщения об ошибках для empty/error states | Аналитик |
| **DESIGN-CONTRACT.md** | Иконки (названия, размеры, экспорт) | Дизайнер |

**Критично:** DESIGN-SYSTEM.md и DESIGN-CONTRACT.md — без них AI не знает,
какого цвета кнопки и как называются иконки. Остальное AI может додумать,
но цвета и шрифты — нет.
