#!/usr/bin/env python3
"""verify_budgets.py — compare a Lighthouse JSON against budgets.json.

Usage:
    verify_budgets.py <lighthouse.json> <budgets.json>

Exits 0 if all budgets pass, non-zero if any breach.
Prints a one-line-per-metric report.
"""

import json
import sys
from pathlib import Path

EXIT_OK = 0
EXIT_BREACH = 1
EXIT_USAGE = 2


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def get_metric(lighthouse: dict, audit_id: str) -> float | None:
    audits = lighthouse.get("audits", {})
    audit = audits.get(audit_id)
    if audit is None:
        return None
    value = audit.get("numericValue")
    if value is None:
        return None
    return float(value)


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(f"usage: {argv[0]} <lighthouse.json> <budgets.json>", file=sys.stderr)
        return EXIT_USAGE

    lh_path = Path(argv[1])
    budgets_path = Path(argv[2])

    if not lh_path.exists():
        print(f"err: {lh_path} not found", file=sys.stderr)
        return EXIT_USAGE
    if not budgets_path.exists():
        print(f"err: {budgets_path} not found", file=sys.stderr)
        return EXIT_USAGE

    lh = load_json(lh_path)
    budgets = load_json(budgets_path)

    assertions = (
        budgets.get("ci", {}).get("assert", {}).get("assertions", {})
    )
    if not assertions:
        print("warn: no assertions found in budgets.json", file=sys.stderr)
        return EXIT_OK

    breaches: list[tuple[str, float, float]] = []
    for audit_id, spec in assertions.items():
        if not isinstance(spec, list) or len(spec) < 2:
            continue
        level, opts = spec[0], spec[1] if len(spec) > 1 else {}
        if not isinstance(opts, dict):
            continue
        max_val = opts.get("maxNumericValue")
        if max_val is None:
            # Boolean / no-numeric assertions skipped here; Lighthouse CI handles them
            continue
        actual = get_metric(lh, audit_id)
        if actual is None:
            print(f"  -- {audit_id}: not measured")
            continue
        passed = actual <= max_val
        marker = "OK" if passed else ("WARN" if level == "warn" else "FAIL")
        print(f"  {marker:5} {audit_id}: {actual:.0f} (budget {max_val:.0f})")
        if not passed and level == "error":
            breaches.append((audit_id, actual, max_val))

    if breaches:
        print(f"\n{len(breaches)} budget breach(es):")
        for audit_id, actual, budget in breaches:
            print(f"  - {audit_id}: {actual:.0f} > {budget:.0f}")
        return EXIT_BREACH

    print("\nAll budgets within target.")
    return EXIT_OK


if __name__ == "__main__":
    sys.exit(main(sys.argv))
