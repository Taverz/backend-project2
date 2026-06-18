# Jobs To Be Done

> **Шаг 1.3 / Research.** JTBD-карта на основе personas.
> Формат: *"When [situation], I want to [motivation], so I can [outcome]."*
> Каждый job связан с feature, который мы должны (или не должны) сделать в MVP.

---

## Conventions

| Маркер | Значение |
|--------|----------|
| 🟢 MVP | Решаем в MVP |
| 🟡 Post-MVP | Знаем job, отложили |
| 🔴 Reject | Сознательно не решаем |

---

## Jobs for Developer (Marina, Vlad)

### J-DEV-1 🟢 Capture an insight before it disappears
> When I figure out something subtle in code, I want to publish a short note about it within 60 seconds, so the insight isn't lost and starts counting toward my reputation.

**Implications:**
- Compose должен быть instant (1 экран, 1 поле, 256 chars)
- Drafts необязательны в MVP — frictionless > safety
- Code block — обязательная кнопка в composer

### J-DEV-2 🟢 Be findable by what I actually know
> When a recruiter looks for someone with my skills, I want them to find me by verified expertise, not by buzzwords in my bio.

**Implications:**
- Profile = expertise scores (per topic), не bio как primary
- Search by topic + min score
- Score должен быть видим в публичной части профиля

### J-DEV-3 🟢 Trust the reactions on my posts
> When someone endorses my post, I want to know if it's from a peer or a junior, so I can value the signal correctly.

**Implications:**
- Endorsement не анонимный
- При просмотре endorsement-листа видно score endorser'а по этой теме
- Не показываем "людей по работе" — показываем людей по компетенции

### J-DEV-4 🟢 See signal in my feed, not drama
> When I open the feed, I want only content related to my expertise areas, ordered by time, without political/lifestyle/motivational posts.

**Implications:**
- Хронологический feed only
- Tag-based filtering (по подпискам на теги или людей)
- Нет category "Lifestyle", "News" в MVP

### J-DEV-5 🟢 Differentiate myself from juniors with the same stack
> When I post about React, I want to mark complexity (this is a Senior-level insight, not "I learned useState"), so my expertise doesn't get diluted.

**Implications:**
- Post type: Insight / Solution / Question / Project
- Complexity tag: Easy / Medium / Hard
- Complexity multiplier влияет на Score

### J-DEV-6 🟡 Receive job offers I'd actually consider
> When a recruiter contacts me, I want the message to show they read my profile, so I don't waste time on templated outreach.

**Implications:**
- Recruiter outreach rate-limited (anti-spam)
- Outreach UI должен **показать profile** рекрутеру в шаблоне
- В MVP — нет messaging вообще (post-MVP)

### J-DEV-7 🟡 Build reputation around a long-form piece
> When I write a deep article on a topic, I want it to anchor my expertise more than a short post.

**Implications:**
- Long-form post type — post-MVP
- В MVP — только короткие посты с code blocks

### J-DEV-8 🔴 Get a lot of followers
> When I post good content, I want to grow my follower count.

**Why reject:** Follower count = vanity metric. Мы не показываем его как primary. Score per topic — да.

### J-DEV-9 🔴 Get daily engagement loops
> When I open the app, I want a streak / daily challenge that keeps me coming.

**Why reject:** Это геймификация. Audience research (Vlad, Marina) явно их отпугивает.

---

## Jobs for Recruiter (Anna)

### J-REC-1 🟢 Find verified specialists by skill + level
> When I need to hire a Senior Rust dev, I want a filtered list of people with Rust score above threshold, so I don't waste hours on screening.

**Implications:**
- Search UI: topic + min score + availability flag
- Score должен быть стабильным и тяжело накручиваемым
- Список результатов отсортирован по score (или комбинации score × recency)

### J-REC-2 🟢 Understand a candidate before reaching out
> When I see a candidate, I want to see their recent posts and what they're working on, so my outreach is relevant.

**Implications:**
- Profile показывает 5-10 последних постов рядом со scores
- Activity timeline (когда последний раз постил по этой теме)

### J-REC-3 🟢 Avoid candidates who recently changed jobs
> When sourcing, I want to filter out people who joined a new role in the last 6 months, so I don't waste outreach.

**Implications:**
- "Job change date" в профиле (optional, self-reported)
- Filter в search

### J-REC-4 🟡 Track candidates over time
> When I find a great candidate who's not looking now, I want to save them and get notified when their status changes.

**Implications:**
- Saved candidates list
- Watch notifications (job status change, big score jump)
- Post-MVP

### J-REC-5 🟡 Send targeted outreach
> When I message a candidate, I want my message tied to their post or score, so it feels relevant.

**Implications:**
- Messaging post-MVP. В MVP — link на профиль в LinkedIn / Twitter / email (если шарит)

### J-REC-6 🔴 Send mass templated outreach
> When I have 200 candidates, I want to send the same message to all of them efficiently.

**Why reject:** Это уничтожает trust для developer (J-DEV-6). Anti-spam by design.

---

## Cross-cutting jobs (для обеих сторон)

### J-CROSS-1 🟢 Read the platform without signing up
> When I see a Bable link on Twitter, I want to read the post without registering, so I can decide if the platform is worth joining.

**Implications:**
- All posts publicly readable (default)
- Login wall только на actions (post, endorse, message)

### J-CROSS-2 🟢 Trust the metrics shown
> When I see a number on this platform (Score, endorsement count), I want to know exactly how it was calculated, so I trust it.

**Implications:**
- Каждый Score кликабелен → explanation page
- Endorsement список показывает endorser + their score
- No hidden ranking factors

### J-CROSS-3 🟢 Be sure my data is mine
> When I publish content, I want guaranteed export and no surprise visibility changes, so I'm comfortable investing in the platform.

**Implications:**
- Export profile / posts — post-MVP, но архитектурно открыто
- Visibility всегда public (MVP) — никаких "private to network" surprise changes

---

## JTBD → Features map (the bridge to step 2)

| Feature (что строим) | Solves jobs |
|---------------------|-------------|
| Quick compose (256 chars + code) | J-DEV-1 |
| Post type + complexity tags | J-DEV-5 |
| Per-topic Expertise Score | J-DEV-2, J-REC-1 |
| Weighted endorsement | J-DEV-3, J-CROSS-2 |
| Score explanation page | J-CROSS-2 |
| Chronological feed by tags + follows | J-DEV-4 |
| Recruiter search (topic + score) | J-REC-1 |
| Profile = scores + recent posts | J-DEV-2, J-REC-2 |
| Public read without auth | J-CROSS-1 |
| Rate-limited outreach (when impl) | J-DEV-6, J-REC-1, anti J-REC-6 |

| Job | Status | When |
|-----|:------:|------|
| J-DEV-1..5 | 🟢 | MVP |
| J-DEV-6, 7 | 🟡 | Post-MVP |
| J-DEV-8, 9 | 🔴 | Never |
| J-REC-1..3 | 🟢 | MVP |
| J-REC-4, 5 | 🟡 | Post-MVP |
| J-REC-6 | 🔴 | Never |
| J-CROSS-1, 2 | 🟢 | MVP |
| J-CROSS-3 | 🟡 | Архитектурно учитываем сразу |
