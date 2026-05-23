# Stack — React (default)

Covers React (vanilla), Next.js, Remix, and Gatsby. Examples are TypeScript by default. Patterns map to `domains/patterns.md`; the goal is idiomatic React on top of the same semantic baseline as `stacks/vanilla.md`.

## Why React is the default

React (and React frameworks) dominate the web app stack landscape. The official Vercel admin starter, the Remix stacks, the Next.js app router examples, shadcn/ui, Radix Primitives, and MUI X are all React-centric. When the user has not specified a stack and detection returns `unknown`, the most common shipping target is React + TypeScript + Tailwind + shadcn/Radix.

This file assumes that default. Where Next.js, Remix, or Gatsby specifics differ, they're called out.

## Library choices

| Concern | Recommended | Notes |
|---|---|---|
| Component primitives | Radix Primitives | Accessible by default; APG-aligned; unstyled. Best when building a bespoke design system. |
| Component library | shadcn/ui | Copy-and-own components built on Radix + Tailwind. Highest customization control. |
| Heavyweight components | MUI X | When you need data grids, date pickers, charts at enterprise scale. Heavier theming. |
| Styling | Tailwind CSS | Class-based; works well with tokens via CSS variables. |
| Forms | React Hook Form + Zod | Performance + schema validation. |
| Tables | TanStack Table v8 | Headless; bring-your-own UI. |
| Routing | Next.js App Router / Remix / TanStack Router | Use the framework's router unless reason not to. |
| Animation | Motion (formerly Framer Motion) | First-class React API; respects `prefers-reduced-motion`. |
| Icons | Lucide React | Tree-shakeable, accessible defaults. |
| Storybook | Storybook 8+ with the a11y addon | Standard. |
| Visual regression | Playwright | Snapshot-per-story. |

Other valid stacks (Chakra UI, Mantine, NextUI, Ariakit, Park UI) — fine choices. The patterns below apply regardless of library.

## Patterns in idiomatic React

### Button

```tsx
import { ButtonHTMLAttributes, forwardRef } from 'react';
import { cn } from '@/lib/cn';

type Variant = 'primary' | 'secondary' | 'destructive' | 'ghost';

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: Variant;
  loading?: boolean;
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'primary', loading, disabled, children, className, ...rest }, ref) => (
    <button
      ref={ref}
      disabled={disabled || loading}
      aria-busy={loading || undefined}
      className={cn(
        'inline-flex items-center justify-center min-h-[2.5rem] px-4 rounded-md',
        'focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent',
        'disabled:opacity-50 disabled:cursor-not-allowed',
        variant === 'primary' && 'bg-accent text-on-accent hover:bg-accent-hover',
        variant === 'secondary' && 'bg-surface-elevated text-text border border-border',
        variant === 'destructive' && 'bg-error text-on-error hover:bg-error-hover',
        variant === 'ghost' && 'bg-transparent text-text hover:bg-surface-elevated',
        className,
      )}
      {...rest}
    >
      {loading ? <Spinner aria-hidden /> : null}
      {children}
    </button>
  ),
);
Button.displayName = 'Button';
```

Notes:

- `<button>` (not `<div role="button">`).
- `aria-busy` while loading (don't disable mid-interaction silently).
- Focus styles explicit, with sufficient contrast.
- Min-height 2.5rem (40 px) — meets WCAG 2.5.8 target size with comfortable hit area.

### Form with inline + summary errors

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useRef } from 'react';

const Schema = z.object({
  email: z.string().email('Enter a valid email address.'),
  password: z.string().min(12, 'Use at least 12 characters.'),
});
type Values = z.infer<typeof Schema>;

export function SignUpForm({ onSubmit }: { onSubmit: (v: Values) => Promise<void> }) {
  const summaryRef = useRef<HTMLDivElement>(null);
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<Values>({ resolver: zodResolver(Schema), mode: 'onSubmit' });

  const errorEntries = Object.entries(errors);

  return (
    <form
      onSubmit={handleSubmit(onSubmit, () => {
        // Move focus to the error summary on invalid submit.
        summaryRef.current?.focus();
      })}
      noValidate
    >
      {errorEntries.length > 0 && (
        <div
          ref={summaryRef}
          tabIndex={-1}
          role="alert"
          aria-labelledby="error-summary-heading"
          className="border border-error bg-error/10 p-4 rounded-md mb-4"
        >
          <h2 id="error-summary-heading" className="font-bold mb-2">
            There {errorEntries.length === 1 ? 'is 1 problem' : `are ${errorEntries.length} problems`} with your submission
          </h2>
          <ul className="list-disc pl-5">
            {errorEntries.map(([name, error]) => (
              <li key={name}>
                <a href={`#${name}`} className="text-error underline">
                  {error?.message as string}
                </a>
              </li>
            ))}
          </ul>
        </div>
      )}

      <div className="mb-4">
        <label htmlFor="email" className="block font-medium">
          Email
        </label>
        <input
          id="email"
          type="email"
          autoComplete="username webauthn"
          aria-invalid={errors.email ? 'true' : undefined}
          aria-describedby={errors.email ? 'email-error' : undefined}
          {...register('email')}
        />
        {errors.email && (
          <p id="email-error" className="text-error mt-1">
            {errors.email.message}
          </p>
        )}
      </div>

      <div className="mb-4">
        <label htmlFor="password" className="block font-medium">
          Password
        </label>
        <input
          id="password"
          type="password"
          autoComplete="new-password"
          aria-invalid={errors.password ? 'true' : undefined}
          aria-describedby={errors.password ? 'password-error' : undefined}
          {...register('password')}
        />
        {errors.password && (
          <p id="password-error" className="text-error mt-1">
            {errors.password.message}
          </p>
        )}
      </div>

      <Button type="submit" loading={isSubmitting}>
        Create account
      </Button>
    </form>
  );
}
```

Notes:

- `mode: 'onSubmit'` — validate on submit, not on every keystroke.
- `autoComplete="username webauthn"` lets passkey conditional UI fire.
- `noValidate` — let our schema handle validation messaging, not the browser's defaults.
- Summary moves focus on invalid submit.
- Each field links to its error via `aria-describedby` and is marked `aria-invalid`.

### Data table (TanStack)

```tsx
import { useReactTable, getCoreRowModel, getSortedRowModel, flexRender, ColumnDef } from '@tanstack/react-table';
import { useState } from 'react';

type Row = { id: string; name: string; email: string; status: 'active' | 'invited' | 'disabled' };

const columns: ColumnDef<Row>[] = [
  { accessorKey: 'name', header: 'Name' },
  { accessorKey: 'email', header: 'Email' },
  { accessorKey: 'status', header: 'Status' },
];

export function UserTable({ data }: { data: Row[] }) {
  const [sorting, setSorting] = useState<{ id: string; desc: boolean }[]>([]);
  const table = useReactTable({
    data,
    columns,
    state: { sorting },
    onSortingChange: setSorting,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
  });

  return (
    <table>
      <caption className="sr-only">Users in your workspace</caption>
      <thead>
        {table.getHeaderGroups().map(group => (
          <tr key={group.id}>
            {group.headers.map(header => {
              const sort = header.column.getIsSorted();
              const ariaSort: 'none' | 'ascending' | 'descending' =
                sort === false ? 'none' : sort === 'asc' ? 'ascending' : 'descending';
              return (
                <th key={header.id} aria-sort={ariaSort} scope="col">
                  <button
                    type="button"
                    onClick={header.column.getToggleSortingHandler()}
                  >
                    {flexRender(header.column.columnDef.header, header.getContext())}
                  </button>
                </th>
              );
            })}
          </tr>
        ))}
      </thead>
      <tbody>
        {table.getRowModel().rows.map(row => (
          <tr key={row.id}>
            {row.getVisibleCells().map(cell => (
              <td key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

Notes:

- `<table>`, `<caption>` (visually hidden), `<thead>`, `<tbody>`, `<th scope="col">`.
- `aria-sort` on sortable headers; updates on click.
- Sort toggle is a `<button>` for keyboard.

### Dialog (Radix)

```tsx
import * as Dialog from '@radix-ui/react-dialog';

export function DeleteAccountDialog({ trigger }: { trigger: React.ReactNode }) {
  return (
    <Dialog.Root>
      <Dialog.Trigger asChild>{trigger}</Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 bg-black/50" />
        <Dialog.Content className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-surface p-6 rounded-md max-w-md">
          <Dialog.Title className="text-xl font-bold">Delete your account?</Dialog.Title>
          <Dialog.Description className="mt-2">
            This is permanent. All your data will be removed within 24 hours.
          </Dialog.Description>
          <div className="mt-6 flex justify-end gap-2">
            <Dialog.Close asChild>
              <Button variant="ghost">Cancel</Button>
            </Dialog.Close>
            <Button variant="destructive" onClick={() => {/* delete */}}>
              Delete account
            </Button>
          </div>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

Notes:

- Radix handles focus trap, Escape to close, focus restore on close, ARIA attributes.
- `Dialog.Title` and `Dialog.Description` are required for AT.
- Destructive button label says what it does ("Delete account"), not "OK".

### Loading feedback

Use the pattern that matches the wait shape (`domains/patterns.md`):

```tsx
// Skeleton (known structure, moderate wait)
<div className="space-y-2 animate-pulse">
  <div className="h-4 w-3/4 bg-surface-elevated rounded" />
  <div className="h-4 w-1/2 bg-surface-elevated rounded" />
</div>

// Spinner (short indeterminate)
<svg role="status" aria-label="Loading" className="animate-spin h-4 w-4">
  <circle ... />
</svg>

// Progress bar (known duration)
<div role="progressbar" aria-valuenow={current} aria-valuemin={0} aria-valuemax={total}>
  <div style={{ width: `${(current / total) * 100}%` }} />
</div>

// Message bar (persistent state)
<div role="status" className="bg-warn/10 border-l-4 border-warn p-4">
  <p>Read-only mode — your changes won't be saved.</p>
</div>
```

Animation pulse honors reduced motion via Tailwind's `motion-safe:` / `motion-reduce:` modifiers or your global CSS reset.

## Storybook story coverage

For every component, write stories covering these states:

```tsx
// Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = { component: Button };
export default meta;
type Story = StoryObj<typeof Button>;

export const Default: Story = { args: { children: 'Click me' } };
export const Primary: Story = { args: { variant: 'primary', children: 'Save changes' } };
export const Secondary: Story = { args: { variant: 'secondary', children: 'Cancel' } };
export const Destructive: Story = { args: { variant: 'destructive', children: 'Delete' } };
export const Loading: Story = { args: { loading: true, children: 'Saving...' } };
export const Disabled: Story = { args: { disabled: true, children: 'Disabled' } };
export const LongLabel: Story = { args: { children: 'A very long button label that wraps' } };
```

Stories drive visual regression and a11y testing. Each must be a state worth checking.

## Playwright visual regression setup

```ts
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  use: {
    baseURL: 'http://localhost:6006',  // Storybook
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile', use: { ...devices['Pixel 7'] } },
  ],
  expect: { toHaveScreenshot: { maxDiffPixels: 100 } },
});
```

```ts
// e2e/button.spec.ts
import { test, expect } from '@playwright/test';

test('Button — Default', async ({ page }) => {
  await page.goto('/iframe.html?id=button--default&viewMode=story');
  await expect(page).toHaveScreenshot('button-default.png');
});

test('Button — Hover', async ({ page }) => {
  await page.goto('/iframe.html?id=button--default&viewMode=story');
  await page.locator('button').hover();
  await expect(page).toHaveScreenshot('button-hover.png');
});

test('Button — Focus', async ({ page }) => {
  await page.goto('/iframe.html?id=button--default&viewMode=story');
  await page.locator('button').focus();
  await expect(page).toHaveScreenshot('button-focus.png');
});
```

Run via `npm run storybook` + `npx playwright test`.

## Tokens via CSS variables

```css
/* tokens.css */
:root {
  --color-surface: 255 255 255;
  --color-surface-elevated: 245 245 247;
  --color-text: 10 10 10;
  --color-text-secondary: 82 82 82;
  --color-accent: 79 70 229;
  --color-on-accent: 255 255 255;
  --color-error: 220 38 38;
  --color-on-error: 255 255 255;
  --color-border: 229 229 229;

  --space-100: 4px;
  --space-200: 8px;
  --space-300: 12px;
  --space-400: 16px;
  --space-500: 24px;
  --space-600: 32px;

  --duration-fast: 150ms;
  --duration-medium: 250ms;
  --duration-slow: 400ms;

  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-pill: 9999px;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-surface: 10 10 10;
    --color-surface-elevated: 23 23 23;
    --color-text: 250 250 250;
    /* ... */
  }
}

@media (prefers-reduced-motion: reduce) {
  :root {
    --duration-fast: 0ms;
    --duration-medium: 0ms;
    --duration-slow: 0ms;
  }
}
```

Tailwind config references these via:

```js
// tailwind.config.ts
theme: {
  extend: {
    colors: {
      surface: 'rgb(var(--color-surface) / <alpha-value>)',
      'surface-elevated': 'rgb(var(--color-surface-elevated) / <alpha-value>)',
      text: 'rgb(var(--color-text) / <alpha-value>)',
      // ...
    },
    spacing: {
      100: 'var(--space-100)',
      200: 'var(--space-200)',
      // ...
    },
    transitionDuration: {
      fast: 'var(--duration-fast)',
      medium: 'var(--duration-medium)',
      slow: 'var(--duration-slow)',
    },
  },
},
```

This puts every visual decision behind a token. `frontend-design` fills the *values* during handoff; component code is unaffected.

## Next.js / Remix / Gatsby specifics

### Next.js (App Router)

- Use server components for non-interactive content. Less JS shipped.
- Route handlers live in `app/<route>/route.ts`; pages in `app/<route>/page.tsx`.
- `loading.tsx` per route segment is the natural place for skeletons.
- `error.tsx` per route segment for error boundaries.
- Image component (`next/image`) handles aspect ratio reservation, which is critical for CLS.
- Font optimization (`next/font`) prevents font-loading layout shift.

### Remix

- Loaders run on the server; data is passed to components without client-side fetching.
- Forms use the native `<form>` posting to actions; progressive enhancement for free.
- Resource routes for non-HTML responses.
- `ErrorBoundary` and `CatchBoundary` per route.

### Gatsby

- Mostly static-generation. CWV-friendly out of the box if assets are managed well.
- Image plugin handles aspect-ratio reservation.

## Common React UX anti-patterns

- **`<div onClick={...}>`** — no keyboard, no focus, no role. Use `<button>`.
- **`<a onClick={preventDefault}>`** — link with no `href` is not a link. Use `<button>`.
- **State left over from mounting** — modal that didn't trap focus or restore it on close.
- **Hydration mismatch** — server and client render differently → flash of wrong content + AT confusion.
- **`autoFocus` on a sign-in form's first field** — moves focus before the user can read the page heading.
- **`useState` for form values when the form is more than three fields** — use React Hook Form or similar.
- **Custom select component** — use `<select>` unless you have a research-grade reason. APG combobox if you must.
- **`tabIndex={1}` to "control focus order"** — never. Order the DOM correctly.
- **Animations using `Motion` without honoring `prefers-reduced-motion`** — Motion provides hooks; use them.
- **Storybook stories that only render the default state** — useless for regression and a11y testing.

## Bibliography

- "React" — react.dev.
- "Next.js App Router" — nextjs.org.
- "Remix" — remix.run.
- Radix Primitives documentation.
- shadcn/ui documentation.
- TanStack Table v8 documentation.
- React Hook Form documentation.
- Storybook 8 documentation.
- Playwright documentation.
- Tailwind CSS documentation.
