# Integrating cross-case and within-case evidence

Read by `/qualstack:design-research`, `/qualstack:case-select`,
`/qualstack:analyze`, `/qualstack:robustness`, `/qualstack:draft-section`
(design, results), and `/qualstack:referee-mock`. It condenses Humphreys &
Jacobs (2023, chs. 9–11), cited below as II with section numbers, into the
rules a multi-method analysis has to follow and the checks a reviewer will
run. Code idioms are in `causalqueries-cookbook.md`.

## The core move: one model, one update

- **All data are values of nodes.** Cross-case X–Y data on many cases and
  clues gathered in a few are partial observations of the same DAG; each case
  contributes the probability of whatever was observed for it (II §9.3.1).
  There is no separate "qualitative verdict" to reconcile with a
  "quantitative estimate": both enter one likelihood.
- **The model is what learns.** In single-case process tracing the
  population shares of nodal types (λ) are fixed inputs. With many cases, λ
  is the object of inference, with a Dirichlet prior, and every answer is a
  summary of the posterior over λ (II §9.2.1, §9.2.2.5).
- **Cases inform one another only through λ.** That requires (a) λ to be
  uncertain (if it were known, cases could teach nothing about each other,
  II §9.2) and (b) the cases to be independent draws from one population.
  Diffusion, shared shocks, or different populations break (b): model them
  (spillover nodes, context nodes, a hierarchy) or do not pool.
- **Update once, query many times.** Population shares, subgroup attribution
  shares, and named-case probabilities all come from the same posterior
  (II §10.3). Separate models for "the regression" and "the cases" defeat
  the point.

## Data format

- One row per case; one column per model node, named exactly as in the model
  statement; values 0, 1, or NA, where **NA means not observed**.
- Keep every case that has any observed node. A case that was not process
  traced stays in the data with NA for its clues; dropping it changes the
  likelihood (next section).
- Any variable used as evidence, qualitative or quantitative, must be a node.
  Evidence that is not in the model cannot be integrated, only narrated.
- Compact data (`event`, `strategy`, `count`, with `data_type = "compact"`)
  is available for large tabulated datasets.

## Which cases got which data: the selection rule

The likelihood principle decides whether case selection matters
(II §9.2.3.2):

| Situation | Ignorable? | What to do |
|---|---|---|
| Clues gathered in cases chosen by their *recorded* X and Y values, all cases kept in the data | Yes | Nothing beyond recording the rule |
| Cases assigned to intensive study at random, or by a rule using only observed values | Yes | Record the rule |
| Only cases with a given outcome were kept, or cases entered the dataset because of their outcome (successful transitions only, reported incidents only) | No | Model the selection (a censored likelihood) or change the population claim |
| Selection depended on something related to potential outcomes that is not in the data (the case "looked promising", access followed success) | No | Put the selecting variable in the model, or say plainly that inference is conditional on selection |

- Keep a **selection log** in `.qualstack/case-selection.md`: for every case
  with within-case data, the rule that put it there and the values the rule
  used.
- Tracing only the cases where the outcome occurred is not fatal in itself:
  Haggard and Kaufman gathered detailed evidence only for democratizers, and
  the II reanalysis keeps the non-democratizers in the data with their clues
  missing. Dropping those cases would make selection depend on the outcome.

## Three answers from one posterior

| Question | How it is asked | What is reported |
|---|---|---|
| Population: how common is a positive effect; what is the ATE? | unconditional query | posterior mean, sd, 95% credible interval |
| Subgroup attribution: among cases with X=1, Y=1 (and given clue values), in what share did X cause Y? | query with `given` | mean, sd, interval |
| A named case: did X cause Y in *this* case? | query with `given` set to the case's observed values | a single probability (no interval) |

For a named case the analyst must say which conditional question is meant
(II §9.3.2.1):

- **Uninformative case (π̂), `case_level = FALSE`.** The case was selected
  *because* it has the observed pattern, or its data are already in the
  update. The answer is the population share for cases like it. This is
  what II uses throughout chapter 10.
- **Informative case (φ̂), `case_level = TRUE`.** A case drawn without regard
  to its values turns out to show the pattern, and that discovery also
  updates beliefs about λ.
- **Never both.** Updating on a case and then asking a φ̂ question of it uses
  its data twice.
- The two can differ sharply and both be right: among cases with K = 1 an
  effect can be rare, while observing K = 1 in a new case can still make an
  effect likely, because seeing K = 1 says which world we are in
  (II §9.3.2.2).

## Where a clue's probative value comes from

- In a single case, probative value comes only from the model: a DAG with
  flat priors makes most clues uninformative (II §9.3.2). Multi-case data
  can **generate** probative value. In II's institutions-and-growth example,
  settler mortality and distance from the equator say nothing about
  individual cases under flat priors, and become informative after training
  on 79 countries (II §10.2.2.1).
- Data can also **undercut** theory-given probative value. In the
  inequality-and-democratization reanalysis, 84 cases gave little support to
  the probative value theory assigned to mobilization and international
  pressure (II §10.1, §10.3).
- So label every clue: **theory-derived** (moves the untrained model),
  **data-derived** (moves only the trained model), **absent**, or
  **contradicted by data**. Produce the table: for each clue and case type,
  the answer with no clue and at each clue value, under the prior-only model
  and the trained model.
- **Flag restriction-driven answers.** If a positive effect of I can run
  only through M by restriction, then Pr(I caused D | M = 0) = 0 whatever the
  data say; report it as an assumption, not a finding (II §10.1.3).
- **A query that barely moves can hide learning.** Compare parameter
  families (posterior mean of each nodal-type share against its prior), not
  only the headline query (II §10.1.4).
- **Clues can matter for cases and not for averages.** A moderator can raise
  the ATE while lowering confidence that the cause did the work in a given
  case with X = 1, Y = 1 (II §10.2.2.1).

## Confounding

- Unobserved confounding is a correlation between nodal types, drawn as a
  bidirected edge (`X <-> Y`) and parameterized as type shares conditional
  on another node's type (II §9.2.3.1).
- With no theory of its direction, allow it with flat priors rather than
  omit it (II ch. 10). The data can then inform it; learning about
  confounding is one way clues become informative about cases.
- Omitting a confounder the analyst believes in is a substantive claim of
  independence, not a simplification.

## Identification and how much the priors drive

- The ATE in an unconfounded X → Y model is identified: with enough data
  the posterior converges. The probability that X caused Y in an
  X = 1, Y = 1 case is **not**: the posterior keeps a ridge and never
  converges to a point, whatever the N (II §9.3.3).
- For non-identified queries, report what was learned as a range, run the
  same update under different priors (`/qualstack:robustness`), and, if in
  doubt, simulate a very large dataset to see whether the remaining shape is
  the prior's.
- With ten or fewer cases priors are not overwhelmed, and more data can
  widen an interval when data and priors pull apart (II §9.2.2.6). Say so.
- Flat priors on a detailed model are not flat on its reduced form: in
  X → M → Y with flat priors, an X → Y effect occurs a quarter of the time,
  not half (II §9.2.2.6).

## Measurement: case studies as calibration

- Model the measurement process instead of treating the measure as the
  construct: X → Y → Y_measured (II §9.4.2).
- Careful qualitative measurement of the true value in a subset of cases
  calibrates the noisy measure for the rest. In II's simulation the posterior
  sd of the ATE was 0.09 with the noisy measure alone, 0.03 with the true
  value for 20% of cases, and 0.02 with the true value for all; two
  independent noisy measures did about as well (Bayesian triangulation).

## Beyond one study (II ch. 11)

Every cross-setting integration needs an explicit **encompassing model** that
captures every way the settings differ; it is only as good as that model.

| Integration | Model move | Data needed |
|---|---|---|
| Jigsaw: studies of different parts of one DAG | one DAG containing every node any study measured | stack all studies, NA where a study did not measure a node; update jointly |
| Experiment plus observational data | X has a randomized parent Z, a natural-assignment parent O confounded with Y, and a switch R | record O (the natural choice or propensity), including for experimental units; assume entering the experiment affects Y only through X |
| Transport to a new context | a Context node shifting the distribution of moderator W | W measured in the target context; without it the posterior is honestly wide |
| Multiple populations | sites' λ drawn from a superpopulation Dirichlet | custom Stan (II §11.4); pooling helps often, not always |

## Mediation language

- A "direct" effect in a model with one mediator is a residual: every path
  not modeled, not a named rival mechanism (II §10.2.3).
- Report Direct 0 / Direct 1 and Indirect 0 / Indirect 1 (the indirect
  effect with X held at 0 or at 1); total = Direct 0 + Indirect 1 =
  Direct 1 + Indirect 0.

## What referees fault in multi-method work

| Complaint | Fix |
|---|---|
| The case studies "illustrate" the regression; nothing they show could have changed the conclusion | Put the clues in the model; report what they moved |
| Cases chosen on the outcome and the non-cases dropped | Keep every case with NA clues; state the selection rule; show it is ignorable or model it |
| No account of why these cases were traced | The selection log, in the design section |
| Case verdicts presented as data-validated when the probative value is assumed | The trained-versus-untrained clue table; label each clue |
| A case-level probability reported with a confidence interval, or a population share reported as a case verdict | Say which question (π̂ or φ̂) and report accordingly |
| Conclusions that follow from restrictions presented as findings | Flag them; show the answer without the restriction (`/qualstack:robustness`) |
| Cases from different populations pooled without comment | A context node, a hierarchy, or a narrower population claim |
| Attribution reported as a point estimate | The posterior range and its sensitivity to priors |
