# Design diagnosis: which clues, which cases, how wide, how deep

Read by `/qualstack:design-research`, `/qualstack:clue-select`,
`/qualstack:case-select`, `/qualstack:fieldwork-plan`, `/qualstack:r-and-r`,
and `/qualstack:referee-mock`. It condenses Humphreys & Jacobs (2023,
chs. 12–14; cited as II) into a decision procedure and maps the
case-selection literature onto it. The tools are R functions bundled with the
skills: `clue-diagnosis.R` (`qs_clue_screen`, `qs_clue_table`,
`qs_strategy_table`, `qs_two_step`) and `case-diagnosis.R`
(`qs_case_strategies`, `qs_wide_deep`), all checked against the book's
published numbers.

## The decision frame

- **A design choice is a decision made inside the model.** For each option:
  list the findings it could produce, their probabilities under the model
  (updated on the data already in hand), the posterior on the query after
  each, and the probability-weighted average of the posterior variances: the
  **expected posterior variance (EPV)**. Lower is better; **expected
  learning** is 1 − EPV / prior variance (II §12.1).
- **There are no general rules.** Which clue, which case, and how to split
  effort depend jointly on the model (DAG, restrictions, priors), the query,
  and what has been observed (II §12.3, §13.4). Simulate; do not intuit.
- **Probability of a finding matters as much as its punch.** A clue that
  would be decisive if found but is unlikely to be found teaches little in
  expectation (II §12.1.3.1).
- **The loss function is a choice.** EPV is the default; expected information
  gain is an alternative (II §13.3.1). Say which one the design uses.

**Forcing checks before any comparison** (refuse to rank options until all
hold):

| Check | Why |
|---|---|
| The model exists as code (`code/01-model.R`): DAG, `<->`, restrictions, priors | Expected learning is computed from it |
| The query is a string and the `given` is stated | "Did X matter here?" and "via M?" rank clues differently |
| Case-level, population-level, or both | Different targets select different cases (II §13.1) |
| The prior variance is not zero | If the model already answers the query (negative effects under monotonicity), nothing can help |
| Every candidate clue has a causal position (mediator, moderator, alternative cause, descendant) and a time stamp | A clue without a position cannot be modeled (II ch. 17) |

## Clue selection (II ch. 12)

**Screen, then compute.** `qs_clue_screen()` reports whether a clue is
d-connected to the query's type nodes given what is observed
(`bayesian-process-tracing.md`, Proposition 1); d-separated clues are worth
nothing under any prior. Then `qs_clue_table()` gives, per clue, the chance of
finding it, the posterior either way, φ1, φ0, probative value, the implied
test type, and expected learning.

Rules the computations keep confirming:

- **Moderators and alternative causes often beat mediators.** In the
  government-survival model the moderator S is worth more than the mediators
  C and R; in the democratization model, international pressure P beats
  mobilization M for "did inequality matter?" in every kind of case
  (II §12.1.1, §12.1.3.1; Fig. 12.4: P alone .037–.070, M alone .007–.026).
- **Clues are valued jointly.** C is informative alone but worthless once X
  is observed, because X = 0 implies C = 1 (II §12.1.1). Rank sets with
  `qs_strategy_table()`, not singletons added up.
- **Zero-value clues:** d-separated from the query; implied by what is known
  (R given Y = 0); nearly certain under the model ("potential
  informativeness rests on uncertainty about what we will find", II §12.1.2).
- **What has been observed changes the ranking.** M is far more informative
  in I = D cases than in I ≠ D cases (II §12.1.3.1).
- **The query changes the ranking.** P is best for "did I matter?", M for
  "did I matter through M?" (II §12.1.3.2).
- **The model changes the ranking.** Allowing one more nodal type (θ^C_1010)
  makes C informative after X is observed (II §12.1.2). Re-run the table
  under each contested restriction (`/qualstack:robustness` logic, before
  data).

**Sequential search and cost** (II §12.2). When clues can be sought in order,
`qs_two_step()` enumerates strategies "(first),(if 0, if 1)", with expected
variance, expected number of clues, and expected cost, and marks the
undominated frontier. Starting with the most informative clue need not be
best: in the democratization model, "(M),(.,P)" (seek M; seek P only if
M = 1) reaches the lowest expected variance, .1049, at expected cost 2.28,
while "(P),(M,.)" reaches only .1061 at 1.78 (prices M = 1, P = 1.5). Record
the chosen point and its stopping rule in `.qualstack/clue-plan.md`.

## Case selection (II ch. 13)

The task: given X, Y (and any other) data on many cases, choose which to
study in depth. `qs_case_strategies()` updates the model once on the data in
hand and evaluates each strategy by reweighting the posterior draws (exact
for the draws; reports the effective sample size). It reproduces II
Table 13.7 (X → M → Y, no negative effects, six cases, M sought in two; ATE):
on the line .0151, off the line .0173, two X = Y = 1 cases .0156.

- **Any cell might do.** With X → Y ← K and the beliefs of II §13.2.1, K is
  doubly decisive in X = Y = 1 and X = 1, Y = 0 cases and worthless in X = 0
  cases; under a different model the ranking reverses.
- **The case of interest is not necessarily the case to study.** Learning
  flows through the population model, so a clue in case B can teach more
  about case A than more digging in A (II §13.2.2).
- **One case teaches nothing about a population** unless the model already
  builds in probative value (monotonicity, informative priors). With
  unrestricted models, every N = 1 strategy gives zero expected learning
  (II §13.3.3.1). **Two cases can create leverage** through covariation.
- **Prefer uncertain findings.** An off-the-line case can beat an on-the-line
  case for learning about on-the-line cases, when what the latter would show
  is nearly certain (II §13.3.3.2).
- **Expect modest learning.** A few traced cases usually move population
  queries a little (II §13.4); report the size, not only the ranking.
- **Selection must be ignorable or modeled.** Choosing which cases to trace by
  their recorded values is ignorable if every case stays in the data
  (`mixed-methods.md`); log the rule in `.qualstack/case-selection.md`.

**The literature, through this lens.** Each tradition answers a different
purpose; state the purpose, then compute.

| Advice | Purpose it serves | How to evaluate it here |
|---|---|---|
| Typical, diverse, extreme, deviant, influential, most-similar, most-different cases (Seawright & Gerring 2008; Gerring 2017) | A menu by purpose | A taxonomy, not a way to compare strategies: compute EPV for the ones that fit the purpose |
| On the regression line to test, off it to build models (Lieberman 2005) | Nested analysis | On-line pairs often win for the ATE in chain models (II Fig. 13.2); off-line cases for discovering omitted nodes are a theory-building purpose with no EPV |
| Deviant or extreme cases to find measurement error and omitted variables (Seawright 2016) | Checking the cross-case model | Model measurement explicitly (`concepts-and-coding.md`) and the case is evaluated like any other |
| Select on X, never on Y (King, Keohane & Verba 1994) | Covariation of X and Y | Not general when leverage comes from a third variable: select on both (II §13.3.3.3) |
| Never select on the outcome (Geddes 1990; Collier & Mahoney 1996) | Avoiding truncated comparisons | Tracing only Y = 1 cases is fine if all cases stay in the data and the query is about them; dropping Y = 0 cases is not |
| Negative cases where the outcome was possible (Mahoney & Goertz 2004) | Scope of comparison | The possibility principle defines the population the model covers |
| Controlled comparison and subnational units (Slater & Ziblatt 2013; Snyder 2001) | Holding context fixed | Context nodes or a narrower population in the model |
| Random or stratified selection (Fearon & Laitin 2008; Herron & Quinn 2016) | Representativeness | A random strategy performs as the average of the pure strategies it mixes |

## Going wide or going deep (II ch. 14)

- **Both have diminishing returns, so mixes often win.** In the confounded
  monotonic model, 400 cases with 50 traced beat 1,600 cases or 100 traced
  for both the ATE and the probability of positive causation (II Fig. 14.2).
- **Depth pays most** when an observable node may confound X and Y, for
  pathway queries, when the model embeds strong beliefs, and when cross-case
  N is modest. **Breadth wins** for the ATE in chain and two-path models.
  With 2,000 perfectly correlated X, Y cases and a possible confounder M,
  2,000 more cases barely move the ATE (sd .152 → .149) while M in 20 cases
  settles it (sd .004) if M is uncorrelated with X and Y (II Fig. 14.1).
- **Costs set the crossover.** With relative cost d of tracing a case versus
  adding an X, Y case, compare N_wide + d·N_deep across designs of similar
  EPV: in II §14.3 the ordering flips at d ≈ 6, 15, and 24.
- **Never discard the X, Y-only cases** when analyzing the traced subset.
- **Recompute after each tranche**: the best next investment depends on what
  is already committed.
- `qs_wide_deep()` simulates designs from the model (priors, or the posterior
  on data in hand) with one Stan run per simulated data set: start with
  `sims = 20`, a 2×2 grid, and modest iterations; report standard errors.

## What the design memo reports

1. The model version and query the diagnosis used; the prior on the query.
2. The clue table and the clue-set table (expected learning, chance of each
   finding, test type), the screen for d-separated clues.
3. The two-step frontier and the chosen strategy with its stopping rule.
4. The case-strategy table (EPV, expected learning, minimum ESS) and the
   selection rule; the wide/deep grid with costs, if breadth is an option.
5. How the rankings change under the contested restrictions.

## What referees fault

| Complaint | Fix |
|---|---|
| "Cases were selected as most-likely / least-likely" with no account of what each could show | The case-strategy table under the stated model and query |
| Only mediators were sought | Moderator and alternative-cause clues in the clue table |
| Hoop and smoking-gun labels chosen before any likelihood was stated | Test types derived from φ1, φ0 (`qs_clue_table`) |
| One case generalized to a population | The N = 1 result: zero expected learning without restrictions; say which restriction does the work |
| Traced cases chosen by access or promise | The selection log; model the selection or narrow the claim |
| Untraced cases dropped from the analysis | Keep them with NA clues (`mixed-methods.md`) |
| Fieldwork stopped "at saturation" | The stopping rule from the clue plan: expected learning per unit cost |
