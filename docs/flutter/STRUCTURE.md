# Chirp Flutter — Project Structure

---

## Stack

| Layer | Choice |
|-------|--------|
| Platform | Flutter 3.x (web + mobile) |
| State management | Riverpod |
| Navigation | GoRouter |
| HTTP | `http` package + custom client |
| Models | Hand-written fromJson/toJson |
| Linting | flutter_lints |

---

## Directory Layout

```
chirp-flutter/
├── lib/
│   ├── main.dart                    # App entry, ProviderScope, MaterialApp.router
│   │
│   ├── app/
│   │   ├── app.dart                 # MaterialApp widget, theme, navigation shell
│   │   └── router.dart              # GoRouter config (all routes, redirects, guards)
│   │
│   ├── core/
│   │   ├── api/
│   │   │   ├── client.dart          # HTTP client: base URL, JWT injection, 401 handling
│   │   │   └── endpoints.dart       # All endpoint constants (from shared/API.md)
│   │   ├── models/
│   │   │   ├── user.dart            # User.fromJson, User.toJson
│   │   │   ├── tweet.dart           # Tweet.fromJson
│   │   │   ├── notification.dart
│   │   │   ├── follow.dart
│   │   │   └── pagination.dart      # PageResponse<T>.fromJson
│   │   ├── auth/
│   │   │   ├── auth_service.dart    # Token storage (flutter_secure_storage)
│   │   │   └── auth_guard.dart      # GoRouter redirect if no token
│   │   ├── theme/
│   │   │   └── app_theme.dart       # Colors, typography from shared/DESIGN-SYSTEM.md
│   │   └── utils/
│   │       ├── date_format.dart     # Relative time ("2m ago", "yesterday")
│   │       └── validators.dart      # Email, password, username client validation
│   │
│   ├── features/                    # Feature-first modules
│   │   ├── auth/
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   └── widgets/
│   │   │       └── auth_form.dart
│   │   ├── home/
│   │   │   ├── providers/
│   │   │   │   └── timeline_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── tweet_card.dart
│   │   │       └── timeline_list.dart
│   │   ├── tweet/
│   │   │   ├── providers/
│   │   │   │   └── tweet_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── tweet_detail_screen.dart
│   │   │   │   └── create_tweet_screen.dart
│   │   │   └── widgets/
│   │   │       ├── tweet_actions.dart
│   │   │       └── tweet_body.dart
│   │   ├── profile/
│   │   │   ├── providers/
│   │   │   │   └── profile_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── followers_screen.dart
│   │   │   │   └── following_screen.dart
│   │   │   └── widgets/
│   │   │       └── profile_header.dart
│   │   ├── notifications/
│   │   │   ├── providers/
│   │   │   │   └── notifications_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── notifications_screen.dart
│   │   │   └── widgets/
│   │   │       └── notification_tile.dart
│   │   └── search/
│   │       ├── providers/
│   │       │   └── search_provider.dart
│   │       ├── screens/
│   │       │   └── search_screen.dart
│   │       └── widgets/
│   │           └── search_bar.dart
│   │
│   └── shared/                      # Reusable UI
│       ├── avatar.dart
│       ├── loading.dart
│       ├── error_widget.dart
│       └── paginated_list.dart
│
├── test/                            # Mirrors lib/ structure
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## Conventions

1. **Feature-first**: every feature = `features/{name}/` with `screens/`, `widgets/`, `providers/`
2. **Riverpod**: one provider per feature, async state (`AsyncValue`)
3. **GoRouter**: routes in one file, `redirect` for auth guard
4. **ApiClient**: single instance, injected via Provider, handles JWT + 401
5. **Endpoints**: constants only, no raw strings in screens

---

## Data Flow

```
Screen → ref.watch(provider) → provider calls ApiClient → Backend
                                  ↑                          ↓
                              fromJson                    JSON response
```

- Screen never calls ApiClient directly
- Provider holds state: loading / data / error
- Pagination: provider tracks cursor + hasMore + loadMore()
