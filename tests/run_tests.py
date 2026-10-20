#!/usr/bin/env python3
"""QualStack script tests: the guard hook, init, status, redact, quotecheck.

Run from anywhere: python3 tests/run_tests.py
Standard library only; every test builds its own throwaway project folder.
Exit 0 = all pass, 1 = failures.
"""
import json
import os
import subprocess
import sys
import tempfile
import traceback
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BIN = ROOT / "bin"
HOOK = ROOT / "hooks" / "qualstack-guard.py"
RESULTS = []


def test(fn):
    RESULTS.append(fn)
    return fn


def run(cmd, cwd=None, stdin=None):
    return subprocess.run(cmd, cwd=cwd, input=stdin, capture_output=True, text=True)


def scaffold(tmp: Path, name="proj", *extra):
    r = run(["bash", str(BIN / "qualstack-init"), name, *extra], cwd=tmp)
    assert r.returncode == 0, r.stderr
    return tmp / name


def hook(event: dict):
    """(decision, message): decision is allow | deny | ask."""
    r = run([sys.executable, str(HOOK)], stdin=json.dumps(event))
    if r.returncode == 2:
        return "deny", r.stderr
    assert r.returncode == 0, f"hook crashed: {r.stderr}"
    if r.stdout.strip():
        out = json.loads(r.stdout)
        return out["hookSpecificOutput"]["permissionDecision"], out["hookSpecificOutput"].get(
            "permissionDecisionReason", "")
    return "allow", ""


def bash(cmd, cwd):
    return hook({"tool_name": "Bash", "tool_input": {"command": cmd}, "cwd": str(cwd)})


# ---------------------------------------------------------------- init


@test
def init_creates_layout_and_stamps_name():
    with tempfile.TemporaryDirectory() as t:
        p = scaffold(Path(t), "land-reform")
        for rel in (".qualstack/config.yaml", "evidence/log.csv", "restricted/README.md",
                    "paper/main.tex", "paper/sections/cases.tex", "code/01-model.R", ".ignore"):
            assert (p / rel).exists(), rel
        assert 'short_name: "land-reform"' in (p / ".qualstack/config.yaml").read_text()


@test
def init_refuses_nesting_and_overwrite_and_bad_names():
    with tempfile.TemporaryDirectory() as t:
        p = scaffold(Path(t), "outer")
        assert run(["bash", str(BIN / "qualstack-init"), "inner"], cwd=p).returncode != 0
        assert run(["bash", str(BIN / "qualstack-init"), "outer"], cwd=t).returncode != 0
        assert run(["bash", str(BIN / "qualstack-init"), "Bad Name"], cwd=t).returncode != 0


@test
def init_quarto_swaps_main_and_sections():
    with tempfile.TemporaryDirectory() as t:
        p = scaffold(Path(t), "q", "--quarto")
        assert (p / "paper/main.qmd").exists() and not (p / "paper/main.tex").exists()
        assert (p / "paper/sections/cases.qmd").exists()
        assert not list((p / "paper/sections").glob("*.tex"))
        assert 'format: "quarto"' in (p / ".qualstack/config.yaml").read_text()


# ---------------------------------------------------------------- hook


@test
def hook_noop_outside_project():
    with tempfile.TemporaryDirectory() as t:
        assert hook({"tool_name": "Read", "tool_input": {"file_path": f"{t}/restricted/key.csv"},
                     "cwd": t})[0] == "allow"
        assert bash("rm -rf restricted", t)[0] == "allow"


@test
def hook_restricted_wall_file_tools():
    with tempfile.TemporaryDirectory() as t:
        p = scaffold(Path(t))
        (p / "restricted/key.csv").write_text("real,pseudonym\nX,P01\n")
        for tool, key in (("Read", "file_path"), ("Write", "file_path"), ("Edit", "file_path")):
            d, msg = hook({"tool_name": tool, "tool_input": {key: str(p / "restricted/key.csv")},
                           "cwd": str(p)})
            assert d == "deny", (tool, d)
        assert hook({"tool_name": "Grep", "tool_input": {"pattern": "x", "path": str(p / "restricted")},
                     "cwd": str(p)})[0] == "deny"
        assert hook({"tool_name": "Glob", "tool_input": {"pattern": "restricted/**/*"},
                     "cwd": str(p)})[0] == "deny"
        assert hook({"tool_name": "Grep", "tool_input": {"pattern": "x", "glob": "restricted/*.csv"},
                     "cwd": str(p)})[0] == "deny"
        # Ordinary reads and project-wide searches are fine (.ignore covers ripgrep).
        assert hook({"tool_name": "Read", "tool_input": {"file_path": str(p / "evidence/log.csv")},
                     "cwd": str(p)})[0] == "allow"
        assert hook({"tool_name": "Grep", "tool_input": {"pattern": "restricted", "path": str(p)},
                     "cwd": str(p)})[0] == "allow"


@test
def hook_restricted_wall_bash():
    with tempfile.TemporaryDirectory() as t:
        p = scaffold(Path(t))
        (p / "paper/notes").mkdir()
        deny = ["cat restricted/key.csv", f"head {p}/restricted/key.csv", "ls restricted",
                "cat r*/key.csv", "head */key.csv", "grep -r Smith .", "grep -rn Smith",
                "find . -name '*.txt'", "rg --no-ignore Smith", "tar czf x.tgz .", "cp -r . /tmp/x",
                "cd paper && cat ../restricted/key.csv"]
        for cmd in deny:
            assert bash(cmd, p)[0] == "deny", cmd
        allow = ["grep -r Smith paper/", "grep -r --exclude-dir=restricted Smith .",
                 "find . -path ./restricted -prune -o -name '*.md' -print", "rg Smith",
                 "ls", "cat evidence/log.csv", "Rscript code/01-model.R",
                 "python3 bin/qualstack-redact apply", "grep -n 'restricted' paper/main.tex",
                 "find paper -name '*.tex'"]
        for cmd in allow:
            assert bash(cmd, p)[0] == "allow", cmd
        # From inside a subfolder, a recursive scan of that subfolder is fine.
        assert bash("grep -r x .", p / "paper")[0] == "allow"


@test
def hook_read_only_sources():
    with tempfile.TemporaryDirectory() as t:
        p = scaffold(Path(t))
        f = p / "evidence/raw/archival/E001-memo.txt"
        f.parent.mkdir(parents=True)
        f.write_text("memo")
        assert hook({"tool_name": "Edit", "tool_input": {"file_path": str(f)}, "cwd": str(p)})[0] == "deny"
        assert hook({"tool_name": "Write", "tool_input": {"file_path": str(f)}, "cwd": str(p)})[0] == "deny"
        new = p / "evidence/raw/archival/E002-new.txt"
        assert hook({"tool_name": "Write", "tool_input": {"file_path": str(new)}, "cwd": str(p)})[0] == "allow"
        assert bash("rm evidence/raw/archival/E001-memo.txt", p)[0] == "deny"
        assert bash("sed -i 's/a/b/' data/raw/x.csv", p)[0] == "deny"
        # Moving, overwriting, or appending to an existing source file is blocked;
        # adding files (including a corrected copy) is not.
        assert bash("mv evidence/raw/archival/E001-memo.txt evidence/raw/archival/E001-x.txt", p)[0] == "deny"
        assert bash("echo x > evidence/raw/archival/E001-memo.txt", p)[0] == "deny"
        assert bash("cd evidence/raw/archival && echo x >> E001-memo.txt", p)[0] == "deny"
        assert bash("cp /tmp/other.txt evidence/raw/archival/E001-memo.txt", p)[0] == "deny"
        assert bash("cat notes.txt | tee evidence/raw/archival/E001-memo.txt", p)[0] == "deny"
        assert bash("cp evidence/raw/archival/E001-memo.txt "
                    "evidence/raw/archival/E001-memo-corrected-2026-01-02.txt", p)[0] == "allow"
        assert bash("cp ~/Downloads/scan.pdf evidence/raw/archival/E003-scan-1989-05-02.pdf", p)[0] == "allow"
        assert bash("echo x > evidence/memos/2026-01-01-note.md", p)[0] == "allow"
        # Memos and coded data stay editable.
        memo = p / "evidence/memos/2026-01-01.md"
        memo.write_text("x")
        assert hook({"tool_name": "Edit", "tool_input": {"file_path": str(memo)}, "cwd": str(p)})[0] == "allow"


@test
def hook_registered_prereg_is_locked():
    with tempfile.TemporaryDirectory() as t:
        p = scaffold(Path(t))
        pre = p / "prereg/prereg.md"
        ev = {"tool_name": "Edit", "tool_input": {"file_path": str(pre)}, "cwd": str(p)}
        assert hook(ev)[0] == "allow"  # drafted, not registered
        cfg = p / ".qualstack/config.yaml"
        cfg.write_text(cfg.read_text().replace('prereg_url: ""', 'prereg_url: "https://osf.io/abcde"'))
        assert hook(ev)[0] == "deny"
        add = p / "prereg/addendum-2026-06-01.md"
        assert hook({"tool_name": "Write", "tool_input": {"file_path": str(add)}, "cwd": str(p)})[0] == "allow"
        assert bash("mv prereg/prereg.md prereg/old.md", p)[0] == "deny"


@test
def hook_freeze_and_careful():
    with tempfile.TemporaryDirectory() as t:
        p = scaffold(Path(t))
        (p / ".qualstack/safety.yaml").write_text('careful: true\nfreeze:\n  path: "submission"\n')
        outside = p / "paper/sections/intro.tex"
        inside = p / "submission/cover-letter.md"
        assert hook({"tool_name": "Edit", "tool_input": {"file_path": str(outside)}, "cwd": str(p)})[0] == "deny"
        assert hook({"tool_name": "Write", "tool_input": {"file_path": str(inside)}, "cwd": str(p)})[0] == "ask"
        assert hook({"tool_name": "Edit", "tool_input": {"file_path": str(p / ".qualstack/safety.yaml")},
                     "cwd": str(p)})[0] == "allow"
        assert bash("rm submission/cover-letter.md", p)[0] == "ask"
        assert bash("cp x paper/y", p)[0] == "deny"


# ---------------------------------------------------------------- redact


def redact_fixture(t):
    p = scaffold(Path(t))
    (p / "restricted/originals").mkdir()
    (p / "restricted/key.csv").write_text(
        "real,pseudonym,kind\nJane Q. Official,P07,person\nJane|Official,P07,person\n"
        "Ministry of the Interior,[Ministry A],organization\n")
    (p / "restricted/originals/int-07.txt").write_text(
        "Q: When did Jane Q. Official decide?\nA: Jane said the Ministry of the Interior "
        "opposed it. Carlos Mendez was there. An official agreed.\n")
    (p / "restricted/originals/smith.txt").write_text("named after a person\n")
    cfg = p / ".qualstack/config.yaml"
    cfg.write_text(cfg.read_text().replace('ai_processing: ""', 'ai_processing: "pseudonymized"'))
    return p


@test
def redact_apply_pseudonymizes_and_never_prints_names():
    with tempfile.TemporaryDirectory() as t:
        p = redact_fixture(t)
        # Project IDs keep their capitals in a neutral name.
        (p / "restricted/originals/E015-p08-2025-03-15.txt").write_text("Jane Q. Official spoke.\n")
        r = run([sys.executable, str(BIN / "qualstack-redact"), "apply"], cwd=p)
        assert r.returncode == 0, r.stderr
        assert "P07" in (p / "evidence/raw/interviews/E015-p08-2025-03-15.txt").read_text()
        for secret in ("Jane", "Official", "Interior", "Carlos", "Mendez", "smith"):
            assert secret not in r.stdout + r.stderr, secret
        out = (p / "evidence/raw/interviews/int-07.txt").read_text()
        assert "P07" in out and "[Ministry A]" in out and "Jane" not in out
        assert "An official agreed" in out  # one-word variants are case-sensitive
        assert not (p / "evidence/raw/interviews/smith.txt").exists()  # non-neutral name withheld
        assert "WITHHELD: 1" in r.stdout
        review = (p / "restricted/redaction-review.txt").read_text()
        assert "Carlos" in review and "Mendez" in review
        # Outputs are never overwritten.
        r2 = run([sys.executable, str(BIN / "qualstack-redact"), "apply"], cwd=p)
        assert "2 skipped" in r2.stdout


@test
def redact_refuses_when_protocol_forbids():
    with tempfile.TemporaryDirectory() as t:
        p = redact_fixture(t)
        cfg = p / ".qualstack/config.yaml"
        cfg.write_text(cfg.read_text().replace('ai_processing: "pseudonymized"', 'ai_processing: "none"'))
        r = run([sys.executable, str(BIN / "qualstack-redact"), "apply"], cwd=p)
        assert r.returncode == 2 and not (p / "evidence/raw/interviews").exists()


@test
def redact_check_flags_leaks_by_pseudonym_only():
    with tempfile.TemporaryDirectory() as t:
        p = redact_fixture(t)
        (p / "paper/sections/cases.tex").write_text("As Jane Q. Official told us in 1989.\nAn official said.\n")
        r = run([sys.executable, str(BIN / "qualstack-redact"), "check"], cwd=p)
        assert r.returncode == 1
        assert "cases.tex:1" in r.stdout and "P07" in r.stdout and "Jane" not in r.stdout
        assert "cases.tex:2" not in r.stdout


# ---------------------------------------------------------------- quotecheck


@test
def quotecheck_statuses():
    with tempfile.TemporaryDirectory() as t:
        p = scaffold(Path(t))
        (p / "evidence/raw/archival").mkdir(parents=True)
        (p / "evidence/raw/interviews").mkdir(parents=True)
        (p / "evidence/raw/archival/E002-memo.txt").write_text(
            "Cabinet memo.\nThe ministry will not raise the export tax unless the ex-\nporters "
            "receive compensation through the exchange-rate regime.\n")
        (p / "evidence/raw/interviews/int-07.txt").write_text(
            "We would never accept the tax without compensation for exporters.\n")
        (p / "evidence/log.csv").write_text(
            "id,type,title,date,author,source,file,accessed,access,cases,clues,reliability,notes\n"
            "E001,interview,Interview P07,2024,P07,int-07,evidence/raw/interviews/int-07.txt,2024,confidential,A,B,,\n"
            "E002,archival,Memo,1989,Ministry,AGN,evidence/raw/archival/E002-memo.txt,2024,open,A,M,,\n"
            "E003,archival,Lost file,1989,Ministry,AGN,evidence/raw/archival/E003.pdf,2024,open,A,M,,\n")
        (p / "paper/sections/cases.tex").write_text(
            "``we would never accept the tax without compensation for exporters'' \\ev{E001}.\n"
            "``The ministry will not raise the export levy unless exporters receive compensation'' \\ev{E002}.\n"
            "``the export tax \\ldots{} through the exchange-rate regime'' \\ev{E002}.\n"
            "``we would never accept the tax without compensation'' \\ev{E002}.\n"
            "``exporters were the decisive constituency for every cabinet'' \\ev{E001}.\n"
            "``the ministry will not raise the export tax'' and nothing else.\n"
            "``the ministry will not raise the export tax'' \\ev{E003}.\n"
            "% ``a commented quotation that should be ignored entirely'' \\ev{E001}\n")
        r = run([sys.executable, str(BIN / "qualstack-quotecheck"), "--json"], cwd=p)
        data = json.loads(r.stdout)
        got = {q["line"]: q["status"] for q in data["quotes"]}
        assert got == {1: "verified", 2: "near", 3: "verified", 4: "elsewhere", 5: "not-found",
                       6: "uncited", 7: "unchecked"}, got
        assert r.returncode == 1


# ---------------------------------------------------------------- status


@test
def status_reports_evidence_trail_and_stage():
    with tempfile.TemporaryDirectory() as t:
        p = scaffold(Path(t))
        (p / "evidence/raw/archival").mkdir(parents=True)
        (p / "evidence/raw/archival/E001.txt").write_text("x")
        (p / "evidence/raw/archival/E009-unlogged.txt").write_text("x")
        (p / "evidence/log.csv").write_text(
            "id,type,title,date,author,source,file,accessed,access,cases,clues,reliability,notes\n"
            "E001,archival,Memo,1989,,AGN,evidence/raw/archival/E001.txt,2024,open,A,M,,\n"
            "E002,archival,Gone,1989,,AGN,evidence/raw/archival/E002.txt,2024,open,A,M,,\n")
        (p / "data/case-data.csv").write_text("case,X,M,Y\nA,1,1,1\nB,0,NA,0\n")
        (p / "data/coding-log.csv").write_text(
            "case,node,value,evidence_ids,rule_version,coder,confidence,note,date\nA,M,1,E001,v1,me,high,,2026\n")
        r = run([sys.executable, str(BIN / "qualstack-status"), "--json"], cwd=p)
        assert r.returncode == 0, r.stderr
        s = json.loads(r.stdout)
        ev = s["evidence"]
        assert ev["log_items"] == 2
        assert ev["unlogged"] == ["evidence/raw/archival/E009-unlogged.txt"]
        assert ev["missing_files"] == ["E002: evidence/raw/archival/E002.txt"]
        assert ev["coded_without_evidence"] == 4 and ev["na_share"]["M"] == 0.5
        assert s["derived_stage"] == "collect" and s["status_matches"] is False


@test
def status_conditional_requirements():
    with tempfile.TemporaryDirectory() as t:
        p = scaffold(Path(t))
        cfg = p / ".qualstack/config.yaml"
        text = cfg.read_text().replace("human_subjects: false", "human_subjects: true")
        cfg.write_text(text.replace("formal: true", "formal: false"))
        s = json.loads(run([sys.executable, str(BIN / "qualstack-status"), "--json"], cwd=p).stdout)
        req = {a["artifact"]: a["required"] for a in s["artifacts"]}
        assert req[".qualstack/interview-guide.md"] and req[".qualstack/fieldwork-plan.md"]
        assert not req["code/01-model.R"] and not req["output/tables/queries.csv"]


# ---------------------------------------------------------------- R tools


def r_function_source(path: Path, name: str) -> str:
    """The text of a top-level R function definition, through its closing brace."""
    lines = path.read_text().splitlines()
    start = next(i for i, l in enumerate(lines) if l.startswith(f"{name} <- function"))
    end = next(i for i in range(start + 1, len(lines)) if lines[i] == "}")
    return "\n".join(lines[start:end + 1])


@test
def graph_helpers_identical_in_both_r_assets():
    a = ROOT / "skills/clue-select/assets/clue-diagnosis.R"
    b = ROOT / "skills/robustness/assets/model-checks.R"
    for name in ("qs_graph", "qs_dconnected"):
        assert r_function_source(a, name) == r_function_source(b, name), f"{name} differs"


@test
def r_tools_reproduce_book_numbers():
    """Skipped (reported) when R or CausalQueries is not installed, as in CI."""
    probe = run(["Rscript", "-e", "quit(status = !requireNamespace('CausalQueries', quietly = TRUE))"]) \
        if subprocess.run(["which", "Rscript"], capture_output=True).returncode == 0 else None
    if probe is None or probe.returncode != 0:
        print("SKIP  r_tools_reproduce_book_numbers (R with CausalQueries not installed)")
        return
    r = run(["Rscript", str(ROOT / "tests/r/verify-book.R"), str(ROOT)])
    assert r.returncode == 0, r.stdout[-3000:] + r.stderr[-2000:]


# ---------------------------------------------------------------- lint


@test
def lint_passes():
    r = run([sys.executable, str(BIN / "qualstack-lint")])
    assert r.returncode == 0, r.stdout[-3000:]


def main():
    failed = 0
    for fn in RESULTS:
        try:
            fn()
            print(f"PASS  {fn.__name__}")
        except Exception:
            failed += 1
            print(f"FAIL  {fn.__name__}")
            traceback.print_exc()
    print(f"\n{len(RESULTS) - failed}/{len(RESULTS)} passed")
    return 1 if failed else 0


if __name__ == "__main__":
    os.environ.pop("CLAUDE_PLUGIN_ROOT", None)
    sys.exit(main())
