# Stack — vanilla HTML / CSS / JS

The semantic baseline. Every other stack reference's idiomatic implementation should preserve the patterns shown here. When a stack reference is a skeleton, fall back to this.

## Why a vanilla baseline matters

Frameworks abstract HTML. Sometimes well, sometimes badly. Knowing what the framework should produce — at the level of HTML elements, ARIA, and keyboard behavior — is the only way to verify the framework is doing its job.

Vanilla HTML+CSS+JS is also genuinely the right stack for many use cases: marketing pages, documentation sites, simple CRUD admin tools, anything that doesn't need rich client-side state management. Don't add a framework for ceremony.

## Patterns in semantic HTML

### Button

```html
<button type="button" class="btn btn-primary">
  Save changes
</button>

<button type="submit" class="btn btn-primary" aria-busy="true">
  <span class="spinner" aria-hidden="true"></span>
  Saving…
</button>
```

```css
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 2.5rem;        /* WCAG 2.5.8: target size at least 24x24 CSS px; 40px is comfortable */
  padding: 0 var(--space-400);
  border-radius: var(--radius-md);
  border: 1px solid transparent;
  font: inherit;
  cursor: pointer;
}

.btn:focus-visible {
  outline: 2px solid var(--color-accent);
  outline-offset: 2px;
}

.btn[aria-busy="true"] { opacity: 0.7; pointer-events: none; }
.btn[disabled] { opacity: 0.5; cursor: not-allowed; }

.btn-primary {
  background: rgb(var(--color-accent));
  color: rgb(var(--color-on-accent));
}
.btn-primary:hover:not([disabled]) { background: rgb(var(--color-accent-hover)); }
```

### Form with inline + summary errors

```html
<form action="/sign-up" method="POST" novalidate>
  <div id="error-summary" tabindex="-1" hidden role="alert" aria-labelledby="error-summary-heading">
    <h2 id="error-summary-heading">There are problems with your submission</h2>
    <ul></ul>
  </div>

  <div class="field">
    <label for="email">Email</label>
    <input
      type="email"
      id="email"
      name="email"
      autocomplete="username webauthn"
      required
      aria-describedby="email-error"
    >
    <p id="email-error" class="error" hidden></p>
  </div>

  <div class="field">
    <label for="password">Password</label>
    <input
      type="password"
      id="password"
      name="password"
      autocomplete="new-password"
      minlength="12"
      required
      aria-describedby="password-error"
    >
    <p id="password-error" class="error" hidden></p>
  </div>

  <button type="submit" class="btn btn-primary">Create account</button>
</form>

<script>
  const form = document.querySelector('form');
  const summary = document.getElementById('error-summary');

  form.addEventListener('submit', (e) => {
    const errors = [];
    summary.querySelector('ul').replaceChildren();

    form.querySelectorAll('input').forEach(input => {
      const errorEl = document.getElementById(`${input.id}-error`);
      if (!input.checkValidity()) {
        const message = input.validationMessage || `Please correct ${input.name}`;
        errorEl.textContent = message;
        errorEl.hidden = false;
        input.setAttribute('aria-invalid', 'true');
        errors.push({ id: input.id, name: input.name, message });
      } else {
        errorEl.hidden = true;
        input.removeAttribute('aria-invalid');
      }
    });

    if (errors.length > 0) {
      e.preventDefault();
      const ul = summary.querySelector('ul');
      errors.forEach(err => {
        const li = document.createElement('li');
        const a = document.createElement('a');
        a.href = `#${err.id}`;
        a.textContent = err.message;
        li.appendChild(a);
        ul.appendChild(li);
      });
      summary.hidden = false;
      summary.focus();
    } else {
      summary.hidden = true;
    }
  });
</script>
```

Notes:

- Browser's native `required` and `minlength` validate; `novalidate` lets us control messaging.
- `autocomplete="username webauthn"` enables passkey conditional UI.
- Summary moves focus on invalid submit; each error links to its field via anchor.

### Sortable data table

```html
<table>
  <caption class="visually-hidden">Users in workspace</caption>
  <thead>
    <tr>
      <th scope="col" aria-sort="ascending">
        <button type="button" data-sort="name">Name ▲</button>
      </th>
      <th scope="col" aria-sort="none">
        <button type="button" data-sort="email">Email</button>
      </th>
      <th scope="col" aria-sort="none">
        <button type="button" data-sort="status">Status</button>
      </th>
    </tr>
  </thead>
  <tbody>
    <tr><td>Alice</td><td>alice@example.com</td><td>Active</td></tr>
    <tr><td>Bob</td><td>bob@example.com</td><td>Invited</td></tr>
  </tbody>
</table>
```

`aria-sort` updates on click. The button-inside-th pattern keeps clicks keyboard-accessible.

### Dialog

```html
<button type="button" id="open-delete">Delete account</button>

<dialog id="delete-dialog" aria-labelledby="delete-title" aria-describedby="delete-desc">
  <h2 id="delete-title">Delete your account?</h2>
  <p id="delete-desc">This is permanent. All your data will be removed within 24 hours.</p>
  <div class="dialog-actions">
    <button type="button" data-close>Cancel</button>
    <button type="button" class="btn btn-destructive" data-confirm>Delete account</button>
  </div>
</dialog>

<script>
  const dialog = document.getElementById('delete-dialog');
  const opener = document.getElementById('open-delete');

  opener.addEventListener('click', () => {
    dialog.showModal();
  });

  dialog.addEventListener('click', (e) => {
    const target = e.target;
    if (target instanceof HTMLElement) {
      if (target.matches('[data-close]')) dialog.close();
      if (target.matches('[data-confirm]')) {
        // perform delete
        dialog.close();
      }
    }
  });
</script>
```

The HTML `<dialog>` element provides:

- Focus trap.
- Escape to close.
- Focus restore on close.
- `role="dialog"` and modal behavior.
- `::backdrop` pseudo-element for overlay styling.

For older browsers (rare in 2026), polyfill with `dialog-polyfill`.

### Loading feedback

```html
<!-- Skeleton -->
<div class="skeleton" aria-hidden="true">
  <div class="skeleton-line" style="width: 75%"></div>
  <div class="skeleton-line" style="width: 50%"></div>
</div>

<!-- Spinner with status announcement -->
<div role="status" class="spinner-wrap">
  <span class="spinner" aria-hidden="true"></span>
  <span class="visually-hidden">Loading</span>
</div>

<!-- Progress bar -->
<div role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" aria-label="Upload progress">
  <div class="progress-fill" style="width: 40%"></div>
</div>

<!-- Message bar -->
<div role="status" class="banner banner-warn">
  <p>Read-only mode — your changes won't be saved.</p>
</div>
```

```css
.skeleton-line {
  height: 1rem;
  background: var(--color-surface-elevated);
  border-radius: var(--radius-sm);
  animation: pulse 1.4s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 0.6; }
  50% { opacity: 1; }
}

@media (prefers-reduced-motion: reduce) {
  .skeleton-line { animation: none; }
}

.visually-hidden {
  position: absolute !important;
  width: 1px; height: 1px;
  margin: -1px; padding: 0; border: 0;
  clip: rect(0 0 0 0); clip-path: inset(50%);
  overflow: hidden; white-space: nowrap;
}
```

## Tokens via CSS variables

```css
:root {
  --color-surface: 255 255 255;
  --color-surface-elevated: 245 245 247;
  --color-text: 10 10 10;
  --color-text-secondary: 82 82 82;
  --color-accent: 79 70 229;
  --color-on-accent: 255 255 255;
  --color-error: 220 38 38;
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
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-surface: 10 10 10;
    --color-text: 250 250 250;
    --color-surface-elevated: 23 23 23;
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

Same structure as `stacks/react.md`'s tokens. Components reference via `rgb(var(--color-text))`, `var(--space-400)`, `var(--duration-medium)`.

## Testing harness

For vanilla, the harness is:

- **Pa11y** — runs axe + HTML CodeSniffer against URLs. Drop in CI as a Node script.
- **axe-core/cli** — the same axe rules used by every other tool, accessible from the command line.
- **Playwright** — for visual regression and end-to-end (Playwright works fine without a framework).
- **Browser native** — DevTools Lighthouse for one-shot audits.

```bash
# package.json
{
  "scripts": {
    "test:a11y": "pa11y http://localhost:3000/ http://localhost:3000/sign-up",
    "test:visual": "playwright test",
    "test:lighthouse": "lhci autorun --collect.url=http://localhost:3000/"
  }
}
```

Component-level isolation: vanilla doesn't have Storybook (Storybook requires a JS framework, mostly). Substitutes:

- Static HTML pages per component, viewed directly in a browser.
- A simple "component gallery" route that renders each component in each state.
- Pa11y can run against these gallery pages directly.

## File organization

For a small to medium vanilla project:

```
project/
├── public/
│   ├── index.html
│   ├── styles/
│   │   ├── tokens.css
│   │   ├── reset.css
│   │   ├── components/
│   │   │   ├── button.css
│   │   │   ├── form.css
│   │   │   └── dialog.css
│   │   └── main.css
│   ├── scripts/
│   │   ├── form-validation.js
│   │   └── dialog.js
│   └── images/
└── tests/
    ├── visual/
    └── e2e/
```

Larger vanilla projects benefit from a build step (PostCSS, esbuild) to bundle CSS modules and ES modules. The HTML stays the source of truth; tooling concatenates and minifies.

## Common vanilla anti-patterns

- **`<a href="#" onclick="...">`** — link to nowhere with click handler. Use `<button>`.
- **`<div>` with click handler** — no keyboard, no focus. Use `<button>`.
- **Custom modal without `<dialog>`** — reinvents focus trap and restore. Use the native element.
- **`alert()` for status** — disrupts focus, blocks the page. Use `role="status"` or `role="alert"`.
- **Inline `style="color: red"` for errors** — no semantic meaning, no theme support. Use a class with token reference.
- **No reduced-motion handling** — animations run for users who explicitly preferred them off.
- **Hand-rolled validation messages** — when `input.validationMessage` is available with localized defaults.
- **`tabindex="0"` on every clickable thing** — use `<button>`; you get tabbing for free.

## Bibliography

- HTML Living Standard — WHATWG.
- "Modern CSS" — moderncss.dev (Stephanie Eckles).
- "Web Components" — webcomponents.org for native component encapsulation when needed.
- "ARIA in HTML" — W3C.
- Pa11y documentation.
- "Inclusive Components" / Heydon Pickering.
