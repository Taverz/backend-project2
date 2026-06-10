# Chirp Flutter — Project Structure

---

## Stack

| Layer | Choice |
|-------|--------|
| Platform | Flutter 3.x (web + mobile) |
| State management | Riverpod (with code generation) |
| Navigation | GoRouter |
| HTTP | `http` package + custom ApiClient |
| Models | Hand-written fromJson/toJson |
| Auth storage | flutter_secure_storage |
| Linting | flutter_lints |

---

## pubspec.yaml (key deps)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5
  riverpod_annotation: ^2.3
  go_router: ^14.0
  flutter_secure_storage: ^9.0
  http: ^1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.4
  build_runner: ^2.4
  flutter_lints: ^4.0
```

---

## Directory Layout

```
chirp-flutter/
├── lib/
│   ├── main.dart                        # ProviderScope + MaterialApp.router
│   │
│   ├── app/
│   │   ├── app.dart                     # MaterialApp.router, theme, shell
│   │   └── router.dart                  # GoRouter: all routes + auth redirect
│   │
│   ├── core/
│   │   ├── api/
│   │   │   ├── client.dart              # ApiClient: base URL, JWT injection, 401→refresh
│   │   │   ├── endpoints.dart           # All endpoint constants (from shared/API.md)
│   │   │   └── exceptions.dart          # ApiException, AuthException
│   │   ├── models/
│   │   │   ├── user.dart                # User, AuthResponse (fromJson)
│   │   │   ├── tweet.dart               # Tweet (fromJson)
│   │   │   ├── notification.dart
│   │   │   └── pagination.dart          # PageResponse<T>.fromJson (generic)
│   │   ├── auth/
│   │   │   ├── auth_service.dart        # Token storage (secure), refresh flow
│   │   │   └── auth_provider.dart       # Riverpod provider: current user, isLoggedIn
│   │   ├── theme/
│   │   │   └── app_theme.dart           # From shared/DESIGN-SYSTEM.md
│   │   └── utils/
│   │       ├── date_format.dart         # "2m ago", "yesterday", "June 10"
│   │       └── validators.dart          # Email, username, password validators
│   │
│   ├── features/                        # Feature-first
│   │   ├── auth/
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart   # login/register/logout state
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   └── widgets/
│   │   │       ├── login_form.dart
│   │   │       └── register_form.dart
│   │   ├── home/
│   │   │   ├── providers/
│   │   │   │   └── timeline_provider.dart  # AsyncNotifier: loadMore, refresh
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── tweet_card.dart         # Avatar + body + actions row
│   │   │       └── timeline_list.dart       # PaginatedListView with refresh
│   │   ├── tweet/
│   │   │   ├── providers/
│   │   │   │   └── tweet_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── tweet_detail_screen.dart
│   │   │   │   └── create_tweet_screen.dart
│   │   │   └── widgets/
│   │   │       ├── tweet_actions.dart       # Like/Reply/Share buttons
│   │   │       └── tweet_body.dart           # Text with highlight
│   │   ├── profile/
│   │   │   ├── providers/
│   │   │   │   └── profile_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── followers_screen.dart
│   │   │   │   └── following_screen.dart
│   │   │   └── widgets/
│   │   │       ├── profile_header.dart
│   │   │       └── stats_row.dart
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
│   │           ├── search_bar_widget.dart
│   │           └── search_results.dart
│   │
│   └── shared/                            # Reusable UI
│       ├── avatar.dart                    # CircleAvatar with initials fallback
│       ├── loading.dart                   # Skeleton / CircularProgressIndicator
│       ├── error_view.dart                # Error + Retry button
│       ├── empty_view.dart                # Empty state with CTA
│       └── infinite_scroll_list.dart      # ScrollController + loadMore callback
│
├── test/                                  # Mirror of lib/ structure
│   ├── core/
│   │   ├── api/
│   │   └── models/
│   ├── features/
│   │   ├── auth/
│   │   ├── home/
│   │   └── ...
│   └── shared/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## Auth patterns

### Token storage

```dart
// core/auth/auth_service.dart
class AuthService {
  final _storage = FlutterSecureStorage();
  
  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }
  
  Future<String?> getAccessToken() => _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');
  Future<bool> isLoggedIn() async => await getAccessToken() != null;
  Future<void> clearTokens() async => await _storage.deleteAll();
}
```

### Auth provider (Riverpod)

```dart
@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    final isLoggedIn = await ref.read(authServiceProvider).isLoggedIn();
    if (isLoggedIn) {
      try { return AuthState(await _fetchUser(), isLoggedIn: true); }
      catch (_) { return AuthState(null, isLoggedIn: false); }
    }
    return AuthState(null, isLoggedIn: false);
  }
  
  Future<void> login(String email, String password) async { /* ApiClient → saveTokens → state */ }
  Future<void> register(String username, String email, String password) async { /* ... */ }
  Future<void> logout() async { /* clearTokens → state = unauthenticated */ }
}
```

### GoRouter guard

```dart
// app/router.dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.isLoggedIn ?? false;
      final path = state.matchedLocation;
      final isPublic = path == '/login' || path == '/register';
      
      if (!isLoggedIn && !isPublic) return '/login';
      if (isLoggedIn && isPublic) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/tweet/:id', builder: (_, state) => TweetDetailScreen(id: state.pathParameters['id']!)),
          GoRoute(path: '/create', builder: (_, __) => const CreateTweetScreen()),
          GoRoute(path: '/user/:id', builder: (_, state) => ProfileScreen(id: state.pathParameters['id']!)),
        ],
      ),
    ],
  );
});
```

### ApiClient with 401 → refresh

```dart
class ApiClient {
  final AuthService _auth;
  final http.Client _client = http.Client();
  static const _base = 'http://localhost:8080/api/v1';

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final token = await _auth.getAccessToken();
      final uri = Uri.parse('$_base$path').replace(queryParameters: query);
      final response = await _client.get(uri, headers: _headers(token));
      if (response.statusCode != 401) return response;
      if (!await _tryRefresh()) break;
    }
    throw AuthException();
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _auth.getRefreshToken();
    if (refresh == null) return false;
    try {
      final res = await _client.post(
        Uri.parse('$_base/auth/refresh'),
        body: jsonEncode({'refresh_token': refresh}),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body);
      await _auth.saveTokens(data['access_token'], data['refresh_token']);
      return true;
    } catch (_) { return false; }
  }

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}
```

---

## Riverpod patterns

### Pagination (Timeline example)

```dart
@riverpod
class Timeline extends _$Timeline {
  String? _cursor;
  bool _hasMore = true;

  @override
  Future<List<Tweet>> build() => _fetch(null);

  Future<List<Tweet>> _fetch(String? cursor) async {
    final client = ref.read(apiClientProvider);
    final res = await client.get('/timeline/home', query: {'limit': '20', if (cursor != null) 'cursor': cursor});
    final body = jsonDecode(res.body);
    _cursor = body['next_cursor'];
    _hasMore = body['has_more'];
    return (body['data'] as List).map((e) => Tweet.fromJson(e)).toList();
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    final more = await _fetch(_cursor);
    state = AsyncData([...state.value ?? [], ...more]);
  }

  Future<void> refresh() async { state = AsyncLoading(); state = AsyncData(await _fetch(null)); }
}
```

### Loading/Error/Data in UI

```dart
// home_screen.dart
final timeline = ref.watch(timelineProvider);
timeline.when(
  loading: () => const SkeletonList(),
  error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(timelineProvider)),
  data: (tweets) => tweets.isEmpty
    ? const EmptyView(message: 'No tweets yet. Follow someone!')
    : TimelineList(tweets: tweets, onLoadMore: () => ref.read(timelineProvider.notifier).loadMore()),
);
```

---

## Forms

```dart
// features/auth/widgets/login_form.dart
class LoginForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).login(_email.text, _password.text);
    if (mounted) setState(() => _loading = false); // Error handled by provider → UI reacts
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(children: [
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
          validator: (v) => validateEmail(v) ? null : 'Invalid email',
        ),
        TextFormField(
          controller: _password,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
          validator: (v) => (v?.length ?? 0) >= 8 ? null : 'At least 8 characters',
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading ? const CircularProgressIndicator() : const Text('Log in'),
        ),
      ]),
    );
  }
}
```

---

## Error handling strategy

| Layer | What happens |
|-------|-------------|
| **ApiClient** | Catches 401 → tries refresh → if fails → throws `AuthException` (caught by GoRouter redirect) |
| **Provider** | Catches exceptions → state = `AsyncError` → UI shows ErrorView |
| **Screen** | `ref.listen(authProvider, (_, next) { if (next is AsyncError) showSnackBar(...) })` |
| **Router** | On `AuthException` or `clearTokens()` → redirect to `/login` |

---

## Key rules

1. **Screen never calls API directly** — always through a provider
2. **Provider holds state** — use `AsyncValue<T>` (loading/error/data)
3. **One provider per feature** — auth, timeline, tweet, profile, notifications, search
4. **Endpoints as constants** — no raw URL strings in screens
5. **Models with fromJson** — exactly matching backend response (camelCase or snake_case based on backend)
6. **No global state** — inject via Riverpod `ref.read()` / `ref.watch()`
