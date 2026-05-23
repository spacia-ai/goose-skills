# Stack — Angular (skeleton)

Skeleton. Patterns map to `stacks/vanilla.md`'s semantic baselines, expressed in modern Angular (signals, standalone components, control flow syntax).

## Library choices

| Concern | Recommended |
|---|---|
| Component primitives | Angular CDK (a11y, overlay, etc.), spartan/ng (Angular shadcn), Ariakit (some adapters) |
| Component library | Angular Material (with theming discipline), spartan/ng |
| Forms | Reactive Forms with Zod-like validators |
| Tables | Angular CDK Table |
| Animation | Angular Animations API (respect `prefers-reduced-motion`) |
| Storybook | Storybook 8 with Angular framework |
| Visual regression | Playwright |

## Patterns

Standalone components with signals; semantic HTML at the template level.

```typescript
// button.component.ts
import { Component, input } from '@angular/core';

@Component({
  selector: 'app-button',
  standalone: true,
  template: `
    <button
      [disabled]="disabled() || loading()"
      [attr.aria-busy]="loading() || null"
      class="btn"
      [class]="['btn-' + (variant() ?? 'primary')]"
    >
      @if (loading()) {
        <span class="spinner" aria-hidden="true"></span>
      }
      <ng-content />
    </button>
  `,
})
export class ButtonComponent {
  variant = input<'primary' | 'secondary' | 'destructive' | 'ghost'>('primary');
  loading = input<boolean>(false);
  disabled = input<boolean>(false);
}
```

For dialogs, use Angular CDK's `@angular/cdk/dialog` — it handles focus trap and restore. For tables, `@angular/cdk/table` provides accessible primitives without Material's heavy theming.

## Tokens and accessibility

CSS variables and accessibility patterns identical to `stacks/vanilla.md`. Angular Material's theming is powerful but encourages a specific aesthetic; if you want a bespoke design system, use CDK + your own tokens.

## Status of this skeleton

Expand as the skill is exercised on real Angular projects. **Fall back to `stacks/vanilla.md` for semantic baselines.**

## Bibliography

- Angular documentation (angular.dev).
- Angular CDK documentation.
- spartan/ng documentation.
- Storybook for Angular documentation.
