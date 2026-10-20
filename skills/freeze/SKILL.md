---
name: freeze
description: Locks writes to a single directory — a QualStack hook denies edits anywhere else in the project folder until /qualstack:unfreeze. Use during R&R to protect submission/, while coding to fence Claude into data/, or to keep Claude inside one part of the project.
argument-hint: "<directory>"
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Edit
---

# /qualstack:freeze

**Stage:** power · **Voice:** safety

`$ARGUMENTS` is the directory writes stay inside, relative to the project folder (`submission`, `paper/sections`, `data`). Without an argument do **not** lock: print the current state from `.qualstack/safety.yaml` and ask which directory; a lock on the whole folder is a no-op that gives false comfort.

Enforcement is the `PreToolUse` hook (`hooks/qualstack-guard.py`): while `freeze.path` is set, writes outside it are denied by the hook itself, including in later sessions that never loaded this skill. `.qualstack/` stays writable so the lock can be cleared; the always-on rules (`restricted/` off limits, `evidence/raw/`, `data/raw/`, and `lit/pdf/` read-only, a registered prereg locked) hold regardless.

## Procedure

1. Read or create `.qualstack/safety.yaml`.
2. Set the lock in exactly this shape:

   ```yaml
   freeze:
     path: "submission"
     set_at: "YYYY-MM-DD HH:MM"
   ```

3. Tell the user what the hook now does: `Write` / `Edit` outside the path (and outside `.qualstack/`) denied; mutating Bash (`rm`, `mv`, `cp`, redirects, `sed -i`, `git reset/clean/checkout --`) with targets outside the lock denied, and asked about when the targets cannot be resolved; reads, greps, and non-mutating commands unaffected.
4. Print the lock state with the absolute path of the target.

## Outputs

- `.qualstack/safety.yaml` updated; summary with the lock target.

## Anti-patterns

- **Working around the lock.** If a step needs a write outside, surface it and ask; do not restructure the work to dodge the hook.

## Next

`/qualstack:unfreeze` clears it; with `/qualstack:careful` it is `/qualstack:guard`.
