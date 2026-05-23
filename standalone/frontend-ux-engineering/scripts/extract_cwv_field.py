#!/usr/bin/env python3
"""extract_cwv_field.py — fetch field Core Web Vitals data.

Two modes:

  CrUX API (default):
    extract_cwv_field.py --crux <origin-or-url>
    Requires CRUX_API_KEY in environment. Returns p75 LCP/INP/CLS over the
    last 28 days for the given origin or specific URL.

  RUM JSON aggregation:
    extract_cwv_field.py --rum <directory>
    Reads RUM JSON event files (one per session or per page view), aggregates
    p75 per metric per route. Expected event shape:
      {"route": "/", "lcp": 1850, "inp": 120, "cls": 0.04, ...}

Output:
    Markdown table to stdout (suitable to paste into the audit report).
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error
from pathlib import Path
from collections import defaultdict


CRUX_ENDPOINT = "https://chromeuxreport.googleapis.com/v1/records:queryRecord"
DEFAULT_FORM_FACTOR = "PHONE"


def query_crux(target: str, api_key: str, form_factor: str = DEFAULT_FORM_FACTOR) -> dict:
    payload: dict = {"formFactor": form_factor}
    if target.startswith(("http://", "https://")):
        payload["url"] = target
    else:
        # treat as origin
        if "://" not in target:
            target = "https://" + target
        payload["origin"] = target

    body = json.dumps(payload).encode("utf-8")
    url = f"{CRUX_ENDPOINT}?key={api_key}"
    req = urllib.request.Request(
        url,
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        print(f"err: CrUX API HTTP {e.code}: {e.read().decode('utf-8', errors='replace')}", file=sys.stderr)
        sys.exit(1)


def percentile(values: list[float], p: float) -> float | None:
    if not values:
        return None
    s = sorted(values)
    k = (len(s) - 1) * p
    f = int(k)
    c = min(f + 1, len(s) - 1)
    if f == c:
        return s[f]
    return s[f] + (s[c] - s[f]) * (k - f)


def aggregate_rum(directory: Path) -> dict:
    """Aggregate RUM events into p75 per route per metric."""
    events_by_route: dict[str, dict[str, list[float]]] = defaultdict(
        lambda: defaultdict(list)
    )

    for path in directory.rglob("*.json"):
        try:
            with path.open("r", encoding="utf-8") as f:
                data = json.load(f)
        except (OSError, json.JSONDecodeError):
            continue

        events = data if isinstance(data, list) else [data]
        for ev in events:
            if not isinstance(ev, dict):
                continue
            route = ev.get("route", "/")
            for metric in ("lcp", "inp", "cls"):
                v = ev.get(metric)
                if isinstance(v, (int, float)):
                    events_by_route[route][metric].append(float(v))

    aggregated = {}
    for route, by_metric in events_by_route.items():
        aggregated[route] = {
            metric: {
                "p75": percentile(values, 0.75),
                "n": len(values),
            }
            for metric, values in by_metric.items()
        }
    return aggregated


def render_crux_table(target: str, response: dict) -> str:
    record = response.get("record", {})
    metrics = record.get("metrics", {})
    out = []
    out.append(f"## Field Core Web Vitals — `{target}`\n")
    out.append("Source: CrUX API (last 28 days, mobile)\n")
    out.append("| Metric | p75 | Target | Pass |")
    out.append("|---|---|---|---|")

    targets = {
        "largest_contentful_paint": ("LCP", 2500, "ms"),
        "interaction_to_next_paint": ("INP", 200, "ms"),
        "cumulative_layout_shift": ("CLS", 100, ""),  # CrUX returns *100 scaled
    }
    for key, (label, threshold, unit) in targets.items():
        m = metrics.get(key)
        if m is None or "percentiles" not in m:
            out.append(f"| {label} | — | ≤ {threshold}{unit} | n/a |")
            continue
        p75 = m["percentiles"].get("p75")
        if p75 is None:
            out.append(f"| {label} | — | ≤ {threshold}{unit} | n/a |")
            continue
        if key == "cumulative_layout_shift":
            display = f"{p75 / 100:.2f}"
            actual = p75 / 100
            target_display = f"≤ {threshold / 1000:.2f}"  # 0.10
            ok = actual <= threshold / 1000
        else:
            display = f"{p75}{unit}"
            actual = p75
            target_display = f"≤ {threshold}{unit}"
            ok = actual <= threshold
        out.append(f"| {label} | {display} | {target_display} | {'✓' if ok else '✗'} |")

    return "\n".join(out)


def render_rum_table(aggregated: dict) -> str:
    out = []
    out.append("## Field Core Web Vitals — RUM\n")
    out.append("| Route | LCP p75 | INP p75 | CLS p75 | Sample n |")
    out.append("|---|---|---|---|---|")
    for route in sorted(aggregated):
        m = aggregated[route]
        lcp = m.get("lcp", {})
        inp = m.get("inp", {})
        cls = m.get("cls", {})
        n = max(lcp.get("n", 0), inp.get("n", 0), cls.get("n", 0))
        out.append(
            f"| `{route}` | "
            f"{lcp.get('p75', '—'):.0f} ms | "
            f"{inp.get('p75', '—'):.0f} ms | "
            f"{cls.get('p75', '—'):.3f} | "
            f"{n} |"
        )
    return "\n".join(out)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--crux", metavar="ORIGIN_OR_URL", help="Query CrUX API for this origin or URL")
    group.add_argument("--rum", metavar="DIR", type=Path, help="Aggregate RUM JSON events from this directory")
    parser.add_argument(
        "--form-factor",
        default=DEFAULT_FORM_FACTOR,
        choices=("PHONE", "DESKTOP", "TABLET", "ALL_FORM_FACTORS"),
        help="CrUX form factor (default: PHONE)",
    )
    args = parser.parse_args()

    if args.crux:
        api_key = os.environ.get("CRUX_API_KEY")
        if not api_key:
            print("err: CRUX_API_KEY not set in environment", file=sys.stderr)
            return 2
        response = query_crux(args.crux, api_key, args.form_factor)
        print(render_crux_table(args.crux, response))
        return 0

    if args.rum:
        if not args.rum.is_dir():
            print(f"err: {args.rum} is not a directory", file=sys.stderr)
            return 2
        aggregated = aggregate_rum(args.rum)
        if not aggregated:
            print("warn: no RUM events found", file=sys.stderr)
            return 0
        print(render_rum_table(aggregated))
        return 0

    parser.print_help()
    return 2


if __name__ == "__main__":
    sys.exit(main())
