#!/usr/bin/env python3
"""QualStack PreToolUse guard.

Enforces, inside any QualStack project folder (a directory tree containing
.qualstack/):

  1. restricted/ never enters the model's context. Identity keys, consent
     forms, unredacted transcripts, and recordings live there. Read, Grep,
     Glob, Write, and Edit calls on a path inside it are denied, and so are
     Bash commands that name it, glob into it, or scan the project root
     recursively without excluding it. The one sanctioned bridge is
     bin/qualstack-redact, which finds the key through .qualstack/config.yaml
     (so its command line never names restricted/) and prints only counts.
     Always on.
  2. Evidence and source inputs are read-only once they exist: evidence/raw/
     (documents, transcripts, and field notes as received or as written on the
     day), data/raw/ (datasets as acquired), and lit/pdf/ (source PDFs) are
     never edited, overwritten, or removed. New files may still be added; that
     is how /qualstack:evidence-log and /qualstack:pdf-ingest work. Always on.
  3. A registered preregistration is the contract. Once design.prereg_url is
     set in .qualstack/config.yaml, existing files under prereg/ are read-only;
     deviations go in a new dated addendum. Always on.
  4. /qualstack:freeze — while .qualstack/safety.yaml sets freeze.path, writes
     are denied outside that directory (.qualstack/ itself stays writable so
     /qualstack:unfreeze can clear the lock).
  5. /qualstack:careful — while careful: true, destructive commands and
     whole-file overwrites of manuscript, output, and coded-data files require
     explicit user confirmation (surfaced as a permission prompt).

Outside a QualStack project folder the hook is a no-op. Denials exit 2 (stderr
is fed back to Claude); confirmations emit the PreToolUse "ask" decision. The
hook is a backstop, not a sandbox: Bash analysis is best-effort pattern
matching, the Grep tool and ripgrep skip restricted/ because .ignore and
.gitignore list it, and the skills carry the same rules as instructions. For
identifiable data whose protocol forbids any third-party processing, the only
real protection is to keep it off this machine.
"""
import fnmatch
import json
import re
import shlex
import sys
from pathlib import Path

FILE_TOOLS = {"Write", "Edit", "MultiEdit", "NotebookEdit"}
READ_TOOLS = {"Read", "NotebookRead"}
CAREFUL_DIRS = ("paper", "output", "submission", "prereg", "data")
RESTRICTED = "restricted"
GLOB_CHARS = set("*?[")

RESTRICTED_REMEDY = ("restricted/ holds identifiable material and never enters the model's "
                     "context. Work from the pseudonymized copies in evidence/ "
                     "(/qualstack:deidentify makes them without Claude reading the originals).")

# Source inputs: additions are fine, mutation of an existing file is not.
# Each entry is (path prefix, where the change actually belongs).
READ_ONLY_DIRS = (
    ("evidence/raw/", "Evidence as received is the record: annotate it in evidence/memos/, "
                      "or add a corrected transcription as a new file and note it in evidence/log.csv."),
    ("data/raw/", "Fix it as a recode in code/03-data.R instead of editing the raw file."),
    ("lit/pdf/", "Edit the converted Markdown in lit/md/ instead of the source PDF."),
)
PREREG_REMEDY = ("The registered plan is the contract: record the change in a new dated "
                 "addendum (prereg/addendum-YYYY-MM-DD.md) and report the deviation in the paper.")

DESTRUCTIVE_BASH = [
    (re.compile(r"(^|[;&|]\s*|\s)rm\s"), "rm"),
    (re.compile(r"git\s+reset\s+--hard"), "git reset --hard"),
    (re.compile(r"git\s+checkout\s+--\s"), "git checkout --"),
    (re.compile(r"git\s+clean\s+-\w*f"), "git clean -f"),
    (re.compile(r"push\s+(\S+\s+)*(--force\b|--force-with-lease\b|-f\b)"), "force push"),
    (re.compile(r"sed\s+(-\w+\s+)*-i"), "sed -i"),
    (re.compile(r"\btruncate\s"), "truncate"),
]
MUTATING_BASH = DESTRUCTIVE_BASH + [
    (re.compile(r"(^|[;&|]\s*|\s)mv\s"), "mv"),
    (re.compile(r"(^|[;&|]\s*|\s)cp\s"), "cp"),
    (re.compile(r"\btee\s"), "tee"),
    (re.compile(r">>?\s*\S"), "shell redirection"),
]

# Flags whose argument is an exclusion pattern, not a target.
EXCLUDE_FLAGS = {"-path", "-ipath", "-wholename", "-name", "--exclude-dir", "--exclude",
                 "--glob", "-g", "--ignore", "-I", "-x", "--exclude-from", "--iglob"}
EXCLUDE_PREFIXES = ("--exclude-dir=", "--exclude=", "--glob=", "--iglob=", "--ignore=")
# Commands that walk a directory tree and would read or list restricted/.
RECURSIVE_SCANNERS = {"find", "tree", "du", "tar", "zip", "rsync"}
# Commands whose first operand is a pattern or script rather than a path.
PATTERN_COMMANDS = {"grep", "egrep", "fgrep", "rg", "ag", "sed", "awk", "perl"}


def allow():
    sys.exit(0)


def deny(reason):
    print(f"QualStack guard: {reason}", file=sys.stderr)
    sys.exit(2)


def ask(reason):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": f"QualStack careful mode: {reason}",
        }
    }))
    sys.exit(0)


def find_project(start):
    """Walk up from `start` to the nearest directory containing .qualstack/."""
    try:
        p = Path(start).resolve()
    except (OSError, RuntimeError):
        return None
    for candidate in [p, *p.parents]:
        if (candidate / ".qualstack").is_dir():
            return candidate
    return None


def read_flat_yaml(path):
    """Yield (section, key, value) from a simple two-level YAML file."""
    try:
        text = path.read_text()
    except OSError:
        return
    section = None
    for raw in text.splitlines():
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        indented = raw[:1] in (" ", "\t")
        line = raw.split(" #")[0].strip()
        key, _, value = line.partition(":")
        key, value = key.strip().lstrip("- ").strip(), value.strip().strip("\"'")
        if not indented:
            section = key if not value else None
            yield None, key, value
        else:
            yield section, key, value


def read_safety(project):
    """Parse .qualstack/safety.yaml without a YAML dependency.

    Understands the flat and two-level forms the safety skills write:
      careful: true
      freeze:
        path: "submission"
      freeze.path: submission
    """
    cfg = {"careful": False, "freeze_path": ""}
    for section, key, value in read_flat_yaml(project / ".qualstack" / "safety.yaml"):
        if section is None and key == "careful":
            cfg["careful"] = value.lower() == "true"
        elif section is None and key == "freeze.path":
            cfg["freeze_path"] = value
        elif section == "freeze" and key == "path":
            cfg["freeze_path"] = value
    return cfg


def prereg_registered(project):
    """True once the user has pasted a registry URL into design.prereg_url."""
    for section, key, value in read_flat_yaml(project / ".qualstack" / "config.yaml"):
        if section == "design" and key == "prereg_url" and value:
            return True
    return False


def resolve(path):
    try:
        return Path(path).resolve()
    except (OSError, RuntimeError):
        return Path(path)


def is_under(path, root):
    try:
        resolve(path).relative_to(resolve(root))
        return True
    except ValueError:
        return False


def absolute(path, cwd):
    p = Path(str(path)).expanduser()
    return p if p.is_absolute() else Path(cwd) / p


def split_command(command):
    """Shell-ish tokens; falls back to a regex split on unbalanced quotes."""
    try:
        return shlex.split(command, comments=False, posix=True)
    except ValueError:
        return re.findall(r"[^\s'\"]+", command)


def bash_paths(command, cwd, project):
    """Best-effort: tokens of a Bash command that resolve inside the project."""
    hits = []
    for token in re.findall(r"[\w~$./-]+", command):
        if "/" not in token and token not in ("data", "paper", "output", "lit", "evidence", "prereg"):
            continue
        if token.startswith("-") or token.startswith("$"):
            continue
        resolved = resolve(absolute(token, cwd))
        if is_under(resolved, project):
            hits.append(resolved)
    return hits


def ro_source_writes(command, cwd, project):
    """Return a description when the command would move, overwrite, or append
    to an existing file in a read-only source directory. Adding new files
    (cp or mv from elsewhere, a corrected copy beside the original) is fine."""
    def ro_file(token, base):
        t = resolve(absolute(token, base))
        return t.is_file() and any(is_under(t, project / d) for d, _ in READ_ONLY_DIRS)

    bases = [Path(cwd)]
    for segment in re.split(r"\|\||&&|[;|&\n]", command):
        if not segment.strip():
            continue
        for target in re.findall(r"\d?>>?\s*([^\s;&|<>]+)", segment):
            if any(ro_file(target, b) for b in bases):
                return f"shell redirection writes to {target}"
        tokens = [t for t in split_command(segment) if not re.match(r"\d?>", t)]
        while tokens and ("=" in tokens[0] or tokens[0] in ("sudo", "command", "nohup")):
            tokens = tokens[1:]
        if not tokens:
            continue
        cmd, operands = tokens[0], [t for t in tokens[1:] if not t.startswith("-")]
        if cmd in ("cd", "pushd") and operands:
            bases.append(absolute(operands[0], bases[-1]))
        elif cmd == "mv" and any(ro_file(o, b) for o in operands for b in bases):
            return "mv would move or rename a source file"
        elif cmd == "cp" and operands and any(ro_file(operands[-1], b) for b in bases):
            return f"cp would overwrite {operands[-1]}"
        elif cmd == "tee" and any(ro_file(o, b) for o in operands for b in bases):
            return "tee would overwrite a source file"
    return None


def glob_reaches(token, cwd, root):
    """True when a glob token has a component, sitting directly in the project
    root, that could expand to restricted/ (r*/key.csv, */notes.txt, *)."""
    base = Path(token).expanduser()
    parts = base.parts
    current = Path(parts[0]) if base.is_absolute() else Path(cwd)
    for part in (parts[1:] if base.is_absolute() else parts):
        if GLOB_CHARS & set(part):
            return resolve(current) == root and fnmatch.fnmatchcase(RESTRICTED, part)
        current = current / part
    return False


def bash_touches_restricted(command, cwd, project):
    """Return a reason string when the command could read or list restricted/."""
    root = resolve(project)
    restricted = root / RESTRICTED
    tokens = split_command(command)
    excluding = any(t.startswith(EXCLUDE_PREFIXES) and RESTRICTED in t for t in tokens) or any(
        prev in EXCLUDE_FLAGS and RESTRICTED in t for prev, t in zip(tokens, tokens[1:]))
    # Directories the command may run in: the cwd plus every `cd` target.
    bases = [Path(cwd)]
    for prev, t in zip(tokens, tokens[1:]):
        if prev in ("cd", "pushd") and not t.startswith("-"):
            bases.append(absolute(t, bases[-1]))
    # Search patterns and scripts are text, not paths: grep's first operand,
    # the argument of -e, sed's and awk's script.
    patterns = set()
    for i, t in enumerate(tokens):
        if Path(t).name in PATTERN_COMMANDS:
            explicit = False
            for j in range(i + 1, len(tokens)):
                if tokens[j] in (";", "&&", "||", "|"):
                    break
                if tokens[j] in ("-e", "--regexp", "-f", "--file"):
                    explicit = True
                    if j + 1 < len(tokens) and tokens[j] in ("-e", "--regexp"):
                        patterns.add(j + 1)
                elif not tokens[j].startswith("-") and not explicit:
                    if j - 1 not in patterns:
                        patterns.add(j)
                    break

    for i, token in enumerate(tokens):
        if not token or token.startswith("-") or i in patterns:
            continue
        prev = tokens[i - 1] if i else ""
        nxt = tokens[i + 1] if i + 1 < len(tokens) else ""
        if prev in EXCLUDE_FLAGS or token.startswith("!") or nxt == "-prune":
            continue  # an exclusion pattern, not a target
        for word in re.split(r"[=:,]", token):
            if not word:
                continue
            for base in bases:
                if RESTRICTED in word and not (GLOB_CHARS & set(word)):
                    target = resolve(absolute(word, base))
                    if target == restricted or is_under(target, restricted):
                        return f"it names {RESTRICTED}/"
                if GLOB_CHARS & set(word) and glob_reaches(word, base, root):
                    return f"the glob '{word}' can expand into {RESTRICTED}/"

    if excluding:
        return None
    # Recursive scans whose starting point contains restricted/.
    for i, token in enumerate(tokens):
        name = Path(token).name
        recursive = (
            name in RECURSIVE_SCANNERS
            or (name in ("grep", "egrep", "fgrep") and any(
                re.fullmatch(r"-\w*[rR]\w*", t) or t == "--recursive" for t in tokens[i + 1:]))
            or (name == "ls" and any(re.fullmatch(r"-\w*R\w*", t) for t in tokens[i + 1:]))
            or (name in ("rg", "ag") and any(
                t in ("--no-ignore", "-u", "-uu", "-uuu", "--unrestricted") for t in tokens[i + 1:]))
            or (name == "cp" and any(re.fullmatch(r"-\w*[rRa]\w*", t) for t in tokens[i + 1:]))
        )
        if not recursive:
            continue
        args = []
        for t in tokens[i + 1:]:
            if t in (";", "&&", "||", "|"):
                break
            if not t.startswith("-"):
                args.append(t)
        starts = args or ["."]
        if name in ("grep", "egrep", "fgrep", "rg", "ag") and len(args) >= 1:
            starts = args[1:] or ["."]  # first operand is the pattern
        for s in starts:
            if GLOB_CHARS & set(s):
                continue
            start = resolve(absolute(s, cwd))
            if start == root or is_under(root, start):
                return (f"'{name}' would walk the project root, including {RESTRICTED}/; "
                        f"use the Grep or Glob tool (they skip it), or exclude it explicitly "
                        f"(--exclude-dir={RESTRICTED}, -path ./{RESTRICTED} -prune)")
    return None


def main():
    try:
        event = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        allow()

    tool = event.get("tool_name", "")
    tool_input = event.get("tool_input") or {}
    cwd = event.get("cwd") or "."

    # ---- Read and search tools: only the restricted/ wall applies. ----
    if tool in READ_TOOLS or tool in ("Grep", "Glob"):
        target = (tool_input.get("file_path") or tool_input.get("notebook_path")
                  or tool_input.get("path") or "")
        start = absolute(target, cwd) if target else Path(cwd)
        project = find_project(start if start.is_dir() else start.parent)
        if project is None:
            allow()
        restricted = project / RESTRICTED
        if target and (resolve(start) == resolve(restricted) or is_under(start, restricted)):
            deny(RESTRICTED_REMEDY)
        path_glob = tool_input.get("glob") if tool == "Grep" else tool_input.get("pattern")
        if path_glob and re.search(r"(^|[/{,])" + RESTRICTED + r"([/},]|$)", path_glob):
            deny(RESTRICTED_REMEDY)
        allow()

    if tool in FILE_TOOLS:
        target = tool_input.get("file_path") or tool_input.get("notebook_path") or ""
        if not target:
            allow()
        target = absolute(target, cwd)
        project = find_project(target.parent)
        if project is None or not is_under(target, project):
            allow()
        rel = resolve(target).relative_to(resolve(project))
        rel_s = rel.as_posix()

        # Rule 1: the restricted wall.
        if rel.parts and rel.parts[0] == RESTRICTED:
            deny(f"{rel_s} is inside {RESTRICTED}/, which Claude never reads or writes; "
                 "the researcher manages that folder by hand.")

        # Rule 2: evidence and source inputs are immutable once they exist.
        if target.exists():
            for prefix, remedy in READ_ONLY_DIRS:
                if rel_s.startswith(prefix):
                    deny(f"{rel_s} is under {prefix}, which is read-only once the file "
                         f"exists. {remedy}")

        # Rule 3: a registered preregistration.
        if rel_s.startswith("prereg/") and target.exists() and prereg_registered(project):
            deny(f"{rel_s} is part of a registered preregistration (design.prereg_url is set). "
                 f"{PREREG_REMEDY}")

        safety = read_safety(project)

        # Rule 4: freeze lock (exempting .qualstack/ so /qualstack:unfreeze works).
        fp = safety["freeze_path"]
        if fp and not rel_s.startswith(".qualstack"):
            freeze_root = Path(fp) if Path(fp).is_absolute() else project / fp
            if not is_under(target, freeze_root):
                deny(f"freeze is active: writes are locked to {fp} (plus .qualstack/). "
                     f"{rel_s} is outside it. Run /qualstack:unfreeze to lift the lock.")

        # Rule 5: careful mode — confirm whole-file overwrites that hurt.
        if safety["careful"] and tool == "Write" and target.exists():
            top = rel.parts[0] if rel.parts else ""
            try:
                n_lines = sum(1 for _ in target.open(errors="ignore"))
                size = target.stat().st_size
            except OSError:
                n_lines, size = 0, 0
            if (top in CAREFUL_DIRS and size > 0) or n_lines >= 100:
                ask(f"overwriting existing {rel_s} ({n_lines} lines). Confirm before replacing it.")
        allow()

    if tool == "Bash":
        command = tool_input.get("command") or ""
        if not command:
            allow()
        project = find_project(cwd)
        if project is None:
            # A command run from outside may still name a project path.
            for token in split_command(command):
                if "/" in token and not token.startswith("-"):
                    candidate = absolute(token, cwd)
                    project = find_project(candidate if candidate.is_dir() else candidate.parent)
                    if project is not None:
                        break
        if project is None:
            allow()

        # Rule 1: the restricted wall.
        why = bash_touches_restricted(command, cwd, project)
        if why:
            deny(f"blocked because {why}. {RESTRICTED_REMEDY}")

        safety = read_safety(project)

        # Rule 2: destructive commands touching a read-only source directory.
        for prefix, remedy in READ_ONLY_DIRS:
            if prefix.rstrip("/") not in command:
                continue
            for pattern, label in DESTRUCTIVE_BASH:
                if pattern.search(command):
                    deny(f"'{label}' targets {prefix}, which is read-only once the "
                         f"files exist. {remedy}")

        why_ro = ro_source_writes(command, cwd, project)
        if why_ro:
            deny(f"{why_ro}, which is read-only once it exists. Add a new file instead "
                 "(a corrected copy beside the original, noted in evidence/log.csv), or "
                 "recode in code/03-data.R.")

        # Rule 3: mutating commands touching a registered preregistration.
        if "prereg" in command and prereg_registered(project):
            for pattern, label in MUTATING_BASH:
                if pattern.search(command) and any(
                        is_under(t, project / "prereg") and t.is_file()
                        for t in bash_paths(command, cwd, project)):
                    deny(f"'{label}' would change a registered preregistration. {PREREG_REMEDY}")

        # Rule 4: freeze lock for mutating commands.
        fp = safety["freeze_path"]
        if fp:
            freeze_root = Path(fp) if Path(fp).is_absolute() else project / fp
            mutates = next((label for pattern, label in MUTATING_BASH if pattern.search(command)), None)
            if mutates:
                targets = bash_paths(command, cwd, project)
                outside = [
                    t for t in targets
                    if not is_under(t, freeze_root) and not is_under(t, project / ".qualstack")
                ]
                if outside:
                    deny(f"freeze is active (writes locked to {fp}) and this '{mutates}' touches "
                         f"{outside[0]}. Run /qualstack:unfreeze first.")
                if not targets:
                    ask(f"freeze is active (locked to {fp}) and this '{mutates}' command's targets "
                        "could not be verified. Confirm it does not write outside the lock.")

        # Rule 5: careful mode — confirm destructive commands.
        if safety["careful"]:
            for pattern, label in DESTRUCTIVE_BASH:
                if pattern.search(command):
                    ask(f"'{label}' detected in a deadline-protected project. Confirm before running.")
            if re.search(r"(^|[;&|]\s*|\s)mv\s", command) and any(
                f"{d}/" in command for d in CAREFUL_DIRS
            ):
                ask("'mv' touches manuscript, output, or coded-data directories. Confirm before running.")
        allow()

    allow()


if __name__ == "__main__":
    main()
