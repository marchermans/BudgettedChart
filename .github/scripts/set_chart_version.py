#!/usr/bin/env python3
"""Apply one chart version to both charts and parent dependency."""

from pathlib import Path
import sys


def set_top_level_version(path: Path, chart_version: str) -> None:
    lines = path.read_text().splitlines()
    for i, line in enumerate(lines):
        if line.startswith("version:"):
            lines[i] = f"version: {chart_version}"
            break
    else:
        raise RuntimeError(f"No top-level version found in {path}")
    path.write_text("\n".join(lines) + "\n")


def set_enable_actual_dependency_version(path: Path, chart_version: str) -> None:
    lines = path.read_text().splitlines()
    in_enable_dep = False
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped == "- name: enable-actual":
            in_enable_dep = True
            continue
        if in_enable_dep and stripped.startswith("version:"):
            indent = line[: len(line) - len(line.lstrip())]
            lines[i] = f"{indent}version: {chart_version}"
            in_enable_dep = False
            break
    else:
        raise RuntimeError(f"No enable-actual dependency version found in {path}")

    path.write_text("\n".join(lines) + "\n")


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: set_chart_version.py <chart-version>", file=sys.stderr)
        return 1

    chart_version = sys.argv[1]
    enable_chart = Path("charts/enable-actual/Chart.yaml")
    actual_chart = Path("charts/actual-budget/Chart.yaml")

    set_top_level_version(enable_chart, chart_version)
    set_top_level_version(actual_chart, chart_version)
    set_enable_actual_dependency_version(actual_chart, chart_version)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

