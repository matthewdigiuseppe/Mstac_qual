---
name: robustness
description: Asks whether the causal model is doing more harm than good and how much the conclusions depend on it — tests the conditional independencies the model implies (refusing tests that condition on a selected collider), posterior predictive checks with dependence statistics, leave-one-out comparison against weaker rival models, a sensitivity table over dropped and softened restrictions, added arrows and confounding, and grids of key type shares (by possible finding, for population and case-level answers), plus influence of single cases, single sources, and confidential evidence — with a stable / sensitive / fragile verdict and the assumptions most in need of defense. Writes code/05-robustness.R and .qualstack/robustness-<date>.md. Use after /qualstack:analyze or process tracing, or when the user or a referee asks whether results depend on monotonicity, priors, or the DAG.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(Rscript *)
  - Bash(date *)
---

# /qualstack:robustness

**Stage:** analyze · **Voice:** skeptical-analyst

Every model is wrong; the question is whether this one is unacceptably inconsistent with the data, and which of its contestable parts the conclusions hang on (Humphreys & Jacobs 2023, ch. 16). Show the variants that could break the result, not the ones that will not.

## Procedure

1. **Load** `code/01-model.R`, `code/04-update.R`, `output/tables/queries.csv`, `data/clean/analysis-data.csv`, `.qualstack/queries.md`, the latest `.qualstack/model-review-*.md` (its rival-model list), the `.qualstack/process-trace-*.md` memos, `evidence/log.csv` (access tiers), and `prereg/prereg.md` if it exists (pre-committed checks run first, as committed). Read `${CLAUDE_PLUGIN_ROOT}/references/model-justification.md`.
2. **Set up** `code/05-robustness.R`: copy `${CLAUDE_PLUGIN_ROOT}/skills/robustness/assets/model-checks.R` to `code/model-checks.R` and source it; `SEED` from `model.seed`; write every table to `output/tables/robustness-*.csv` and the objects to `output/models/robustness.rds`.
3. **Implied independencies** — `qs_ci_tests(model, data)`. Read the notes: a test the function marks invalid (cases observing both nodes all share a collider's value) is reported as untestable in these data, not as passed. A dependence given a mediator may reflect unobserved confounding rather than a violation; say which.
4. **Posterior predictive checks** — `qs_ppc(updated, data, stats)`, with statistics that target the model's independence claims (correlations of cause with outcome, cause with mediator, alternative cause with outcome), not only means. The replicates copy the data's missingness by the observed values, the same assumption the analysis makes. Bayesian p-values are warning lights: report them with that caveat.
5. **Rival models** — build the variants from the model review as functions of the base code (each restriction dropped, each softened to a quantitative prior, each plausible missing arrow added, each exclusion relaxed with `<->`, each rival theory). Compare the base model with at least one weaker rival by `qs_loo(model, data)` (one Stan run per distinct data pattern: tell the user the runtime). Expect the asymmetry: a weaker model loses little when the stronger one is right.
6. **Sensitivity table** — `qs_sensitivity(variants, queries, given, data)` for population and subgroup queries, and per traced case `qs_trace_case()` (from `code/trace-case.R`, copied by `/qualstack:process-trace`) under each variant with `using` as in `/qualstack:process-trace`. Report by possible finding: a conclusion robust when a clue was found can be fragile had it not been. Flag answers fixed by the base model's restrictions (`base_determined`), sign flips, and crossings of .5.
7. **Influence** — (a) each traced case: set its clues to NA, re-update, report the change in the primary query; (b) each source cluster that supplies a clue value alone: set those values to NA; (c) confidential evidence: set clue values resting only on `access = confidential` items to NA and report how much the conclusion depends on evidence readers cannot see (`transparency-and-ethics.md`); (d) measurement: for clues with material error rates, the variant with true K → reported Kr.
8. **Verdict.** **Stable** (no variant reverses a conclusion the paper states; the predictive checks raise no warning on dependence statistics), **Sensitive** (some conclusions move with contestable assumptions: the paper states which and qualifies them), **Fragile** (the headline holds only under the base restrictions or rests on one case or one source: rewrite it as conditional). Name the assumptions most in need of defense: the uncertain ones that move the answers. If a check fails, propose an amended model and say it needs independent data to be tested; do not refit on the same data and call it confirmed.
9. **Save** `.qualstack/robustness-<YYYY-MM-DD>.md`: the independence tests, predictive checks, LOO comparison, sensitivity table, influence results, the sentence the paper must carry (e.g. "the attribution falls from [base] to [variant] if negative effects of I on M are allowed"), the assumptions most in need of defense. The line `Verdict: stable | sensitive | fragile` comes first, right under the title, because `/qualstack:paper-status` reads the first line that mentions a verdict; the words "verdict" and "recommendation" appear on no other line.

## Outputs

- `code/05-robustness.R`, `code/model-checks.R`; `output/tables/robustness-*.csv`, `output/models/robustness.rds`.
- `.qualstack/robustness-<date>.md`.
- Summary block: failed or untestable checks, the LOO comparison, the variant that moves the primary answer most, influential cases and sources, dependence on confidential evidence, verdict.

## Anti-patterns

- **Variants chosen to survive.** The rival-model list comes from the review, before the results.
- **Untestable checks reported as passed.** Selection on the outcome blocks some tests; say so.
- **Means-only predictive checks.** Easy statistics pass bad models.
- **Fragility in the appendix only.** A fragile headline is qualified in the abstract.
- **Silent model revision.** A model changed after a failed check is a new model, reported as such.

## Next

`/qualstack:evidence-audit`, then `/qualstack:viz` (sensitivity and evidence-path figures) and `/qualstack:draft-section results`.
