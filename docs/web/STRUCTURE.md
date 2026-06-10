# Chirp Web — Project Structure (TypeScript)

---

## Stack

| Layer | Choice |
|-------|--------|
| Language | TypeScript 5.x |
| Framework | React 18 + Vite |
| Routing | React Router 6 |
| HTTP | Axios |
| State | React Context + hooks (or Zustand for complex state) |
| Auth | localStorage (MVP) / httpOnly cookie (prod) |
| Styling | Tailwind CSS 3 |
| Linting | ESLint + Prettier |

---

## Directory Layout

```
chirp-web/
├── public/
│   └── icons/              # SVG icons from shared/DESIGN-CONTRACT.md
│
├── src/
│   ├── main.tsx             # ReactDOM.createRoot, App
│   ├── App.tsx              # BrowserRouter, QueryClientProvider
│   │
│   ├── api/
│   │   ├── client.ts        # Axios instance + interceptors (JWT, 401 refresh)
│   │   ├── endpoints.ts     # API path constants (from shared/API.md)
│   │   ├── auth.ts          # login(), register() functions
│   │   ├── tweets.ts        # getTimeline(), createTweet(), likeTweet()
│   │   ├── users.ts         # getProfile(), followUser(), etc.
│   │   └── notifications.ts
│   │
│   ├── auth/
│   │   ├── AuthContext.tsx   # React Context: user, tokens, login/logout/register
│   │   ├── AuthGuard.tsx     # ProtectedRoute component
│   │   └── storage.ts       # localStorage wrapper (saveTokens, getAccessToken)
│   │
│   ├── components/          # Shared UI components
│   │   ├── TweetCard.tsx
│   │   ├── Avatar.tsx
│   │   ├── Button.tsx
│   │   ├── InputField.tsx
│   │   ├── LoadingSkeleton.tsx
│   │   ├── ErrorState.tsx
│   │   ├── EmptyState.tsx
│   │   └── Layout.tsx       # Top bar + Bottom tab bar (web: left sidebar)
│   │
│   ├── pages/
│   │   ├── LoginPage.tsx
│   │   ├── RegisterPage.tsx
│   │   ├── HomePage.tsx
│   │   ├── TweetDetailPage.tsx
│   │   ├── CreateTweetPage.tsx
│   │   ├── ProfilePage.tsx
│   │   ├── FollowersPage.tsx
│   │   ├── FollowingPage.tsx
│   │   ├── NotificationsPage.tsx
│   │   └── SearchPage.tsx
│   │
│   ├── hooks/               # Custom React hooks
│   │   ├── useTimeline.ts   # fetch + pagination + refresh
│   │   ├── useTweets.ts
│   │   ├── useProfile.ts
│   │   └── useNotifications.ts
│   │
│   ├── types/               # TypeScript interfaces (from shared/API.md)
│   │   ├── user.ts          # User, AuthResponse
│   │   ├── tweet.ts         # Tweet, PageResponse<Tweet>
│   │   ├── notification.ts
│   │   └── pagination.ts    # PageResponse<T>
│   │
│   ├── theme/
│   │   └── index.css        # Tailwind config + custom tokens (from shared/DESIGN-SYSTEM.md)
│   │
│   └── utils/
│       ├── dateFormat.ts    # Relative time
│       └── validators.ts    # Email, username, password validation
│
├── index.html
├── tailwind.config.ts
├── tsconfig.json
├── vite.config.ts
├── package.json
└── README.md
```

---

## Routing

```typescript
// App.tsx
<Routes>
  {/* Public */}
  <Route path="/login" element={<LoginPage />} />
  <Route path="/register" element={<RegisterPage />} />
  <Route path="/tweets/:id" element={<TweetDetailPage />} />
  <Route path="/users/:id" element={<ProfilePage />} />
  <Route path="/users/:id/followers" element={<FollowersPage />} />
  <Route path="/users/:id/following" element={<FollowingPage />} />
  <Route path="/search" element={<SearchPage />} />
  
  {/* Protected */}
  <Route element={<ProtectedRoute />}>
    <Route path="/" element={<Layout />}>
      <Route index element={<Navigate to="/home" />} />
      <Route path="home" element={<HomePage />} />
      <Route path="notifications" element={<NotificationsPage />} />
      <Route path="create" element={<CreateTweetPage />} />
    </Route>
  </Route>
</Routes>
```

---

## Data Flow

```
Page → useQuery/useMutation → api/*.ts → Axios client → Backend
  ↑                                    ↓
types/*.ts ← json()              JSON response
```

```typescript
// hooks/useTimeline.ts
export function useTimeline() {
  const [tweets, setTweets] = useState<Tweet[]>([]);
  const [cursor, setCursor] = useState<string | null>(null);
  const [hasMore, setHasMore] = useState(true);
  const [loading, setLoading] = useState(true);

  const loadMore = async () => {
    const res = await api.get('/timeline/home', { params: { limit: 20, cursor } });
    setTweets(prev => [...prev, ...res.data.data]);
    setCursor(res.data.next_cursor);
    setHasMore(res.data.has_more);
    setLoading(false);
  };

  return { tweets, loading, hasMore, loadMore, refresh: () => { setCursor(null); loadMore(); } };
}
```

---

## Conventions

1. **Page** — full screen. **Component** — reusable UI piece
2. **Api functions** — one file per domain (auth.ts, tweets.ts). Returns typed data
3. **Hooks** — encapsulate state + API calls. One hook per feature
4. **AuthContext** — wraps App, provides user + login/logout/register
5. **Tailwind** — utility classes only. Custom theme → tailwind.config.ts
6. **Error handling** — try/catch in hooks → setError state → ErrorState component
7. **Pagination** — cursor stored in hook state, loadMore() on scroll to bottom

---

## Styling (Tailwind)

```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        primary: '#1DA1F2',
        background: '#FFFFFF',
        'background-dark': '#15202B',
        card: '#F5F5F5',
        'card-border': '#E1E8ED',
        'text-primary': '#0F1419',
        'text-secondary': '#536471',
        error: '#E0245E',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
};
```

---

## Web-specific considerations

| Aspect | Web solution |
|--------|-------------|
| Layout | Left sidebar (desktop) → Bottom tabs (mobile responsive) |
| Auth for prod | httpOnly cookie (backend sets cookie, JS cannot read it → XSS safe) |
| SEO | SSR (Next.js) when needed. For MVP: client-side is fine |
| PWA | Optional: service worker + manifest.json for mobile install |
| Icons | SVG components from `/public/icons/` or Lucide/Heroicons library |
