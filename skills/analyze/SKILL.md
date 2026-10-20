---
name: analyze
description: Runs the formal analysis — assembles one row per case with every model node (0/1/NA, untraced cases kept), updates the causal model once on all the evidence, and answers every query with prior next to posterior: population and subgroup answers with intervals, named-case answers asked the right way (cases in the data are never double-counted), what the data taught each part of the model, and which clues' probative value came from theory and which from data. Writes code/03-data.R, code/04-update.R, and output/tables/. Use when coding is complete, when the user wants the results, asks to update the model or "run CausalQueries", or after new evidence is coded.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(Rscript *)
  - Bash(date *)
---

# /qualstack:analyze

**Stage:** analyze · **Voice:** analyst

One model, one update, many queries (Humphreys & Jacobs 2023, chs. 9–10): the cross-case data and the traced cases enter a single likelihood, and every answer, about the population, a subgroup, or a named case, is read off the same posterior. This skill runs that pipeline and reads its output honestly.

## Procedure

1. **Load** `.qualstack/queries.md`, `.qualstack/model.md`, `.qualstack/case-selection.md` (the selection rule), `data/case-data.csv`, `data/coding-log.csv`, `data/coding-rules.md`, `code/01-model.R`, `.qualstack/config.yaml` (`model.seed`). Read `${CLAUDE_PLUGIN_ROOT}/references/mixed-methods.md`, `${CLAUDE_PLUGIN_ROOT}/references/r-conventions.md`, and grep `${CLAUDE_PLUGIN_ROOT}/references/causalqueries-cookbook.md` as needed. If `model.formal: false`, stop: the analysis is `/qualstack:process-trace` case by case.
2. **Preconditions.** `data/case-data.csv` was built from the coding log, not by hand (`/qualstack:code-evidence`); every coded value has evidence IDs; second-coder agreement exists. If not, say what is missing before running anything.
3. **Assemble** (`code/03-data.R`, from `${CLAUDE_PLUGIN_ROOT}/skills/analyze/assets/03-data-template.R`): cross-case data from `data/raw/` dichotomized by the rules in `data/coding-rules.md`, joined to the coded cases by `case`; conflicts between the dataset and the case coding stop the script; every case with any observed node stays, NA where not observed. The script's checks catch the silent failures (a misspelled column dropped, a non-0/1 value dropping a case). Run `Rscript code/03-data.R` and read the data-pattern table.
4. **Selection.** From the case-selection log: were clues sought by a rule on recorded values with every case kept (ignorable), or did anything related to outcomes decide (not ignorable: model the selection or narrow the claim)? Write the answer into the results notes; do not proceed silently.
5. **Update and query** (`code/04-update.R`, from `${CLAUDE_PLUGIN_ROOT}/skills/analyze/assets/04-update-template.R`): edit `CLUES` and `CELLS`, keep `SEED`, run `Rscript code/04-update.R`. Read `output/models/stan-warnings.txt`; any warning means raise `ITER` and re-run, never report around it.
6. **Read the results**, and record each point for `/qualstack:draft-section results`:
   - `output/tables/queries.csv`: prior vs. posterior for every query; size claims to posteriors and intervals.
   - `output/tables/case-answers.csv`: each traced case's answer is the share of cases like it (π̂; the case's data are already in the update); never also report a case-level φ̂ for it.
   - `output/tables/parameters.csv`: what the data taught each nodal-type share; a headline that barely moves can hide learning (II §10.1.4).
   - `output/tables/clue-value.csv`: label each clue **theory-derived** (moves the untrained answer), **data-derived** (moves only the trained one), **absent**, or **contradicted by data**.
   - Answers fixed by restrictions (exactly 0 or 1 in every model): report as assumptions.
   - Non-identified queries (the probability of causation for X = Y = 1 cases): report the posterior range and note that more cases cannot collapse it; `/qualstack:robustness` shows how much the prior drives it.
7. **Integrity.** `Rscript code/03-data.R` then `Rscript code/04-update.R` from a clean session reproduces `queries.csv` within Monte Carlo error; state the tolerance. Append to `decisions` in config anything chosen at this step (iterations, cells, clues), and set `paper.status: "analyzing"` if it is at an earlier stage.

## Outputs

- `code/03-data.R`, `code/04-update.R`; `data/clean/analysis-data.csv`.
- `output/models/model-updated.rds`, `output/models/stan-warnings.txt`; `output/tables/queries.csv`, `queries.tex`, `case-answers.csv`, `parameters.csv`, `clue-value.csv`.
- Summary block: the primary query prior → posterior with interval, the selection verdict, clue labels, answers that are assumptions, Stan diagnostics.

## Anti-patterns

- **Separate models for "the regression" and "the cases."** One model, one update.
- **Dropping untraced cases** or recoding NA as 0.
- **Double counting.** Updating on a case, then asking a case-level φ̂ question of it.
- **Reporting around Stan warnings.**
- **A probability of causation reported with false precision** when the query is not identified.

## Next

`/qualstack:robustness` (always), then `/qualstack:evidence-audit`, `/qualstack:viz`, `/qualstack:draft-section results`.
