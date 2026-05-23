# Stack — server-rendered (Hotwire / LiveView / htmx / Unpoly / Django / Laravel)

Skeleton. Server-rendered apps render HTML on the server and progressively enhance with small JS layers (Stimulus for Hotwire, LiveView's morphdom for Phoenix, htmx attributes, Unpoly, Alpine.js). Patterns map to `stacks/vanilla.md`'s semantic baselines.

## When server-rendered is the right choice

- Teams with strong server-side traditions (Rails, Django, Laravel, Phoenix).
- Apps where most surfaces are CRUD with limited rich interactivity.
- Teams who don't want a separate frontend build pipeline.
- Applications where SEO and CWV are paramount and the team can ship server-rendered HTML without hydration cost.

When the app is heavily interactive (real-time collaborative editing, complex client-state), a JS framework may be better suited. Server-rendered is excellent for the 80% of products that are forms + tables + dashboards.

## Common variants

| Variant | Server framework | JS layer |
|---|---|---|
| Rails Hotwire | Ruby on Rails | Turbo + Stimulus |
| Phoenix LiveView | Phoenix (Elixir) | Server-driven via WebSocket; minimal client JS |
| htmx | Any (Python, Ruby, PHP, Go) | htmx attributes + Hyperscript or Alpine.js |
| Unpoly | Any | Unpoly's progressive enhancement layer |
| Django + HTMX | Django | htmx attributes |
| Laravel + Livewire | Laravel | Livewire's reactivity layer |

## Patterns

### Button

Same as `stacks/vanilla.md`. Server templates emit `<button>` with class names. No framework-specific magic needed.

### Form

Native `<form action method>` with server-side validation. Render errors inline + summary on the response. Hotwire / LiveView / htmx can swap the response into the page without a full reload, but the underlying mechanism is the same form post.

```erb
<%# Rails example %>
<%= form_with model: @user, local: true do |f| %>
  <% if @user.errors.any? %>
    <div tabindex="-1" role="alert" id="error-summary" autofocus>
      <h2><%= pluralize(@user.errors.count, 'problem') %> with your submission</h2>
      <ul>
        <% @user.errors.each do |error| %>
          <li><a href="#<%= error.attribute %>"><%= error.full_message %></a></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <%= f.label :email %>
  <%= f.email_field :email,
      autocomplete: 'username webauthn',
      required: true,
      'aria-describedby': @user.errors[:email].any? ? 'email-error' : nil,
      'aria-invalid': @user.errors[:email].any? ? 'true' : nil %>
  <% if @user.errors[:email].any? %>
    <p id="email-error" class="error"><%= @user.errors[:email].first %></p>
  <% end %>

  <%= f.submit 'Create account' %>
<% end %>
```

The `autofocus` on the error summary moves keyboard focus on render. Same pattern works in Django, Laravel, Phoenix templates.

### Live updates (Hotwire / LiveView)

Hotwire Streams and LiveView pushes update specific DOM regions. Make sure live updates respect:

- **Focus management.** If the user is typing in a form, don't yank their focus.
- **Status announcements.** Use `aria-live` regions for changes the user should know about. LiveView provides `Phoenix.LiveView.JS` helpers for this.
- **Reduced motion.** Server-driven animations should honor `prefers-reduced-motion`.

### Data table

Native `<table>` with sortable headers. Hotwire / LiveView / htmx can re-sort via server roundtrip without full page reload, but the underlying HTML is `<table>` with `aria-sort` attributes.

### Dialog

`<dialog>` element + small JS layer to open / close. Hotwire's `turbo-frame` or htmx's `hx-get` into a `<dialog>` is the common pattern.

## Hydration / progressive enhancement discipline

- The page must work without JS. JS enhances; it does not enable.
- The form must submit and validate without JS. JS makes it feel faster.
- The table must render and be navigable without JS. JS makes sort interactive.
- The dialog must be accessible (or replaced with a navigation to a real page) if JS fails.

This is genuinely how Hotwire, LiveView, htmx, and Unpoly are designed. Use the design.

## Tokens and accessibility

CSS variables identical to `stacks/vanilla.md`. Server-rendered output should not affect the styling layer.

## Testing

- **System tests / integration tests** in the server framework's idiom (Rails system tests, Django LiveServerTestCase, Phoenix's `LiveViewTest`, Laravel's Dusk). These exercise the server-rendered HTML in a real browser.
- **Pa11y / axe-cli** against rendered pages — works the same as for vanilla.
- **Playwright** for end-to-end and visual regression.

## Status of this skeleton

Expand as the skill is exercised on real Hotwire / LiveView / htmx projects. **Fall back to `stacks/vanilla.md` for semantic baselines.**

## Bibliography

- Hotwire documentation (hotwired.dev).
- Phoenix LiveView documentation.
- htmx documentation (htmx.org).
- Unpoly documentation (unpoly.com).
- Alpine.js documentation.
- Laravel Livewire documentation.
