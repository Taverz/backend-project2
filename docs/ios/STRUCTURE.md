# Chirp iOS — Project Structure

---

## Stack

| Layer | Choice |
|-------|--------|
| Language | Swift |
| UI | SwiftUI |
| Architecture | MVVM + Coordinator (or NavigationStack) |
| DI | Manual (via `@main` App struct + Environment) |
| Networking | URLSession + async/await |
| Models | Codable (JSON → struct) |
| Auth tokens | Keychain |
| Async | async/await, Swift Concurrency |
| Linting | SwiftLint |

---

## Directory Layout

```
chirp-ios/
├── Chirp.xcodeproj
│
├── Sources/
│   ├── ChirpApp.swift                 # @main App, WindowGroup, DI setup
│   ├── ContentView.swift              # Root view with NavigationStack + tabs
│   │
│   ├── Core/
│   │   ├── API/
│   │   │   ├── APIClient.swift        # URLSession wrapper, JWT injection, 401 handling
│   │   │   ├── Endpoints.swift        # All endpoint paths (from shared/API.md)
│   │   │   └── AuthInterceptor.swift  # Token injection + refresh flow
│   │   ├── Models/
│   │   │   ├── User.swift             # Codable struct, from shared/API.md
│   │   │   ├── Tweet.swift            # Codable struct
│   │   │   ├── Notification.swift
│   │   │   ├── Follow.swift
│   │   │   └── PageResponse.swift     # Generic PageResponse<T: Codable>
│   │   ├── Auth/
│   │   │   ├── AuthService.swift      # Keychain storage, token check
│   │   │   └── AuthGuard.swift        # Computed property: isLoggedIn
│   │   ├── Theme/
│   │   │   ├── Colors.swift           # From shared/DESIGN-SYSTEM.md
│   │   │   ├── Typography.swift       # Font modifiers
│   │   │   └── Spacing.swift          # Spacing constants
│   │   └── Utils/
│   │       ├── DateFormatter.swift    # Relative date ("2m ago", "yesterday")
│   │       └── Validators.swift       # Client-side validation
│   │
│   ├── Features/                      # Feature-first
│   │   ├── Auth/
│   │   │   ├── ViewModels/
│   │   │   │   ├── LoginViewModel.swift
│   │   │   │   └── RegisterViewModel.swift
│   │   │   └── Views/
│   │   │       ├── LoginView.swift
│   │   │       └── RegisterView.swift
│   │   ├── Home/
│   │   │   ├── ViewModels/
│   │   │   │   └── TimelineViewModel.swift
│   │   │   └── Views/
│   │   │       ├── HomeView.swift
│   │   │       ├── TweetCardView.swift
│   │   │       └── TimelineListView.swift
│   │   ├── Tweet/
│   │   │   ├── ViewModels/
│   │   │   │   ├── TweetDetailViewModel.swift
│   │   │   │   └── CreateTweetViewModel.swift
│   │   │   └── Views/
│   │   │       ├── TweetDetailView.swift
│   │   │       ├── CreateTweetView.swift
│   │   │       └── TweetActionBar.swift
│   │   ├── Profile/
│   │   │   ├── ViewModels/
│   │   │   │   └── ProfileViewModel.swift
│   │   │   └── Views/
│   │   │       ├── ProfileView.swift
│   │   │       ├── FollowersView.swift
│   │   │       ├── FollowingView.swift
│   │   │       └── ProfileHeaderView.swift
│   │   ├── Notifications/
│   │   │   ├── ViewModels/
│   │   │   │   └── NotificationsViewModel.swift
│   │   │   └── Views/
│   │   │       ├── NotificationsView.swift
│   │   │       └── NotificationRow.swift
│   │   └── Search/
│   │       ├── ViewModels/
│   │       │   └── SearchViewModel.swift
│   │       └── Views/
│   │           ├── SearchView.swift
│   │           └── SearchBarView.swift
│   │
│   └── Shared/                        # Reusable UI
│       ├── AvatarView.swift
│       ├── LoadingView.swift
│       ├── ErrorView.swift
│       └── PaginatedList.swift
│
├── Resources/
│   ├── Assets.xcassets
│   └── Preview Content/
│
├── Tests/
│   └── ChirpTests/
│       ├── Models/
│       ├── ViewModels/
│       └── APIClientTests.swift
│
└── README.md
```

---

## Conventions

1. **MVVM**: View (SwiftUI) → ViewModel (`@Observable` / `@Published`) → APIClient
2. **State**: `enum ViewState { case loading, loaded(T), error(String) }`
3. **Navigation**: `NavigationStack` + `NavigationPath` for push, `TabView` for tabs
4. **DI**: Manual — App struct creates and injects dependencies via `@Environment`
5. **Async**: `async/await` through the entire stack
6. **Error handling**: `throws` in APIClient → `do/catch` in ViewModel → update ViewState

---

## Data Flow

```swift
struct HomeView: View {
    @State private var viewModel = TimelineViewModel()
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading: LoadingView()
            case .loaded(let tweets): TweetList(tweets: tweets)
            case .error(let msg): ErrorView(msg) { viewModel.refresh() }
            }
        }
        .task { await viewModel.loadTimeline() }
    }
}

@Observable
class TimelineViewModel {
    var state: ViewState<[Tweet]> = .loading
    private var cursor: String?
    private var hasMore = true
    
    func loadTimeline() async {
        do {
            let page = try await api.getTimeline(cursor: cursor)
            state = .loaded(page.data)
            cursor = page.nextCursor
            hasMore = page.hasMore
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

## State Pattern

```swift
enum ViewState<T> {
    case loading
    case loaded(T)
    case error(String)
}
```

## Navigation

```swift
TabView {
    NavigationStack { HomeView() }     .tabItem { Label("Home", systemImage: "house") }
    NavigationStack { SearchView() }   .tabItem { Label("Search", systemImage: "magnifyingglass") }
    NavigationStack { NotificationsView() }.tabItem { Label("Notifications", systemImage: "bell") }
    NavigationStack { ProfileView() }  .tabItem { Label("Profile", systemImage: "person") }
}
// Push: .navigationDestination(for: Tweet.self) { TweetDetailView(tweet: $0) }
```

## Pagination

```swift
List(tweets) { tweet in
    TweetCardView(tweet: tweet)
        .onAppear { if tweet == tweets.last { await vm.loadMore() } }
}
.refreshable { await vm.refresh() }
```
