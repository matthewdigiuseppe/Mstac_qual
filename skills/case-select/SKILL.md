---
name: case-select
description: Chooses which cases to study in depth by computing, under the project's causal model and query, the expected posterior variance of every candidate strategy — on or off the regression line, positive cases, fixing X or Y, most-similar pairs, named cases — given the cross-case data already in hand, then fixes the selection rule and the selection log so that the choice is ignorable. Replaces generic rules (typical, deviant, most-likely, never select on Y) with numbers. Writes .qualstack/case-selection.md and the case section of code/02-design.R. Use when the user asks which or how many cases to pick, defends a case choice, or a reviewer questions it.
argument-hint: "[strategy names or cases to compare]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(Rscript *)
  - Bash(date *)
---

# /qualstack:case-select

**Stage:** design · **Voice:** methodologist

Which cases are worth tracing depends on the model, the query, and the data already seen, so no generic rule survives contact with a specific project (Humphreys & Jacobs 2023, ch. 13). This skill computes the comparison the rules gesture at, and refuses to justify a case by a label alone.

## Procedure

1. **Load** `.qualstack/queries.md`, `.qualstack/design.md`, `.qualstack/model.md`, `code/01-model.R`, `output/models/model.rds`, and the cross-case data (`data/raw/`, or `data/clean/analysis-data.csv` if `/qualstack:analyze` has built it). Read `${CLAUDE_PLUGIN_ROOT}/references/design-diagnosis.md` (case selection, and the literature table) and the selection section of `${CLAUDE_PLUGIN_ROOT}/references/mixed-methods.md`.
2. **Purpose first.** Is the target a named case, a case type, or the population? Is the depth for model updating (the default here), for checking measurement of X and Y, or for discovering omitted nodes (theory building, which has no expected-learning number: say so and choose by that purpose)? Write it down.
3. **The candidate set.** The population and the cases with data (one row per case, model-node columns, 0/1/NA), their observed values, and practical constraints (access, language, sources). With no cross-case data yet, the comparison runs on the model's priors.
4. **Strategies to compare**, as conditions on observed values, one per case to be traced: the user's preferred choice; the generic alternatives (one or two on the line, off the line, two positive cases, fix X, fix Y); any named pair. Include at least one strategy the user did not propose.
5. **Compute.** Copy `${CLAUDE_PLUGIN_ROOT}/skills/case-select/assets/case-diagnosis.R` to `code/case-diagnosis.R` and add to `code/02-design.R`: load the model; `set.seed(SEED)`; update once on the data in hand with clues NA (`update_model(model, data)`; with no data, `update_model(model)` gives prior draws); then `qs_case_strategies(updated, query, strategies, clues, given, data = data)`. Run `Rscript code/02-design.R`; write the strategy table and `attr(res, "patterns")` to `output/tables/case-diagnosis.csv` and `case-patterns.csv`. Check `min_ess` (raise iterations if it is below a few hundred) and the warning for strategies needing more cases than a cell holds.
6. **Read the numbers against the rules** (`design-diagnosis.md`): under an unrestricted model one traced case teaches nothing about a population; two cases can; the case of interest may not be the case to study; a strategy whose findings are nearly certain teaches little; expected learning is usually modest, so report its size. Re-run under each contested restriction from the latest model review: does the ranking survive?
7. **Wide or deep**, if more cross-case data could be gathered instead: `qs_wide_deep()` with the relative cost from `.qualstack/design.md` (slow; tell the user the runtime first).
8. **Fix the rule and the log.** The selection rule in words (which cells, how cases within a cell are chosen: at random among those with accessible sources, or by a stated criterion), and a selection-log table in `.qualstack/case-selection.md` with one row per traced case: case, rule, the observed values the rule used, date chosen, and any case dropped and why. Selection on recorded values with every case kept in the data is ignorable; selection on anything related to outcomes that is not in the data is not (`mixed-methods.md`): model it or narrow the claim.
9. **Save** `.qualstack/case-selection.md`: purpose, candidate set, strategies and their EPV and expected learning, the pattern table for the chosen strategy (what each finding would do), ranking under contested restrictions, the chosen strategy and rule, the selection log.

## Outputs

- `.qualstack/case-selection.md`; `code/02-design.R` (case section); `code/case-diagnosis.R`; `output/tables/case-diagnosis.csv`, `output/tables/case-patterns.csv`.
- Summary block: the purpose, the top strategies with expected learning, whether the ranking survives the contested restrictions, the chosen cases, the selection rule.

## Anti-patterns

- **A label as a reason.** "Most-likely case", "deviant case", "on the line" without the computed comparison.
- **Selecting for access and calling it design.** If access decided, log it, and ask whether access relates to the outcome.
- **One case, population claims.** Say which restriction makes one case informative, or trace two.
- **Dropping the cases not traced.** They stay in the data with NA clues.

## Next

`/qualstack:clue-select` for the chosen cases, then `/qualstack:fieldwork-plan`. If the model changes, re-run: `/qualstack:paper-status` marks this memo stale.
