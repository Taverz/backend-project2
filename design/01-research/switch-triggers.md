# Switch Triggers

> Что **конкретно** заставит реальную персону зарегистрироваться в Bable и потом вернуться.
> Без switch trigger продукт не запускается — даже если он лучше существующих.

---

## Принцип

Люди не уходят с существующих платформ, потому что новая *лучше*. Они уходят, когда:
1. Текущая платформа делает что-то **невыносимое** ("я больше не могу терпеть X")
2. Новая платформа решает **конкретную задачу прямо сейчас** ("мне нужно Y, и только Bable это делает")
3. Кто-то из их круга **уже там и зовёт** ("я подписан на Алису, она там")

Mы должны спроектировать все три.

---

## Switch triggers для Marina (Mid Backend Dev)

### Trigger 1 — "Twitter become unusable"
- Алгоритмическая лента показывает 20% политики
- Tech-аккаунты, на которые подписалась, теряются в feed
- **Точка boiling:** *"я больше не нахожу Rust-контент, который интересен"*
- **Что Bable даёт:** хронологический feed по навыкам, который she actually wants to read

### Trigger 2 — "Time to find new role"
- Marina начинает искать работу через 6 месяцев
- LinkedIn outreach — спам, GitHub-профиль не выделяет её среди прочих
- **Точка boiling:** *"я не Senior на бумаге, но я know my shit, как это показать?"*
- **Что Bable даёт:** Score per topic как доказательство, без CV

### Trigger 3 — "Frend joined and shared score"
- Marina видит у друга/коллеги в Twitter-bio: `Rust 680 on Bable`
- **Точка boiling:** *"А я лучше него в Rust, у меня будет больше"*
- **Что Bable даёт:** место померяться без вульгарности (это не leaderboard, но Score сравним внутри своей подсетки)

### Что **возвращает** Marina после регистрации
- Уведомление: *"Vlad endorsed your post — his Rust score is 820"* — это **престижно**
- Score рос на +30 после её поста — **видимый прогресс**
- Recruiter написал, **прочитав конкретный пост**, не шаблон

### Что **отвалит** Marina
- Первый recruiter spam — *"если тут как в LinkedIn, я ухожу"*
- Не получила ни одного endorsement за первые 3 поста — *"никто меня не видит"*
- Лента пустая, потому что никого нет — *"contentdesert"*

### Implication для design / product
- **Cold start strategy:** seed первой когорты вручную (qualified senior devs)
- **First-post amplification:** новый пост от нового пользователя показывается чуть выше в feed первые 24 часа
- **Onboarding telemetry:** если первый пост без endorsement за 48h — это red flag для нашего продукта

---

## Switch triggers для Vlad (Senior FE)

### Trigger 1 — "Twitter audience gone"
- Vlad ушёл с Twitter после политизации
- Mastodon — фрагментарно, аудитория не следует
- **Точка boiling:** *"мне нужна place, где у меня снова будет audience и influence"*
- **Что Bable даёт:** концентрированная tech-аудитория с context (он не объясняет, кто он — Score говорит)

### Trigger 2 — "Speaking gigs hard to get"
- Конференции хотят speakers с "tangible influence", не только GitHub stars
- **Точка boiling:** *"как доказать, что я influencer без vanity follower count?"*
- **Что Bable даёт:** Score per topic + endorsement от других senior'ов = трекаемый proof

### Trigger 3 — "Recruiter Quality"
- Vlad устал от шаблонных LinkedIn outreach
- **Точка boiling:** *"я хочу видеть только outreach, где recruiter читал, что я пишу"*
- **Что Bable даёт:** outreach с обязательным reference на конкретный пост

### Что **возвращает** Vlad
- Качественный endorsement от уважаемого человека в индустрии (видит chain доверия)
- Outreach от компании, которая прочитала его последние 3 поста и предлагает конкретную команду
- Запрос на speaking от организаторов конференции, нашли через Score

### Что **отвалит** Vlad
- Появление motivational/influencer контента в feed — *"тут стало как LinkedIn"*
- Junior endorsement от нерелевантных аккаунтов — *"система сломана, мой Score девальвируется"*
- Любая попытка геймификации — *"я не подросток"*

### Implication
- **Quality bar в первой когорте важнее количества.** Лучше 50 senior'ов, чем 500 mixed
- **Endorsement explanation видна сразу** — Vlad должен видеть, чьи endorsements его не интересуют, и научиться выявлять девальвацию
- **Visible признак "Vlad на платформе"** для других devs — он социальный proof

---

## Switch triggers для Anna (Recruiter)

### Trigger 1 — "Quarterly KPI desperation"
- 3-й месяц квартала, 2 Senior Rust роли всё ещё открыты
- LinkedIn Recruiter не работает — response rate упал до 8%
- **Точка boiling:** *"мне нужно попробовать что-то новое или fail KPI"*
- **Что Bable даёт:** концентрированный pool с фильтром по skill (если pool существует)

### Trigger 2 — "Heard from candidate"
- Кандидат на интервью говорит *"найдите меня на Bable, там видно"*
- **Точка boiling:** *"если они **рекомендуют** платформу мне, это сигнал"*
- **Что Bable даёт:** validated через candidate behaviour

### Trigger 3 — "Sourcing experiment budget"
- В Anna's компании есть Q-budget на new sourcing channels
- **Точка boiling:** *"могу попробовать без риска"*
- **Что Bable даёт:** free tier или low entry barrier

### Что **возвращает** Anna
- Первый closed hire через Bable — она навсегда там
- Anti-spam mechanics — её outreach получает **больше** responses, чем в LinkedIn (потому что low spam volume в платформе)
- Public response rate растёт — становится "trusted recruiter" — больше отвечают

### Что **отвалит** Anna
- 0 кандидатов в её нише (Rust pool < 50) — *"нет supply"*
- Кандидаты регистрируются и исчезают (lurkers без активности) — *"нечего смотреть"*
- Slow search (>3s) — recruiter'ы не терпят latency

### Implication
- **Critical mass:** нужно минимум 100-200 active devs per major skill area, чтобы recruiter увидел value
- **Hold Anna's first contact:** при регистрации recruiter получает 30-day free, но первый месяц нужен **high-quality matching** — иначе уйдёт
- **Search performance — критично:** budget < 300ms

---

## Network triggers (cross-persona)

### Direct trigger: "Friend joined"
- Marina видит в Discord *"checking out bable.io, кстати, найдите меня там"*
- Vlad ретвитнул свой Bable-профиль с *"My Bable profile is now public"*
- Anna услышала от senior'а *"мы недавно нашли отличного кандидата через Bable"*

### Indirect trigger: "Bable mentioned in tech-conversation"
- HackerNews thread про "LinkedIn alternatives" — Bable в комментах
- Подкаст обсуждает trust signals в hiring — упоминание Bable Score
- Tech-блог пишет sравнение dev platforms — Bable в списке

### Implication для design
- **Profile public-by-default** — без login wall
- **Profile URL shareable** — `bable.io/u/marina`, не `bable.io?user=12345`
- **Profile card visible в OG / Twitter card** — когда шарят, видно скриншот score'ов
- **README badge** для GitHub — `[![Bable](https://bable.io/badge/marina/rust)](https://bable.io/u/marina)`

---

## Cold-start strategy (вытекает из triggers)

Если первая когорта слабая, остальные не придут. Поэтому:

### Phase 0 — Seed (manual)
- Найти 30-50 уважаемых mid-senior devs в Rust, React, Go (через личные сети)
- Manually invite, помочь зарегистрироваться, написать первые посты
- Гарантировать высокое качество (а не количество)

### Phase 1 — Friends of friends
- Каждый из 30-50 приглашает 2-3 человек из своей сети
- К концу 1-го месяца: 150-200 active devs, 2-3 темы покрыты

### Phase 2 — Recruiter pilot
- Когда supply ≥ 200 в одной теме — invite 5-10 recruiter'ов
- 3-месяц free trial, посмотреть response rate
- Если работает — public launch

### Phase 3 — Public launch
- Open registration
- ProductHunt / HackerNews launch
- Twitter / LinkedIn announcements (через Phase 0 audience)

### Implication для MVP
- **Invite codes** для phase 0/1 (не open registration сразу)
- **Recruiter подписка отдельная** — для phase 2 нужен tooling
- **Public profile без auth** — критично с самого начала

---

## Summary

| Persona | Что заставит зайти | Что заставит вернуться | Что отпугнёт |
|---------|-------------------|----------------------|-------------|
| Marina | Friend's bio link / job search | First endorsement / Score growth | Recruiter spam / empty feed |
| Vlad | Twitter audience loss / speaking gigs | Senior endorsement / quality outreach | Influencer content / junk endorsements |
| Anna | KPI desperation / candidate-rec | First close / high response rate | Empty supply / slow search |

### Universal принципы для дизайна

1. **Public-by-default profiles** — switch triggers требуют шеринга
2. **Shareable URLs + OG cards** — каждый профиль = маркетинг
3. **First-post amplification** — новички должны почувствовать сигнал
4. **Recruiter response rate visible** — recruiter trust механика
5. **Anti-spam by structure** — без этого Marina и Vlad уйдут после 1-го LinkedIn-style outreach
