---
name: clue-select
description: Decides which evidence to look for in each traced case, and in what order, from the causal model — screens out clues that cannot be informative (d-separation), then for each candidate clue and clue set reports the chance of finding it, the posterior either way, the likelihoods (phi1, phi0), probative value if found and if absent, the implied test type (hoop, smoking gun, doubly decisive, straw in the wind), and expected learning; builds two-step search plans with costs and their frontier; and fixes the clue plan with likelihoods and stopping rules before evidence is seen. Writes .qualstack/clue-plan.md. Use when the user asks what to look for in the archive or interviews, whether a piece of evidence would be a smoking gun or a hoop test, or how to sequence fieldwork.
argument-hint: "[case or case type]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(Rscript *)
  - Bash(date *)
---

# /qualstack:clue-select

**Stage:** design · **Voice:** methodologist

A clue's value comes from the model and from how uncertain we are about what we will find, not from where it sits on the hypothesized path (Humphreys & Jacobs 2023, ch. 7, 12). Moderators and alternative causes often beat mediators; clues are valued jointly; a test label is an output of the likelihoods, never an input.

## Procedure

1. **Load** `.qualstack/queries.md`, `.qualstack/case-selection.md` (the cases and what is known about them), `.qualstack/theory.md` (clue positions), `.qualstack/model.md`, `code/01-model.R`, and if the model has been updated on cross-case data, `output/models/model-updated.rds`. Read `${CLAUDE_PLUGIN_ROOT}/references/bayesian-process-tracing.md` and the clue section of `${CLAUDE_PLUGIN_ROOT}/references/design-diagnosis.md`.
2. **Candidates.** Every node that could be observed in the case, by position: mediators, moderators, alternative causes, symptoms of the query, surrogates for unobserved X or Y. If the theory names evidence that is not a node, it cannot be evaluated here: add the node (`/qualstack:causal-model`) or mark it for the informal route in `/qualstack:process-trace`.
3. **Which model answers.** Untrained single-case tracing: `using = "parameters"` at the prior means. Model updated on cross-case data: `using = "posteriors"`, with `case_level = TRUE` for a case not in the update data and `case_level = FALSE` for a case already in it (`mixed-methods.md`). Say which, per case.
4. **Compute.** Copy `${CLAUDE_PLUGIN_ROOT}/skills/clue-select/assets/clue-diagnosis.R` to `code/clue-diagnosis.R` and add a clue section to `code/02-design.R`, for each case type to be traced (its known values as `given`):
   - `qs_clue_screen(model, query_nodes, clues, observed)`: drop d-separated clues;
   - `qs_clue_table(model, query, given, clues, using)`: chance of finding, posterior if found and if not, φ1, φ0, probative value both ways, test type, expected learning;
   - `qs_strategy_table(model, query, given, strategies, using)`: the sets the user could afford;
   - `qs_two_step(model, query, given, clues, prices, using)` when clues can be sought in sequence; prices are elicited costs (archive days, interviews, travel), not guesses made for the user.
   Run `Rscript code/02-design.R`; write `output/tables/clue-diagnosis.csv` and `output/tables/clue-frontier.csv`.
5. **Interrogate the table.** Flag clues implied by what is known, clues whose finding is nearly certain, clues valuable only in combination or worthless after another clue, rankings that change between case types. Re-run under each contested restriction or prior from the latest model review: does the top clue survive? Report whether the top clue is a mediator, a moderator, or an alternative cause.
6. **Sources and reliability.** For each chosen clue: where it would be found (archives, interviewees, sites; the source map for `/qualstack:fieldwork-plan`), the chance a search finds it if it exists, and the chance a source reports it falsely. If those error rates are material, the clue enters the model as true K → reported Kr (`evidence-and-sources.md`), and its value is recomputed: a clue a source finds half the time is worth much less.
7. **The plan.** Per case: the clues in order, the conditional second step (if any), the stopping rule ("stop when the remaining expected learning per day is below …"), and for each clue the likelihoods φ1, φ0 that `/qualstack:preregister` can lock, with the test type they imply.
8. **Save** `.qualstack/clue-plan.md`.

## Outputs

- `.qualstack/clue-plan.md` — per case type: screen, clue table, set table, frontier with prices and the chosen point, ranking under contested restrictions, sources and error rates, the ordered plan with stopping rules and likelihoods.
- `code/02-design.R` (clue section), `code/clue-diagnosis.R`, `output/tables/clue-diagnosis.csv`, `output/tables/clue-frontier.csv`.
- Summary block per case type: the top clue and its position, its expected learning and test type, the chosen sequence, the stopping rule.

## Anti-patterns

- **Mediators by default.** The path is not where probative value lives by right.
- **Test labels before likelihoods.** "The memo would be a smoking gun" is a claim to compute.
- **Ranking singletons and adding them up.** Value is joint.
- **Dramatic but improbable findings.** A clue that would settle everything if found, but almost surely will not be, is a long shot; price it as one.
- **Likelihoods revised after the evidence is in.** The plan's numbers are dated before collection.

## Next

`/qualstack:coding-rules` (what counts as each clue's 1, 0, and NA), `/qualstack:fieldwork-plan`, `/qualstack:preregister`.
