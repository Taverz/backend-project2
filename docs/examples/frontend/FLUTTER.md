# Chirp Flutter Frontend — Map

> **Для кого:** человек (онбординг) + AI (контекст для генерации кода).
> **Принцип:** каждый файл отвечает на вопрос «где искать?» и «как это работает?».

---

## 1. Идентичность проекта (копия из SOUL.md)

| Свойство | Значение |
|----------|----------|
| Проект | Chirp — Twitter-клон |
| Frontend | Flutter (web + mobile) |
| Backend | Go, REST API, порт 8080 |
| Auth | JWT access (15min) + refresh (7d) |
| API base | `/api/v1/` |

## 2. Экранная карта

```
/                       → SplashScreen (проверка JWT)
/login                  → LoginScreen
/register               → RegisterScreen
/home                   → HomeScreen (лента твитов)
/tweet/{id}             → TweetDetailScreen
/user/{id}              → ProfileScreen
/user/{id}/followers    → FollowersScreen
/user/{id}/following    → FollowingScreen
/notifications          → NotificationsScreen
/create                 → CreateTweetScreen
/search                 → SearchScreen
```

### Навигация

- Bottom navigation: Home, Search, Notifications, Profile
- Push: Tweet detail, User profile, Create tweet
- Modal: Login/Register (если не авторизован)

## 3. Структура директорий

```
chirp-flutter/
├── lib/
│   ├── main.dart                    # App entry, MaterialApp, routing
│   ├── app/
│   │   ├── app.dart                 # App widget, theme, navigation shell
│   │   └── router.dart              # GoRouter конфигурация (все routes)
│   ├── core/
│   │   ├── api/
│   │   │   ├── client.dart          # HTTP client (base URL, headers, JWT injection)
│   │   │   ├── interceptors.dart    # Auth interceptor (refresh 401)
│   │   │   └── endpoints.dart       # Константы: /auth/register, /tweets, ...
│   │   ├── auth/
│   │   │   ├── auth_service.dart    # Хранение токенов, проверка срока
│   │   │   └── auth_guard.dart      # Redirect to /login если нет токена
│   │   ├── theme/
│   │   │   ├── app_theme.dart       # Colors, typography, spacing
│   │   │   └── widgets.dart         # Общие стили для компонентов
│   │   ├── models/                  # Data transfer objects (from JSON)
│   │   │   ├── user.dart
│   │   │   ├── tweet.dart
│   │   │   ├── notification.dart
│   │   │   ├── follow.dart
│   │   │   └── pagination.dart      # PageResponse<T>
│   │   └── utils/
│   │       ├── date_format.dart     # "2 min ago", "yesterday" форматтер
│   │       └── validators.dart      # Email, password, username валидация
│   ├── features/                    # Каждая фича = свой модуль
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── widgets/
│   │   │   │   └── auth_form.dart   # Переиспользуемая форма
│   │   │   └── providers/
│   │   │       └── auth_provider.dart  # State: user, tokens, loading
│   │   ├── home/
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── tweet_card.dart      # Один твит в ленте
│   │   │   │   └── timeline_list.dart   # Пагинированный список
│   │   │   └── providers/
│   │   │       └── timeline_provider.dart
│   │   ├── tweet/
│   │   │   ├── screens/
│   │   │   │   ├── tweet_detail_screen.dart
│   │   │   │   └── create_tweet_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── tweet_actions.dart     # Like, reply, share кнопки
│   │   │   │   └── tweet_body.dart        # Текст + медиа
│   │   │   └── providers/
│   │   │       └── tweet_provider.dart
│   │   ├── profile/
│   │   │   ├── screens/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── followers_screen.dart
│   │   │   │   └── following_screen.dart
│   │   │   └── providers/
│   │   │       └── profile_provider.dart
│   │   ├── notifications/
│   │   │   ├── screens/
│   │   │   │   └── notifications_screen.dart
│   │   │   ├── widgets/
│   │   │   │   └── notification_tile.dart
│   │   │   └── providers/
│   │   │       └── notifications_provider.dart
│   │   └── search/
│   │       ├── screens/
│   │       │   └── search_screen.dart
│   │       └── providers/
│   │           └── search_provider.dart
│   └── shared/                       # Переиспользуемые UI-компоненты
│       ├── avatar.dart               # User avatar с инициалами
│       ├── loading.dart              # Spinner / skeleton
│       ├── error_widget.dart         # Повтор при ошибке
│       └── paginated_list.dart       # Бесконечный скролл (ScrollController)
├── test/                             # Тесты по той же структуре
├── pubspec.yaml
└── README.md
```

## 4. Data Flow

```
Screen → Provider (state) → Repository (API calls) → HTTP Client → Backend
                              ↑
                         Models (JSON → Dart)
```

**Provider — единственный источник правды** для экрана.
**Repository — точка интеграции с API**, слой маппинга JSON → Model.

**Пример для Timeline:**

```
HomeScreen
  └── TimelineProvider
        ├── fetchTimeline(cursor) → ApiClient.get('/timeline/home?limit=20&cursor=...')
        │     └── Response → PageResponse<Tweet> → update state
        ├── refresh() → clear + fetchTimeline(null)
        └── loadMore() → fetchTimeline(lastCursor)
```

## 5. API Layer

**`core/api/client.dart`**:

```dart
class ApiClient {
  static const baseUrl = 'http://localhost:8080/api/v1';

  Future<Response> get(String path, {Map<String,String>? query});
  Future<Response> post(String path, {Map<String,dynamic>? body});
  Future<Response> delete(String path);

  // Автоматически:
  // - добавляет Authorization: Bearer <token> если токен есть
  // - при 401 пытается refresh, если не вышло → logout
  // - кидает ApiException с HTTP status + detail
}
```

**`core/api/endpoints.dart`**:

```dart
class Endpoints {
  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';

  // Tweets
  static const tweets = '/tweets';
  static String tweet(String id) => '/tweets/$id';
  static String userTweets(String userId) => '/users/$userId/tweets';
  static String like(String tweetId) => '/tweets/$tweetId/like';
  static const search = '/tweets/search';

  // Follow
  static String follow(String userId) => '/users/$userId/follow';
  static String followers(String userId) => '/users/$userId/followers';
  static String following(String userId) => '/users/$userId/following';

  // Timeline
  static const homeTimeline = '/timeline/home';

  // Notifications
  static const notifications = '/notifications';
  static String markRead(String id) => '/notifications/$id/read';
}
```

## 6. Models (DTO)

Каждый model — `fromJson` / `toJson`. Соответствует Response из backend/DESIGN-API.md.

```dart
class Tweet {
  final String id;
  final String authorId;
  final String body;
  final String? parentId;
  final DateTime createdAt;

  factory Tweet.fromJson(Map<String, dynamic> json) => Tweet(
    id: json['id'],
    authorId: json['author_id'],
    body: json['body'],
    parentId: json['parent_id'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'body': body,
    if (parentId != null) 'parent_id': parentId,
  };
}

class PageResponse<T> {
  final List<T> data;
  final String? nextCursor;
  final bool hasMore;
  final int? total;

  factory PageResponse.fromJson(json, T Function(Map<String,dynamic>) fromItem) {
    return PageResponse(
      data: (json['data'] as List).map((e) => fromItem(e)).toList(),
      nextCursor: json['next_cursor'],
      hasMore: json['has_more'] ?? false,
      total: json['total'],
    );
  }
}
```

## 7. State Management

Выбран **Riverpod** (или Provider, или BLoC — решение фиксируется здесь).

```dart
// Пример TimelineProvider
@riverpod
class Timeline extends _$Timeline {
  Future<PageResponse<Tweet>> build() => _fetch(null);

  Future<PageResponse<Tweet>> _fetch(String? cursor) async {
    final client = ref.read(apiClientProvider);
    final response = await client.get(Endpoints.homeTimeline,
      query: {'limit': '20', if (cursor != null) 'cursor': cursor},
    );
    return PageResponse.fromJson(response.data, Tweet.fromJson);
  }

  Future<void> refresh() async { state = AsyncLoading(); state = await _fetch(null); }
  Future<void> loadMore() async { ... }
}
```

## 8. Theme

```dart
class AppTheme {
  static const primary = Color(0xFF1DA1F2);  // Twitter blue
  static const background = Color(0xFF15202B);  // Dark mode
  static const card = Color(0xFF192734);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    cardColor: card,
    fontFamily: 'Inter',
  );
}
```

## 9. Что AI надо знать про Flutter-проект

| AI должен | Где это лежит |
|-----------|---------------|
| Какой API вызывать | `core/api/endpoints.dart` |
| Как парсить ответ | `core/models/*.dart` → fromJson |
| Какой экран показывать | `app/router.dart` — GoRouter config |
| Как обновить состояние | `features/*/providers/*.dart` |
| Как выглядит компонент | `features/*/widgets/` или `shared/` |
| Какие цвета/шрифты | `core/theme/app_theme.dart` |

Если AI знает эти 6 точек входа — он может найти любой файл и понять контекст.

---

## Итого: минимальный набор файлов для frontend

| Файл | Объём | Зачем |
|------|-------|-------|
| `FLUTTER.md` | ~200 строк | Эта карта — ответ на вопрос «где что лежит» |
| `lib/core/api/endpoints.dart` | ~30 строк | Все эндпоинты в одном месте |
| `lib/core/api/client.dart` | ~80 строк | HTTP-клиент с авто-JWT и обработкой 401 |
| `lib/core/models/*.dart` | ~30-50 строк | fromJson для каждого ответа API |
| `lib/app/router.dart` | ~50 строк | Все route'ы с guards |
| `lib/core/theme/app_theme.dart` | ~30 строк | Цвета, шрифты, отступы |

Этого достаточно, чтобы:
- **Человек** зашёл в проект и за час разобрался, где что менять
- **AI** получил контекст и мог генерировать новые экраны, не гадая структуру
- **Оба** знали, где искать API-вызовы, модели, темы, routing
