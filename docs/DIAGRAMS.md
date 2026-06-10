# Chirp — Diagrams

> Рендерящиеся диаграммы (Mermaid format).
> Читать в GitHub, Obsidian, VS Code с Mermaid plugin.
> Покрытие: screen flow, feature flow, state machine, component tree.

---

## 1. Screen Flow — Navigation Graph

> Как пользователь перемещается между экранами.

```mermaid
graph TD
    %% Auth flow
    Splash["/splash"] -->|has token?| Home["/home"]
    Splash -->|no token| Login
    
    Login["/login"] -->|success| Home
    Login -->|tap link| Register
    
    Register["/register"] -->|success| Home
    Register -->|tap link| Login
    
    %% Main tabs
    Home -->|tap tweet| TweetDetail["/tweet/{id}"]
    Home -->|tap FAB| Create["/create"]
    Home -->|tap tab| Search["/search"]
    Home -->|tap tab| Notifications["/notifications"]
    Home -->|tap tab| Profile["/user/{me}"]
    
    %% Profile sub-screens
    Profile -->|tap followers| Followers["/user/{id}/followers"]
    Profile -->|tap following| Following["/user/{id}/following"]
    Profile -->|tap logout| Login
    
    %% Tweet detail
    TweetDetail -->|tap author| Profile
    TweetDetail -->|tap reply| Create
    
    %% Notifications
    Notifications -->|tap notification| TweetDetail
    
    %% Search
    Search -->|tap result| TweetDetail
    
    %% Auth guard redirects
    style Login fill:#1DA1F2,color:#fff
    style Home fill:#192734,color:#fff
    style Splash fill:#15202B,color:#fff
    
    classDef auth fill:#1DA1F2,color:#fff;
    classDef protected fill:#192734,color:#fff;
    classDef public fill:#F5F5F5,color:#0F1419;
    
    class Login,Register auth;
    class Home,TweetDetail,Create,Notifications,Profile,Followers,Following protected;
    class Splash,Search public;
```

---

## 2. Auth Flow — Login Sequence

> Взаимодействие пользователя, UI, ApiClient и Backend при входе.

```mermaid
sequenceDiagram
    actor User
    participant LoginScreen
    participant ApiClient
    participant Backend
    
    User->>LoginScreen: tap "Log in"
    
    LoginScreen->>LoginScreen: validate form
    
    alt invalid email
        LoginScreen-->>User: show inline error
    else invalid password
        LoginScreen-->>User: show inline error
    else valid
        LoginScreen->>LoginScreen: button=spinner, fields=disabled
        LoginScreen->>ApiClient: POST /auth/login {email, password}
        ApiClient->>Backend: POST /auth/login
        
        alt 200 OK
            Backend-->>ApiClient: {user, access_token, refresh_token}
            ApiClient->>LoginScreen: save tokens, authState=authenticated
            LoginScreen-->>User: redirect /home
        else 401 Unauthorized
            Backend-->>ApiClient: 401
            ApiClient-->>LoginScreen: show toast "Invalid email or password"
            LoginScreen->>LoginScreen: button=enabled, fields=enabled
        else 429 Rate Limited
            Backend-->>ApiClient: 429
            ApiClient-->>LoginScreen: show toast + disable button 30s
        else 500 Server Error
            Backend-->>ApiClient: 500
            ApiClient-->>LoginScreen: show ErrorView + Retry
        end
    end
```

---

## 3. Auth Flow — Token Refresh

> Что происходит, когда access token протух.

```mermaid
sequenceDiagram
    participant App
    participant ApiClient
    participant AuthService
    participant Backend
    
    App->>ApiClient: GET /timeline/home
    
    ApiClient->>Backend: GET /timeline/home + Bearer <expired>
    Backend-->>ApiClient: 401 Unauthorized
    
    ApiClient->>AuthService: get refresh_token
    
    alt has refresh token
        ApiClient->>Backend: POST /auth/refresh {refresh_token}
        
        alt 200 OK
            Backend-->>ApiClient: {new_access, new_refresh}
            ApiClient->>AuthService: save new tokens
            ApiClient->>Backend: RETRY GET /timeline/home + Bearer <new>
            Backend-->>ApiClient: 200 + tweets
            ApiClient-->>App: return tweets
        else refresh failed
            Backend-->>ApiClient: 401
            ApiClient->>AuthService: clear tokens
            ApiClient-->>App: redirect /login
        end
    else no refresh token
        ApiClient->>AuthService: clear tokens
        ApiClient-->>App: redirect /login
    end
```

### Race condition guard

```mermaid
sequenceDiagram
    participant Req1 as "Request 1 (tweets)"
    participant Req2 as "Request 2 (notifications)"
    participant Req3 as "Request 3 (profile)"
    participant Gate as "Refresh Gate"
    participant Backend
    
    par 3 parallel requests
        Req1->>Backend: GET /timeline/home → 401
        Req2->>Backend: GET /notifications → 401
        Req3->>Backend: GET /users/me → 401
    end
    
    Req1->>Gate: is refreshing?
    note over Gate: refreshPromise == null
    Gate->>Backend: POST /auth/refresh (ONE call)
    
    Req2->>Gate: is refreshing?
    note over Gate: refreshPromise != null → wait
    Req3->>Gate: is refreshing?
    note over Gate: refreshPromise != null → wait
    
    Backend-->>Gate: 200 + new tokens
    Gate->>Gate: save new tokens
    Gate->>Gate: refreshPromise = null
    
    Gate->>Req1: retry with new token → 200
    Gate->>Req2: retry with new token → 200
    Gate->>Req3: retry with new token → 200
```

---

## 4. Auth State Machine

> Все состояния авторизации и переходы между ними.

```mermaid
stateDiagram-v2
    [*] --> Unknown: app launch
    
    Unknown --> Authenticated: token found in storage
    Unknown --> Unauthenticated: no token
    
    Unauthenticated --> Loading: tap "Log in" / "Sign up"
    
    Loading --> Authenticated: 200 + tokens
    Loading --> Error: 400/401/409/429/500
    Loading --> Unauthenticated: network timeout
    
    Error --> Loading: tap "Retry" / fix field
    
    Authenticated --> Unauthenticated: logout / refresh failed
    Authenticated --> Loading: 401 (background, refresh)
    
    Authenticated --> [*]: app closed
    Unauthenticated --> [*]: app closed
    
    note right of Authenticated
        Can access: /home, /profile,
        /notifications, /create
    end note
    
    note right of Unauthenticated
        Can access: /login, /register,
        /tweets/{id}, /search (public)
    end note
```

---

## 5. Component Tree — HomeScreen

> Из каких виджетов состоит HomeScreen и какие данные каждый получает.

```mermaid
graph TD
    HomeScreen --> TopBar
    HomeScreen --> TimelineList
    HomeScreen --> FAB["FAB (+)"]
    HomeScreen --> EmptyState
    HomeScreen --> ErrorView
    
    TopBar --> Logo["Text('Chirp')"]
    TopBar --> UserAvatar["Avatar (size=32)"]
    UserAvatar -->|GET /users/me| UserAPI
    
    TimelineList --> TweetCard
    TimelineList --> LoadingSkeleton
    
    TweetCard --> Avatar["Avatar (size=48)"]
    TweetCard --> UserInfo["Column: username + timestamp"]
    TweetCard --> Body["Text(body)"]
    TweetCard --> ActionBar
    
    ActionBar --> LikeButton["LikeButton(active, count)"]
    ActionBar --> ReplyButton["ReplyButton(count)"]
    ActionBar --> ShareButton["ShareButton"]
    
    TweetCard -->|GET /timeline/home| TimelineAPI
    
    EmptyState -->|timeline empty| EmptyMessage["Text('No tweets yet')"]
    ErrorView -->|error| RetryButton["Button('Try again')"]
    
    FAB -->|push| CreateTweet["/create"]
    
    classDef data fill:#1DA1F2,color:#fff;
    classDef widget fill:#192734,color:#fff;
    classDef state fill:#E0245E,color:#fff;
    
    class TimelineAPI,UserAPI data;
    class HomeScreen,TopBar,TimelineList,TweetCard,ActionBar,Avatar widget;
    class EmptyState,ErrorView,LoadingSkeleton state;
```

---

## 6. Data Flow — LoginScreen

> Как данные трансформируются от ввода пользователя до сохранения токенов.

```mermaid
flowchart LR
    UserInput["User<br/>email + password"] --> Form
    
    Form["LoginForm<br/>validate form"] -->|invalid| FieldError["Inline error<br/>under field"]
    Form -->|valid| ApiCall["ApiClient<br/>POST /auth/login"]
    
    ApiCall -->|200| AuthService["AuthService<br/>saveTokens()"]
    AuthService --> SecureStorage["SecureStorage<br/>access_token<br/>refresh_token"]
    AuthService --> AuthState["AuthState<br/>.authenticated(user)"]
    AuthState --> Navigate["Navigate<br/>→ /home"]
    
    ApiCall -->|401| Toast["Toast<br/>'Invalid email or password'"]
    ApiCall -->|500| ErrorScreen["ErrorView<br/>'Something went wrong'<br/>+ Retry"]
    ApiCall -->|429| Timer["Button disabled<br/>30s countdown"]
    
    style UserInput fill:#F5F5F5
    style AuthState fill:#1DA1F2,color:#fff
    style SecureStorage fill:#192734,color:#fff
    style Navigate fill:#00BA7C,color:#fff
    style Toast fill:#E0245E,color:#fff
    style ErrorScreen fill:#E0245E,color:#fff
    style FieldError fill:#FFAD1F
```

---

## 7. Auth — Register Flow (укороченная)

```mermaid
sequenceDiagram
    actor User
    participant RegisterScreen
    participant Backend
    
    User->>RegisterScreen: tap "Sign up"
    RegisterScreen->>RegisterScreen: validate all fields
    
    alt invalid username
        RegisterScreen-->>User: inline error "3-30 chars"
    else invalid email
        RegisterScreen-->>User: inline error "invalid format"
    else invalid password
        RegisterScreen-->>User: inline error "8+ chars"
    else valid
        RegisterScreen->>Backend: POST /auth/register
        alt 201
            Backend-->>RegisterScreen: save tokens, redirect /home
        else 409 email
            Backend-->>RegisterScreen: highlight email "already registered"
        else 409 username
            Backend-->>RegisterScreen: highlight username "already taken"
        else 500
            Backend-->>RegisterScreen: ErrorView + Retry
        end
    end
```

---

## 8. Auth Guard Decision Tree

> Логика AuthGuard при каждом переходе между маршрутами.

```mermaid
flowchart TD
    RouteChange["Route change"] --> CheckState{Check authState}
    
    CheckState -->|loading| Wait["Show spinner,<br/>don't redirect"]
    Wait --> CheckState
    
    CheckState -->|authenticated| CheckTarget{Target route}
    CheckTarget -->|/login or /register| RedirectHome["Redirect → /home"]
    CheckTarget -->|protected route| Allow["Show content"]
    
    CheckState -->|unauthenticated| CheckPublic{Is route public?}
    CheckPublic -->|yes: /tweets/{id}, /search| Allow
    CheckPublic -->|no: /home, /profile| RedirectLogin["Redirect → /login"]
    
    style RedirectHome fill:#1DA1F2,color:#fff
    style RedirectLogin fill:#E0245E,color:#fff
    style Allow fill:#00BA7C,color:#fff
    style Wait fill:#FFAD1F
```

---

## 9. Как использовать эти диаграммы

| Где открыть | Рендерится? |
|-------------|:-----------:|
| GitHub (.md file) | ✅ Автоматически |
| Obsidian | ✅ С Mermaid plugin |
| VS Code | ✅ С Mermaid preview |
| JetBrains IDE | ✅ С Markdown plugin |
| Любой Markdown viewer | ⚠️ Покажет сырой код Mermaid |

**Для редактирования:** любой текстовый редактор
**Для экспорта:** https://mermaid.live — вставить код → экспорт PNG/SVG
