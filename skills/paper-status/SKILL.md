---
name: paper-status
description: Reports where a project stands from its .qualstack/ memory and pipeline outputs — stage, missing artifacts, stale memos, the integrity of the evidence trail (unlogged files, missing files, coded values with no evidence), and the one recommended next skill. Use when the user asks where they left off or what's next, wants a status check, or opens a session on an existing project.
allowed-tools:
  - Bash(python3 *)
  - Read
  - Grep
  - Glob
  - Edit
---

# /qualstack:paper-status

**Stage:** any · **Voice:** project-manager

Opening a session, returning after a gap, "where were we?", "what's next?". Read-only apart from an offered `paper.status` correction.

## Procedure

1. **Inventory in one call:**

   ```bash
   python3 "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-status"
   ```

   It finds `.qualstack/` at or above the current directory (exit 1 and a pointer to `/qualstack:qualstack-init` if there is none), reads `.qualstack/config.yaml`, and prints: every pipeline artifact by stage with its state (present / thin / stub / missing / optional), date, and verdict line, where `thin` means the file exists but is too small or too repetitive to be a real artifact of its kind; memos that are stale because an input changed after they were written (a model review older than `code/01-model.R`, coded case data older than the coding rules, a process-tracing memo older than the evidence log, PDFs dropped in `lit/pdf/` but never ingested); the **evidence trail** (files in `evidence/raw/` that no log row names, log rows whose files are missing, duplicate IDs, log rows pointing into `restricted/`, and coded values in `data/case-data.csv` with no evidence row in `data/coding-log.csv`); the stage the artifacts imply; whether that matches `paper.status`; and the required artifacts still missing up to that stage. Requirements follow the config: `design.fieldwork` / `design.human_subjects` make the fieldwork plan and interview guide required, and `model.formal: false` (informal Bayesian process tracing only) drops the model code and query table. Do not re-derive any of this with your own globs and greps.
2. **Spot-check what the verdict rests on.** Open every artifact the script marks `thin`, and the one `present` artifact that anchors the derived stage (the furthest one). If any of them is placeholder text, say so and derive the stage yourself from the last real artifact; the script's heuristics are size and repetition, and your reading beats them.
3. **Reconcile `paper.status`.** If the script's derived stage, or your corrected one, disagrees with config, say so and offer to update the field in `.qualstack/config.yaml`; never change it unasked.
4. **Recommend exactly one next step:** the earliest required gap wins over a shinier later stage; a stale memo counts as a gap; a broken evidence trail (unlogged files, coded values with no evidence) outranks anything downstream of it, because every later artifact inherits the break. Name the skill and the reason in one sentence.

## Outputs

A printed report, in this order, and nothing written to the project folder:

1. **The config lines** as the script prints them: title, `paper.status`, design, prereg, model statement and primary query, privacy setting, target journals.
2. **Bottom line, four short sentences (under 80 words):** the stage and whether it matches `paper.status`; which memos are stale (a placeholder is a gap, not a stale memo); the state of the evidence trail; the one next skill and why.
3. **One per-stage table**, the script's rows with your spot-check corrections already applied (state, date, verdict or a short note). One table is the inventory; do not paste raw script output and then re-summarize it.
4. **Only what changes the next step:** a placeholder you found behind a `present` or `thin` label, a mismatch to correct, the unlogged files by name.

Write for the author, not about the process: no "the script says", no state-versus-correction columns, no mention of which heuristic decided what. Report the corrected state and, where you overrode the script, one short note in the row.

With consent only: `paper.status` corrected in `.qualstack/config.yaml`.

## Anti-patterns

- **Guessing the stage from the conversation.** The artifacts on disk are the record, and the script reads them.
- **Three next steps.** One; the pipeline is ordered for a reason.
- **A stub counted as done.** The script strips template comments before deciding; trust its `stub` state, open anything it calls `thin`, and spot-check the artifact the stage rests on.
- **Ignoring the evidence trail.** An unlogged document cannot be cited, quote-checked, or archived; a coded value with no evidence row cannot be defended.
- **A report longer than the project's problems.** Bottom line, one table, then only what changes the next step.
