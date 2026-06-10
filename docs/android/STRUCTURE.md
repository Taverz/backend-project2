# Chirp Android — Project Structure

---

## Stack

| Layer | Choice |
|-------|--------|
| Language | Kotlin |
| UI | Jetpack Compose |
| Architecture | MVVM + Clean Architecture (data/domain/presentation) |
| DI | Hilt |
| Navigation | Jetpack Navigation Compose |
| HTTP | Retrofit + OkHttp |
| Models | Kotlinx Serialization / Moshi |
| Auth tokens | DataStore / EncryptedSharedPreferences |
| Async | Kotlin Coroutines + Flow |
| Linting | detekt, ktlint |

---

## Directory Layout

```
chirp-android/
├── app/
│   └── src/main/java/com/chirp/
│       │
│       ├── ChirpApp.kt                     # Application class, Hilt entry
│       ├── MainActivity.kt                 # Single activity, setContent with NavHost
│       │
│       ├── di/                             # Hilt modules
│       │   ├── NetworkModule.kt            # OkHttp + Retrofit + Auth interceptor
│       │   ├── RepositoryModule.kt         # Bind repository implementations
│       │   └── DatabaseModule.kt           # Room database (if offline cache)
│       │
│       ├── data/                           # Data layer
│       │   ├── remote/
│       │   │   ├── ApiService.kt           # Retrofit interface (all endpoints)
│       │   │   ├── AuthInterceptor.kt      # JWT injection + 401 → refresh
│       │   │   └── dto/                    # API response DTOs
│       │   │       ├── UserDto.kt
│       │   │       ├── TweetDto.kt
│       │   │       ├── NotificationDto.kt
│       │   │       └── PageResponseDto.kt
│       │   ├── local/                      # Optional: Room entities
│       │   └── repository/                 # Repository implementations
│       │       ├── AuthRepositoryImpl.kt
│       │       ├── TweetRepositoryImpl.kt
│       │       └── TimelineRepositoryImpl.kt
│       │
│       ├── domain/                         # Domain layer (pure Kotlin)
│       │   ├── model/
│       │   │   ├── User.kt
│       │   │   ├── Tweet.kt
│       │   │   ├── Notification.kt
│       │   │   └── PageResponse.kt
│       │   ├── repository/                 # Repository interfaces
│       │   │   ├── AuthRepository.kt
│       │   │   ├── TweetRepository.kt
│       │   │   └── TimelineRepository.kt
│       │   └── usecase/                    # Optional: if complex logic
│       │       ├── FollowUserUseCase.kt
│       │       └── CreateTweetUseCase.kt
│       │
│       ├── presentation/                   # UI layer
│       │   ├── navigation/
│       │   │   └── NavGraph.kt             # All routes, navigation actions
│       │   ├── theme/
│       │   │   ├── Color.kt               # From shared/DESIGN-SYSTEM.md
│       │   │   ├── Type.kt                # From shared/DESIGN-SYSTEM.md
│       │   │   └── Theme.kt               # ChirpTheme light/dark
│       │   ├── components/                 # Shared UI components
│       │   │   ├── TweetCard.kt
│       │   │   ├── Avatar.kt
│       │   │   ├── LoadingIndicator.kt
│       │   │   └── ErrorScreen.kt
│       │   └── screen/                     # One package per screen
│       │       ├── splash/
│       │       │   └── SplashScreen.kt
│       │       ├── auth/
│       │       │   ├── LoginScreen.kt
│       │       │   ├── RegisterScreen.kt
│       │       │   └── AuthViewModel.kt
│       │       ├── home/
│       │       │   ├── HomeScreen.kt
│       │       │   └── HomeViewModel.kt
│       │       ├── tweet/
│       │       │   ├── TweetDetailScreen.kt
│       │       │   ├── CreateTweetScreen.kt
│       │       │   └── TweetViewModel.kt
│       │       ├── profile/
│       │       │   ├── ProfileScreen.kt
│       │       │   ├── FollowersScreen.kt
│       │       │   ├── FollowingScreen.kt
│       │       │   └── ProfileViewModel.kt
│       │       ├── notifications/
│       │       │   ├── NotificationsScreen.kt
│       │       │   └── NotificationsViewModel.kt
│       │       └── search/
│       │           ├── SearchScreen.kt
│       │           └── SearchViewModel.kt
│       │
│       └── util/                           # Utilities
│           ├── DateFormatter.kt
│           └── Validators.kt
│
├── build.gradle.kts
└── README.md
```

---

## Conventions

1. **MVVM**: Screen (Composable) → ViewModel (StateFlow) → Repository → ApiService
2. **One-shot events**: `SharedFlow` for navigation/toast events
3. **State**: `sealed class UiState { Loading, Success(data), Error(message) }`
4. **DI**: Hilt `@HiltViewModel`, `@Inject` in repositories
5. **Navigation**: NavHost with string routes, safe args for IDs
6. **Error handling**: `Result<T>` or custom sealed class in repositories

---

## Data Flow

```
Composable → collectAsState(viewModel.uiState)
  → ViewModel (coroutineScope.launch)
    → Repository.suspend function
      → ApiService (Retrofit) → Backend
          ↓
      Result<T> ← dto.toDomain()
    → _uiState.update { Success(data) }
  → Composable re-renders
```

## State Pattern

```kotlin
sealed class UiState<out T> {
    object Loading : UiState<Nothing>()
    data class Success<T>(val data: T) : UiState<T>()
    data class Error(val message: String) : UiState<Nothing>()
}
```

## Pagination

```kotlin
// In ViewModel
private var cursor: String? = null
private var hasMore = true

fun loadMore() {
    if (!hasMore || uiState.value !is Success) return
    // GET /timeline/home?cursor=$cursor&limit=20
}

fun refresh() {
    cursor = null
    hasMore = true
    // GET /timeline/home?limit=20
}
```
