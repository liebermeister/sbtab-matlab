#!/usr/bin/env python3
"""Check staged TSV/CSV files for numbers damaged by spreadsheet programs.

Used as a git pre-commit hook (see install_hooks.sh). Two kinds of damage are detected, both
typical of saving a file from a spreadsheet program with German (or other non-English) locale
settings, where "." is the thousands separator and "," the decimal separator:

1. A number with exactly three decimals loses its decimal point: 46298.203 -> 46298203,
   0.001 -> 1 (the point was read as a thousands separator). Detected by comparing each staged
   file with its last committed version, cell by cell, for rows with the same key (table ID and
   the first three cells).
2. A number is written with a decimal comma: 1e-06 -> 1,00E-06 (TSV files only; in CSV files,
   commas separate the cells). Detected in rows that are new or changed.

Both kinds of damage once caused errors of exactly a factor of 1000 in model and data files.

Usage:
  check_tsv_numbers.py              check the staged files (as a pre-commit hook)
  check_tsv_numbers.py OLD NEW      compare two files directly

Exit code 1 if a problem is found. To commit anyway (if the change is intended):
  git commit --no-verify
"""
import csv
import io
import re
import subprocess
import sys

THREE_DECIMALS = re.compile(r"^-?\d+\.\d{3}$")
DECIMAL_COMMA = re.compile(r"^[-+]?\d+(,\d+)+([eE][-+]?\d+)?$")
TABLE_ID = re.compile(r"""TableID\s*=\s*['"]([^'"]*)['"]""")


def rows(text, delimiter):
    """Return {key: cells} with key = (table ID, first three cells), and the list of data lines."""
    result = {}
    lines = []
    table = None
    if delimiter == ",":
        records = list(csv.reader(io.StringIO(text)))
    else:
        records = [line.rstrip("\r").split("\t") for line in text.split("\n")]
    for cells in records:
        if not cells:
            continue
        first = cells[0].strip()
        if first.startswith("!!"):
            m = TABLE_ID.search(delimiter.join(cells))
            table = m.group(1) if m else first
            continue
        if first.startswith("!") or first.startswith("%") or not any(c.strip() for c in cells):
            continue
        cells = [c.strip() for c in cells]
        result[(table,) + tuple(cells[:3])] = cells
        lines.append(tuple(cells))
    return result, lines


def lost_point(old, new):
    if not THREE_DECIMALS.match(old):
        return False
    sign = "-" if old.startswith("-") else ""
    digits = old.lstrip("-").replace(".", "").lstrip("0") or "0"
    return new == sign + digits


def check(old_text, new_text, name):
    delimiter = "," if name.lower().endswith(".csv") else "\t"
    problems = []
    new_rows, new_lines = rows(new_text, delimiter)
    if old_text is not None:
        old_rows, old_lines = rows(old_text, delimiter)
        for key, new_cells in new_rows.items():
            old_cells = old_rows.get(key)
            if old_cells is None:
                continue
            for i, (u, v) in enumerate(zip(old_cells, new_cells)):
                if lost_point(u, v):
                    problems.append(f"{name}: row {key[1:]}, column {i + 1}: {u} -> {v} "
                                    "(decimal point lost; spreadsheet locale?)")
        unchanged = set(old_lines)
    else:
        unchanged = set()
    if delimiter == "\t":
        for cells in new_lines:
            if cells in unchanged:
                continue
            for i, c in enumerate(cells):
                if DECIMAL_COMMA.match(c):
                    problems.append(f"{name}: row {cells[:3]}, column {i + 1}: '{c}' "
                                    "(number with a comma; spreadsheet locale?)")
    return problems


def git(*args):
    r = subprocess.run(["git", *args], capture_output=True)
    return r.stdout.decode("utf-8", errors="replace") if r.returncode == 0 else None


def main():
    if len(sys.argv) == 3:
        old = open(sys.argv[1], encoding="utf-8", errors="replace").read()
        new = open(sys.argv[2], encoding="utf-8", errors="replace").read()
        problems = check(old, new, sys.argv[2])
    else:
        names = git("diff", "--cached", "--name-only", "--diff-filter=ACMR", "-z") or ""
        problems = []
        for name in names.split("\0"):
            if not name.lower().endswith((".tsv", ".csv")):
                continue
            new = git("show", f":{name}")
            if new is None:
                continue
            old = git("show", f"HEAD:{name}")
            problems += check(old, new, name)
    if problems:
        print("check_tsv_numbers: possible number damage by a spreadsheet program:", file=sys.stderr)
        for p in problems[:50]:
            print("  " + p, file=sys.stderr)
        if len(problems) > 50:
            print(f"  ... and {len(problems) - 50} more", file=sys.stderr)
        print("If these changes are intended, commit with: git commit --no-verify", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
