# Visual Directions

> **3 направления** на выбор. Каждое поддерживает positioning и принципы, но по-разному.
> Выбираем одно — на нём строим дизайн-систему.
> Не выбираем "примерно нравится А и Б" — это размывает решения вниз по стеку.

---

## Как оценивать

Каждое направление проверяется по 4 вопросам:

1. **Поддерживает ли brand pillars?** (peer-verified / signal-over-noise / transparent)
2. **Marina и Vlad сказали бы "это серьёзно"?**
3. **Anna сказала бы "это профессиональный инструмент"?**
4. **Отличается ли от Twitter / LinkedIn визуально с первого взгляда?**

---

## Direction A — **Terminal Brutalism**

> Densely-packed dark UI, monospace acccents, almost editorial restraint.
> Bable выглядит как Linear, Vercel dashboard, Raycast, Cron, Arc browser dev tools.

### Mood
- Profession-grade developer tool
- "I'm working, don't bother me"
- Plotting hierarchy через типографику, не через цвет
- Чувство **системы**, не приложения

### References
- **Linear** — density, фокус на содержании, тёмный без cute
- **Vercel dashboard** — белые цифры на чёрном, монохром + 1 акцент
- **Raycast** — типографика-first, минимум хрома
- **Cron / Notion Calendar** — сухость, точность
- **arc.net** — dev-friendly, professional dark
- **GitHub dark dimmed** — comfortable читабельный dark

### Palette feel
- Background: глубокий чёрный или тёмный graphite (`#0A0A0A` / `#1A1A1A`)
- Text: высокий контраст white (`#EDEDED`)
- Accent: один яркий (electric blue, lime, или amber — выбираем при tokens)
- Никаких gradient, никаких 3D

### Typography feel
- **Sans-serif** для UI (Inter / Geist / Söhne)
- **Mono-serif или mono** для metadata, кода (JetBrains Mono / Geist Mono)
- Hierarchy через weight и size, не через цвет

### UI signature
```
┌─────────────────────────────────────────┐
│  Bable                          ●  ⌘K   │  ← top bar minimal
├─────────────────────────────────────────┤
│                                          │
│  ●  vlad.dev                             │
│     Senior FE, fmr Acme.                 │
│     React 720  System Design 510 Rust 280│  ← scores as inline metadata
│                                          │
│     ─────                                │  ← divider, 1px
│                                          │
│     12 Jun · 14:22                       │  ← timestamp dense
│                                          │
│     The Suspense subtree boundary        │
│     leaks promises if you don't wrap     │
│     the parent in startTransition. Here's│
│     why:                                 │
│                                          │
│     ```jsx                               │  ← code block prominent
│     <Suspense fallback={<Spinner />}>    │
│       <Async />                          │
│     </Suspense>                          │
│     ```                                  │
│                                          │
│     #react · medium                      │  ← tags as data, not chip
│     ─────                                │
│     ↑ 14 endorsements · 3 replies        │  ← actions dense, label-first
└─────────────────────────────────────────┘
```

### За направление
- ✅ Pillar 2 (signal-over-noise) — буквально воплощено
- ✅ Marina и Vlad — *"я ждал этого"*
- ✅ Anna — *"выглядит как инструмент, а не игрушка"*
- ✅ Отличается от Twitter / LinkedIn максимально

### Против
- ❌ Высокий barrier для junior'ов — может выглядеть пугающе
- ❌ Менее "tweetable" в маркетинге — нет cute screenshots
- ❌ Light mode потребует усилий, чтобы не выглядеть скучно

### Test
Если показать Vlad'у и сказать *"это новая dev-платформа"* — он откроет, не закроет.

---

## Direction B — **Editorial Calm**

> Тонкая типографика, много воздуха, спокойная цветовая палитра.
> Bable выглядит как Read.cv, Stripe Press, Pitch, Posthog blog, Vercel Conf landing.

### Mood
- Тех-журнал, не tech-dashboard
- Содержание — главное, оформление — рамка
- Светлая база с тёмными элементами (или наоборот, но без harsh contrast)
- Чувство **уважения к слову**, не плотности

### References
- **Read.cv** — профиль как страница журнала
- **Stripe Press** — серьёзность через типографику
- **Pitch.com** — сдержанный, чистый, но не sterile
- **PostHog blog** — tech content, но дышит
- **Substack reader** — фокус на чтении
- **Editorial NYT / Bloomberg** — иерархия через type

### Palette feel
- Background: тёплый white (`#FAF8F5`) или soft graphite (`#1F1F1F`)
- Text: умеренный contrast (`#0F0F0F` light / `#E7E2DC` dark)
- Accent: muted (terra cotta, sage, indigo deeper)
- Subtle background tones (cream / paper)

### Typography feel
- **Serif** для headlines и body (Söhne, Inter Display, или actual serif — Charter, Tiempos)
- **Sans-serif** для UI chrome
- Большие размеры, generous line-height (1.6+)
- Tracking широкий для caps

### UI signature
```
┌─────────────────────────────────────────┐
│                                          │
│   Bable                          Sign in │  ← top bar serif logo
│                                          │
├─────────────────────────────────────────┤
│                                          │
│        Vlad Iliev                        │  ← name large, serif
│        Senior FE Engineer                │  ← muted
│                                          │
│        ─                                 │  ← thin divider
│                                          │
│        React           720               │  ← score as editorial figure
│        System Design   510               │
│        Rust            280               │
│                                          │
│        ─                                 │
│                                          │
│        June 12, 2026                     │  ← date full, не "12 Jun"
│                                          │
│        The Suspense subtree boundary     │
│        leaks promises if you don't       │
│        wrap the parent in start          │
│        transition. Here's why...         │
│                                          │
│        [code block — softer styling]     │
│                                          │
│        Tagged   react · medium           │
│                                          │
│        14 endorsements                   │
│                                          │
└─────────────────────────────────────────┘
```

### За направление
- ✅ Marina, Vlad — *"тут не как у всех"*, отличается уважением к тексту
- ✅ Уникально (никто из конкурентов так не выглядит для dev-аудитории)
- ✅ Хорошо смотрится на маркетинговых сайтах / Twitter cards
- ✅ Сильный bias к **чтению**, не скроллингу

### Против
- ❌ Anna может сказать *"красиво, но не утилитарно"*
- ❌ Density низкая — меньше постов на экран
- ❌ Light mode default — нарушает PRINCIPLES "темная тема по умолчанию"
  - (можно решить: dark editorial, но это сложнее)
- ❌ Less "techy" — junior'ы могут не воспринимать как dev-tool

### Test
Если показать non-tech друзю и спросить *"что это"* — должен сказать *"какой-то журнал или блог"*. Если так — направление дойдёт.

---

## Direction C — **Modernized Forum**

> Современная переинтерпретация Stack Overflow / HN.
> Чёткие карточки, разумная плотность, lots of metadata visible, но без визуального шума.
> Bable выглядит как Lobste.rs, Discord channels, Linear comments, GitHub issues.

### Mood
- Знакомо tech-аудитории (форум, который они знают)
- Но без устаревшего chrome (Stack Overflow 2010-ish)
- Density умеренная — не Linear, не Read.cv
- Чувство **сообщества**, но серьёзного

### References
- **Lobste.rs** — структура форума с минимальным дизайном
- **Hacker News** — но рефакторинг (HN ужасно выглядит)
- **GitHub Issues / Discussions** — comments, threading, метаданные
- **Reddit (old.reddit стиль, не new)** — структура, не яркость
- **Discord forum channels** — современная переработка форум-формата
- **Tildes.net** — сообщество-focused, серьёзный

### Palette feel
- Background: neutral dark (`#161B22`) — GitHub-style
- Cards: чуть выше (`#1C2128`)
- Text: comfortable white (`#E6EDF3`)
- Accent: tech blue (`#388BFD`) или green
- Status-colors active (red, green, amber для notifications)

### Typography feel
- **Inter / SF Pro** — universal sans
- **JetBrains Mono** для code и метаданных
- Стандартные iOS / Material sizes (адаптивно)
- Hierarchy через size + weight, цвет вторичен

### UI signature
```
┌─────────────────────────────────────────┐
│  Bable    Feed  Discover  Notifications │  ← navigation tabs visible
│                              [Search]  ●│
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │  ●  Vlad Iliev (@vlad)               │ │
│ │     React 720 · System Design 510   │ │  ← score as badges horizontal
│ │     2h ago                           │ │
│ │                                      │ │
│ │     The Suspense subtree boundary    │ │
│ │     leaks promises if you don't      │ │
│ │     wrap the parent in              │ │
│ │     startTransition.                 │ │
│ │                                      │ │
│ │     [code block in container]       │ │
│ │                                      │ │
│ │     [react] [medium] [insight]       │ │  ← tag chips
│ │                                      │ │
│ │     ⌃ 14   💬 3   ⋯                  │ │  ← actions with icons
│ └─────────────────────────────────────┘ │
│                                          │
│ ┌─────────────────────────────────────┐ │
│ │  (next post card)                    │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### За направление
- ✅ Сразу понятно tech-аудитории (форум-pattern знаком)
- ✅ Density баланс — больше постов чем Editorial, меньше шума чем Twitter
- ✅ Карточки структурируют, не размывают
- ✅ Pillar 1 (peer-verified) — score badges visible везде

### Против
- ❌ Менее differentiated — выглядит как "хороший Reddit для tech"
- ❌ Может ассоциироваться с устаревшими форумами
- ❌ Vlad может сказать *"я хотел нечто менее обычное"*
- ❌ Tag chips могут стать визуальным шумом

### Test
Если показать tech-friend'у — он сразу поймёт, **как это работает**. Это и плюс (низкий barrier), и минус (нет элемента "вау").

---

## Сравнительная таблица

| Критерий | A: Terminal Brutalism | B: Editorial Calm | C: Modernized Forum |
|----------|:----------------------:|:-----------------:|:-------------------:|
| Поддержка Pillar 2 (signal>noise) | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Уникальность визуала | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Понятность tech-аудитории | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| Density | ⭐⭐⭐ | ⭐ | ⭐⭐ |
| Подходит для marketing screenshots | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Совместимо с principle "dark by default" | ⭐⭐⭐ | ⭐⭐ (нужно усилие) | ⭐⭐⭐ |
| Recruiter воспринимает как professional | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| Сложность дизайн-системы | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Risk: cold (отпугнёт) | ⭐⭐ | ⭐ | ⭐⭐⭐ ok |
| Sum | **22** | **20** | **21** |

(Метрика грубая, но даёт направление)

---

## Моё рекомендуемое направление

**A — Terminal Brutalism**.

Почему:
1. **Самая чёткая поддержка позиционирования.** "Signal over noise" — буквально воплощена в визуале
2. **Marina и Vlad точно полюбят.** Они users, мы их слушаем
3. **Уникально** — никто из конкурентов не выглядит так в нашей категории
4. **Pillar 3 (transparent)** — density позволяет показать больше данных вокруг каждого числа

Главный риск — **barrier для junior'ов**. Но junior'ы не primary user (см. personas — Marina mid, Vlad senior). И PRINCIPLES § 1 говорит: "tech-аудитория не любит decoration".

---

## Что дальше

Выбери одно направление. После выбора:

1. **Step 3 — Design Tokens:** выводим primitives из направления (colour scale, type scale, spacing, radius, motion)
2. **Step 4 — Components:** строим atomic library (Button, Avatar, ScoreBadge, PostCard ...)
3. **Step 5 — Flows & Wireframes:** sitemap, navigation, low-fi
4. **Step 6 — Screens:** hi-fi реализация всех 10 экранов MVP
