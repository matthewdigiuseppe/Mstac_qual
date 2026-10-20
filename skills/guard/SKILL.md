---
name: guard
description: Maximum-safety mode — /qualstack:careful plus /qualstack:freeze in one toggle, enforced by the QualStack hook.
argument-hint: "[directory]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Edit
---

# /qualstack:guard

**Stage:** power · **Voice:** safety

`$ARGUMENTS` is the directory to freeze writes to (as in `/qualstack:freeze`); if omitted, ask which.

## Procedure

1. Set `careful: true` in `.qualstack/safety.yaml` (as `/qualstack:careful` does).
2. Set `freeze.path` to the supplied directory (as `/qualstack:freeze` does).
3. Print the combined state. Both are enforced by the `PreToolUse` hook (`hooks/qualstack-guard.py`): destructive commands prompt for confirmation, writes outside the freeze path are denied.

## Outputs

- `.qualstack/safety.yaml` with both `careful: true` and `freeze.path`; summary of both flags + the freeze target.

## Next

`/qualstack:unfreeze` removes just the freeze (careful stays on); `/qualstack:careful off` removes just careful (freeze stays on).
