# Chirp — Project Overview (for Designer + AI)

> Краткая информация о проекте для контекста дизайна.
> Источник: SOUL.md

---

## Что за проект

Chirp — Twitter-клон. Платформа коротких сообщений с подписками,
лентами, лайками, поиском и уведомлениями.

## Платформы

| Платформа | Дизайн |
|-----------|--------|
| Mobile (iOS + Android) | Основной дизайн, bottom tabs |
| Web (desktop) | Адаптация mobile-дизайна, левая панель вместо bottom tabs |

## Аудитория

Тысячи → миллионы пользователей. Молодёжь 18-35 лет.

## Тон

- Дружелюбный, но не детский
- Минималистичный (Twitter-стиль)
- Темная тема по умолчанию (Twitter-тёмная)
- Акцент на контенте, не на UI

## Цвета (основные)

| Token | Light | Dark |
|-------|-------|------|
| Primary | `#1DA1F2` | `#1DA1F2` |
| Background | `#FFFFFF` | `#15202B` |
| Card | `#F5F5F5` | `#192734` |
| Text primary | `#0F1419` | `#E7E9EA` |
| Text secondary | `#536471` | `#71767B` |
| Error | `#E0245E` | `#F4212E` |

## Навигация (основная)

```
Bottom tabs: Home | Search | Notifications | Profile
Push: Tweet detail, User profile, Create tweet
Modal: Login, Register (когда не авторизован)
```
