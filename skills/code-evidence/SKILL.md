---
name: code-evidence
description: Applies the versioned coding rules to the logged evidence, case by case and node by node — one data/coding-log.csv row per case and node with the evidence IDs, rule version, coder, confidence, and the search behind every 0 — builds data/case-data.csv from the log by script, never by hand, and runs a blind second coding with the qualstack:coder agent, reporting percent agreement and Cohen's kappa per node before any disagreement is reconciled. Use when coding rules exist and evidence is logged, when the user asks to code cases, fill in the case data, record what the evidence shows for a node, check intercoder reliability, double-code, or recode a node after its rule changed.
argument-hint: "[case ...|blind|agree|build|recode <node>]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Agent
  - Bash(python3 *)
  - Bash(date *)
---

# /qualstack:code-evidence

**Stage:** collect · **Voice:** coder

NA means not observed; 0 means observed absent. A failed search coded 0 manufactures evidence, and a wrong 0 moves the posterior as far as a true one (Humphreys & Jacobs 2023). The coder applies the rule in force to every case alike, refuses to code silence as 0, never edits the case data by hand, and never shows a second coder the first coder's codes, the outcome, or the hypothesis.

## Procedure

1. **Preconditions.** Every statement node has a complete block in `data/coding-rules.md` (else `/qualstack:coding-rules`); the case's evidence is logged (else `/qualstack:evidence-log`). `Read ${CLAUDE_PLUGIN_ROOT}/references/concepts-and-coding.md`, sections "0 versus NA", "Coding procedure and the coding log", and "Reliability". Create `data/coding-log.csv` with the header `case,node,value,evidence_ids,rule_version,coder,confidence,note,date` if it is missing. `$ARGUMENTS`: case IDs to code (default: every logged case with uncoded nodes), `blind`, `agree`, `build`, or `recode <node>`. Today: `date +%Y-%m-%d`.
2. **Participant material checks `privacy.ai_processing`.** Empty or `none`: Claude reads no interview or field note; the researcher codes every value that rests on one and Claude records the rows as dictated. `pseudonymized`: only pseudonymized files in `evidence/raw/` that have a log row. A participant who declined AI processing is coded by the researcher alone, whatever the setting. Never `restricted/`.
3. **Outcome last.** Where the project allows, code the clue nodes across all cases before opening the evidence on the outcome, and the outcome node last. When the outcome is already known (most historical work), say so in the summary: the blind second coding is then the check.
4. **One case at a time, one node at a time**, under the rule version in force, from the items the log ties to that case and node (`cases`, `clues`), searches included. Apply `1 if`, `0 if`, `NA if` literally:
   - **1** only when the rule's Boolean condition is met;
   - **0** only on positive evidence of absence (a well-placed source denies it; a complete series is silent) or a logged search that would very probably have found it, cited by ID, with the series, the period, and why it records the property. Silence is not 0;
   - **NA** otherwise, saying whether the search fell short of the 0 standard or nobody looked. NA must not depend on the value: the same search in every case.
   A hard case takes the rule's hard-case clause and `low` confidence. A source conflict is settled by the precedence clause, with both IDs and `low` confidence; a tie is measurement error, not missingness, so it takes the default value. Deep-background material never codes a value by itself, and a withdrawn item codes nothing. What a 1 or a 0 needs never depends on the case's outcome or fit.
5. **One row per case and node**, NAs included, appended with Edit. `evidence_ids`: `;`-separated, all in `evidence/log.csv`. `rule_version`: the node's (`v2`). `coder`: the initials of whoever decided. Claude proposes each value with its clause and evidence and the researcher decides; the proposing is itself LLM annotation, logged once with `/qualstack:llm-checklist` as human-in-the-loop. If the researcher lets Claude decide unreviewed, `coder` is `llm:<task id>` and the ledger says fully automated. `confidence`: high, medium, or low (low: a plausible reading gives the other value). `note`: the clause applied, the search behind a 0, why NA, the raw level near a cut, any conflict, written for publication (no names, no confidential quotation). `date`: today. The log is append-only: a correction, an adjudication, or a recode is a new row, and the last row for a case and node is the value of record.
6. **Build**: `python3 ${CLAUDE_PLUGIN_ROOT}/skills/code-evidence/assets/coding-tools.py build` writes `data/case-data.csv` (`case`, then one column per node; values `0`, `1`, `NA`; NA = not observed) from the rows of record. It refuses on a value outside 0/1/NA, a row under an old rule version, a 0 or 1 with no evidence or citing an unknown or withdrawn item, a 0 with no note, a missing case-and-node row, or rule nodes that differ from the model statement. Fix the log, not the output; never edit `data/case-data.csv` by hand.
7. **Blind second coding** (`blind`). All cases when N is small; otherwise a random sample drawn with `model.seed` and fixed before anyone looks at the first codes, plus the hard cases, reported apart. In `.qualstack/review-cache/coding-<date>/` write:
   - `rules-blind.md`: the blocks of the nodes to be coded, without the model statement, the outcome's block, anchors marked `(in sample)`, or change-log lines that mention cases;
   - `brief.md`: the path to `rules-blind.md`, the nodes (clue nodes, never the outcome), the cases, and per case the evidence IDs with their paths in `evidence/raw/` or `evidence/md/`, only items `privacy.ai_processing` allows. An item written after the outcome was known is left out, or listed as a copy (`excerpts/E014.md`) with the outcome passages replaced by `[outcome passage removed]`; say which. Nothing else: no first codes, no `data/case-data.csv`, no outcome, no hypothesis, no model, memos, or manuscript.
   Spawn the `qualstack:coder` agent with `brief.md` as its prompt. Save its CSV verbatim as `coder-b.csv` and its rule problems as `rule-problems.md`; its values never enter the log directly. If Claude proposed the first codes, an LLM second coder may share Claude's blind spots: a human second coder on a sample is the stronger check, and the report says which was used.
8. **Agreement before adjudication** (`agree`): `python3 ${CLAUDE_PLUGIN_ROOT}/skills/code-evidence/assets/coding-tools.py agree data/coding-log.csv .qualstack/review-cache/coding-<date>/coder-b.csv --out .qualstack/review-cache/coding-<date>/agreement.md`. Per node it reports the 0/1/NA cross-tab, percent agreement, Cohen's (1960) kappa with NA as a category and on 0/1 pairs only, positive and negative specific agreement, value-versus-NA splits, and the base rate. Report kappa beside the base rate: 20 cases with 19 coded 1 by each coder, but not the same 19, give 90% agreement and kappa = −0.05.
9. **Reconcile** each disagreement in `agreement.md` by the rule's clauses, never by which value fits: the clause, the evidence IDs, the final value. Append the final value to the log with `coder` = `adjudicated` and a note citing `agreement.md`. Count the resolutions that went to each coder and those that moved values toward the hypothesis. A disagreement that exposes an ambiguous rule goes to `/qualstack:coding-rules` (new version, full recode). Rebuild (step 6).
10. **Log the instrument**: `/qualstack:llm-checklist log`, with the model and version, the date, `brief.md` as the user prompt and `agents/coder.md` at the plugin version as the system prompt, what the agent saw at which `privacy.ai_processing` level, and the agreement statistics as validation.
11. **Recode** (`recode <node>`) after a version change: every case on that node under the new version, as new rows (old rows stay), then rebuild and report each value that changed. Never recode only the cases that hurt.

## Outputs

- `data/coding-log.csv` (appended rows); `data/case-data.csv` (built, never edited).
- `.qualstack/review-cache/coding-<date>/`: `brief.md`, `rules-blind.md`, `coder-b.csv`, `agreement.md`, `rule-problems.md`, and any `excerpts/`.
- Summary block: cases × nodes coded; per node the counts of 1, 0, and NA and the NA share; each 0 with its search; low-confidence values (flips for `/qualstack:robustness`); the agreement table; adjudications (how many, to which coder, toward the hypothesis); rule problems; whether the outcome was known when coding; the next step.

## Anti-patterns

- **Silence coded 0.** A 0 cites positive evidence of absence or a search that would have found the property.
- **Searching only where the clue is expected.** An NA that depends on the value biases the update.
- **Hand-edited case data.** It drifts from the log, and `/qualstack:evidence-audit` will find the drift.
- **A brief that leaks.** Outcomes, hypotheses, first codes, in-sample anchors.
- **Pasting in the second coder's values.** They are adjudicated by the rule, value by value.
- **Kappa without the base rate.** At extreme base rates it misleads.
- **Recoding only the cases that hurt.**

## Next

`/qualstack:process-trace` per case; `/qualstack:analyze` once `data/case-data.csv` builds; `/qualstack:robustness` for low-confidence values and contested codings; an ambiguous rule → `/qualstack:coding-rules`, then `/qualstack:code-evidence recode <node>`.
