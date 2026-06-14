# Anti-Personas

> Кому Bable **не** для. Если эти люди приходят и остаются — мы делаем неправильный продукт.
> Это важнее, чем personas: за каждым "yes для Marina" должно стоять "no для AP-1".

---

## AP-1 — Greg, LinkedIn Influencer

```
┌───────────────────────────────────────────────────┐
│  Greg, 38                                         │
│  "Tech Career Coach & 10x Mentor"                 │
│  100k followers on LinkedIn                       │
│  Posts: 5 motivational threads a week             │
│  Никогда не писал production-код последние 8 лет │
└───────────────────────────────────────────────────┘
```

### Что он делает на LinkedIn
- *"Here's what I learned from getting laid off..."* (carousel из 10 слайдов)
- *"Junior devs, STOP doing these 5 things"* (engagement bait)
- Sells coaching, courses, "Career Acceleration Program"

### Что он будет делать на Bable, если мы не закроем дверь
- Постить мотивационные посты с #career, #software
- Накапливать endorsement через свою аудиторию из LinkedIn
- Конвертировать score в продажи курсов
- Снижать ценность Score для всех остальных

### Как закрываем
- **Tone of voice в copy** — placeholder "What did you figure out?" (Greg не "figured out" ничего технического)
- **Content moderation rule:** пост с topic-tag но без topic-substance → flag
- **Endorsement weight зависит от Score эндорсящего по теме** — его LinkedIn-follower'ы junior'ы или вообще не tech → их endorsements почти ничего не весят
- **Нет "follow back" механики** — невозможно построить аудиторию из вежливости

### Тест
Если Greg попробовал Bable, посмотрел и сказал *"тут нет ROI на мои посты"* — мы правы.

---

## AP-2 — Maxim, Mass-source Recruiter

```
┌───────────────────────────────────────────────────┐
│  Maxim, 26                                        │
│  Agency recruiter (контрактор для 10 компаний)   │
│  KPI: 50 outreach в день, 5 ответов в неделю      │
│  Шлёт один и тот же шаблон всем                   │
└───────────────────────────────────────────────────┘
```

### Что он делает в LinkedIn
- Copy-paste шаблон с `{first_name}`
- "Hi {first_name}, I came across your profile..."
- Шлёт 50 outreach в день, не читает профили
- Конверсия 2%, но объём решает

### Что он будет делать на Bable
- Тянет тот же шаблон в outreach
- Spamит 50 кандидатов в день
- Marina и Vlad после первого спама уйдут

### Как закрываем (когда импл-нем outreach)
- **Rate limit на outreach** — максимум 5 в день для нового recruiter, растёт при positive responses
- **Outreach UI требует reference на конкретный пост** кандидата — нельзя написать без чтения профиля
- **Public response rate** recruiter'а — если люди игнорируют его outreach, это видно всем кандидатам
- **Кандидат может пометить outreach as spam** — повторно от того же recruiter блокируется

### Тест
Если Maxim попробовал и сказал *"тут слишком сложно, проще в LinkedIn"* — мы правы.

---

## AP-3 — Junior с CV inflation

```
┌───────────────────────────────────────────────────┐
│  Tim, 22                                          │
│  Junior FE (1 год опыта, 3 месяца в production)  │
│  В LinkedIn: "Senior Full-Stack Engineer"        │
│  Хочет быстро накачать профиль                    │
└───────────────────────────────────────────────────┘
```

### Что он попытается на Bable
- Поставить себе level "Senior" в bio
- Накачать endorsements через джуниор-друзей
- Скопировать чужие insights

### Как закрываем
- **Уровень не self-declared** — выводится из Score
- **Endorsement weight зависит от Score эндорсящего** — друзья-junior'ы добавят почти 0 в Score
- **Plagiarism detection** — post-MVP, но через embedding-similarity к существующим
- **Showcase posts с реальной идентичностью** — невозможно "сделать вид"

### Тест
Если Tim пишет качественные посты и его эндорсят senior'ы — он **законно** растёт. Это успех.
Если Tim не пишет содержательно, его Score остаётся низким — Bable работает.

### Важный nuance
**Tim — не враг.** Если он использует Bable для **роста**, это хорошо. Враг — Tim, который пытается **обмануть систему**, чтобы выглядеть Senior быстрее, чем он реально станет.

---

## AP-4 — Lurker без вклада

```
┌───────────────────────────────────────────────────┐
│  Anna, 34                                         │
│  Senior dev, занятой, time-poor                   │
│  Читает HN, не пишет нигде                        │
│  "Я не contributor, я только consume"             │
└───────────────────────────────────────────────────┘
```

### Что она делает
- Зарегистрировалась, посмотрела feed
- Не postила, не endorsed
- Не вернулась через 2 недели

### Это не враг — но это не пользователь, который оживляет платформу
- Lurkers нужны (читатели = аудитория для контента)
- Но если их 90%+, content loop умирает

### Что мы делаем
- **Не штрафуем за lurking.** Никаких "post or be removed" уведомлений.
- **Минимальный barrier to endorse** — если читает регулярно, рано или поздно тыкнет endorsement
- **Не давим onboarding-туториалами** "Make your first post!"
- **Просто принимаем** — Lurker → eventually Reader → eventually Endorser → eventually Poster (или нет)

---

## AP-5 — Community drama-seeker

```
┌───────────────────────────────────────────────────┐
│  Various                                          │
│  Любит спорить про Rust vs Go, vim vs emacs       │
│  Тратит часы в комментариях                       │
│  Никогда не показывает свой код                   │
└───────────────────────────────────────────────────┘
```

### Что они делают
- Заходят в комменты к чужому посту
- Спор не по существу, а про "ты не понял суть"
- Toxic threading

### Как закрываем
- **Endorsement не лайк** — спорщики не получают score за активность в комментах
- **Threading visible** (см. tweet-card) — видно, кто переходит на личности
- **Flag по теме "off-topic harassment"** — модерация
- **Endorsement weight требует score по теме** — те, кто только спорят, не растут

---

## Тест продукта по anti-personas

Если через 3 месяца после запуска MVP:

| Признак | Что значит |
|---------|-----------|
| Greg есть, но Score ≤ 100 | ✅ Защита работает |
| Greg есть, и Score 800 | ❌ Endorsement weight сломан |
| Maxim spamит — кандидаты молчат / уходят | ❌ Outreach limits слабые |
| Maxim спамил, забанен через flag | ✅ |
| Tim растёт от качества постов | ✅ |
| Tim в Senior за 2 месяца с фальшивыми постами | ❌ |
| Lurker регистрируется, читает, не пишет | ✅ это норма |
| Drama в комментах с банами/флагами | ✅ модерация работает |
| Drama в комментах без последствий | ❌ модерация сломана |

Цель: **architecture закрывает anti-persons by design**, а не post-hoc через moderation overhead.
