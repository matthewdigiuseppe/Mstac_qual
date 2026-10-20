#!/usr/bin/env python3
"""coding-tools.py — the coding log's two mechanical jobs.

Bundled with QualStack (/qualstack:code-evidence). Standard library only; never
opens restricted/ or an evidence file.

  build [--project DIR] [--dry-run]
      Writes data/case-data.csv from data/coding-log.csv; the case data is never
      edited by hand. The log is append-only, so the row of record for a case
      and node is its last row. Refuses to write (exit 1) when a row of record
      is coded under an old rule version, has a value outside 0/1/NA, codes 0 or
      1 with no evidence ID or with an ID that is not in evidence/log.csv or is
      withdrawn, codes 0 with an empty note (the search or the positive evidence
      of absence belongs there), lacks a coder, a confidence of high/medium/low,
      or an ISO date; when a node in data/coding-rules.md has no row for some
      case; or when the rules' nodes differ from the model statement (rules
      header, code/01-model.R). Columns follow the rule blocks' order; blocks
      under a final "# Retired nodes" heading are skipped. NA means not observed.

  agree FIRST SECOND [--out FILE]
      Agreement between two codings, computed before any adjudication. Each
      file needs case,node,value columns; for data/coding-log.csv the last row
      per case and node not coded `adjudicated` is used. Per node: pairs coded
      by both, the 0/1/NA cross-tab, percent agreement, Cohen's (1960) kappa with
      NA as a category and on 0/1 pairs only, positive and negative specific
      agreement, how often one coder coded a value where the other coded NA,
      and the base rate of 1s; then every disagreement, with a blank
      resolution column to fill in.
"""
from __future__ import annotations

import argparse
import csv
import datetime as dt
import re
import sys
from pathlib import Path

LOG_HEADER = ["case", "node", "value", "evidence_ids", "rule_version", "coder", "confidence",
              "note", "date"]
CATS = ["1", "0", "NA"]


def find_project(start: Path):
    p = start.resolve()
    for c in [p, *p.parents]:
        if (c / ".qualstack").is_dir():
            return c
    return None


def natural(s: str):
    return [int(t) if t.isdigit() else t.lower() for t in re.split(r"(\d+)", s)]


def statement_nodes(statement: str) -> set:
    return {t.strip() for t in re.split(r"<->|->|<-|;", statement) if t.strip()}


def parse_rules(path: Path):
    """(nodes in block order, {node: 'vN'}, header statement, retired nodes)."""
    nodes, versions, statement, retired, in_retired = [], {}, "", set(), False
    for line in path.read_text(encoding="utf-8").splitlines():
        if re.match(r"^#\s+Retired", line, re.I):
            in_retired = True
            continue
        m = re.match(r"^\s*-\s*\*\*Model statement:\*\*\s*`([^`]*)`", line)
        if m and not statement and not in_retired:
            statement = m.group(1).strip()
        m = re.match(r"^##\s+`([A-Za-z][A-Za-z0-9]*)`(.*)$", line)
        if m:
            if in_retired:
                retired.add(m.group(1))
                continue
            v = re.search(r"\(v(\d+)\b", m.group(2))
            nodes.append(m.group(1))
            versions[m.group(1)] = f"v{v.group(1)}" if v else ""
    return nodes, versions, statement, retired


def code_statement(project: Path) -> str:
    try:
        text = (project / "code" / "01-model.R").read_text(encoding="utf-8")
    except OSError:
        return ""
    m = re.search(r'^\s*STATEMENT\s*<-\s*"([^"]*)"', text, re.M) or \
        re.search(r'make_model\(\s*"([^"]*)"', text)
    return m.group(1) if m else ""


def read_rows(path: Path):
    with path.open(newline="", encoding="utf-8-sig") as fh:
        reader = csv.reader(fh)
        header = [h.strip() for h in next(reader, [])]
        rows = []
        for line_no, fields in enumerate(reader, start=2):
            if any(f.strip() for f in fields):
                rows.append((line_no, fields))
    return header, rows


def evidence_ids(project: Path):
    ids, withdrawn = set(), set()
    try:
        with (project / "evidence" / "log.csv").open(newline="", encoding="utf-8-sig") as fh:
            for r in csv.DictReader(fh):
                eid = (r.get("id") or "").strip()
                if eid:
                    ids.add(eid)
                    if (r.get("notes") or "").strip().lower().startswith("withdrawn"):
                        withdrawn.add(eid)
    except OSError:
        pass
    return ids, withdrawn


def is_iso_day(text: str) -> bool:
    try:
        dt.date.fromisoformat(text)
        return len(text) == 10
    except ValueError:
        return False


def cmd_build(project: Path, dry_run: bool) -> int:
    rules_path = project / "data" / "coding-rules.md"
    log_path = project / "data" / "coding-log.csv"
    out_path = project / "data" / "case-data.csv"
    if not rules_path.is_file():
        print("ERROR data/coding-rules.md is missing: run /qualstack:coding-rules first.")
        return 1
    if not log_path.is_file():
        print("ERROR data/coding-log.csv is missing: nothing has been coded yet.")
        return 1
    nodes, versions, rules_stmt, retired = parse_rules(rules_path)
    errors, notes = [], []
    if not nodes:
        errors.append("data/coding-rules.md has no node blocks (headings like '## `M` — label (v1, 2026-01-01)')")
    for n in sorted({x for x in nodes if nodes.count(x) > 1}):
        errors.append(f"node {n} has more than one rule block")
    for n in nodes:
        if not versions.get(n):
            errors.append(f"node {n}: rule heading carries no version '(vN, YYYY-MM-DD)'")
    for label, stmt in (("the rules' model statement", rules_stmt),
                        ("code/01-model.R", code_statement(project))):
        if stmt and statement_nodes(stmt) != set(nodes):
            only_s = sorted(statement_nodes(stmt) - set(nodes))
            only_r = sorted(set(nodes) - statement_nodes(stmt))
            errors.append(f"nodes in {label} and the rule blocks differ: "
                          f"no block for {only_s or 'none'}; block but not in statement: {only_r or 'none'}")

    header, rows = read_rows(log_path)
    if header != LOG_HEADER:
        print("ERROR data/coding-log.csv header must be exactly: " + ",".join(LOG_HEADER))
        return 1
    ev_ids, withdrawn = evidence_ids(project)
    last = {}
    for line_no, fields in rows:
        if len(fields) != len(LOG_HEADER):
            errors.append(f"line {line_no}: {len(fields)} fields, header has {len(LOG_HEADER)} "
                          "(quote any cell that contains a comma)")
            continue
        r = {k: v.strip() for k, v in zip(LOG_HEADER, fields)}
        last[(r["case"], r["node"])] = (line_no, r)

    cases = sorted({c for c, _ in last}, key=natural)
    for (case, node), (line_no, r) in sorted(last.items(), key=lambda kv: kv[1][0]):
        where = f"line {line_no} ({case}, {node})"
        if not case:
            errors.append(f"{where}: no case ID")
        if node not in versions:
            if node in retired:
                notes.append(f"{where}: node {node} is retired; row ignored")
            else:
                errors.append(f"{where}: node {node} has no block in data/coding-rules.md")
            continue
        value = r["value"]
        if value not in ("0", "1", "NA"):
            errors.append(f"{where}: value '{value}' is not 0, 1, or NA")
        if r["rule_version"] != versions[node]:
            errors.append(f"{where}: coded under {r['rule_version'] or 'no version'}, rule is "
                          f"{versions[node]}: recode this case under {versions[node]}")
        ids = [x.strip() for x in r["evidence_ids"].split(";") if x.strip()]
        if value in ("0", "1") and not ids:
            errors.append(f"{where}: a {value} needs the evidence IDs behind it")
        for eid in ids:
            if eid not in ev_ids:
                errors.append(f"{where}: evidence ID {eid} is not in evidence/log.csv")
            elif eid in withdrawn and value in ("0", "1"):
                errors.append(f"{where}: cites withdrawn item {eid}; recode without it (NA if nothing else)")
        if value == "0" and not r["note"]:
            errors.append(f"{where}: a 0 needs its search or its positive evidence of absence in note")
        if not r["coder"]:
            errors.append(f"{where}: no coder")
        if r["confidence"] not in ("high", "medium", "low"):
            errors.append(f"{where}: confidence '{r['confidence']}' is not high, medium, or low")
        if not is_iso_day(r["date"]):
            errors.append(f"{where}: date '{r['date']}' is not YYYY-MM-DD")
    for case in cases:
        gaps = [n for n in nodes if (case, n) not in last]
        if gaps:
            errors.append(f"case {case}: no row for {', '.join(gaps)} (log NA with the reason: "
                          "searched short of the 0 standard, or never looked)")

    for n in notes:
        print(f"NOTE  {n}")
    if errors:
        for e in errors:
            print(f"ERROR {e}")
        print(f"\n{len(errors)} error(s): data/case-data.csv was not written.")
        return 1

    table = [["case"] + nodes]
    for case in cases:
        table.append([case] + [last[(case, n)][1]["value"] for n in nodes])
    if not dry_run:
        with out_path.open("w", newline="", encoding="utf-8") as fh:
            csv.writer(fh, lineterminator="\n").writerows(table)
    verb = "would write" if dry_run else "wrote"
    print(f"{verb} data/case-data.csv: {len(cases)} case(s) x {len(nodes)} node(s) "
          f"from {len(rows)} log row(s); NA = not observed")
    print(f"{'node':12} {'version':8} {'1':>4} {'0':>4} {'NA':>4} {'low conf.':>9}")
    for n in nodes:
        vals = [last[(c, n)][1] for c in cases]
        count = {v: sum(1 for r in vals if r["value"] == v) for v in ("1", "0", "NA")}
        low = sum(1 for r in vals if r["confidence"] == "low")
        print(f"{n:12} {versions[n]:8} {count['1']:>4} {count['0']:>4} {count['NA']:>4} {low:>9}")
    return 0


def load_codes(path: Path, problems: list):
    with path.open(newline="", encoding="utf-8-sig") as fh:
        reader = csv.DictReader(fh)
        if not {"case", "node", "value"} <= {h.strip() for h in (reader.fieldnames or [])}:
            raise SystemExit(f"{path}: needs case,node,value columns")
        codes = {}
        for row in reader:
            row = {(k or "").strip(): (v or "").strip() for k, v in row.items()}
            if row.get("coder", "").lower() == "adjudicated":
                continue
            value = row["value"]
            if value.upper() in ("", "NA"):
                value = "NA"
            elif value not in ("0", "1"):
                problems.append(f"{path.name}: ({row['case']}, {row['node']}) value '{value}' "
                                "is not 0, 1, or NA; pair skipped")
                continue
            codes[(row["case"], row["node"])] = value
    return codes


def kappa(table, cats):
    n = sum(table[a][b] for a in cats for b in cats)
    if n == 0:
        return None, None
    po = sum(table[c][c] for c in cats) / n
    pe = sum((sum(table[c][b] for b in cats) / n) * (sum(table[a][c] for a in cats) / n) for c in cats)
    return po, (None if pe >= 1 else (po - pe) / (1 - pe))


def fmt(x, pct=False):
    if x is None:
        return "n/a"
    return f"{x * 100:.0f}%" if pct else f"{x:.2f}"


def cmd_agree(first: Path, second: Path, out: str) -> int:
    problems = []
    a_codes, b_codes = load_codes(first, problems), load_codes(second, problems)
    pairs = sorted(set(a_codes) & set(b_codes), key=lambda k: (natural(k[1]), natural(k[0])))
    only_a = sorted(set(a_codes) - set(b_codes))
    only_b = sorted(set(b_codes) - set(a_codes))
    nodes = sorted({n for _, n in pairs}, key=natural)
    lines = [
        "# Intercoder agreement (before adjudication)", "",
        f"- First coder: `{first}`; second coder: `{second}`",
        f"- Pairs coded by both: {len(pairs)}; first coder only (outside the second coder's "
        f"batch): {len(only_a)}; second coder only: {len(only_b)}",
        "- Kappa with NA as a category treats 0/1/NA as three nominal codes; kappa on 0/1 pairs "
        "drops every pair in which either coder coded NA (counted under 'Value vs NA').", "",
        "| Node | Pairs | Agree | Kappa (NA a category) | Kappa (0/1 pairs) | 0/1 pairs | Pos. agr. "
        "| Neg. agr. | Value vs NA | Base rate of 1s |",
        "|---|---|---|---|---|---|---|---|---|---|",
    ]
    tabs, disagreements, total_agree = [], [], 0
    for node in nodes:
        t = {a: {b: 0 for b in CATS} for a in CATS}
        for case, n in pairs:
            if n == node:
                t[a_codes[(case, n)]][b_codes[(case, n)]] += 1
        n_pairs = sum(t[a][b] for a in CATS for b in CATS)
        po3, k3 = kappa(t, CATS)
        po2, k2 = kappa(t, ["1", "0"])
        a11, b10, c01, d00 = t["1"]["1"], t["1"]["0"], t["0"]["1"], t["0"]["0"]
        n2 = a11 + b10 + c01 + d00
        pos = 2 * a11 / (2 * a11 + b10 + c01) if (2 * a11 + b10 + c01) else None
        neg = 2 * d00 / (2 * d00 + b10 + c01) if (2 * d00 + b10 + c01) else None
        vna = t["1"]["NA"] + t["0"]["NA"] + t["NA"]["1"] + t["NA"]["0"]
        ones = sum(t["1"][b] for b in CATS) + sum(t[a]["1"] for a in CATS)
        coded = ones + sum(t["0"][b] for b in CATS) + sum(t[a]["0"] for a in CATS)
        base = ones / coded if coded else None
        total_agree += sum(t[c][c] for c in CATS)
        lines.append(f"| {node} | {n_pairs} | {fmt(po3, True)} | {fmt(k3)} | {fmt(k2)} | {n2} | "
                     f"{fmt(pos)} | {fmt(neg)} | {vna} | {fmt(base)} |")
        tabs += [f"### {node}", "", "| first \\ second | 1 | 0 | NA |", "|---|---|---|---|"]
        tabs += [f"| {a} | " + " | ".join(str(t[a][b]) for b in CATS) + " |" for a in CATS] + [""]
        disagreements += [(case, n, a_codes[(case, n)], b_codes[(case, n)])
                          for case, n in pairs if n == node and a_codes[(case, n)] != b_codes[(case, n)]]
    if pairs:
        lines.append(f"| all nodes | {len(pairs)} | {fmt(total_agree / len(pairs), True)} | | | | | | | |")
    lines += ["", "## Cross-tabs (rows: first coder; columns: second coder)", ""] + tabs
    lines += ["## Disagreements", "", "Resolve each by the rule's clauses, never by which value fits; "
              "record the clause and the evidence IDs.", "",
              "| Case | Node | First | Second | Resolution (clause, evidence, final value) |",
              "|---|---|---|---|---|"]
    lines += [f"| {c} | {n} | {a} | {b} | |" for c, n, a, b in disagreements] or ["| none | | | | |"]
    if only_b:
        lines += ["", "## Coded by the second coder only (the first coder has no row: log one)", ""]
        lines += [f"- {c}, {n}" for c, n in only_b]
    if problems:
        lines += ["", "## Input problems", ""] + [f"- {p}" for p in problems]
    text = "\n".join(lines) + "\n"
    if out:
        Path(out).parent.mkdir(parents=True, exist_ok=True)
        Path(out).write_text(text, encoding="utf-8")
    print(text, end="")
    if out:
        print(f"\nwritten to {out}")
    return 0


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(prog="coding-tools.py",
                                 description="Build case data from the coding log; measure agreement.")
    sub = ap.add_subparsers(dest="command", required=True)
    b = sub.add_parser("build", help="write data/case-data.csv from data/coding-log.csv")
    b.add_argument("--project", default="", help="project folder (default: nearest .qualstack/ above cwd)")
    b.add_argument("--dry-run", action="store_true", help="check only; write nothing")
    g = sub.add_parser("agree", help="agreement between two codings")
    g.add_argument("first")
    g.add_argument("second")
    g.add_argument("--out", default="", help="also write the report here (Markdown)")
    opts = ap.parse_args(argv)
    if opts.command == "agree":
        return cmd_agree(Path(opts.first), Path(opts.second), opts.out)
    project = find_project(Path(opts.project or Path.cwd()))
    if project is None:
        print("No .qualstack/ found; run this inside a QualStack project.", file=sys.stderr)
        return 1
    return cmd_build(project, opts.dry_run)


if __name__ == "__main__":
    sys.exit(main())
