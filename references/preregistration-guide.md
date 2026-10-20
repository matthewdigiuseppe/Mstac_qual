# Preregistration guide for qualitative and multi-method designs

Read by `/qualstack:preregister` before drafting. The parts it locks come
from `/qualstack:query-design`, `/qualstack:causal-model`,
`/qualstack:case-select`, `/qualstack:clue-select`, `/qualstack:coding-rules`,
and `/qualstack:fieldwork-plan`; the deviations section serves
`/qualstack:r-and-r` and `/qualstack:draft-section` when the paper reports
what changed. The bundled template is
`skills/preregister/assets/prereg-template.md`. Registries, embargo options,
and journal tracks change: this file says what to check, and the check is
made against the current version. Humphreys & Jacobs (2023) is cited as II.

## Why preregister a case study

- **The forking paths of process tracing** are which clues count, how much
  each counts, which rival it is weighed against, which cases get traced,
  and where a coding threshold sits. Each can be chosen after the evidence
  is in, and each choice moves the answer (Jacobs 2020).
- **A probative value set after the clue is seen is a specification chosen
  after the estimate.** "The memo is a smoking gun", written once the memo
  is in hand, is not a test result.
- **Plans are feasible for qualitative inference** (Kern & Gleditsch 2017;
  Piñeiro & Rosenblatt 2016), inductive designs included: they register
  the procedure and the researcher's starting assumptions rather than
  hypotheses (Haven & Van Grootel 2019).
- **What a plan buys:** a visible line between confirmatory and
  exploratory claims; a reviewer who cannot say the hoop test was always
  going to be passed; a dated record of what the field changed.
- **What it does not do:** forbid exploration, or bind the author to a
  plan the field made impossible. Unplanned work is labeled, not banned;
  deviations are reported, not hidden.
- **Results-free review** evaluates the design before results exist
  (Jacobs 2020); the same plan serves both. Check whether the target
  journal currently runs a results-free or registered-report track, and
  whether it takes qualitative and observational designs.

## The standard

Apply both tests to every section; a section that fails either is not
finished.

1. **Two researchers.** Given only the plan, the registered code, and the
   coded evidence, would two researchers compute the same posterior on the
   primary query without talking to each other?
2. **What the evidence could have shown.** Could a reader see, for every
   planned clue, how far finding it and not finding it would move the
   query, before anyone looked?

## How causal-model preregistration differs

| Experimental or regression plan | Causal-model plan |
|---|---|
| Hypotheses about the sign and size of coefficients | The query: a counterfactual quantity, case-level or population-level, in code syntax with its `given` |
| An estimator and a significance test | The model (DAG, restrictions, confounding, priors) and one `update_model()` call |
| Power: the minimum detectable effect | Expected learning: the expected reduction in posterior variance from each clue and each case strategy |
| Outcome measures and index construction | Coding rules mapping evidence to 0, 1, or NA for each node |
| Sample size and stopping rule | Cases and the selection rule; each clue's search and fieldwork's end |
| A decision rule on a p-value or interval | Thresholds on the posterior, reported beside the prior |

- **Lock the model and the clue likelihoods, not hypotheses about
  coefficients.** A model justifies the prior on the query and the
  likelihood of each clue together (II §7.3), so registering it fixes the
  probative value of every clue on a modeled node at once, including
  evidence nobody foresaw: a document found in the field that bears on node
  M takes M's probative value from the registered model, not from the
  author's reading of it.
- **Evidence that needs a new node is a model revision.** Register it in an
  addendum before the evidence is coded, and report the registered and
  revised models side by side.
- **Priors are part of the plan.** Register them with their justification
  and with the alternatives robustness will run; a prior chosen after the
  update is a result chosen after the update.
- **The model is registered as code.** Attach `code/01-model.R` and record
  its `sha256sum`; a different hash at analysis time is a deviation,
  whatever the paper calls it.
- **Restrictions are the strongest claims in the plan.** A monotonicity
  restriction can turn a clue into a hoop test; register the reason and the
  robustness run without it.
- **Conditional search plans** (II §12.2) are data strategies fixed in
  advance: which clue first, and what to seek next given what it shows.
  They register naturally, with their expected cost and expected learning.
- **Informal Bayesian process tracing** (`model.formal: false`) registers
  the exhaustive, mutually exclusive hypotheses, the prior on each, and
  Pr(K | H) for every planned clue under every hypothesis, stated
  explicitly (Fairfield & Charman 2017) and as a range for the sensitivity
  analysis. Likelihoods elicited after reading the evidence are the failure
  the plan exists to prevent.
- **Multi-method designs** add the cross-case dataset and its version, the
  cut-points that make its variables binary, the population, and the rule
  that decides which cases get within-case data. The rule must use only
  recorded values or say what else it conditions on: selection on
  unrecorded features is not ignorable (`mixed-methods.md`).

## What to lock, with vague-to-specific examples

1. **Query.** One primary; the rest secondary.
   - Vague: "We trace whether the opposition split caused the transition."
   - Specific: "Q1 (primary, case level): in Case A, where the split
     (X = 1) and the transition (Y = 1) are observed, did X cause Y? Query
     `Y[X=1] > Y[X=0]`, given `X==1 & Y==1`, answered with `query_model()`
     at the registered model's parameters. Prior: 0.50."
2. **Model.** The statement; each restriction and prior with its label
   (R1, P1) and reason; confounding arcs, or the reason there are none; the
   code and its hash.
3. **Clues.** For each: the node; where it will be sought (source
   categories, never names); φ1 = Pr(K = 1 | query true) and
   φ0 = Pr(K = 1 | query false); the probative value if found and if absent;
   the chance of finding it; the posterior either way; the expected
   learning.
   - Vague: "We will look for evidence of the mechanism in the archives."
   - Specific: "K1, the interior ministry's internal assessment of the
     split (node M): sought in the ministry's cabinet-correspondence series
     for 1988–90 and in interviews with senior ministry officials (category
     only). From the registered model: φ1 = 0.40, φ0 = 0.10, a smoking gun;
     found with probability 0.25; posterior 0.80 if found, 0.40 if not;
     expected learning 0.12."
   - The example carries the general lesson: a smoking gun that is
     unlikely to turn up teaches little in expectation. Choose clues by
     expected learning, and register the number.
4. **Search strategy.** Every clue in every traced case, or a two-step
   plan: the first clue, what follows each result, expected cost and
   learning.
5. **Cases.** Population, selection rule, the cases and the values the rule
   used, the replacement rule if access fails, the selection log.
6. **Coding rules.** Each node's rule version and the hash of
   `data/coding-rules.md`; the 0 standard (the search that must fail before
   a 0 is coded rather than NA); blind second coding; any LLM coder, with
   its model version, brief, and validation plan.
7. **Updating and reporting.** The data-assembly and updating scripts, the
   seed, the sampler settings, and what is reported for each query.
8. **Decision rules.**
   - Vague: "We will weigh the evidence holistically."
   - Specific: "Q1 is supported if its posterior is at least 0.75, counts
     against if at most 0.25, and is otherwise inconclusive; the prior and
     the posterior under every pattern of clue results are reported."
   - Thresholds are a reporting convention, not a significance test; their
     job is to keep the verdict from being written after the number.
9. **Robustness, committed now.** Named alternative priors; each
   restriction relaxed; confounding allowed; clue measurement error (true K
   → reported K); each case and each source dropped; values coded only from
   confidential items set to NA.
10. **Stopping rules.**
    - Vague: "Fieldwork continues until saturation."
    - Specific: "K1's search ends when the series named above has been read
      in full; interviews in each category stop after three consecutive
      interviews add nothing to any clue node; fieldwork ends on 30 June
      2027 or when the budget is spent, whichever is first."
    - Saturation is an empirical claim about a sample (Guest, Bunce &
      Johnson 2006); the plan states the criterion that will be checked,
      per interview category, before the interviews start.
11. **Surprises and deviations.** The addendum procedure below.
12. **Data availability and embargo.** What will be shared, what cannot
    be and why, and the embargo.

## Registries and timing

| Option | Check before choosing |
|---|---|
| OSF Registries | Which templates are currently offered and whether one fits a qualitative or causal-model design; attachments for code and tables; embargo length; whether reviewers can get an anonymized view-only link |
| EGAP registry | Where it is currently hosted, and whether it takes observational and qualitative designs |
| AsPredicted | Whether its short, fixed questions can carry a model, a clue table, and a selection rule, or only point to attachments |
| A journal's results-free or registered-report track | Whether the target journal currently offers one, for which article types, and what the first stage requires |

- **What any registry must give:** a time stamp, an immutable record, and
  an embargo. A plan in a private folder or a git repository is a plan,
  not a registration.
- **When:** before the decisive evidence is collected or read. Scoping
  fieldwork for access may come first if the plan says what it saw.
- **Historical and archival work.** The evidence often exists already, and
  some of it has been read. Register before reading the decisive series,
  and disclose by category what has been read: the secondary literature,
  published document collections, series consulted on a scoping trip. A
  plan written after the archive was read, without saying so, is worse
  than none.
- **Explore, then register.** Build the model on a scoping case, register
  it, then trace the test cases. The scoping case is reported as
  exploratory and does not count toward the confirmatory answer.

## Embargo and protection

- A public plan that names cases, sites, and sources can endanger
  participants and close the field. Describe sources by category ("senior
  ministry officials", "provincial party archives"), coarsen small sites,
  and never name an interviewee.
- Register under an embargo when the case itself is sensitive; check the
  registry's current embargo options and whether reviewers can see an
  embargoed plan.
- Run `qualstack-redact check` on `prereg/` before filing: the plan is
  publication.

## Deviations and addenda

Once `design.prereg_url` is set in `.qualstack/config.yaml`, the guard hook
makes the files in `prereg/` read-only; changes go in new files.

- **One dated addendum per change**: `prereg/addendum-YYYY-MM-DD.md`,
  written before the affected evidence is coded, stating what changed, why,
  what had been seen when the change was made, and what the plan now says.
- **Results-free framing.** The addendum describes the change and its
  reason, not what the change does to the answer. If the effect is already
  known, say so: that makes the change exploratory.

| Event | What the addendum does | What the paper reports |
|---|---|---|
| Archive closed, series missing, participant withdrew | The clue stays NA; nothing else changes | The clue as planned and not observed, and why |
| New evidence on a modeled node | Its probative value computed from the registered model before it is coded | Results with and without it |
| Evidence that needs a new node | The revised model, labeled as such, before the evidence is coded | Registered and revised models side by side |
| A coding rule proves ambiguous on contact with the evidence | A new rule version; every case recoded on that node | Results under both versions |
| The data contradict a restriction | The model without it, as a revision | Both models, side by side |
| A case is inaccessible, or a case is added | Replacement by the registered rule, or the reason for the addition, in the selection log | Results with and without the added case |
| A new query | Labeled exploratory | Kept apart from the confirmatory answers |

- **The deviations table** in the paper or appendix lists every element
  with what was registered, what was done, why, when, and the effect on
  the primary answer. A deviation reported only in a footnote is a
  deviation hidden.

## Common failures to refuse

- Clues listed with test labels but no likelihoods, chance of finding, or
  expected learning.
- Probative values from the author's judgment while a model exists to
  compute them.
- A clue plan computed on an earlier version of the model.
- A query in words only, with no `given` and no level.
- Decision rules missing or verbal ("consistent with").
- A selection rule that hides what it conditions on ("cases with good
  archives").
- No 0 standard: absence of evidence left free to be coded 0 or NA after
  the fact.
- No stopping rule, or "until saturation" with no criterion.
- Evidence already seen, not disclosed.
- A public plan that names participants or small sites.
- Model changes later described as robustness.

## What referees fault

| Complaint | Fix |
|---|---|
| "Preregistered", with nothing a reader could hold the author to | The query in code syntax, the model hash, the clue table with numbers, thresholds on the posterior |
| The likelihoods look chosen after the fact | The registered clue table, time-stamped before collection |
| The decisive clue was not in the plan | Its probative value from the registered model, results with and without it, labeled as unplanned |
| The registered model and the published one differ silently | The hash, and both models side by side |
| Cases added or dropped without explanation | The selection log, and results with and without |
| Deviations in a footnote | The deviations table |
| The plan was written after the archive was read | The disclosure of what had been seen, by category |
| Robustness checks chosen after the results | The committed list, run in full, before any extras |
