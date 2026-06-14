# Motion Tokens

> Editorial calm = restrained motion. Никаких больших анимаций. Только короткие, цельные transitions.

---

## Duration

| Token | ms | Use |
|-------|:--:|-----|
| `duration-instant` | 0 | No animation (reduced-motion, accessibility) |
| `duration-fast` | 120 | Hover states, focus, button feedback |
| `duration-base` | 200 | Default for color transitions, opacity |
| `duration-slow` | 320 | Page transitions, modal open/close |
| `duration-deliberate` | 500 | Like-burst, sparingly used micro-celebrations |

### Rules

- **Default: `duration-base`** (200ms).
- **Hover / focus: `duration-fast`** (120ms) — пользователь не ждёт, мгновенно.
- **Modals: `duration-slow`** (320ms) — viewer должен заметить открытие.
- **Никогда > 500ms** в MVP. Длинные анимации — только если есть **специальный motivational reason** (которого у нас нет).

---

## Easing

| Token | Curve | Use |
|-------|-------|-----|
| `easing-out` | `cubic-bezier(0.16, 1, 0.3, 1)` | **Default** — для появления (modal open, fade in) |
| `easing-in-out` | `cubic-bezier(0.4, 0, 0.2, 1)` | Для перемещений (X/Y translates) |
| `easing-in` | `cubic-bezier(0.5, 0, 0.75, 0)` | Для исчезновения (modal close, fade out) |
| `easing-linear` | `linear` | Только для skeleton pulse, progress bars |

### Rules

- **`easing-out` для всех "появления"** (новый элемент входит)
- **`easing-in` для всех "исчезновения"** (элемент уходит)
- **Никогда не `cubic-bezier(0.42, 0, 0.58, 1)` (Material's standard)** — у нас editorial, не Material

---

## Allowed animations

| Animation | Where | Tokens |
|-----------|-------|--------|
| Fade in/out | Modal, dropdown, toast | `duration-slow` + `easing-out` (in) / `easing-in` (out) |
| Color transition | Hover, focus, active states | `duration-fast` + `easing-out` |
| Endorse icon swap | When endorsing | `duration-base` + scale 0.95→1.05→1 (Source Serif "bounce") |
| Card hover | Slight bg shift | `duration-fast` color transition |
| Skeleton pulse | Loading state | 1500ms infinite, linear, opacity 0.3 → 0.6 |
| Slide-up (modal mobile) | Modal entrance mobile | `duration-slow` + `easing-out` translate-y 16 → 0 |

---

## Forbidden animations

- ❌ Bouncing / spring physics (исключение — endorse icon)
- ❌ Rotating decorative spinners (используем skeleton, не spinner)
- ❌ Parallax scrolling
- ❌ Sequenced "reveal" анимации (контент появляется по одному элементу)
- ❌ Page transitions с motion-effects (curtain, zoom)
- ❌ Anything > 500ms (кроме reduced-motion-respecting skeleton)

---

## Reduced motion

При `prefers-reduced-motion: reduce`:

- All `duration` → `duration-instant` (0ms)
- Skeleton pulse → static (opacity 0.5 без animation)
- Toast still fades, но через opacity-step без translate
- Endorse icon swap — instant без scale

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Performance

Чтобы анимации не лагали:

- **Только `transform` и `opacity`** анимируем (composited на GPU)
- **Никаких `top`, `left`, `width`, `height`** transitions (вызывают layout)
- **`will-change: transform`** на элементах, которые точно будут анимироваться (но не везде)

---

## Examples (псевдокод)

### Endorse button → endorsed

```
[♥ outline]                ← idle
   ↓ tap
[♥ filled, scale 1.1]      ← duration-base, easing-out
   ↓ 200ms
[♥ filled, scale 1.0]      ← settle
```

### Modal open

```
overlay opacity 0 → 0.5   (duration-slow, easing-out)
modal opacity 0 → 1       (duration-slow, easing-out)
modal translate-y 16 → 0  (duration-slow, easing-out)
```

### Toast appearance

```
opacity 0 → 1             (duration-base)
translate-y 8 → 0         (duration-base, easing-out)
... visible 3s ...
opacity 1 → 0             (duration-fast, easing-in)
```
