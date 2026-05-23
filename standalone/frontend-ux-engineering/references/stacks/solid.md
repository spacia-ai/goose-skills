# Stack — SolidJS / SolidStart (skeleton)

Skeleton. Patterns map to `stacks/vanilla.md`'s semantic baselines, expressed in SolidJS with fine-grained reactivity (`createSignal`, `createMemo`, `createEffect`).

## Library choices

| Concern | Recommended |
|---|---|
| Component primitives | Kobalte (accessible Solid primitives, APG-aligned) |
| Component library | shadcn-solid (Tailwind + Kobalte) |
| Forms | Modular Forms |
| Tables | TanStack Table v8 (Solid adapter) |
| Animation | Solid Transition Group, Motion for Solid |
| Storybook | Storybook 8 with Solid framework |
| Visual regression | Playwright |

## Patterns

```tsx
// Button.tsx
import { JSX, splitProps, createSignal } from 'solid-js';

type Props = {
  variant?: 'primary' | 'secondary' | 'destructive' | 'ghost';
  loading?: boolean;
} & JSX.ButtonHTMLAttributes<HTMLButtonElement>;

export function Button(props: Props) {
  const [local, rest] = splitProps(props, ['variant', 'loading', 'children', 'disabled']);
  return (
    <button
      {...rest}
      disabled={local.disabled || local.loading}
      aria-busy={local.loading || undefined}
      class={`btn btn-${local.variant ?? 'primary'}`}
    >
      {local.loading && <span class="spinner" aria-hidden="true" />}
      {local.children}
    </button>
  );
}
```

Kobalte provides APG-aligned primitives for dialog, combobox, listbox, tabs, etc. Use them for any custom widget rather than rolling your own ARIA.

## SolidStart specifics

- Server-rendered with islands.
- `createAsync` for data; provide loading and error states via `<Suspense>` and `<ErrorBoundary>`.
- Image optimization via `@solidjs/start` integrations or external CDN.

## Status of this skeleton

Expand as the skill is exercised on real Solid / SolidStart projects. **Fall back to `stacks/vanilla.md` for semantic baselines.**

## Bibliography

- SolidJS documentation.
- SolidStart documentation.
- Kobalte documentation.
- shadcn-solid documentation.
- Storybook for Solid documentation.
