# Component Guidelines

> How components are built in this project.

---

## Overview

<!--
Document your project's component conventions here.

Questions to answer:
- What component patterns do you use?
- How are props defined?
- How do you handle composition?
- What accessibility standards apply?
-->

(To be filled by the team)

---

## Component Structure

<!-- Standard structure of a component file -->

(To be filled by the team)

---

## Glassmorphism Card Pattern

A reusable pattern for wrapping content in a frosted glass container.

### Pattern (ArkUI / HarmonyOS)

Every glass card = `Stack` with two layers:

```typescript
Stack() {
  // Layer 1: Glass background (blurs content behind)
  Column()
    .width('100%')
    .height('100%')
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .backgroundColor($r('app.color.glass_bg'))
    .borderRadius(radius)

  // Layer 2: Sharp content on top
  Image() / Text() / Button() / ...
}
.borderRadius(radius)
.border({
  width: 1,
  color: $r('app.color.glass_border'),
  radius: radius
})
.shadow({
  radius: shadowRadius,
  color: $r('app.color.glass_shadow')
})
```

### Color Resources

| Resource | Light | Dark | Usage |
|----------|-------|------|-------|
| `glass_bg` | `#4DFFFFFF` (30% white) | `#14FFFFFF` (8% white) | Glass tint |
| `glass_border` | `#26FFFFFF` (15% white) | `#1AFFFFFF` (10% white) | Glass edge |
| `glass_shadow` | `#26000000` (15% black) | `#26FFFFFF` (15% white) | Glass shadow |

### Rules

- The glass background layer MUST come first (underneath content)
- Content layer stays fully opaque (no tint/blur on the content itself)
- `borderRadius` on inner Column MUST match outer Stack for seamless glass
- For circular avatars: use `CircleShape` clip on BOTH the glass layer and the content layer
- For 2in1 devices: keep `border({ width: deviceTypeInfo === '2in1' ? 1 : 0 })` pattern

### When to Use

Use this pattern for any UI component that needs to appear elevated/frosted:
- Cover image cards
- Avatar containers
- Floating action buttons (FABs)
- Mini-player bars
- Active navigation items
- Search bars
- Action buttons (create, add, set)

### Don't Use

- On full-screen backgrounds (use `BlurStyle.BACKGROUND_ULTRA_THICK` instead)
- On modals/dialogs that need a distinct solid background
- On very small elements (< 24px) where blur is imperceptible

---

## Props Conventions

<!-- How props should be defined and typed -->

(To be filled by the team)

---

## Styling Patterns

<!-- How styles are applied (CSS modules, styled-components, Tailwind, etc.) -->

(To be filled by the team)

---

## Accessibility

<!-- A11y requirements and patterns -->

(To be filled by the team)

---

## Common Mistakes

<!-- Component-related mistakes your team has made -->

(To be filled by the team)
