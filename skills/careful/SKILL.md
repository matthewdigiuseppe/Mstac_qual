---
name: careful
description: Toggles warn-before-destructive mode for this project — a QualStack hook then requires confirmation before rm, git reset, force-push, or overwriting manuscript, output, prereg, or coded-data files. Use near deadlines or before autonomous work on a submission-ready project; run with argument off to disable.
argument-hint: "[off]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Edit
---

# /qualstack:careful

**Stage:** power · **Voice:** safety

A mechanism, not a promise: the `PreToolUse` hook (`hooks/qualstack-guard.py`) runs before every `Write`, `Edit`, and `Bash` call, and while `.qualstack/safety.yaml` has `careful: true` the actions below become confirmation prompts, even in a fresh session that never loaded this skill.

## Procedure

1. Read or create `.qualstack/safety.yaml` (default `careful: false`).
2. Set the top-level line `careful: true` (or `false` if `$ARGUMENTS` is `off`); the hook parses exactly this shape.
3. Tell the user what now prompts for confirmation:
   - `rm`, `git reset --hard`, `git checkout --`, `git clean -f`, force push, `sed -i`, `truncate`;
   - `mv` touching `paper/`, `output/`, `submission/`, `prereg/`, or `data/`;
   - `Write` replacing an existing non-empty file under those directories, or any existing file of 100+ lines.
   Reads, greps, targeted `Edit`s, and writes to `.qualstack/`, `code/`, and `evidence/memos/` proceed normally. Independent of this toggle and always on: `restricted/` is never read or written, `evidence/raw/`, `data/raw/`, and `lit/pdf/` are read-only once a file exists, and a registered preregistration is locked.
4. Print the state: careful mode `<on|off>`, enforced by the QualStack guard hook.

## Outputs

- `.qualstack/safety.yaml` updated; summary of the current state.

## Anti-patterns

- **Bypassing while on.** A confirmed prompt covers that command only; never flip the flag off to avoid future prompts unless the user runs `/qualstack:careful off`.

## Next

Pair with `/qualstack:freeze`; both together is `/qualstack:guard`.
