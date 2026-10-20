# Preregistration — <paper title>

Registry: <registry> · Drafted: <YYYY-MM-DD> · Authors: <names> · Embargo: <none | until YYYY-MM-DD | until publication>
Design: <process-tracing | comparative | multi-method | comparative-historical> · Inference: <causal model, CausalQueries <version> | informal Bayesian process tracing>

**Evidence already seen at registration**, by category and without names: <none | scoping interviews: number and role categories | archive series read: which | secondary literature | cross-case data: dataset, version, variables examined>

*With an informal model (`model.formal: false`), section 1 lists the hypotheses (exhaustive, mutually exclusive) and the prior on each with its reason; section 4 gives Pr(K | H) for every planned clue under every hypothesis, as a range, in place of model-derived values; section 6 states the informal updating procedure.*

## 1. Causal model

- Statement: `<exactly as in code/01-model.R>`
- Restrictions: R1 `<statement>` — <justification>; R2 …
- Confounding: C1 `<A <-> B>` — <justification>; or "none, because <reason>"
- Priors: P1 <node, nodal type, alpha> — <justification>; all other types flat (alpha = 1)
- Code: `code/01-model.R`, sha256 `<hash>`, attached verbatim (Appendix A)
- Model review: <verdict, date>

## 2. Queries

| ID | In words | Query | `given` | Level | Prior |
|---|---|---|---|---|---|
| Q1 (primary) | <In case A, did X cause Y?> | `Y[X=1] > Y[X=0]` | `X==1 & Y==1` | case | <0.xx> |
| Q2 | <> | <> | <> | <case / population> | <> |

## 3. Cases

- Population: <the set of cases the population-level queries are about>
- Selection rule: <using recorded values only, e.g. every X = 1, Y = 1 case in the dataset; otherwise what else it conditions on>
- Cases chosen: <case — the rule — the values the rule used>
- Replacement if access fails: <rule>
- Selection log: `.qualstack/case-selection.md`, one row per case that receives within-case evidence

## 4. Clue plan

| Clue (node) | Sought where (source categories) | φ1 | φ0 | PV if found | PV if absent | Test | Pr(found) | Posterior if found / absent | Expected learning | 0 standard: the search that must fail |
|---|---|---|---|---|---|---|---|---|---|---|
| <K1 (M)> | <> | <> | <> | <> | <> | <> | <> | <> | <> | <> |

- Strategy: <every clue in every traced case | two-step: seek <K1>; if K1 = 0 seek <K2>; if K1 = 1 stop; expected cost <>, expected learning <>>
- Values computed by `code/02-design.R` on the registered model; `output/tables/clue-diagnosis.csv` attached (Appendix B)

## 5. Coding rules

- `data/coding-rules.md`, sha256 `<hash>`; node versions: <X v1, M v2, Y v1, …>; attached (Appendix C)
- Coders: <who>; blind second coding: <all cases | a random sample of <n> plus the hard cases>, the second coder blind to outcomes, hypotheses, and first codes; agreement reported per node before adjudication
- LLM coder or assessor: <none | task ID in `.qualstack/llm-usage.jsonl`, model version, brief file, validation plan>

## 6. Updating and reporting

- Data: `code/03-data.R` writes one row per case, values 0 / 1 / NA (NA = not observed)
- Updating: `code/04-update.R`; seed <model.seed>; chains <>, iterations <>; one `update_model()` call on all data
- Reported: every query with its prior beside its posterior; posterior mean and credible interval for population queries; case-level answers for traced cases

## 7. Decision rules

| Query | Support if | Evidence against if | Otherwise | Why these thresholds |
|---|---|---|---|---|
| Q1 | posterior ≥ <0.xx> | posterior ≤ <0.xx> | inconclusive | <> |

Counterfactual table: the posterior on Q1 under each pattern of clue results (from section 4), attached (Appendix B).

## 8. Robustness (committed now)

- Alternative priors: <named>
- Each restriction relaxed in turn: <R1, R2, …>
- Confounding allowed between: <>
- Clue measurement error: <true K → reported K, with error rates <>>
- Each case dropped; each source dropped
- Values coded only from confidential items set to NA, one at a time and together

## 9. Stopping, surprises, and deviations

- Each clue's search ends when: <the sources in its 0 standard have been searched>
- Fieldwork ends: <date | budget | sources exhausted>, whichever comes first; interviews in a category stop when <saturation criterion>
- Surprises: a dated addendum (`prereg/addendum-YYYY-MM-DD.md`), written before the new evidence is coded, stating what changed and why, not what it does to the answer
- A closed archive or withdrawn participant: the clue stays NA
- New evidence on a modeled node: its probative value from the registered model before it is coded; a new node is a model revision; results reported with and without
- A revised model: reported beside the registered one
- Every deviation reported in the paper beside the registered plan, with its effect on the primary answer

## 10. Data availability and embargo

- Shared at publication: <model code, case data, coding log and rules, evidence log with access tiers, annotations> via <repository>
- Withheld, why, and the access route: <confidential interviews: consent terms; archive reproduction terms>
- Embargo: <choice and reason>; the public plan names no participant, and sources appear by category

## Appendices

A. `code/01-model.R`, verbatim. B. `output/tables/clue-diagnosis.csv` and the counterfactual table. C. `data/coding-rules.md` as registered.
