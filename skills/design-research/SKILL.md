---
name: design-research
description: Sets the data strategy for a qualitative or multi-method study inside the causal model — single-case process tracing, small-N comparison, nested multi-method, or comparative-historical — what cross-case data exist or could be built, whether to go wide (more cases) or deep (more evidence per case) given costs, which cases and clues the design will rest on, how evidence becomes coded data, and what result would change the conclusion. Writes .qualstack/design.md and stubs the design section. Use after /qualstack:model-review passes, when the user asks how to design the study, how many cases, or whether to add cases or dig deeper.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(Rscript *)
  - Bash(date *)
---

# /qualstack:design-research

**Stage:** design · **Voice:** methodologist

The design is chosen by what it is expected to teach about the query under the model, at what cost (Humphreys & Jacobs 2023, chs. 12–14), not by the conventions of a method label. This skill sets the frame; `/qualstack:case-select` and `/qualstack:clue-select` do the detailed diagnosis inside it.

## Procedure

1. **Load** `.qualstack/research-question.md`, `.qualstack/queries.md`, `.qualstack/model.md`, the latest `.qualstack/model-review-*.md` (refuse to proceed on a `fail` verdict), `code/01-model.R`, `.qualstack/config.yaml`, and `data/raw/` (what cross-case data exist). Read `${CLAUDE_PLUGIN_ROOT}/references/design-diagnosis.md` and `${CLAUDE_PLUGIN_ROOT}/references/mixed-methods.md`.
2. **Design type** (set `design.type`): `process-tracing` (one or a few cases, untrained model; probative value comes from theory), `comparative` (small N; cases inform each other only through the population model, which needs uncertain λ and cases from one population), `multi-method` (cross-case data on many cases plus traced cases, one model and one update), `comparative-historical` (sequences and junctures; time-stamped nodes). Say which queries each type can answer: a single untrained case cannot teach about a population; population claims from a few cases need restrictions doing work, which must be defended.
3. **The population and the data in hand.** The population the model covers (cases where the outcome was possible), the cross-case data available for which nodes (source, coverage, measurement), and the cases already known. If cross-case data must be built, cost it.
4. **Wide or deep.** If adding cases (cross-case nodes only) is an option, elicit relative cost d (tracing a case vs. adding an X, Y case) and run a small grid with `qs_wide_deep()` (copy `${CLAUDE_PLUGIN_ROOT}/skills/case-select/assets/case-diagnosis.R` to `code/case-diagnosis.R`; start with `sims = 20` and a 2×2 grid; it runs one Stan update per simulated data set, so tell the user the runtime before starting). Check the conditions that favor depth (an observable possible confounder, pathway queries, strong model beliefs, modest N) and breadth (ATE in chain or two-path models). Never recommend a pure strategy without comparing a mix.
5. **Hand-offs, in order:** `/qualstack:case-select` (which cases to trace), `/qualstack:clue-select` (which clues in them, in what order, with what stopping rule), `/qualstack:coding-rules` (how evidence becomes node values), `/qualstack:fieldwork-plan` and `/qualstack:interview-guide` (if sources must be gathered in the field), `/qualstack:preregister` (before evidence is seen). Record which apply.
6. **Integration plan** for multi-method designs: all cases in one data set with NA for clues not sought; the selection rule recorded so that it is ignorable or modeled; which named-case questions will be π̂ (cases in the data) and which φ̂ (new cases).
7. **What would change the conclusion.** For the primary query: the posterior threshold that changes the paper's claim, and which clue findings, in which cases, could cross it (from the clue and case diagnoses once run). If no feasible finding could cross it, the design cannot answer the question: narrow it, or change the query.
8. **Ethics and access** headlines (`design.fieldwork`, `design.human_subjects`, `privacy.ai_processing` to be set), and the longest pole.
9. **Save** `.qualstack/design.md` with the rationale tables (or pointers to the case and clue memos once they exist) and stub `paper/sections/design.tex` with the design type, population, and the case and clue logic to be filled by `/qualstack:draft-section design`. Set `paper.status: "designing"` in `.qualstack/config.yaml` if it is at an earlier stage.

## Outputs

- `.qualstack/design.md` — design type and what it can answer, population and data in hand, wide/deep grid with costs (if run), hand-off list, integration plan, the conclusion-changing findings, ethics and access, timeline.
- `paper/sections/design.tex` stub; `design.type` in config; `code/case-diagnosis.R` if the grid ran.
- Summary block: design type, wide/deep recommendation with its cost assumption, next skills in order.

## Anti-patterns

- **Method label as design.** "A process-tracing study of three cases" says nothing about what the cases can teach.
- **Population claims from one untrained case.**
- **Pure strategies by habit.** Diminishing returns make mixes the default to beat.
- **Dropping the untraced cases** from the multi-method analysis.

## Next

`/qualstack:case-select`, then `/qualstack:clue-select`, `/qualstack:coding-rules`, `/qualstack:fieldwork-plan`, `/qualstack:preregister`.
