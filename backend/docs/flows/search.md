# Search Tweets Flow

```
Client                  Transport              UseCase                SearchEngine
  │                        │                      │                       │
  │ GET /tweets/search?q=  │                      │                       │
  │────────────────────────►                      │                       │
  │                        │ Decode query params  │                       │
  │                        │──────► SearchTweets  │                       │
  │                        │                      │ SearchTweets(query)   │
  │                        │                      │──────────────────────►│
  │                        │                      │ (in-memory: grep,     │
  │                        │                      │  ES: fulltext query)  │
  │                        │                      │◄──────────────────────│
  │                        │◄────────────────────►│                       │
  │ 200 + results + cursor │                      │                       │
  │◄────────────────────────│                      │                       │
```

### Шаги

1. **Transport** — Parse query params: q (required), limit, cursor
2. **Transport** — If `q == ""` → 400 "query parameter 'q' is required"
3. **UseCase** — `searchEngine.SearchTweets(ctx, q, limit, cursor)`
4. **Engine** — Execute search:
   - **In-memory**: `strings.Contains(strings.ToLower(body), strings.ToLower(q))` + sort by ID desc
   - **Elasticsearch**: fulltext query with scoring
5. **Engine** — Apply cursor pagination
6. **Transport** — Respond 200 + {data, next_cursor, has_more}

### Индексация

Твиты автоматически индексируются при создании:

```
POST /tweets → CreateUseCase → SearchEngine.IndexTweet(tweet)
```

### Адаптеры

| Режим | Поведение | Когда |
|-------|-----------|-------|
| In-memory | `strings.Contains()` grep по телам твитов | `ELASTICSEARCH_URL` не задан |
| Elasticsearch | Fulltext query с scoring | `ELASTICSEARCH_URL=http://...` |

### Пагинация

| Параметр | Тип | Default | Max |
|----------|-----|:-------:|:---:|
| q | string | — | обязательный |
| limit | int | 20 | 50 |
| cursor | string (tweet_id) | "" | — |

### Ошибки

| Status | Detail |
|:------:|--------|
| 400 | query parameter 'q' is required |
