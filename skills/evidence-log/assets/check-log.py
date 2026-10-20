#!/usr/bin/env python3
"""check-log.py — validate evidence/log.csv, the spine of the evidence trail.

Bundled with QualStack (/qualstack:evidence-log; /qualstack:source-critique runs
it after writing the reliability column). Reads evidence/log.csv,
.qualstack/config.yaml (ID prefixes, model.statement), and the node headings of
data/coding-rules.md; lists evidence/raw/ but never opens an evidence file, and
never touches restricted/. Standard library only.

Errors (exit 1): a header other than the 13 columns; a row with the wrong
number of fields; an ID malformed or used twice; type or access outside its
list; a required field empty; a date that is not ISO 8601 at its precision
(1989, 1989-05, 1989-05-01; a trailing "?" marks an inferred date, "a/b" a
span); accessed before date; a listed file missing or under restricted/; an
interview whose author is not a pseudonym (the value is never printed);
reliability neither "pending" nor "<node> s=<p> f=<p> (<reason>)" entries
separated by ";" with 0 < s, f < 1.

Warnings: gaps in the ID sequence (rows are withdrawn, never deleted); a file
in evidence/raw/ whose name does not start with its row's ID; a file outside
evidence/ and data/raw/; an interview or field note whose access is not
confidential; a clue or reliability node that is not a model node; s <= f; a
reliability node missing from clues; a "derivative of" target that is not in
the log; a row with no file and no reason in notes; files in evidence/raw/
that no row names.

Usage: python3 check-log.py [--project DIR]
"""
from __future__ import annotations

import argparse
import calendar
import csv
import datetime as dt
import re
import sys
from pathlib import Path

HEADER = ["id", "type", "title", "date", "author", "source", "file", "accessed", "access",
          "cases", "clues", "reliability", "notes"]
TYPES = {"archival", "interview", "fieldnote", "secondary", "press", "official", "memoir",
         "dataset", "other"}
ACCESS = {"open", "archive-restricted", "confidential"}
REQUIRED = ["id", "type", "title", "date", "author", "source", "accessed", "access", "reliability"]
DATE_PART = re.compile(r"^(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?$")
REL_ENTRY = re.compile(r"^([A-Za-z][A-Za-z0-9]*)\s+s=(\d*\.?\d+)\s+f=(\d*\.?\d+)\s*(?:\((.*)\))?$")
NO_FILE_REASON = re.compile(r"no (copy|file|reproduction|transcript)|not (reproducible|copied|permitted|"
                            r"consented)|withheld|awaiting|withdrawn|pending deidentif", re.I)


def find_project(start: Path):
    p = start.resolve()
    for c in [p, *p.parents]:
        if (c / ".qualstack").is_dir():
            return c
    return None


def read_config(project: Path) -> dict:
    """evidence.id_prefix, evidence.person_prefix, model.statement (no PyYAML)."""
    cfg = {"id_prefix": "E", "person_prefix": "P", "statement": ""}
    try:
        lines = (project / ".qualstack" / "config.yaml").read_text().splitlines()
    except OSError:
        return cfg
    section = None
    for raw in lines:
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        indent = len(raw) - len(raw.lstrip())
        line = raw.split(" #")[0].strip()
        if indent == 0:
            section = line.rstrip(":") if line.endswith(":") else None
            continue
        key, _, value = line.partition(":")
        key, value = key.strip(), value.strip().strip("\"'")
        if section == "evidence" and key in ("id_prefix", "person_prefix") and value:
            cfg[key] = value
        elif section == "model" and key == "statement":
            cfg["statement"] = value
    return cfg


def statement_nodes(statement: str) -> set:
    return {t.strip() for t in re.split(r"<->|->|<-|;", statement) if t.strip()}


def model_nodes(project: Path, cfg: dict) -> set:
    """Node names from data/coding-rules.md headings, else from the model statement."""
    nodes = set()
    try:
        for line in (project / "data" / "coding-rules.md").read_text(encoding="utf-8").splitlines():
            if re.match(r"^#\s+Retired", line, re.I):
                break
            m = re.match(r"^##\s+`([A-Za-z][A-Za-z0-9]*)`", line)
            if m:
                nodes.add(m.group(1))
    except OSError:
        pass
    return nodes or statement_nodes(cfg["statement"])


def parse_date(text: str):
    """(start, end, inferred) for an ISO date at year, month, or day precision,
    or a span a/b; None if malformed."""
    text = text.strip()
    inferred = text.endswith("?")
    text = text.rstrip("?").strip()
    parts = text.split("/")
    if len(parts) > 2:
        return None
    bounds = []
    for part in parts:
        m = DATE_PART.match(part.strip())
        if not m:
            return None
        y, mo, d = int(m.group(1)), m.group(2), m.group(3)
        try:
            if d:
                start = end = dt.date(y, int(mo), int(d))
            elif mo:
                start = dt.date(y, int(mo), 1)
                end = dt.date(y, int(mo), calendar.monthrange(y, int(mo))[1])
            else:
                start, end = dt.date(y, 1, 1), dt.date(y, 12, 31)
        except ValueError:
            return None
        bounds.append((start, end))
    if len(bounds) == 2 and bounds[1][1] < bounds[0][0]:
        return None
    return bounds[0][0], bounds[-1][1], inferred


def split_list(cell: str):
    return [x.strip() for x in (cell or "").split(";") if x.strip()]


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(prog="check-log.py", description="Validate evidence/log.csv.")
    ap.add_argument("--project", default="", help="project folder (default: nearest .qualstack/ above cwd)")
    opts = ap.parse_args(argv)
    project = find_project(Path(opts.project or Path.cwd()))
    if project is None:
        print("No .qualstack/ found; run this inside a QualStack project.", file=sys.stderr)
        return 1
    cfg = read_config(project)
    nodes = model_nodes(project, cfg)
    log = project / "evidence" / "log.csv"
    errors, warnings = [], []
    try:
        with log.open(newline="", encoding="utf-8-sig") as fh:
            table = list(csv.reader(fh))
    except OSError:
        print("evidence/log.csv is missing; /qualstack:qualstack-init creates it.", file=sys.stderr)
        return 1
    if not table or [h.strip() for h in table[0]] != HEADER:
        print("ERROR header must be exactly: " + ",".join(HEADER))
        return 1

    id_re = re.compile(rf"^{re.escape(cfg['id_prefix'])}(\d{{3,}})$")
    person_re = re.compile(rf"^{re.escape(cfg['person_prefix'])}\d{{2,}}$")
    rows, seen, numbers, referenced = [], set(), [], set()
    for line_no, fields in enumerate(table[1:], start=2):
        if not any(f.strip() for f in fields):
            continue
        if len(fields) != len(HEADER):
            errors.append(f"line {line_no}: {len(fields)} fields, header has {len(HEADER)} "
                          "(quote any cell that contains a comma)")
            continue
        rows.append((line_no, {k: v.strip() for k, v in zip(HEADER, fields)}))
    ids = {r["id"] for _, r in rows}

    for line_no, r in rows:
        rid = r["id"] or f"line {line_no}"
        m = id_re.match(r["id"])
        if not m:
            errors.append(f"{rid}: ID must be {cfg['id_prefix']} plus at least three digits (E014)")
        else:
            numbers.append(int(m.group(1)))
        if r["id"] in seen:
            errors.append(f"{rid}: ID used twice; IDs are never reused")
        seen.add(r["id"])
        for col in REQUIRED:
            if not r[col]:
                errors.append(f"{rid}: '{col}' is empty")
        if r["type"] and r["type"] not in TYPES:
            errors.append(f"{rid}: type '{r['type']}' is not one of {', '.join(sorted(TYPES))}")
        if r["access"] and r["access"] not in ACCESS:
            errors.append(f"{rid}: access '{r['access']}' is not one of {', '.join(sorted(ACCESS))}")

        date = parse_date(r["date"]) if r["date"] else None
        if r["date"] and date is None:
            errors.append(f"{rid}: date '{r['date']}' is not ISO 8601 (1989, 1989-05, 1989-05-01, "
                          "with '?' if inferred, 'a/b' for a span)")
        accessed = parse_date(r["accessed"]) if r["accessed"] else None
        if r["accessed"] and (accessed is None or accessed[2]):
            errors.append(f"{rid}: accessed '{r['accessed']}' is not an ISO date (no '?': you know it)")
        elif date and accessed and accessed[1] < date[0] and not date[2]:
            errors.append(f"{rid}: accessed {r['accessed']} is before the item's date {r['date']}")

        files = split_list(r["file"])
        for f in files:
            rel = f.strip("/")
            if Path(rel).parts and Path(rel).parts[0] == "restricted":
                errors.append(f"{rid}: file '{f}' is under restricted/, which no log row may name")
                continue
            referenced.add(rel)
            if not (project / rel).exists():
                errors.append(f"{rid}: file '{f}' does not exist")
            if not (rel.startswith("evidence/") or rel.startswith("data/raw/")):
                warnings.append(f"{rid}: file '{f}' is outside evidence/ and data/raw/")
            if rel.startswith("evidence/raw/") and r["id"] and \
                    not Path(rel).name.lower().startswith(r["id"].lower()):
                warnings.append(f"{rid}: '{Path(rel).name}' does not start with {r['id']}; "
                                "raw files cannot be renamed, so record the mapping in notes")
        if not files and not NO_FILE_REASON.search(r["notes"]):
            warnings.append(f"{rid}: no file, and notes do not say why (file withheld: no AI "
                            "processing consented; no copy permitted; awaiting /qualstack:deidentify)")

        if r["type"] == "interview" and not all(person_re.match(a) for a in split_list(r["author"])):
            # The value is never printed: it may be a real name.
            errors.append(f"{rid}: interview author is not a pseudonym ({cfg['person_prefix']}01, ...); "
                          "replace it (the value is not shown here)")
        if r["type"] in ("interview", "fieldnote") and r["access"] and r["access"] != "confidential":
            warnings.append(f"{rid}: {r['type']} with access '{r['access']}'; the default is "
                            "confidential, and another tier needs the consent form's wording in notes")

        clues = split_list(r["clues"])
        for c in clues:
            if nodes and c not in nodes:
                warnings.append(f"{rid}: clue '{c}' is not a model node")
        rel_cell = r["reliability"]
        if rel_cell and rel_cell.lower() != "pending":
            for entry in split_list(rel_cell):
                m = REL_ENTRY.match(entry)
                if not m:
                    errors.append(f"{rid}: reliability entry '{entry}' is not "
                                  "'<node> s=<p> f=<p> (<reason>)'")
                    continue
                node, s, f, reason = m.group(1), float(m.group(2)), float(m.group(3)), m.group(4)
                if not (0 < s < 1 and 0 < f < 1):
                    errors.append(f"{rid}: {node} s={s} f={f}: both must lie strictly between 0 and 1")
                if not (reason or "").strip():
                    errors.append(f"{rid}: {node} s/f has no reason in parentheses")
                if s <= f:
                    warnings.append(f"{rid}: {node} s={s} <= f={f}: a report is no likelier when "
                                    "the clue is true; check the direction")
                if clues and node not in clues:
                    warnings.append(f"{rid}: reliability names {node}, which is not in clues")
                if nodes and node not in nodes:
                    warnings.append(f"{rid}: reliability node '{node}' is not a model node")
        for target in re.findall(r"derivative of\s+([A-Za-z]{1,3}\d{2,6})", r["notes"], re.I):
            if target not in ids:
                warnings.append(f"{rid}: 'derivative of {target}' names an ID not in the log")

    if numbers:
        missing = sorted(set(range(min(numbers), max(numbers) + 1)) - set(numbers))
        if missing:
            shown = ", ".join(f"{cfg['id_prefix']}{n:03d}" for n in missing[:10])
            warnings.append(f"ID gaps: {shown}{' ...' if len(missing) > 10 else ''} "
                            "(rows are withdrawn with 'withdrawn:' in notes, never deleted)")
    raw = project / "evidence" / "raw"
    if raw.is_dir():
        for p in sorted(raw.rglob("*")):
            if not p.is_file() or p.name == ".gitkeep":
                continue
            rel = p.relative_to(project).as_posix()
            if rel not in referenced and not any(rel.startswith(x.rstrip("/") + "/") for x in referenced):
                warnings.append(f"unlogged raw file: {rel}")

    width = max([3] + [len(str(n)) for n in numbers])
    next_id = f"{cfg['id_prefix']}{(max(numbers) + 1 if numbers else 1):0{width}d}"
    span = (f" ({cfg['id_prefix']}{min(numbers):0{width}d}-{cfg['id_prefix']}{max(numbers):0{width}d})"
            if numbers else "")
    print(f"evidence/log.csv: {len(rows)} row(s){span}, next free ID {next_id}; "
          f"{len(errors)} error(s), {len(warnings)} warning(s)")
    for e in errors:
        print(f"ERROR {e}")
    for w in warnings:
        print(f"WARN  {w}")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
