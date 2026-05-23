# Stack — Vue 3 / Nuxt

Skeleton. Patterns map to `stacks/vanilla.md`'s semantic baselines, expressed in idiomatic Vue 3 with `<script setup>` and the Composition API. Nuxt-specifics are noted where they differ.

## Library choices

| Concern | Recommended |
|---|---|
| Component primitives | Radix Vue (formerly Radix-Vue), Reka UI |
| Component library | shadcn-vue (Tailwind + Radix Vue), @nuxt/ui (Nuxt only), Naive UI |
| Forms | VeeValidate + Zod |
| Tables | TanStack Table v8 (Vue adapter) |
| Animation | Motion for Vue, transition components |
| Storybook | Storybook 8 with Vue 3 framework |
| Visual regression | Playwright |

## Patterns

### Button

```vue
<script setup lang="ts">
defineProps<{
  variant?: 'primary' | 'secondary' | 'destructive' | 'ghost';
  loading?: boolean;
  disabled?: boolean;
}>();
</script>

<template>
  <button
    :disabled="disabled || loading"
    :aria-busy="loading || undefined"
    class="btn"
    :class="[`btn-${variant ?? 'primary'}`]"
  >
    <span v-if="loading" class="spinner" aria-hidden="true" />
    <slot />
  </button>
</template>
```

### Form (VeeValidate)

VeeValidate handles validation timing (default: on-submit + after-touch), inline errors, and submission state. Pair with a manual error summary that focuses on invalid submit, like the vanilla example.

```vue
<script setup lang="ts">
import { useForm } from 'vee-validate';
import { toTypedSchema } from '@vee-validate/zod';
import { z } from 'zod';

const Schema = z.object({
  email: z.string().email('Enter a valid email.'),
  password: z.string().min(12, 'Use at least 12 characters.'),
});

const { handleSubmit, errors, defineField } = useForm({
  validationSchema: toTypedSchema(Schema),
});
</script>
```

The summary-on-submit pattern from `stacks/vanilla.md` and `stacks/react.md` translates directly — move focus to the summary in the `handleSubmit` invalid callback.

### Data table, dialog, loading feedback

Use TanStack Table Vue adapter, Radix Vue Dialog primitive, and the same loading patterns as vanilla. Vue's native `<Transition>` honors `prefers-reduced-motion` when the CSS does.

## Tokens

CSS variables identical to `stacks/vanilla.md`. Tailwind config the same as `stacks/react.md`. Vue does not change the token strategy.

## Nuxt-specifics

- Server-rendered by default; CWV-friendly.
- `<NuxtImg>` handles aspect-ratio reservation for CLS.
- `useFetch` / `useAsyncData` for data; provide loading and error states.
- `app.vue` and `error.vue` for global error handling.
- @nuxt/ui ships accessible components and a token system; consider it as a starting point.

## Status of this skeleton

This file is a skeleton in v1. For full pattern coverage including Storybook + Playwright examples in Vue, expand it as the skill is exercised on real Vue projects.

When using this skeleton, **fall back to `stacks/vanilla.md` for semantic baselines** and translate to Vue 3 idioms.

## Bibliography

- Vue 3 documentation.
- Nuxt 3 / 4 documentation.
- Radix Vue documentation.
- shadcn-vue documentation.
- VeeValidate documentation.
- Storybook for Vue documentation.
