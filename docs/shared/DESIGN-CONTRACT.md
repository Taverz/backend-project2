# Chirp — Design ↔ Dev Contract

> Контракт между дизайнерами (Figma) и разработчиками (код).
> Как называются компоненты, как экспортируются иконки, какие состояния у экранов.

---

## 1. Figma → Code naming

Каждый слой/компонент в Figma называется так же, как в коде.
Без перевода, без транслитерации.

| Figma layer name | Code name (все платформы) |
|------------------|--------------------------|
| `TweetCard` | `TweetCard` / `tweet_card.dart` / `TweetCard.kt` / `TweetCardView.swift` |
| `Avatar` | `Avatar` |
| `PrimaryButton` | `PrimaryButton` |
| `InputField` | `InputField` |
| `NotificationTile` | `NotificationTile` |
| `LoadingSkeleton` | `LoadingSkeleton` |
| `ErrorState` | `ErrorState` |
| `EmptyState` | `EmptyState` |
| `BottomTabBar` | `BottomTabBar` |
| `TopBar` | `TopBar` |

**Правило:** дизайнер называет фрейм в Figma — разработчик ищет точно такое же имя в коде. Без маппинга.

---

## 2. Design Tokens

Цвета, шрифты, отступы — через именованные токены.
Дизайнер использует токен — разработчик использует тот же токен.

### Colors

| Token name | Figma name | Hex | Code variable |
|-----------|-----------|-----|---------------|
| `primary` | `Primary` | `#1DA1F2` | `AppTheme.primary` / `Color.primary` / `Colors.primary` |
| `background` | `Background` | `#FFFFFF` / `#15202B` | `AppTheme.background` |
| `card` | `Card` | `#F5F5F5` / `#192734` | `AppTheme.card` |
| `cardBorder` | `CardBorder` | `#E1E8ED` / `#38444D` | `AppTheme.cardBorder` |
| `textPrimary` | `TextPrimary` | `#0F1419` / `#E7E9EA` | `AppTheme.textPrimary` |
| `textSecondary` | `TextSecondary` | `#536471` / `#71767B` | `AppTheme.textSecondary` |
| `error` | `Error` | `#E0245E` / `#F4212E` | `AppTheme.error` |
| `success` | `Success` | `#00BA7C` | `AppTheme.success` |

### Typography

| Token name | Figma style | Size/Weight | Code |
|-----------|------------|:-----------:|------|
| `h1` | `H1` | 24/700 | `TextStyle(fontSize: 24, fontWeight: FontWeight.w700)` |
| `body` | `Body` | 16/400 | `TextStyle(fontSize: 16, fontWeight: FontWeight.w400)` |
| `bodyBold` | `BodyBold` | 16/700 | `TextStyle(fontSize: 16, fontWeight: FontWeight.w700)` |
| `caption` | `Caption` | 13/400 | `TextStyle(fontSize: 13, fontWeight: FontWeight.w400)` |
| `button` | `Button` | 15/600 | `TextStyle(fontSize: 15, fontWeight: FontWeight.w600)` |

### Spacing

| Token | Pixels | Figma name | Code |
|-------|:------:|-----------|------|
| `spaceXs` | 4 | `4px` | `Spacing.xs` |
| `spaceSm` | 8 | `8px` | `Spacing.sm` |
| `spaceMd` | 12 | `12px` | `Spacing.md` |
| `spaceLg` | 16 | `16px` | `Spacing.lg` |
| `spaceXl` | 24 | `24px` | `Spacing.xl` |
| `spaceXxl` | 32 | `32px` | `Spacing.xxl` |

---

## 3. Icons

### Export format

| Property | Spec |
|----------|------|
| Format | SVG (не PNG) |
| Size | 24×24 (viewBox="0 0 24 24") |
| Color | CurrentColor (inherit from text color) |
| Stroke | 1.5px |
| Stroke linecap | round |
| Stroke linejoin | round |
| Fill | none (кроме filled heart для liked) |

### Figma → code naming

| Icon name in Figma | File name | iOS SF Symbol | Android resource |
|-------------------|-----------|---------------|-----------------|
| `heart-outline` | `ic_heart_outline.svg` | `heart` | `ic_heart_outline` |
| `heart-filled` | `ic_heart_filled.svg` | `heart.fill` | `ic_heart_filled` |
| `reply` | `ic_reply.svg` | `arrowshape.turn.up.left` | `ic_reply` |
| `retweet` | `ic_retweet.svg` | `arrow.2.squarepath` | `ic_retweet` |
| `share` | `ic_share.svg` | `square.and.arrow.up` | `ic_share` |
| `search` | `ic_search.svg` | `magnifyingglass` | `ic_search` |
| `bell` | `ic_bell.svg` | `bell` | `ic_bell` |
| `bell-filled` | `ic_bell_filled.svg` | `bell.fill` | `ic_bell_filled` |
| `profile` | `ic_profile.svg` | `person.circle` | `ic_profile` |
| `close` | `ic_close.svg` | `xmark` | `ic_close` |
| `new-tweet` | `ic_new_tweet.svg` | `square.and.pencil` | `ic_new_tweet` |
| `settings` | `ic_settings.svg` | `gearshape` | `ic_settings` |

**Правило:** дизайнер экспортирует SVG с именем из таблицы. Разработчик кладёт файл в `/assets/icons/` с тем же именем. Без переименования.

---

## 4. Screen states in Figma

Каждый экран в Figma содержит **все состояния**:

| State | Figma page name | Code проверка |
|-------|----------------|---------------|
| Loading | `{ScreenName}/Loading` | `TimelineViewModel.state == .loading` |
| Empty | `{ScreenName}/Empty` | `timeline.isEmpty` |
| Error | `{ScreenName}/Error` | `error != nil` |
| Data | `{ScreenName}/Data` | `tweets.isNotEmpty` |
| Loading more | `{ScreenName}/LoadingMore` | `isLoadingMore && hasMore` |

**Figma example:**

```
Pages panel:
├── Home/
│   ├── Loading        ← 3 skeleton cards
│   ├── Empty          ← "No tweets yet" + "Find people" CTA
│   ├── Error          ← "Something went wrong" + Retry
│   ├── Data           ← список твитов
│   └── LoadingMore    ← spinner внизу списка
├── Profile/
│   ├── Loading
│   ├── OwnProfile     ← "Edit profile" button
│   ├── OtherProfile   ← "Follow" button
│   ├── NotFound       ← "User not found"
│   └── Data           ← tweets tab
```

---

## 5. Export rules for designers

| What | Format | Name rule | Where to put |
|------|--------|----------|-------------|
| Icons | SVG, 24×24, currentColor | `ic_{name}.svg` | `/assets/icons/` |
| Images/photos | PNG/WebP, max 2x | `img_{name}.png` | `/assets/images/` |
| Illustrations | SVG | `ill_{name}.svg` | `/assets/illustrations/` |
| Animations | Lottie JSON | `anim_{name}.json` | `/assets/animations/` |

**Figma export settings for icons:**
- Export as: SVG
- Suffix: `ic_`
- 1x only (vector scales infinitely)
- Stroke: convert to outline → **NO** (keep stroke for currentColor)

---

## 6. Auto-layout / Constraints

| Figma property | Code equivalent |
|---------------|----------------|
| Auto Layout → Horizontal | `Row` (Flutter) / `Row` (Compose) / `HStack` (SwiftUI) |
| Auto Layout → Vertical | `Column` / `Column` / `VStack` |
| Fill container | `flex: 1` / `Modifier.fillMaxWidth()` / `frame(maxWidth: .infinity)` |
| Hug content | `mainAxisSize: min` / `wrapContentWidth` / `fixedSize` |
| Center | `MainAxisAlignment.center` / `Arrangement.Center` |
| Space between | `MainAxisAlignment.spaceBetween` / `Arrangement.SpaceBetween` |
| Padding | `padding: EdgeInsets.all(16)` / `Modifier.padding(16.dp)` |
| Gap | `SizedBox(width: 8)` / `Spacer(8)` / `Spacer().frame(width: 8)` |

---

## 7. Text styles in Figma

Дизайнер использует **Text Styles**, не ручные настройки.

| Figma Text Style | Applies to |
|-----------------|-----------|
| `H1` | Screen titles |
| `H2` | Section headers |
| `Body` | Tweet text, form labels |
| `BodyBold` | Usernames, emphasis |
| `Caption` | Timestamps, helper text |
| `Button` | All button labels |

**Правило:** ни один текстовый слой не должен быть без стиля. Если стиля нет — дизайнер его сначала создаёт, потом применяет.

---

## 8. Component variants

### Button

| Figma variant | States | Code |
|-------------|--------|------|
| `Button/Primary` | Default, Hover, Disabled, Loading | `PrimaryButton` |
| `Button/Outline` | Default (Follow), Active (Following) | `OutlineButton` |
| `Button/Text` | Default, Disabled | `TextButton` |

### TweetCard

| Figma variant | State |
|-------------|-------|
| `TweetCard/Default` | Обычный твит |
| `TweetCard/Liked` | ❤️ filled |
| `TweetCard/WithImage` | Твит с медиа (будущее) |

---

## 9. Figma file structure

```
Chirp Design (Figma project)
├── 🎨 Design System
│   ├── Colors           ← все токены цветов
│   ├── Typography       ← все text styles
│   ├── Spacing          ← все отступы
│   ├── Icons            ← все иконки (SVG)
│   └── Components       ← Button, InputField, Avatar, TweetCard
│
├── 📱 Screens (mobile)
│   ├── Auth             ← Login, Register
│   ├── Home             ← Timeline
│   ├── Tweet            ← Detail, Create
│   ├── Profile          ← Profile, Followers, Following
│   ├── Notifications
│   └── Search
│
├── 🖥️ Screens (web)
│   └── ...              ← same screens, wider layout
│
└── 🔄 Prototype         ← навигация между экранами
```

---

## 10. Review process

1. Дизайнер закончил экран → **ставит в Pronto / Zeplin / Figma Dev Mode**
2. Разработчик открывает → сверяет:
   - Все ли состояния есть (Loading, Empty, Error, Data)?
   - Все ли иконки названы по контракту?
   - Все ли текстовые слои используют Text Styles?
3. Если несоответствие → задача дизайнеру на правку
4. Если OK → реализация

---

## Итого

| Что | Ответственный | Где зафиксировано |
|-----|--------------|-------------------|
| Цвета | Дизайнер → Figma tokens | DESIGN-SYSTEM.md |
| Шрифты | Дизайнер → Figma text styles | DESIGN-SYSTEM.md |
| Компоненты | Дизайнер → Figma components | DESIGN-SYSTEM.md |
| Иконки | Дизайнер → SVG export | Этот файл (секция 3) |
| Состояния экранов | Дизайнер → Figma pages | Этот файл (секция 4) |
| Naming | Оба соблюдают | Этот файл (секция 1) |
| Экспорт | Дизайнер соблюдает правила | Этот файл (секция 5) |
