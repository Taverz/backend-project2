# Chirp Backend — Configuration

> Все настройки — через переменные окружения (12-factor app).

---

## 1. Переменные окружения

| Переменная | Тип | Дефолт | Описание |
|-----------|:---:|:------:|----------|
| `HTTP_PORT` | string | `"8080"` | Порт HTTP-сервера |
| `APP_ENV` | string | `"development"` | Окружение: development / production |
| `DATABASE_URL` | string | `""` | PostgreSQL DSN. Пусто → in-memory |
| `REDIS_URL` | string | `""` | Redis URL. Пусто → Redis отключён |
| `ELASTICSEARCH_URL` | string | `""` | Elasticsearch URL. Пусто → in-memory grep |
| `KAFKA_BROKERS` | string | `""` | Kafka brokers (csv). Пусто → in-memory event bus |
| `JWT_ACCESS_SECRET` | string | авто-generate (dev) | 32 байта hex. Access token signing |
| `JWT_REFRESH_SECRET` | string | авто-generate (dev) | 32 байта hex. Refresh token signing |

---

## 2. Выбор адаптеров

### PostgreSQL

```
DATABASE_URL = "postgres://user:pass@host:5432/chirp"  → PostgreSQL (pgx/v5 pool)
DATABASE_URL = ""                                       → In-memory (разработка, данные теряются)
```

### Redis

```
REDIS_URL = "redis://user:pass@host:6379/0"  → Redis (go-redis/v9)
REDIS_URL = ""                                → Redis отключён
```

### Elasticsearch

```
ELASTICSEARCH_URL = "http://host:9200"  → Elasticsearch (go-elasticsearch/v8)
ELASTICSEARCH_URL = ""                  → In-memory (grep по телам твитов, работает без ES)
```

**Требуется:** добавить библиотеку `github.com/elastic/go-elasticsearch/v8` в зависимости.

### Kafka

```
KAFKA_BROKERS = "host1:9092,host2:9092"  → Kafka (kafka-go producer)
KAFKA_BROKERS = ""                       → In-memory event bus (goroutine pub/sub)
```

**Требуется:** добавить библиотеку `github.com/segmentio/kafka-go` в зависимости.

---

## 3. Безопасность

### JWT в development

Если `APP_ENV=development` и `JWT_ACCESS_SECRET` не задан — секреты генерируются
автоматически при каждом запуске функцией `crypto/rand`. **Все ранее выданные
токены становятся невалидными после перезапуска.**

### JWT в production

```bash
# Сгенерировать секреты (32 байта = 64 hex символа)
JWT_ACCESS_SECRET=$(openssl rand -hex 32)
JWT_REFRESH_SECRET=$(openssl rand -hex 32)

# Экспортировать
export JWT_ACCESS_SECRET JWT_REFRESH_SECRET
```

---

## 4. Примеры запуска

### Разработка (без БД)

```bash
make run
```

### С PostgreSQL (локально)

```bash
DATABASE_URL=postgres://user:pass@localhost:5432/chirp make run
```

### С Redis

```bash
REDIS_URL=redis://localhost:6379/0 make run
```

### Полный стек

```bash
DATABASE_URL=postgres://... \
REDIS_URL=redis://... \
ELASTICSEARCH_URL=http://localhost:9200 \
KAFKA_BROKERS=localhost:9092 \
make run
```
