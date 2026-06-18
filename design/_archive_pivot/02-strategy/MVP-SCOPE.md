# MVP Scope

> Финальный список фич MVP. Каждая фича обоснована через JTBD или Positioning.
> Всё, чего здесь нет — out of scope (или явно отложено).

---

## Принцип отбора

Фича попадает в MVP если:
1. Решает 🟢 MVP job из `01-research/jtbd.md`, ИЛИ
2. Без неё нарушается один из 3 brand pillars (peer-verified / signal-over-noise / transparent), ИЛИ
3. Без неё switch trigger из `01-research/switch-triggers.md` не сработает

Фича **не** попадает если:
1. Решает 🟡 / 🔴 job (post-MVP или reject)
2. Попадает в anti-pattern из `01-research/anti-patterns.md`
3. Можем сейчас не сделать, и пользователь не заметит отсутствия

---

## In Scope (MVP)

### Auth
| # | Фича | Job / Pillar / Trigger |
|---|------|----------------------|
| A1 | Email + password регистрация | Base |
| A2 | Login / logout | Base |
| A3 | JWT access + refresh | Base |
| A4 | Public-by-default профили (URL `/u/{username}`) | J-CROSS-1, Switch trigger Marina #3 |

### Profile
| # | Фича | Job / Pillar / Trigger |
|---|------|----------------------|
| P1 | Profile с avatar, display_name, bio | Base |
| P2 | **Topic Scores per skill** (Rust 720, React 540) — топ 3 над bio | J-DEV-2, Pillar 1 |
| P3 | Список последних 10 постов | J-REC-2 |
| P4 | Score explanation page (клик на Score → details) | J-CROSS-2, Pillar 3 |
| P5 | Activity timeline — когда писал что | J-REC-2 |
| P6 | Edit profile (bio, display_name, availability flag) | Base |
| P7 | Availability indicator (Open / Selective / Not looking) — без big "OPEN TO WORK" | J-DEV-6 (defensive form) |

### Posts
| # | Фича | Job / Pillar / Trigger |
|---|------|----------------------|
| C1 | Compose: 256 char text + optional code block | J-DEV-1 |
| C2 | **Required topic tag** при публикации | J-DEV-5, Pillar 1 |
| C3 | **Required complexity** (Easy/Medium/Hard) | J-DEV-5 |
| C4 | Post type (Insight / Solution / Question / Project) | J-DEV-5 |
| C5 | Edit post в течение 5 минут после публикации | PP-6.1 |
| C6 | Delete own post | Base |
| C7 | Public read без auth (по URL `/p/{id}`) | J-CROSS-1 |
| C8 | Reply (thread с parent_id, 1 уровень) | Base |

### Endorsement
| # | Фича | Job / Pillar / Trigger |
|---|------|----------------------|
| E1 | Endorse / unendorse пост | J-DEV-3, Pillar 1 |
| E2 | **Weighted endorsement** — weight = log10(1 + endorser.score_topic) × complexity_multiplier | J-DEV-3, Pillar 1 |
| E3 | Endorsement list (avatar + username + endorser's score на эту тему) | J-DEV-3, PP-1.3 |
| E4 | Decay −2% / month если нет постов в теме | Pillar 1 (anti-vanity) |
| E5 | Undo endorse в течение 5 сек (toast) | PP-6.1 |

### Feed
| # | Фича | Job / Pillar / Trigger |
|---|------|----------------------|
| F1 | **Хронологический** feed по людям + темам, на которые подписан | J-DEV-4, Pillar 2 |
| F2 | Cold-start: новый юзер видит top weekly posts в выбранных topic'ах | PP-10.3 |
| F3 | Pull-to-refresh (mobile) | Base |
| F4 | Cursor-based pagination | Base |
| F5 | Empty state: "Follow people or topics to see posts" | PP-8.2 |
| F6 | First-post amplification (новые посты от новых юзеров — буст 24h) | Switch trigger Marina |

### Follow / Subscribe
| # | Фича | Job / Pillar / Trigger |
|---|------|----------------------|
| FL1 | Follow / unfollow человек | J-DEV-4 |
| FL2 | Subscribe / unsubscribe topic (tag) | J-DEV-4 |
| FL3 | Following / followers списки в профиле — **не на главной**, без счётчика в навигации | Pillar 2 (anti-vanity) |

### Search & Discovery
| # | Фича | Job / Pillar / Trigger |
|---|------|----------------------|
| S1 | Search by topic + min Score (recruiter primary) | J-REC-1 |
| S2 | Search by username | Base |
| S3 | Search by post text | J-CROSS-1 |
| S4 | Filter: availability (Open / Selective / Not looking) | J-REC-3 |
| S5 | Sort: by Score desc / by recency / by activity | J-REC-1 |

### Notifications (in-app, no push)
| # | Фича | Job / Pillar / Trigger |
|---|------|----------------------|
| N1 | Endorsement received | Switch trigger Marina (retention) |
| N2 | New follower (mute-able) | Base |
| N3 | Reply to your post | Base |
| N4 | Mention `@username` | Base |
| N5 | **No badge counter в навигации** | Pillar 2 (anti-engagement-loop) |

### Roles
| # | Фича | Job / Pillar / Trigger |
|---|------|----------------------|
| R1 | Developer role (default) | Base |
| R2 | Recruiter role — отдельный signup флаг, разное primary navigation | J-REC-1 |
| R3 | Recruiter view: search-first UI | J-REC-1 |
| R4 | Recruiter response rate visible в их профиле (после первых 10 outreach) | J-DEV-6, PP-9.2 |

### Moderation (minimal)
| # | Фича | Job / Pillar / Trigger |
|---|------|----------------------|
| M1 | Flag post / user (single button в … menu) | PRINCIPLES §4 |
| M2 | Block user (не вижу в feed, не пишет мне) | PRINCIPLES §4 |

---

## Out of Scope MVP — Post-MVP

| Фича | Когда | Почему отложено |
|------|-------|----------------|
| Direct messages / outreach UI | Post-MVP | Нужны rate-limits, response rate tracking, anti-spam. Сейчас — recruiter контактирует через external link |
| Long-form posts (Medium-style) | Post-MVP | MVP про короткий формат |
| Q&A с accepted answers | Post-MVP | Усложняет основную модель |
| Onboarding flow | Post-MVP | Отложен явно по бриф |
| Push notifications | Post-MVP | Не нужны для core loop |
| Saved candidates list (recruiter) | Post-MVP | Усложняет recruiter UI |
| External proof (GitHub OAuth, StackOverflow import) | Post-MVP | Bable должен сам валидировать |
| Score growth chart / activity charts | Post-MVP | Visual layer above core data |
| Plagiarism detection | Post-MVP | Когда контента достаточно для embedding |
| AI-content filter | Post-MVP | После накопления baseline |
| Mentions notifications за пределами app | Post-MVP | Email digest |
| Badge system | Post-MVP | Если будем, то только expertise-связанные |

---

## Out of Scope MVP — Never

| Фича | Почему отказ |
|------|-------------|
| Algorithmic feed ("For You") | Анти-Pillar 2 |
| Streaks / daily challenges | Анти-anti-pattern AP-1.2 |
| Follower count как primary metric | AP-2.1 |
| Skill self-declaration list | AP-3.3, AP-5.2 |
| Paid verification | AP-5.1 |
| Mass-templated outreach | J-REC-6 |
| Trending / virality boosters | Анти-Pillar 2 |
| Stories | Анти-Pillar 2 |
| Ads | Анти-Pillar 3 (PRINCIPLES §3) |

---

## Размер MVP

| Площадь | Count |
|---------|-------|
| Фичей в scope | **47** (A1-4, P1-7, C1-8, E1-5, F1-6, FL1-3, S1-5, N1-5, R1-4, M1-2) |
| Уникальных экранов primary navigation | ~10 (Feed, Compose, Profile, Profile Edit, Score Explanation, Search, Recruiter Search, Post Detail, Endorsements List, Notifications) |
| Cross-cutting compoнентов | ~12 (Avatar, ScoreBadge, EndorsementButton, TopicTag, ComplexityBadge, PostCard, ProfileHeader, SearchBar, FollowButton, AvailabilityChip, FlagMenu, EmptyState) |

---

## Что меняется относительно старого "Twitter clone" backend

Backend (Go) был под Twitter. Изменения, нужные для Bable MVP:

| Backend изменение | Зачем |
|-------------------|------|
| Tweet → Post (с type, complexity, topic_tag) | C2, C3, C4 |
| Like → Endorsement (с weight calc) | E1, E2 |
| User: добавить role (dev / recruiter) | R1, R2 |
| User: добавить availability | P7 |
| Score: per-topic table, обновляется async | P2, E2 |
| Search: расширить — фильтры topic + min Score | S1, S5 |
| Decay job: cron / scheduled task | E4 |
| Response rate: aggregate per recruiter (когда impl outreach) | R4 |

Это переделка, не косметика. Архитектура в `backend/DESIGN.md` нужна апдейт после утверждения этого scope.

---

## Чек-лист "что я добавляю"

При желании добавить фичу — проверь:

1. Решает ли 🟢 MVP job? Если нет → отложить
2. Поддерживает ли brand pillar? Если нет → отложить
3. Попадает ли в anti-pattern? Если да → не делать
4. Можем без неё запуститься и сохранить ядро? Если да → отложить
5. Требует ли она ещё одной фичи (трансивно)? Учесть зависимости

Если все ответы "да" → добавляем в scope. Иначе — post-MVP.
