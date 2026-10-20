---
name: process-trace
description: Weighs the evidence for one case — assembles its coded clues and logged evidence, computes from the causal model how far each clue moved belief about the case query (the evidence path) and what each would have implied had it come out the other way (the counterfactual table), handles evidence outside the model with stated likelihood ranges, gets blind likelihood assessments from an assessor that does not know which explanation the author favors, checks dependence among sources, and states what finding would change the conclusion. Writes .qualstack/process-trace-<case>.md. Use when the user asks what the evidence shows in a case, whether X caused Y there, how strong a piece of evidence is, or wants a Bayesian process-tracing analysis.
argument-hint: "<case> [--blind]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Agent
  - Bash(Rscript *)
  - Bash(date *)
---

# /qualstack:process-trace

**Stage:** analyze · **Voice:** analyst

Evidence moves belief about a case only through likelihoods, and the likelihoods come from the model or from a stated, criticized judgment, never from the label "smoking gun" (Humphreys & Jacobs 2023, ch. 5, 7; Fairfield & Charman 2022). This skill shows the reader what each observation did and what it could have done.

## Procedure

1. **Load** for case `$ARGUMENTS`: its rows in `data/case-data.csv` and `data/coding-log.csv`, the `evidence/log.csv` rows naming the case, `.qualstack/chronology-<case>.md`, `.qualstack/clue-plan.md`, `.qualstack/queries.md`, `.qualstack/model.md`, the source critiques. Check `privacy.ai_processing` before opening any participant-derived file: with `none` (or empty), work from coded values and the log only. Read `${CLAUDE_PLUGIN_ROOT}/references/bayesian-process-tracing.md`.
2. **Sequence check.** The chronology must show the order the DAG assumes (cause before mediator before outcome) for every clue used; a clue realized after the outcome is a symptom or surrogate, not a mediator, and is treated as one.
3. **Choose the question** (`mixed-methods.md`): untrained single-case tracing (`using = "parameters"`); a case in the cross-case data the model was updated on (`using = "posteriors"`, `case_level = FALSE`, the share of cases like it); a new case not in that data (`case_level = TRUE`). Never update on the case and then ask a `case_level = TRUE` question of it.
4. **Model-based trace.** Copy `${CLAUDE_PLUGIN_ROOT}/skills/process-trace/assets/trace-case.R` to `code/trace-case.R`; call `qs_trace_case(model, query, known, clues, using, case_level)` with the known values (e.g. X, Y) and the clues in the order sought (from the coding log). Report the **evidence path** (posterior before any clue and after each) and the **counterfactual table** (posterior had each clue come out the other way, others as found). Note clues whose other value is impossible under the model, and answers fixed by restrictions (0 or 1 whatever the evidence: an assumption).
5. **Evidence outside the model.** For items no node represents (a speech, a pattern in a memo), use the informal route with `qs_informal_trace(prior, items)`: hypotheses that are exhaustive and mutually exclusive (restate rivals so they are; Zaks 2017); the prior from background knowledge stated in a sentence; for each item in a fixed order decided before reading, Pr(E | H) and Pr(E | not H) as ranges, with the source critique behind them; weight in decibels; the running posterior at both ends of the ranges.
6. **Blind assessment** (`--blind`, and always for the two or three items that move the posterior most): spawn the `qualstack:assessor` agent with a brief that gives a neutral case description, the explanations labeled only H-A, H-B, … in a meaningless order, the background facts, and the evidence item paths (only within what `privacy.ai_processing` allows). Compare its likelihoods with the author's; a gap larger than the author's own range is reported, not resolved silently. Log the assessor's use with `/qualstack:llm-checklist`.
7. **Dependence.** Items sharing an origin (one leak reported five times; a memoir and the interview built on it) count once: combine them before updating, in both routes.
8. **Robustness for this case.** Rerun the trace under the contested restrictions from the model review (or call `/qualstack:robustness` for the full battery): does the direction of each update survive? Sensitivity often depends on what was found (`model-justification.md`).
9. **What would change the conclusion.** The observation, not yet made or not obtainable, that would move the posterior across the decision threshold in `queries.md`; whether it was sought (and the search would have found it) or not.
10. **Save** `.qualstack/process-trace-<case>.md` and a dated memo `evidence/memos/<date>-process-trace-<case>.md` (narrative reasoning, citing E-IDs). Write the evidence path (`step, clue, value, posterior`) to `output/tables/trace-<case>.csv` and the counterfactual table to `output/tables/trace-<case>-counterfactual.csv`, for `/qualstack:viz` and the appendix. Set `paper.status: "analyzing"` in `.qualstack/config.yaml` if it is at an earlier stage.

## Outputs

- `.qualstack/process-trace-<case>.md` — the question and `using` setting; sequence check; evidence path; counterfactual table; informal items with likelihood ranges and decibels; blind vs. author likelihoods; dependence decisions; sensitivity of each update; the conclusion-changing observation; the posterior in words sized to its value.
- `evidence/memos/<date>-process-trace-<case>.md`; `output/tables/trace-<case>.csv`, `output/tables/trace-<case>-counterfactual.csv`; `code/trace-case.R`.
- Summary block: prior → posterior, the clue that moved it most, the clue that would have moved it most the other way, blind-assessment gaps, the conclusion in one hedged sentence.

## Anti-patterns

- **Test labels instead of likelihoods.** "It passed a hoop test" says nothing until the prior and φ's are stated.
- **Independent-looking echoes.** Five reports of one leak are one source.
- **Mechanism from occurrence.** The mediator happened; the path query is a different question.
- **Only the favored path traced.** Alternative-cause clues are often the most informative.
- **Likelihoods chosen after reading.** Use the clue plan's numbers, or say that they were set afterward and show the range.

## Next

Every traced case done → `/qualstack:analyze` (multi-method) or `/qualstack:robustness`; then `/qualstack:viz` and `/qualstack:draft-section cases`.
