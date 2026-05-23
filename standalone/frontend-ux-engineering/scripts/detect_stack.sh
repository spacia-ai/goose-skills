#!/usr/bin/env bash
# detect_stack.sh — inspect a project root and print one stack id.
# Output is one of:
#   react | vue | svelte | angular | solid | astro | server-rendered | vanilla | unknown
# Caches result to .frontend-ux/stack unless --force is passed.

set -euo pipefail

ROOT="${1:-.}"
FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
  ROOT="${2:-.}"
fi

CACHE="$ROOT/.frontend-ux/stack"

if [[ "$FORCE" -eq 0 && -f "$CACHE" ]]; then
  cat "$CACHE"
  exit 0
fi

cd "$ROOT"

detect() {
  # 1. package.json — explicit framework dependency
  if [[ -f package.json ]]; then
    local pkg
    pkg=$(cat package.json)

    # Order matters: meta-frameworks before the underlying runtime.
    if grep -qE '"(astro)"' <<<"$pkg"; then echo "astro"; return; fi
    if grep -qE '"(@nuxt/kit|nuxt)"' <<<"$pkg"; then echo "vue"; return; fi
    if grep -qE '"(@sveltejs/kit|svelte)"' <<<"$pkg"; then echo "svelte"; return; fi
    if grep -qE '"(next|gatsby|@remix-run/[a-z-]+)"' <<<"$pkg"; then echo "react"; return; fi
    if grep -qE '"@angular/core"' <<<"$pkg"; then echo "angular"; return; fi
    if grep -qE '"solid-js"' <<<"$pkg"; then echo "solid"; return; fi
    if grep -qE '"@builder.io/qwik"' <<<"$pkg"; then echo "solid"; return; fi  # closest skeleton
    if grep -qE '"vue"' <<<"$pkg"; then echo "vue"; return; fi
    if grep -qE '"react"' <<<"$pkg"; then echo "react"; return; fi
    if grep -qE '"lit"' <<<"$pkg"; then echo "vanilla"; return; fi
  fi

  # 2. Root config files
  if [[ -f astro.config.mjs || -f astro.config.ts || -f astro.config.js ]]; then echo "astro"; return; fi
  if [[ -f nuxt.config.ts || -f nuxt.config.js ]]; then echo "vue"; return; fi
  if [[ -f svelte.config.js || -f svelte.config.ts ]]; then echo "svelte"; return; fi
  if [[ -f next.config.js || -f next.config.mjs || -f next.config.ts ]]; then echo "react"; return; fi
  if [[ -f remix.config.js || -f remix.config.ts ]]; then echo "react"; return; fi
  if [[ -f angular.json ]]; then echo "angular"; return; fi

  # 3. Server-rendered ecosystems
  if [[ -f Gemfile ]] && grep -qE '(stimulus|turbo)' Gemfile 2>/dev/null; then echo "server-rendered"; return; fi
  if [[ -f mix.exs ]] && grep -qE '(phoenix|phoenix_live_view)' mix.exs 2>/dev/null; then echo "server-rendered"; return; fi
  if [[ -f composer.json ]] && grep -qE 'laravel/framework' composer.json 2>/dev/null; then echo "server-rendered"; return; fi
  if [[ -f manage.py ]] || (ls -- *.py 2>/dev/null | head -1 >/dev/null && [[ -f requirements.txt || -f pyproject.toml ]]); then
    if (grep -qE '(django|flask|jinja)' requirements.txt 2>/dev/null) || \
       (grep -qE '(django|flask|jinja)' pyproject.toml 2>/dev/null); then
      echo "server-rendered"; return
    fi
  fi
  # htmx detection — search for hx-* attributes in source
  if grep -rqE 'hx-(get|post|put|delete|target|swap|trigger)' --include='*.html' --include='*.erb' --include='*.jinja' --include='*.j2' --include='*.blade.php' --include='*.heex' --include='*.tmpl' . 2>/dev/null | head -1 >/dev/null; then
    echo "server-rendered"; return
  fi

  # 4. Vanilla — root .html files, no framework
  if compgen -G "*.html" >/dev/null 2>&1 || [[ -d public && -f public/index.html ]]; then
    echo "vanilla"; return
  fi

  echo "unknown"
}

result=$(detect)

mkdir -p "$(dirname "$CACHE")"
echo "$result" > "$CACHE"
echo "$result"
