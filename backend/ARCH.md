# Стек и архитектура бэкенда (папка backend/):

Технологии

Go 1.25, роутер chi v5 (go-chi/chi)
PostgreSQL через pgx/v5 — основное хранилище
Redis (go-redis/v9) — кэш/таймлайн
Elasticsearch (go-elasticsearch/v8) — поиск
Kafka (segmentio/kafka-go) — асинхронные события (уведомления, и т.п.)
JWT (golang-jwt/jwt/v5) — аутентификация
bcrypt/crypto (golang.org/x/crypto)
Swagger (swaggo/swag, http-swagger) — автогенерация API-документации
OpenTelemetry — трейсинг/метрики
Архитектурный паттерн — Clean Architecture / Ports & Adapters (Hexagonal), разложенный по слоям в internal/:


domain/     — чистые сущности (user, tweet, timeline, search, trend, notification, media), без внешних зависимостей
usecase/    — бизнес-логика, по одной директории на каждый домен, зависит только от port
port/       — интерфейсы-контракты для адаптеров (DIP)
adapter/    — реализации port: postgres, redis, kafka, es, memory, storage
transport/  — HTTP-слой (chi-хендлеры + middleware)
app/        — сборка приложения (DI/wiring)
config/     — конфигурация
Зависимости строго однонаправленные: domain ← usecase ← port ← adapter, transport не обращается к adapter напрямую — это совпадает с правилами в CLAUDE.md §5 ("Backend. domain не импортирует ничего из проекта, usecase зависит только от port, transport не вызывает adapter напрямую").

Структура по доменам (vertical slicing) внутри каждого слоя (usecase/tweet, usecase/user, usecase/timeline и т.д.) — то есть Clean Architecture + Domain-oriented organization, плюс event-driven часть через Kafka для уведомлений/таймлайна.

## --------

Outbox-паттерна нет. Что есть по факту:

Outbox в БД отсутствует — нет ни таблицы outbox/events, ни упоминаний "outbox" в коде (migrations/ только users/tweets/follows/likes/timeline/notifications).
Kafka-адаптер — это стаб-заглушка (internal/adapter/kafka/event.go): EventBus.Publish ничего не делает (return nil), Subscribe — пустая функция. В коде прямо написано: "EventBus is a stub for Kafka. Real implementation requires kafka-go — add when KAFKA_BROKERS is set."
То есть сейчас публикация событий просто "в пустоту", без гарантии доставки. Если реализовывать честно (без потери событий при сбое между записью в Postgres и отправкой в Kafka), нужен либо:

Transactional Outbox — писать событие в таблицу outbox в той же транзакции с доменной записью, отдельный воркер вычитывает и публикует в Kafka, либо
CDC (Debezium) на уже существующие таблицы.
Хочешь, чтобы я предложил план внедрения outbox-таблицы + relay-воркера именно для этого проекта, или это просто вопрос на понимание текущей архитектуры?


## ---------

Что планировалось vs что есть
Архитектура
Планировалось: Микросервисная сетка из 4-5 сервисов, общающихся через gRPC и Kafka.
Что есть: Монолит с Clean Architecture / Hexagonal внутри. Это не плохо само по себе — CA/Hexagonal это серьёзный паттерн — но это принципиально другое. Никаких отдельных процессов, никакого gRPC между сервисами, никакой service mesh.
Вердикт: Самое большое расхождение с планом. Всё остальное — детали.

Стек — что есть, чего нет
ТехнологияПланФактPostgreSQL✅✅ естьRedis✅✅ естьKafka✅⚠️ заглушка, Publish делает return nilElasticsearch✅✅ естьgRPC✅ для всех internal calls❌ нет, только HTTP/chiMongoDB✅ для черновиков/медиа❌ нетCassandra/ScyllaDB✅ для hot feed❌ нетOpenTelemetry✅⚠️ подключён, но насколько глубоко — неясноJaeger/Grafana/Loki✅❌ нет упоминанийPyroscope/pprof✅❌ нетSLO/SLI дашборды✅❌ нетOutbox patternнужен при Kafka❌ нет

Паттерны — что есть, чего нет
Есть:

Clean Architecture / Ports & Adapters — реализована нормально, судя по описанию
Vertical slicing по доменам внутри слоёв
DIP через port-интерфейсы
JWT аутентификация
Swagger документация

Нет / сделано частично:

Transactional Outbox — критично если Kafka нужна для гарантий. Сейчас события просто теряются при любом сбое
gRPC — ни interceptors, ни deadline propagation, ни streaming
Event-driven архитектура — декларирована, но Kafka-адаптер — стаб
Observability — OTel есть, но трейсы через Kafka/gRPC (которых нет), service map, pprof, алерты по бюджету ошибок — всё отсутствует
Rate limiting — стандартная вещь для Twitter-клона, не упомянута
CQRS — при такой write/read нагрузке логично, но не применён
Circuit breaker — при микросервисах обязателен, здесь нет смысла без них


Главная проблема
Проект реализован как один Go-сервис с хорошей внутренней структурой, но цель была научиться микросервисной архитектуре. Это как учиться водить машину на симуляторе — паттерны выглядят правильно, но реальных проблем (network partitions, distributed tracing, inter-service auth, gRPC deadlines) ты не встретишь.
Clean Architecture в монолите — полезный навык. Но он не заменяет опыт работы с gRPC streaming, Kafka consumer groups, или Outbox pattern с реальной Kafka.

Что стоит сделать дальше (приоритеты)

Оживить Kafka — убрать стаб, подключить реальный kafka-go, добавить Outbox таблицу + relay worker
Выделить хотя бы один gRPC сервис — например Feed Service отдельным процессом, общающимся по gRPC с основным сервисом. Сразу появятся реальные проблемы с deadline propagation и interceptors
Нормальный OTel — traces должны проходить сквозь Kafka (W3C Trace Context в headers), дашборд в Grafana с p95 latency
Outbox + relay worker — без этого Kafka бесполезна при сбоях

MongoDB и Cassandra можно оставить на потом — они дают меньше архитектурного опыта, чем живая Kafka и хотя бы один gRPC-сервис.


## Что сделано

**Архитектурные паттерны:**
- Clean Architecture / Hexagonal (Ports & Adapters)
- Dependency Inversion (port-интерфейсы)
- Vertical slicing по доменам
- Repository pattern (адаптеры для PG, Redis, ES)
- Middleware chain (chi)

**Принципы:**
- SOLID (частично — DI через интерфейсы есть, остальное неизвестно)
- ACID на уровне PostgreSQL транзакций
- Separation of Concerns (слои domain/usecase/adapter/transport)
- JWT-based stateless auth

---

## Что пропущено

**Надёжность данных:**
- Transactional Outbox
- Idempotent consumers (Kafka)
- Saga pattern (для распределённых операций)
- Optimistic/Pessimistic locking (конкурентные обновления)

**Архитектурные паттерны:**
- CQRS (разделение read/write моделей)
- Event Sourcing
- Circuit Breaker
- Retry + Dead Letter Queue (Kafka)
- gRPC interceptors (auth, tracing, deadlines)
- Bulkhead pattern

**Observability:**
- Distributed tracing сквозь все слои
- SLO/SLI метрики
- Structured logging с trace_id
- Алерты по error budget

**Принципы:**
- CAP theorem осознанный выбор (нигде не задокументирован)
- Eventual consistency явная обработка
- Backpressure (при высокой нагрузке)
- Rate limiting / throttling
- Graceful degradation
