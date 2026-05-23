# Stack — Svelte 5 / SvelteKit

Skeleton. Patterns map to `stacks/vanilla.md`'s semantic baselines, expressed in idiomatic Svelte 5 with runes (`$state`, `$derived`, `$effect`).

## Library choices

| Concern | Recommended |
|---|---|
| Component primitives | Bits UI, Melt UI |
| Component library | shadcn-svelte (Tailwind + Bits UI), Skeleton UI |
| Forms | sveltekit-superforms + Zod |
| Tables | TanStack Table v8 (Svelte adapter) |
| Animation | Native Svelte transitions, Motion for Svelte |
| Storybook | Storybook 8 with Svelte framework |
| Visual regression | Playwright |

## Patterns

### Button (Svelte 5 runes)

```svelte
<script lang="ts">
  type Props = {
    variant?: 'primary' | 'secondary' | 'destructive' | 'ghost';
    loading?: boolean;
    disabled?: boolean;
    children?: import('svelte').Snippet;
  };
  let { variant = 'primary', loading = false, disabled = false, children }: Props = $props();
</script>

<button
  disabled={disabled || loading}
  aria-busy={loading || undefined}
  class="btn btn-{variant}"
>
  {#if loading}<span class="spinner" aria-hidden="true"></span>{/if}
  {@render children?.()}
</button>
```

### Form (sveltekit-superforms)

Superforms handles progressive enhancement — the form works without JS, and enhances with JS for inline validation. The summary-on-invalid pattern from `stacks/vanilla.md` applies; move focus to the summary in the invalid handler.

### Data table, dialog, loading feedback

Use TanStack Table Svelte adapter, Bits UI Dialog primitive, and the same loading patterns as vanilla. Svelte's native `transition:` directives honor `prefers-reduced-motion` when the CSS does (or use `reducedMotion` from `svelte/motion`).

## Tokens

CSS variables identical to `stacks/vanilla.md`. Tailwind config the same as `stacks/react.md`.

## SvelteKit-specifics

- Server-rendered by default; CWV-friendly.
- `+page.server.ts` for server-side data; `+page.svelte` for the page.
- Form actions provide progressive-enhancement form handling out of the box (`use:enhance`).
- Error pages: `+error.svelte` per route.
- Image optimization via `@sveltejs/enhanced-img` or external CDN.

## Status of this skeleton

This file is a skeleton in v1. For full pattern coverage including Storybook + Playwright examples, expand it as the skill is exercised on real SvelteKit projects.

When using this skeleton, **fall back to `stacks/vanilla.md` for semantic baselines** and translate to Svelte 5 idioms.

## Bibliography

- Svelte 5 documentation.
- SvelteKit documentation.
- Bits UI documentation.
- shadcn-svelte documentation.
- sveltekit-superforms documentation.
- Storybook for Svelte documentation.
