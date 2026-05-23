#!/usr/bin/env bash
# run_audit.sh — collect axe + Lighthouse + Pa11y evidence for an audit.
# Usage:
#   run_audit.sh --url http://localhost:3000
#   run_audit.sh --build "npm run build" --serve
#   run_audit.sh --url https://example.com --pages /,/sign-in,/dashboard
#
# Always exits 0; the agent reads the JSON and authors the report.

set -uo pipefail

URL=""
BUILD_CMD=""
SERVE=0
PAGES_CSV="/"
OUT_DIR=".frontend-ux/audit"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) URL="$2"; shift 2 ;;
    --build) BUILD_CMD="$2"; shift 2 ;;
    --serve) SERVE=1; shift ;;
    --pages) PAGES_CSV="$2"; shift 2 ;;
    --out) OUT_DIR="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

mkdir -p "$OUT_DIR"

# 1. Build if requested
if [[ -n "$BUILD_CMD" ]]; then
  echo ">> Building: $BUILD_CMD"
  eval "$BUILD_CMD" || echo "WARN: build command exited non-zero; continuing"
fi

# 2. Serve if requested
SERVE_PID=""
cleanup() {
  if [[ -n "$SERVE_PID" ]]; then
    kill "$SERVE_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

if [[ "$SERVE" -eq 1 ]]; then
  echo ">> Serving build on http://localhost:3000"
  if command -v npx >/dev/null 2>&1; then
    npx --yes serve -l 3000 dist 2>/dev/null &
    SERVE_PID=$!
    sleep 5
    URL="${URL:-http://localhost:3000}"
  else
    echo "WARN: npx not available; cannot --serve" >&2
  fi
fi

if [[ -z "$URL" ]]; then
  echo "ERR: no URL provided. Use --url <url> or --build <cmd> --serve" >&2
  exit 0
fi

# Convert comma-separated paths to URL list
IFS=',' read -ra PATHS <<< "$PAGES_CSV"
URL_LIST=()
for p in "${PATHS[@]}"; do
  if [[ "$p" =~ ^https?:// ]]; then
    URL_LIST+=("$p")
  else
    # Trim trailing slash on URL, leading slash on path duplicated
    base="${URL%/}"
    path="/${p#/}"
    URL_LIST+=("${base}${path}")
  fi
done

echo ">> Audit URL list: ${URL_LIST[*]}"

# 3. axe-core CLI
if command -v npx >/dev/null 2>&1; then
  echo ">> Running axe-core/cli"
  npx --yes @axe-core/cli "${URL_LIST[@]}" \
    --tags wcag2a,wcag2aa,wcag22aa \
    --save "$OUT_DIR/axe.json" 2>"$OUT_DIR/axe.log" || \
    echo "axe-core/cli completed with findings (see $OUT_DIR/axe.json)"
else
  echo "WARN: npx not available; skipping axe-core" > "$OUT_DIR/axe.log"
fi

# 4. Lighthouse — mobile and desktop
if command -v npx >/dev/null 2>&1; then
  for url in "${URL_LIST[@]}"; do
    safe_name=$(echo "$url" | sed 's|https*://||; s|/|_|g; s|[^A-Za-z0-9_-]|_|g')
    for profile in mobile desktop; do
      echo ">> Lighthouse $profile: $url"
      npx --yes lighthouse "$url" \
        --preset="$profile" \
        --output=json \
        --output-path="$OUT_DIR/lighthouse-${profile}-${safe_name}.json" \
        --quiet \
        --chrome-flags="--headless --no-sandbox" 2>>"$OUT_DIR/lighthouse.log" || \
        echo "lighthouse $profile completed with findings"
    done
  done
else
  echo "WARN: npx not available; skipping Lighthouse" >> "$OUT_DIR/lighthouse.log"
fi

# 5. Pa11y — optional, only if installed
if command -v pa11y >/dev/null 2>&1; then
  echo ">> Running Pa11y"
  > "$OUT_DIR/pa11y.json"
  echo "[" >> "$OUT_DIR/pa11y.json"
  first=1
  for url in "${URL_LIST[@]}"; do
    [[ "$first" -eq 0 ]] && echo "," >> "$OUT_DIR/pa11y.json"
    pa11y "$url" --reporter json >> "$OUT_DIR/pa11y.json" 2>"$OUT_DIR/pa11y.log" || true
    first=0
  done
  echo "]" >> "$OUT_DIR/pa11y.json"
else
  echo "Pa11y not installed; skipping (install: npm install -g pa11y)" > "$OUT_DIR/pa11y.log"
fi

# 6. Concise summary
echo ""
echo "=== Audit summary ==="
echo "Output directory: $OUT_DIR"
echo ""
if [[ -f "$OUT_DIR/axe.json" ]]; then
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PYEOF'
import json, os, sys
out = os.environ.get("OUT_DIR", ".frontend-ux/audit")
path = os.path.join(out, "axe.json")
try:
    with open(path) as f: data = json.load(f)
except Exception as e:
    print(f"axe.json: cannot parse ({e})"); sys.exit(0)
if isinstance(data, dict):
    data = [data]
counts = {"critical": 0, "serious": 0, "moderate": 0, "minor": 0}
for run in data:
    for v in run.get("violations", []):
        impact = v.get("impact", "minor")
        counts[impact] = counts.get(impact, 0) + len(v.get("nodes", []))
print("axe-core: " + ", ".join(f"{k}={v}" for k, v in counts.items()))
PYEOF
  fi
fi
echo "Lighthouse outputs: $(ls "$OUT_DIR"/lighthouse-*.json 2>/dev/null | wc -l) file(s)"
echo "Pa11y output: $([[ -f "$OUT_DIR/pa11y.json" ]] && echo "present" || echo "skipped")"
echo ""
echo "Read the JSON files to author findings. Cite specific rule ids and measured values."

exit 0
