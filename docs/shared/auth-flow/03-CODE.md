# Auth — код на каждой платформе

---

## Backend (Go) — уже реализовано

| Файл | Что делает |
|------|-----------|
| `domain/user/` | User, Email, Username, Password value objects + validation |
| `port/auth.go` | AuthService interface (IssueTokenPair, ValidateAccessToken) |
| `port/password.go` | PasswordHasher interface (Hash, Compare) |
| `usecase/user/register.go` | Validate → unique → bcrypt → save → JWT |
| `usecase/user/login.go` | Find by email → compare → JWT |
| `adapter/memory/auth.go` | JWT HS256, access 15min, refresh 7d |
| `transport/auth_handler.go` | Decode → validate → usecase → response |
| `transport/middleware/auth.go` | AuthGuard middleware (Bearer → userID in context) |

---

## Flutter (Dart)

### Token storage

```dart
class AuthService {
  final _storage = FlutterSecureStorage();
  
  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }
  
  Future<String?> getAccessToken() => _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');
  Future<void> clearTokens() async { await _storage.deleteAll(); }
  Future<bool> isLoggedIn() async => await getAccessToken() != null;
}
```

### API Client with 401 handling

```dart
class ApiClient {
  final AuthService _auth;
  final client = http.Client();
  
  Future<Response> get(String path, {Map<String,String>? query}) async {
    final response = await client.get(
      Uri.parse('$baseUrl$path').replace(queryParameters: query),
      headers: await _headers(),
    );
    if (response.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) return get(path, query: query); // retry
      throw AuthException(); // → redirect /login
    }
    return response;
  }
  
  Future<Map<String,String>> _headers() async {
    final token = await _auth.getAccessToken();
    return {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
  }
  
  Future<bool> _tryRefresh() async {
    final refresh = await _auth.getRefreshToken();
    if (refresh == null) return false;
    final res = await client.post(Uri.parse('$baseUrl/auth/refresh'),
      body: jsonEncode({'refresh_token': refresh}));
    if (res.statusCode != 200) return false;
    final data = jsonDecode(res.body);
    await _auth.saveTokens(data['access_token'], data['refresh_token']);
    return true;
  }
}
```

### GoRouter Auth Guard

```dart
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    final isAuthRoute = state.matchedLocation == '/login' 
                     || state.matchedLocation == '/register';
    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/home';
    return null;
  },
);
```

---

## Android (Kotlin)

### Token storage

```kotlin
class TokenStorage(context: Context) {
    private val prefs = EncryptedSharedPreferences.create(
        "auth_prefs", 
        MasterKey.DEFAULT_MASTER_KEY_ALIAS,
        context,
        PrefKeyEncryptionScheme.AES256_SIV,
        PrefValueEncryptionScheme.AES256_GCM
    )
    
    fun saveTokens(access: String, refresh: String) {
        prefs.edit().putString("access_token", access)
            .putString("refresh_token", refresh).apply()
    }
    
    fun getAccessToken(): String? = prefs.getString("access_token", null)
    fun clearTokens() = prefs.edit().clear().apply()
}
```

### Retrofit Auth Interceptor

```kotlin
class AuthInterceptor(private val tokenStorage: TokenStorage) : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val token = tokenStorage.getAccessToken()
        val request = chain.request().newBuilder()
            .addHeader("Authorization", "Bearer $token")
            .build()
        val response = chain.proceed(request)
        
        if (response.code == 401) {
            // try refresh → retry, or clear → NavGraph → Login
        }
        return response
    }
}
```

### NavGraph Guard

```kotlin
NavHost(navController, startDestination = "splash") {
    composable("splash") { SplashScreen(onAuth = { navController.navigate("home") }) }
    composable("login") { LoginScreen(onSuccess = { navController.navigate("home") { popUpTo(0) } }) }
    composable("register") { RegisterScreen(onSuccess = { navController.navigate("home") }) }
    composable("home") { HomeScreen(onLogout = { 
        tokenStorage.clearTokens()
        navController.navigate("login") { popUpTo(0) }
    }) }
}
```

---

## iOS (Swift)

### Token storage

```swift
class KeychainService {
    func save(key: String, value: String) {
        let query = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: key,
                     kSecValueData: value.data(using: .utf8)!] as CFDictionary
        SecItemDelete(query) // remove old
        SecItemAdd(query, nil)
    }
    
    func read(key: String) -> String? {
        let query = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: key,
                     kSecReturnData: true, kSecMatchLimit: kSecMatchLimitOne] as CFDictionary
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        return (result as? Data).flatMap { String(data: $0, encoding: .utf8) }
    }
    
    func delete(key: String) {
        SecItemDelete([kSecClass: kSecClassGenericPassword, kSecAttrAccount: key] as CFDictionary)
    }
}
```

### URLSession Auth Delegate

```swift
class TokenRefreshDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didFinishCollecting metrics: URLSessionTaskMetrics) {}
    
    // Handle 401 in APIClient
}

actor APIClient {
    private let keychain = KeychainService()
    private let session = URLSession.shared
    
    func request(_ path: String) async throws -> Data {
        var request = URLRequest(url: URL(string: "http://localhost:8080\(path)")!)
        request.setValue("Bearer \(keychain.read(key: "access_token") ?? "")",
                        forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        
        if http.statusCode == 401 {
            try await refreshTokens()
            return try await request(path) // retry
        }
        return data
    }
}
```

### ViewModel with auth state

```swift
@Observable
class AuthViewModel {
    var isLoggedIn: Bool { keychain.read(key: "access_token") != nil }
    
    func login(email: String, password: String) async {
        do {
            let body = ["email": email, "password": password]
            let data = try await api.post("/auth/login", body: body)
            let resp = try JSONDecoder().decode(AuthResponse.self, from: data)
            keychain.save(key: "access_token", value: resp.accessToken)
            keychain.save(key: "refresh_token", value: resp.refreshToken)
        } catch {
            state = .error("Invalid email or password")
        }
    }
}
```

---

## Web (TypeScript / React)

### Token storage

```typescript
// Option A: localStorage (simpler)
const TOKEN_KEYS = { access: 'chirp_access', refresh: 'chirp_refresh' };

export function saveTokens(access: string, refresh: string) {
  localStorage.setItem(TOKEN_KEYS.access, access);
  localStorage.setItem(TOKEN_KEYS.refresh, refresh);
}

export function getAccessToken(): string | null {
  return localStorage.getItem(TOKEN_KEYS.access);
}

export function clearTokens() {
  localStorage.removeItem(TOKEN_KEYS.access);
  localStorage.removeItem(TOKEN_KEYS.refresh);
}

// Option B: httpOnly cookie (more secure)
// Backend sets cookie on login/register, JS cannot read it.
```

### API Client + Interceptor

```typescript
const api = axios.create({ baseURL: 'http://localhost:8080/api/v1' });

api.interceptors.request.use((config) => {
  const token = getAccessToken();
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  (res) => res,
  async (error) => {
    if (error.response?.status !== 401) throw error;
    const refresh = localStorage.getItem(TOKEN_KEYS.refresh);
    if (!refresh) { clearTokens(); window.location.href = '/login'; return; }
    
    try {
      const { data } = await axios.post('/auth/refresh', { refresh_token: refresh });
      saveTokens(data.access_token, data.refresh_token);
      error.config.headers.Authorization = `Bearer ${data.access_token}`;
      return api(error.config); // retry
    } catch {
      clearTokens();
      window.location.href = '/login';
    }
  }
);
```

### React Router Auth Guard

```typescript
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const token = getAccessToken();
  if (!token) return <Navigate to="/login" replace />;
  return <>{children}</>;
}

// App
<Routes>
  <Route path="/login" element={<LoginPage />} />
  <Route path="/register" element={<RegisterPage />} />
  <Route path="/home" element={<ProtectedRoute><HomePage /></ProtectedRoute>} />
</Routes>
```

### Form component

```typescript
function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const { data } = await api.post('/auth/login', { email, password });
      saveTokens(data.access_token, data.refresh_token);
      window.location.href = '/home';
    } catch (err) {
      setError('Invalid email or password');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input type="email" value={email} onChange={e => setEmail(e.target.value)} placeholder="Email" />
      <input type="password" value={password} onChange={e => setPassword(e.target.value)} placeholder="Password" />
      {error && <p className="error">{error}</p>}
      <button type="submit" disabled={loading}>{loading ? 'Loading...' : 'Log in'}</button>
    </form>
  );
}
```
