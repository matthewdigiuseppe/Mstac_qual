# Bayesian process tracing

Read by `/qualstack:process-trace`, `/qualstack:clue-select`,
`/qualstack:model-review`, `/qualstack:evidence-audit`,
`/qualstack:draft-section cases`, and `/qualstack:referee-mock`. It
condenses Humphreys & Jacobs (2023, chs. 5, 7, 8; cited as II) and connects
them to the process-tracing literature (Van Evera 1997; Collier 2011; Mahoney
2012; Bennett 2015; Fairfield & Charman 2017, 2022). The question throughout:
how much should this piece of evidence move belief about this case, and why?

## Two routes to one logic

| | Informal Bayesian process tracing | Model-based process tracing |
|---|---|---|
| Prior on the hypothesis | Stated by the analyst, with reasons | The model's probability of the query given what is observed |
| Likelihood of each piece of evidence | Stated by the analyst for each hypothesis | Derived from the same model |
| Strength | Flexible; close to how historians reason | Priors and likelihoods are mutually consistent and can be challenged at their source (II §7.3) |
| Weakness | Priors and likelihoods can be set incoherently, and after the fact | Only as good as the model; reductive about rich evidence |

QualStack's default is model-based whenever a model exists, with the
informal route for evidence the model does not represent and for projects
that set `model.formal: false`. Where both exist, compare them: a gap between
the formal posterior and the analyst's informal one is a finding about the
model or about the analyst.

## The arithmetic

- **Bayes for one clue** (II §5.1.6): with prior p on H and
  φ1 = Pr(K = 1 | H), φ0 = Pr(K = 1 | not H),
  Pr(H | K = 1) = φ1·p / (φ1·p + φ0·(1 − p)); if the clue is sought and not
  found, replace φ by 1 − φ.
- **Odds form:** posterior odds = prior odds × likelihood ratio. Its log is
  additive, which is why Fairfield & Charman (2022) report the **weight of
  evidence** in decibels, 10·log10(LR).
- **Probative value** of a realized clue is log(φ1/φ0); of its absence,
  log((1 − φ0)/(1 − φ1)). They can differ wildly: with φ1 = .999 and
  φ0 = .333, finding the clue is "barely worth mentioning" (log10 ratio 0.47)
  while its absence is "decisive" (2.82) (II §5.1.6, after Jeffreys).
- **Probative value describes evidence in hand, not evidence to seek.** Two
  clues with the same probative value if found can have expected learning of
  0.96 and 0.05, because one is likely to be found and the other is not
  (II §5.1.6). Choose what to look for by **expected learning** (the expected
  reduction in posterior variance), which uses the prior:
  `/qualstack:clue-select` and `design-diagnosis.md`.
- **Priors matter, and surprise is not learning** (II §5.3.1). How far a test
  moves belief depends on the prior: a smoking gun teaches most when the prior
  is low-to-middling (about .25), a failed hoop test when it is
  middling-to-high (about .75). Disconfirming evidence against a strongly held
  hypothesis is likely a false negative; confirming evidence for an
  implausible one is likely a false positive.

## Van Evera's tests as regions, not strengths

For an X = 1, Y = 1 case, let φ_b = Pr(K | X caused Y) and
φ_d = Pr(K | Y would have occurred anyway). The four classic tests (Van Evera
1997; Collier 2011) are regions of the (φ_b, φ_d) square (II §5.2.1, with
boundaries where the ratios reach 2):

| Test | Shape | φ_b / φ_d | (1 − φ_d)/(1 − φ_b) |
|---|---|---|---|
| Smoking gun | Unlikely unless H; finding it helps, missing it barely hurts | high | low |
| Hoop | Likely if H; missing it hurts, finding it barely helps | low | high |
| Doubly decisive | Both | high | high |
| Straw in the wind | Neither | low | low |

The label names the shape of the evidence, never its strength: "it passed a
hoop test" and "we found a smoking gun" say nothing about the posterior until
the prior and the φ's are stated. Mahoney (2012) and Collier (2011) present
the tests in necessary/sufficient language; the continuous version is what an
analysis should report.

## Where probative value comes from

- **From the model.** In X → K → Y, the probability of K under each
  hypothesis follows from the shares of nodal types (II §7.3). Ruling out a
  negative effect of X on K turns K into a hoop test for "X caused Y"; making
  null effects unlikely at both steps turns it into a smoking gun. Changing
  the model changes the test, which is why the likelihoods must be derived,
  not asserted.
- **A DAG alone gives nothing.** With flat priors over X → M → Y, observing M
  in an X = 1, Y = 1 case leaves the probability that X caused Y at 0.25
  whatever M shows (II §7.5.1). Single-case process tracing needs thicker
  background knowledge: a restriction such as monotonicity, or quantitative
  priors such as "positive X → M effects are twice as common as negative
  ones", or a model trained on cross-case data (`mixed-methods.md`).
- **Restrictions can settle the answer before any evidence.** If monotonicity
  rules out a negative effect, the probability that X prevented Y is 0 in
  every case, whatever the archive holds (II §8.2.3). Report such answers as
  assumptions.
- **Learning requires uncertainty** (II §7.5.2). A clue whose value is nearly
  predictable from what is already known cannot teach much, however
  "relevant" it is.

## Which observations can be informative

**Proposition 1** (II §7.4, after Pearl): a set of clues K is uninformative
about the query nodes Q, given what has been observed W, if K is d-separated
from Q by W. d-connection is necessary, not sufficient. Q is the set of θ
nodes the query depends on: for X's effect on Y through M, both θ^M and θ^Y.

| Clue's position | Informative about X's effect on Y when… |
|---|---|
| The cause X itself, alone | Never: X's value says nothing about X's effect until Y is seen |
| Mediator (X → K → Y) | Y has been observed |
| Symptom of the query (Q → K: a trace of the conditions that make the effect possible) | Always potentially, whatever else is known |
| Surrogate for the outcome (Y → K) | Y has not been observed directly |
| Surrogate for the cause (X → K, K not on the path) | X has not been observed directly |
| Instrument (K → X only) | Y is observed and X is not |
| Confounder (K → X and K → Y) | Y is observed |
| Moderator or alternative cause (K → Y) | Y is observed; often the most informative clue of all |

The last row is the practical lesson of II ch. 8: re-modeling Haggard and
Kaufman's study of inequality and democratization, the alternative-cause clue
(international pressure) was far more informative than the mediator clue
(mobilization) the authors relied on. Process tracing that looks only along
the hypothesized path leaves leverage unused.

## Many pieces of evidence

- **Update jointly, through the model.** A set of observations is one partial
  data pattern; the posterior keeps the causal types consistent with all of
  it. Order does not matter (II §5.3.3).
- **Never multiply likelihood ratios as if independent** unless the pieces
  are independent given each hypothesis. Two reports that trace to one leak,
  one participant's recollection told twice, or a memoir and the interview
  based on it are one source.
- **Clues condition each other.** In II ch. 8, international pressure is
  worthless once mobilization has been observed in an I = 1, D = 1 case and
  informative if mobilization was absent; an alternative cause lowers
  attribution to the focal cause even when the model specifies no
  interaction.
- **Update every unknown.** If unsure whether a clue is a hoop or a smoking
  gun (two "worlds"), update beliefs about the world too: averaging the
  fixed-world answers with prior weights gives 5/6 where the right answer is
  3/4 (II §5.3.2).

## Rival explanations

- Bayes needs an exhaustive set of hypotheses, not an exhaustive list: "X
  caused Y" against "X did not cause Y" is enough when the model supplies
  Pr(K | not H) (II §5.1.2). Writing out concrete rivals is still the best
  way to elicit likelihoods informally (Fairfield & Charman 2017).
- Rivals in the literature are often not mutually exclusive (Zaks 2017), and
  causes are not rivals (`causal-models.md`). Before eliciting likelihoods,
  restate the competing accounts as mutually exclusive claims about the case:
  "X was a difference-maker for Y here" versus "it was not", or the full set
  of combinations of two candidate causes.

## Elicitation discipline

- **Likelihoods before evidence.** The clue plan (`/qualstack:clue-select`)
  records Pr(K | H) and Pr(K | not H) for each planned clue before it is
  sought; the prereg can lock them.
- **Blind assessment.** For evidence the model does not represent, have the
  `qualstack:assessor` agent state the likelihoods under neutrally labeled
  hypotheses, without knowing which the author favors, and compare with the
  author's own numbers (`/qualstack:process-trace --blind`).
- **Source criticism is likelihood estimation.** Who produced a document, for
  whom, when, and with what incentives decides how likely it is to say what
  it says under each hypothesis (`evidence-and-sources.md`).
- **Report the counterfactual table.** For each clue, the posterior if it had
  come out the other way, and under each data strategy (no clues, each clue
  alone, all). A reader should see what the evidence could have shown.
- **Sensitivity of informal numbers.** Give each informal likelihood as a
  range and report the posterior at both ends.

## The informal procedure (when `model.formal: false`, or for evidence outside the model)

1. The hypotheses: an exhaustive, mutually exclusive set of claims about the
   case.
2. The prior on each, from background knowledge stated in a sentence, not
   from the case evidence about to be weighed.
3. For each evidence item, in a fixed order decided before reading: what it
   is (E-ID), its source assessment, Pr(E | H) for each hypothesis with a
   reason, the likelihood ratio for the main pair, the weight in decibels, the
   running posterior.
4. Dependence: which items share an origin; combine or discount them.
5. The posterior with its range under the likelihood ranges.
6. What would change the conclusion: the observation, not yet made, that
   would move the posterior across the decision threshold.

## What referees fault

| Complaint | Fix |
|---|---|
| "The hypothesis passes a hoop test" as if that confirmed it | State the prior and φ's; report the posterior |
| Likelihoods that look chosen after the fact | Likelihoods from the model or the clue plan, dated before collection |
| Evidence piled up as if each item were independent | Dependence check; one source counted once |
| Mechanism inferred from the mediator occurring | The path query; mediator evidence only with the outcome observed |
| Only the favored path examined | Moderator and alternative-cause clues |
| Surprising evidence treated as decisive | The prior; surprise against a strong prior is often error |
| Only cases where the outcome occurred are traced, with no rationale | The model says what other cases would show (II §8.1.4) |
| A rich narrative with no statement of what would have counted against it | The counterfactual table |
