---
name: unfreeze
description: Clears the /qualstack:freeze write lock; careful mode, if on, stays on.
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Edit
---

# /qualstack:unfreeze

**Stage:** power · **Voice:** safety

## Procedure

1. Read `.qualstack/safety.yaml`.
2. Remove the `freeze:` block (or empty its `path`); the guard hook stops denying outside writes as soon as no path is set.
3. Confirm writes are allowed everywhere again (apart from the always-on rules) and report the `careful` state, which this skill does not change.

## Outputs

- `.qualstack/safety.yaml` updated; summary: lock cleared, `careful` unchanged.
