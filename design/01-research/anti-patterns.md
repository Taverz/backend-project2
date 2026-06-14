# Anti-Patterns

> **Шаг 1.4 / Research.** Что мы **не делаем** — и почему.
> Каждый anti-pattern привязан к конкуренту, откуда взят, и persona, которая его не терпит.
> Этот список — щит против дрейфа продукта в "ещё один LinkedIn".

---

## Категория 1: Engagement-фарминг

### AP-1.1 — Алгоритмическая лента "For You"

**Где живёт:** Twitter/X, LinkedIn, Instagram

**Почему отказ:**
- Marina и Vlad явно сказали — это шум
- Algorithmic feed оптимизирует engagement, не сигнал
- В тех-нише качество ↔ кликабельность не коррелируют (часто наоборот)

**Что вместо:** Хронологический feed по подпискам (люди + теги).

### AP-1.2 — Стрики / daily challenges

**Где живёт:** LeetCode, Duolingo, GitHub heatmap, Snapchat

**Почему отказ:**
- Marina: *"выглядит детски"*. Vlad: *"любые элементы геймификации в стиле 'стрик 5 дней!'"*
- Стрики переключают motivation с внутренней (учусь) на внешнюю (не сломать стрик)
- Создают chrome > content

**Что вместо:** Activity timeline в profile показывает, **когда** человек постил, но без "🔥 14 days!" labels.

### AP-1.3 — Push-уведомления для re-engagement

**Где живёт:** Все соцсети

**Почему отказ:**
- Шум, который тех-аудитория давно научилась игнорировать
- Push о "у вас 3 новых endorsement" не приносит пользы

**Что вместо в MVP:** Без push вообще. Может быть, дайджест email раз в неделю (post-MVP).

### AP-1.4 — "Notifications" вкладка как primary loop

**Где живёт:** Twitter, LinkedIn

**Почему отказ:**
- Уведомления как dopamine pull
- Marina: *"не нужны 'у вас новый contact'"*

**Что вместо:** Inbox для важного (endorsement от респектабельного человека, recruiter outreach). Без badges-счётчиков на иконке таба.

---

## Категория 2: Vanity metrics

### AP-2.1 — Follower count как первая метрика профиля

**Где живёт:** Twitter, Instagram, LinkedIn

**Почему отказ:**
- Vlad: следить за конкретными людьми — да, но **количество** последователей ничего не доказывает
- Корреляция с экспертизой нулевая

**Что вместо:** В profile сверху — топ-3 expertise scores с темами. Followers count — мелким шрифтом ниже или скрыт.

### AP-2.2 — Лайки как primary metric

**Где живёт:** Twitter, Instagram, всё

**Почему отказ:**
- Тривиально накручиваются
- Не показывают, кто лайкнул (junior vs senior — одно и то же)
- Создают "engagement bait" контент

**Что вместо:** Endorsement (а не like) с весом. Показывается endorsement count + top 3 endorsers рядом.

### AP-2.3 — GitHub-style contribution heatmap

**Где живёт:** GitHub

**Почему отказ:**
- Это стрик в маске активности
- Стимулирует "коммиты ради коммитов"
- Marina: *"не показывает, что я **умею объяснять**"*

**Что вместо:** Score growth chart по теме — показывает динамику без давления на ежедневность.

### AP-2.4 — Global ranking / leaderboards

**Где живёт:** LeetCode, HackerRank

**Почему отказ:**
- Vlad: *"я не хочу быть в одной куче с FE-джунами"*. Соревнование вредит экспертному tone
- Бесполезно для рекрутера (он ищет в категории, не "top 10")

**Что вместо:** Score per topic — естественная сегментация. Никаких "Top 100 developers globally".

---

## Категория 3: Inauthentic content

### AP-3.1 — Motivation / influencer-стиль посты

**Где живёт:** LinkedIn (особенно)

**Примеры из LinkedIn:**
- *"This ONE LESSON from my CTO changed my career..."*
- *"Failure taught me MORE than success ever did 💯"*
- *"Hot take: senior engineers don't write code 🧠"*

**Почему отказ:**
- Маркер mass-platform, который devs ненавидят
- Anna (recruiter) сама не верит таким постам

**Как блокировать:**
- Tone of voice в UI (placeholder "What did you figure out?" вместо "What's on your mind?")
- В onboarding явно: "Bable is for technical insights. Save motivation for LinkedIn."

### AP-3.2 — Buzzword profiles ("ninja", "rockstar", "10x")

**Где живёт:** LinkedIn bios

**Почему отказ:**
- Anna: *"я игнорирую профили с этими словами"*
- Не сочетается с **доказательством через Score**

**Что вместо:** Bio как secondary, profile определяется Scores. Если человек хочет написать "Senior Rust Engineer" — окей, но это **под** Score, не вместо.

### AP-3.3 — One-click skill endorsements

**Где живёт:** LinkedIn

**Пример:** *"Does Marina know React? [yes/no]"* — junior-friends лайкают все скиллы, и валюта обесценивается.

**Почему отказ:**
- Endorsement обесценивается без context
- В LinkedIn выглядит как theatre, а не trust signal

**Что вместо:** Endorsement только на конкретный пост, не на абстрактный skill. Skill score выводится из endorsement'ов на постах с этим тегом.

---

## Категория 4: Spam / pollution

### AP-4.1 — Templated recruiter outreach

**Где живёт:** LinkedIn

**Пример:** *"Hi {first_name}! I came across your profile and was impressed..."*

**Почему отказ:**
- Marina, Vlad: главная причина отписки от LinkedIn
- Devalues outreach as a whole
- Anna сама не хочет, но KPI давят — нужна структурная защита

**Как блокировать:**
- Rate limit на outreach в неделю (когда implementируем)
- В outreach UI обязательно показать рекрутеру **последний пост кандидата** (или сделать обязательным reference на него)
- Public reputation для recruiter (Average response rate, "respect this rec" badges) — post-MVP

### AP-4.2 — "Open to opportunities" badges как карьерное унижение

**Где живёт:** LinkedIn

**Почему отказ:**
- Marina: *"карьерное унижение"*
- Бинарный сигнал слишком грубый

**Что вместо:** Subtle availability indicator (Open / Selective / Not looking) с настройкой, кому видно. Без "OPEN TO WORK" зелёной рамки.

### AP-4.3 — Notification spam для re-engagement

**Где живёт:** все соцсети

**Пример:** *"You appeared in 3 searches this week!"*, *"5 people viewed your profile!"*

**Почему отказ:**
- Это уловки для возврата, не сигнал
- Тех-аудитория давно игнорирует

**Что вместо:** Notifications только для прямых действий (endorsement, outreach, mention). Без passive engagement bait.

---

## Категория 5: Theatre verification

### AP-5.1 — Paid verification (бlue check)

**Где живёт:** X (после 2022)

**Почему отказ:**
- Дискредитирует verification как концепцию
- Платный сигнал ≠ trust signal

**Что вместо:** Verification через peer-recognition (score, endorsement). Если человек хочет verified — должен это заработать через активность.

### AP-5.2 — Self-declared skills без proof

**Где живёт:** LinkedIn ("Skills" секция)

**Почему отказ:**
- Бессмысленны без weight (см. AP-3.3)
- Anna: *"я их игнорирую при поиске"*

**Что вместо:** Skill = topic + Score, выведенный из контента. Никакой "Add a skill" кнопки.

---

## Категория 6: UX-смерть смыслом

### AP-6.1 — Cookie/notification permission walls

**Где живёт:** все европейские сайты

**Почему отказ:**
- Friction на самой важной странице (первая попытка чтения)
- J-CROSS-1: чтение должно работать без любых барьеров

### AP-6.2 — Login wall на read

**Где живёт:** LinkedIn, Pinterest, Quora

**Почему отказ:**
- J-CROSS-1: J-CROSS-1 явно говорит нет
- Снижает виральность — никто не шарит ссылку, требующую login

### AP-6.3 — Emoji как обязательный UI element

**Где живёт:** Slack, Discord, multiple social

**Почему отказ:**
- Marina, Vlad: *"не сочетается с серьёзным тоном"*
- В IT-нише emoji сигналит "casual", что подрывает professional tone

**Что вместо:** Иконки (SF Symbols / Lucide / Material outline) вместо emoji в UI. Emoji разрешён в **контенте** постов — это пользовательский выбор.

### AP-6.4 — Декоративные иллюстрации (3D, isometric, gradients)

**Где живёт:** SaaS landing pages (Notion, Airtable, и т.д.)

**Почему отказ:**
- Tech-аудитория относится к этому как к "marketing fluff"
- Vlad, Marina: предпочтение plain professional dark UI (как Linear)

**Что вместо:** Минимальный chrome, type-driven design, монохром + 1 акцент.

---

## Итог

| Категория | Кол-во anti-patterns | Где живут |
|-----------|:--------------------:|-----------|
| Engagement-фарминг | 4 | Все соцсети |
| Vanity metrics | 4 | Все соцсети + LeetCode |
| Inauthentic content | 3 | LinkedIn |
| Spam / pollution | 3 | LinkedIn |
| Theatre verification | 2 | X, LinkedIn |
| UX-смерть | 4 | EU sites, LinkedIn, SaaS |
| **Total** | **20** | — |

Этот список — фильтр для каждого UX-решения. Когда AI или дизайнер
предлагает фичу, мы проверяем: *"это попадает в один из 20 anti-patterns?"* — если да, переделываем.
