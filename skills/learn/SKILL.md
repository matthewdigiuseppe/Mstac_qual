---
name: learn
description: Appends a project-specific fact — node names, case labels, coding conventions, design decisions, quoting and formatting preferences — to .qualstack/learnings.jsonl so every later skill applies it. Use whenever the user states a convention Claude should remember, or repeats a correction twice.
argument-hint: "<fact to remember>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(date *)
---

# /qualstack:learn

**Stage:** power · **Voice:** memory

For any project-specific fact the user has had to say twice; it belongs in the project's memory, not their head. `$ARGUMENTS` is the fact, free-form.

## Procedure

1. **Classify:** `node_name` (a model node, its meaning, its coding), `case` (case labels, case boundaries, periods), `convention` (analytical or coding practice specific to this project), `decision` (design or framing, with rationale), `preference` (output, quoting, formatting, style), `reference` (an external resource: an archive, a collection, a dataset), or `other`.
2. **Screen for identifying content.** A learning is read by every later skill and may end up in the archive: never store a real name, a key entry, or a detail that would identify a participant. Use the pseudonym; if the fact is itself identifying, it belongs in `restricted/`, which the user maintains by hand.
3. **Normalize:** trim whitespace and trailing punctuation; capitalize the sentence.
4. **Append** one line to `.qualstack/learnings.jsonl`:

   ```json
   {"date":"YYYY-MM-DD","kind":"<class>","fact":"<normalized fact>"}
   ```

5. **Echo** the line so the user can confirm.
6. **Scope hint.** If the fact generalizes across projects (a methods habit, a tooling preference, a writing rule), suggest also adding it to global memory (`~/.claude/CLAUDE.md`) rather than only here.

## Outputs

- `.qualstack/learnings.jsonl` — one new line; summary with the scope hint if any.

## Anti-patterns

- **Transient state.** "Currently coding the Chile case" is conversation, not memory.
- **What the files already encode.** The coding rules, the model code, and the evidence log are the memory for what they hold.
- **Identifying details.** Pseudonyms only.
