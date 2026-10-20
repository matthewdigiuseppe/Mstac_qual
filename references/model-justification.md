# Justifying and evaluating a causal model

Read by `/qualstack:causal-model`, `/qualstack:model-review`,
`/qualstack:robustness`, `/qualstack:analyze`, `/qualstack:evidence-audit`,
and `/qualstack:referee-mock`. It condenses Humphreys & Jacobs (2023,
chs. 15–17; cited as II): where a model's probative value can legitimately
come from, and the four checks of whether a model is doing more harm than
good. The checks are implemented in `model-checks.R`
(`qs_implied_independencies`, `qs_ci_tests`, `qs_ppc`, `qs_loo`,
`qs_sensitivity`), which reproduces the book's chapter 16 numbers.

## Why this is acute for case studies

- **Case-level inference rests on beliefs about individual-level effects**:
  the probability of seeing clue K in a case if X caused Y there. That runs
  into the fundamental problem of causal inference; average effects do not
  settle it (II §15.1).
- **A single case can barely test its own model**: only events the model
  gives probability zero refute it. For case-level queries, inference "might
  be little more than conditional applications of a model" (II §15.1).
- **So the question is usefulness, not truth.** Every model is wrong; ask
  whether this one is unacceptably inconsistent with the data and how much
  the conclusions depend on its contestable parts (II ch. 16).

## Where a model can come from

| Ground | What it supplies | Caveat |
|---|---|---|
| Theory, including formal models (II §6.3) | Nodes, arrows, restrictions from an argument whose logic can be checked | Only as good as the theory's assumptions; equilibrium selection and irrationality must be modeled, not assumed away |
| Expert or prior-literature beliefs | Quantitative priors (`set_priors`) | Elicit before seeing the case evidence; record whose beliefs |
| Experimental or as-if-random data | Probative value derived, not posited (II §15.1.2) | The traced case must be exchangeable with the experimental units |
| Observational cross-case data | Learned λ, and probative value for some clues (II ch. 10) | Not with an agnostic structure: "nothing from nothing" |
| Causal discovery (II §15.2) | A skeleton and some orientations | Assumes every confounder is measured (PC; FCI relaxes this); time order orients edges; report what stays unoriented |

**Nothing from nothing** (II §15.1.1). With observational data on X, M, Y
and a model allowing confounding between every pair, M gives no traction even
when the true process is a simple monotone chain: Pr(X caused Y) stays near
.50 whether M = 1 or M = 0. Assuming only that X is randomized, the same data
give .88 when M = 1 and .54 when M = 0. Some structural assumption has to do
the work; name it.

**Derive, don't posit, probative value** (II §15.1.2). Update an agnostic
X → Y ← K model (flat priors, no restrictions, X and K unconfounded roots)
on experimental data and read the test type off the case-level answers.
On 1,000 simulated units per design (II Table 15.2): Pr(X caused Y) with no
K / K = 0 / K = 1 is .48 / .01 / .98 (doubly decisive), .46 / .04 / .50
(hoop), .56 / .52 / .90 (smoking gun), .49 / .29 / .70 (straw in the wind).

- **Priors and likelihoods are not independent.** A prior on "X caused Y"
  and a separate Pr(K | H) are both claims about causal relations and must
  come from one set of beliefs (II §15.1.2, §17.1). When a user supplies them
  separately, translate them into a model or ask what model implies both.
- **Mediators in chain models can yield hoop tests, generally not smoking
  guns** (II §15.1.2). A claimed mediator smoking gun needs a moderator or a
  restriction that does the work; find it.
- **Non-identification does not destroy probative value.** Bounds can certify
  a test type even when the probability of causation is only partially
  identified (II Table 15.1).

## Unintended structure (II §17.2)

- **Adding detail changes implied priors.** Flat priors on X → Y put .25 on a
  positive effect; flat priors on X → M → Y put .125 on it. Recompute the
  implied prior on the main query after every added node or arrow.
- **Adding a node can destroy a claimed test.** If W is a smoking gun in
  X → Y ← W, it cannot remain one in X → M → Y ← W unless W also points into
  M or the X → M step is certain.
- **Coarse time stamps blur acyclicity.** "Mobilization in the 1990s" and
  "democratization in the 1990s" cannot fix an arrow's direction; time-stamp
  nodes finely enough that the order is a fact, not a convention.
- **Complexity explodes**: 4, 16, 256, 65,536 nodal types for 1–4 parents.
  Restrict (monotonicity, no high-order interactions) and say the inference is
  conditional on it.

## The four checks (II ch. 16)

**1. Implied conditional independencies** (before or with data). Every
missing arrow implies independencies among observed nodes:
`qs_implied_independencies()` lists them; `qs_ci_tests()` reports, per
stratum of the conditioning set, the difference in Pr(A = 1) between B = 1 and
B = 0 with a Fisher exact p-value. In the book's running example, the model
X → M → Y implies Y ⊥ X | M, yet the difference is .345 at M = 0 and .341 at
M = 1: the model is too strong.

- Use data not selected on a collider. If the cases that observe both nodes
  all share the outcome (clues gathered only where democratization occurred),
  the test conditions on a collider and is invalid; `qs_ci_tests()` says so.
- Under unobserved confounding a mediator can act as a collider; a dependence
  given M is then not a violation.

**2. Posterior predictive checks** (Bayesian p-values). Draw parameters from
the posterior, simulate data sets of the same size and missingness, compute
statistics, and ask how extreme the observed ones are (`qs_ppc()`).

- Choose statistics that target the model's independence claims (the
  correlation of cause and outcome, cause and mediator), not only means: in
  the running example the too-strong model passes on mean(Y) (p = 1) and fails
  on cor(X, Y) (p = 0); the weaker model gives .86 and .40.
- Bayesian p-values are not calibrated and depend on N (II Fig. 16.2): read
  them as warning lights, not tests with a size.

**3. Leave-one-out likelihood** (comparing models). For each data pattern,
update without one case and predict it (`qs_loo()`); compare models by the
log10 LOO likelihood. In the running example the weaker model predicts the
left-out cases about 10^4.5 times better.

- **The asymmetry**: a permissive model loses little when a stricter one is
  true (the book's reverse case costs a factor of about 10^5 on 200 cases,
  from overfitting), while a strict model can fail badly when it is wrong.
- Plot each pattern's predicted probability against its count; a strict
  model compresses the predictions.

**4. Sensitivity** (how much the conclusions depend on the model).
`qs_sensitivity()` runs the same queries under named variants and flags sign
changes, crossings of .5, and answers fixed by the base model's restrictions.

| Variant | How |
|---|---|
| Drop each monotonicity restriction, one at a time | Rebuild without that `set_restrictions()` line |
| Replace a logical restriction with a quantitative prior | Small prior mass instead of zero, e.g. Pr(negative I → M) = .1 (II §16.2.4) |
| Relax an exclusion restriction | Add the direct arrow or `<->` |
| Add the plausible missing arrow | E.g. D → M in the institutions model |
| Vary a key nodal-type share over a grid | II Table 16.2: in an X = Y = 1 case, Pr(X caused Y) given M = 0 runs from 0 to .25 as λ^Y_10 runs from 0 to .25 |

- **Sensitivity depends on what is found.** In that grid the answer given
  M = 1 is .25 throughout; given M = 0 it moves (II §16.1.4). Report it per
  possible finding.
- **Population and case-level conclusions differ in sensitivity.** In the
  democratization model, removing all monotonicity restrictions moves the
  ATE from −.23 to −.01 and the attribution for I = 1, D = 1 cases from .07
  to .50, while the I = 0, D = 1 answer moves only from −.44 to −.51
  (II Fig. 16.9).
- **Name the assumptions most in need of defense**: the uncertain ones that
  move the conclusions. They go in the limitations section and the agenda
  (II §17.1).

## When a check fails

- Propose an amended model, say what it changes, and evaluate it against
  independent data; refitting on the same data and declaring success is
  forking paths (II §16.2.1).
- If no independent data exist, report both models' answers and the check
  that separates them.

## What the robustness memo reports

The implied independencies and their tests (with the selection caveat); the
posterior predictive table; the LOO comparison of the base model with at least
one weaker rival; the sensitivity table by variant and by possible finding;
the assumptions most in need of defense; a verdict in the book's register
("neither model emerges with a spotless bill of health" is an acceptable
conclusion).

## What referees fault

| Complaint | Fix |
|---|---|
| Probative values asserted, not derived | The model, or experimental data, that yields them |
| A prior on the hypothesis and likelihoods set independently | One model implying both |
| A mediator presented as a smoking gun | The moderator or restriction doing the work, or relabel |
| No evidence the model fits | Implied independencies tested; predictive checks on dependence statistics |
| Conclusions that hold only under monotonicity | The sensitivity table; flag answers fixed by restrictions |
| A single model, no rival | LOO against a weaker model |
| The model revised after a failed check, then re-tested on the same data | An independent test, or both models reported |
