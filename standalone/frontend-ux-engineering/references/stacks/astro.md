# Stack — Astro (skeleton)

Skeleton. Astro's strength is the **islands architecture**: server-rendered HTML by default with partial hydration only where needed. This is genuinely good for CWV — most pages ship near-zero JS.

## When Astro is the right choice

- Content-heavy sites (marketing, documentation, blogs, e-commerce front pages).
- Apps with limited interactive surfaces (a few forms, occasional widgets).
- Teams that want to opt into framework components (React, Vue, Svelte, Solid) per island, not site-wide.

When the user is mostly building dashboards, real-time apps, or heavily interactive UIs, Astro is not the optimal choice — pick the framework that matches the interaction density.

## Library choices

| Concern | Recommended |
|---|---|
| Astro components | `.astro` files for server-rendered surfaces |
| Interactive islands | React / Vue / Svelte / Solid components — pick per island |
| Component primitives | Use the chosen framework's primitive library (Radix, Bits UI, Kobalte, etc.) |
| Forms | Server-action style forms (Astro 4+ actions); fallback to native form posts |
| Animation | CSS for static; framework's animation lib for islands |
| Visual regression | Playwright |

## Patterns

### Static button (Astro component)

```astro
---
// Button.astro
type Props = {
  variant?: 'primary' | 'secondary' | 'destructive' | 'ghost';
  href?: string;
};
const { variant = 'primary', href } = Astro.props;
const Tag = href ? 'a' : 'button';
---

<Tag class={`btn btn-${variant}`} href={href}>
  <slot />
</Tag>
```

### Interactive island (React inside Astro)

```astro
---
import { InteractiveCounter } from '../components/InteractiveCounter';
---

<h1>My page</h1>
<p>Static content here.</p>

<InteractiveCounter client:visible />
```

`client:visible` hydrates only when the component scrolls into view. Other directives: `client:load`, `client:idle`, `client:media`, `client:only`. Pick the lightest one that still works.

## Hydration discipline

- Default: no JS. `.astro` components are SSR-only.
- Hydrate islands with the lightest directive that meets the requirement.
- Don't hydrate static content. Marketing copy doesn't need hydration.
- One framework per island is fine. Mixing React and Vue islands on the same page is allowed but adds ship-cost — minimize.

## Tokens and accessibility

CSS variables and accessibility patterns identical to `stacks/vanilla.md`. Tailwind works the same way as in `stacks/react.md`.

## Status of this skeleton

Expand as the skill is exercised on real Astro projects. **Fall back to `stacks/vanilla.md` for semantic baselines** and to the appropriate framework's stack file (`react.md`, `vue.md`, `svelte.md`, `solid.md`) for interactive island patterns.

## Bibliography

- Astro documentation (astro.build).
- "Islands Architecture" — Jason Miller (preactjs.com / web.dev).
- Storybook integrations per framework.
