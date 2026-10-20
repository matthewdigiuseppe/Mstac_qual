# Concepts, nodes, and coding rules

Read by `/qualstack:causal-model` (defining nodes), `/qualstack:coding-rules`
(writing the rules), `/qualstack:code-evidence` (applying them),
`/qualstack:evidence-audit` (tracing values to evidence), and
`/qualstack:referee-mock` (the measurement referee). CausalQueries nodes are
binary, so every concept ends as 0, 1, or NA for one case in one period; this
file makes that value mean the concept, mean the same thing in every case, and
say "not observed" when nothing was observed.

## From concept to node

A node is a yes/no property of a case in a stated period: `B` = 1 if regime
and opposition negotiated the transition's rules in the 24 months before the
founding election.

- **Three levels (Goertz 2006, 2020).** Basic: the theory's concept
  ("negotiated transition"). Secondary: its dimensions (talks, agreed rules,
  the agreement governs the transition). Indicator: what is coded (minutes, a
  signed pact, the electoral law). The rule names all three.
- **Structure sets aggregation.** Necessary-and-sufficient: every dimension
  required (AND); adding one can only turn 1s into 0s. Family resemblance: m
  of n suffice, dimensions substitute (OR); adding one can only turn 0s into
  1s. Match the structure to where the theory puts the causal power; write
  `1 if` as Boolean logic: `(a) AND ((b) OR (c))`.
- **The 0 is a category too.** "Not negotiated" pools imposed transitions,
  collapses, and no transition; a binary node assumes all 0s (and all 1s) act
  alike on its children. If they do not, split the node.
- **Ladder of abstraction (Sartori 1970).** Fewer attributes (intension) reach
  more cases (extension); stretching carries the label to cases lacking its
  attributes. Check every attribute before any 1; when cases are added
  (`data/raw/`, /qualstack:case-select), climb the ladder openly (drop an
  attribute, rename, new version, recode all) or leave them out.
- **Diminished subtypes (Collier & Levitsky 1997)** lack an attribute of the
  root ("illiberal democracy": no full civil liberties); classical subtypes
  are full instances that add one. Such a case is 0 on the root unless the
  rule says otherwise; if the missing attribute matters, make it a node.
- **Measurement validity (Adcock & Collier 2001).** Background concept →
  systematized concept → indicators → scores, each level in the rule.
  *Content*: indicators cover every element of the systematized concept and
  nothing else. *Convergent/discriminant*: scores match other measures of the
  concept (a `data/raw/` dataset, gaps explained) and do not duplicate another
  node, least of all the outcome. *Nomological*: scores fit an established
  relationship other than the one under test. Different evidence across cases
  needs context-specific indicators argued equivalent.

## Dichotomizing honestly

- **Theory places the cut** where the effect switches on ("protest the regime
  cannot repress without splitting the army"), calibrated on substantive
  anchors, not sample statistics (Schneider & Wagemann 2012): a median split
  moves as cases are added and makes half the cases 1.
- **Fixed before coding.** The cut, its reason, and one or two alternatives
  are dated in `data/coding-rules.md` before any case is coded, and in
  `prereg/` if registered (/qualstack:preregister); /qualstack:robustness runs
  the alternatives. A cut moved after seeing a posterior is a forking path.
- **What is lost**: within-category variation and distance from the cut; log
  the raw level in `note`, flip near-cut cases in /qualstack:robustness.
- **Two nodes** when the parts have different causes or effects: onset
  (`Onset`: any sustained protest) vs. intensity (`Mass`: above the mass
  threshold). Nested nodes need a restriction against impossible combinations:
  `set_restrictions(model, "(Mass[Onset=0] == 1)")`.
- **Ordinal concepts**: k levels become k − 1 nested cumulative nodes ("at
  least level 2", …) or one node at the level theory names. Splits cost: n
  binary parents give 2^(2^n) nodal types (4, 16, 256, 65,536 for n = 1–4).
- **Timing.** A value covers a period anchored to a dated event from
  /qualstack:chronology; causes are measured before the outcome. Evidence
  written after the outcome counts only for what it reports about the period,
  with hindsight weighed in /qualstack:source-critique.
- **Unit.** The value belongs to the case, bounded in space and time (Gerring
  2017): the episode, not the country-year. Sub-unit properties (regions,
  factions) need a stated aggregation (any, all, a majority).

## What a coding rule contains

/qualstack:coding-rules writes exactly this to `data/coding-rules.md`, one
block per node in statement order; no complete block, no coding.

```markdown
# Coding rules

- **Model statement:** `<exactly as in code/01-model.R>`
- **Unit:** <case definition; IDs as in data/case-data.csv>
- **0 standard:** positive evidence of absence or the stated search; else NA.
- **Source precedence:** <ordered source types>; **ties:** <default value>

## `<node>` — <short label> (v2, YYYY-MM-DD)

- **Concept:** <background concept, as the literature uses it>
- **Systematized definition:** <dimensions; AND / OR / m of n>
- **Indicators:** (a) <observable>; (b) <observable>; (c) <observable>
- **Period:** <window anchored to a dated event>
- **1 if:** <Boolean rule over indicators, e.g. (a) AND ((b) OR (c))>
- **0 if:** <evidence of absence, or the search and why it would find it>
- **NA if:** <sources lost or closed; search short of the 0 standard>
- **Threshold:** <the cut; theoretical reason; pre-stated alternatives>
- **Evidence types:** <evidence/log.csv types that can establish it; minimum>
- **Anchors:**
  - Clear 1: <case> — <why> (<E0xx>)
  - Clear 0: <case> — <why> (<E0xx>)
  - Hard case: <case> — <the ambiguity> → <value>, by <clause>
- **Change log:**
  - v1 (YYYY-MM-DD): created.
  - v2 (YYYY-MM-DD): <what changed, why>; all <n> cases recoded.
```

Each evidentiary situation lands in exactly one of `1 if`, `0 if`, `NA if`;
test the block on anchors from pilot or out-of-scope cases where possible, and
turn each resolved hard case into a clause.

## 0 versus NA

The most consequential coding distinction in an Integrated Inferences
analysis: NA means not observed; 0 means observed absent. Coding a failed
search as 0 manufactures evidence.

- **The rule.** A 0 needs positive evidence of absence (a well-placed source
  denies it; a complete series, e.g. the cabinet minutes, is silent) or a
  search that would very probably have found the clue had it been there,
  stated in the log `note`: sources, period, terms, why they would record it.
- **Formally.** A case's likelihood sums over its NA nodes, so an NA
  contributes nothing about that node in that case; a wrong 0 moves the
  posterior as far as a true 0 (Humphreys & Jacobs 2023). In X → K → Y
  (monotonic, flat priors) P(X caused Y) in an X = 1, Y = 1 case is 0.20 with
  K unobserved, 0.25 with K = 1, and 0 with K = 0: K is a hoop clue (Van Evera
  1997), and a failed search coded 0 kills the hypothesis.
- **NA must not depend on the value.** CausalQueries treats NA as missing at
  random. Coding a failed strong search NA hides a true 0: in a 300-case
  simulation of X → K → Y, logging only hits moved the average effect from a
  true 0.20 to under 0.10, worse than never seeking K. Seeking the clue only
  where it is expected, or tracing cases for promising archives, does the
  same; selecting on observed values (every X = 1, Y = 1 case) is fine.
- **Hard to classify is not missing**: hard-case clause, low confidence, a
  flip in /qualstack:robustness. **One bar for every case**: what a 1 or a 0
  needs never depends on the case's outcome or fit with the hypothesis.

## Coding procedure and the coding log

- **One row per coded value**, NAs included, in `data/coding-log.csv`
  (`case,node,value,evidence_ids,rule_version,coder,confidence,note,date`):
  `evidence_ids` `;`-separated, all in `evidence/log.csv`; `rule_version` the
  node's (`v2`); `coder` initials; `confidence` `high`, `medium`, `low` (low:
  a plausible reading gives the other value); `note` the clause, the search
  behind a 0, why NA (searched short of the standard, or never looked), the
  underlying level, any conflict. Causal-process observations stay attached to
  the data-set values they become (Brady & Collier 2010).
- **`data/case-data.csv` is generated from the log** (latest rows), never
  hand-edited; /qualstack:evidence-audit checks they match, evidence IDs
  resolve, values carry current rule versions, and every 0 names its search.
- **Rule changes**: bump the version, log what and why, recode every case on
  that node (old rows stay), regenerate the case data. Never recode only the
  cases that hurt; a change made after seeing results is reported under both
  versions, and as a deviation if registered.
- **Blind coding.** Code clue nodes before seeing outcomes. When the author
  knows outcomes and hypothesis (most historical work), a second coder blind
  to both codes from the rules and excerpts stripped of outcome-revealing
  passages; report whether adjudication moved values toward the hypothesis.
- **Source conflicts are settled in the rule, not case by case**: a precedence
  order (contemporaneous internal records over retrospective interviews,
  participants over observers, documents without an audience over public
  statements), reliability from /qualstack:source-critique, several
  historiographies for secondary evidence (Lustick 1996). A tie is measurement
  error, not missingness: default value, low confidence, both IDs logged.

## Reliability

- **Double-code** all cases if N is small, else a pre-drawn random sample plus
  the hard cases (reported apart), the second coder blind to the first's codes
  and notes. Before adjudicating, report per node the 0/1/NA cross-tab and:

| Statistic | Use | Watch for |
|---|---|---|
| Percent agreement | Readable baseline | Inflated when one value dominates |
| Cohen's kappa (Cohen 1960) | Two coders (`irr::kappa2()`); κ = (p_o − p_e)/(1 − p_e), chance from each coder's marginals | Say whether NAs were dropped or made a category; misleads at extreme base rates |
| Krippendorff's alpha (Krippendorff 2018) | Any number of coders (`irr::kripp.alpha()`), missing codes allowed, nominal metric; floors .800, and .667 for tentative conclusions | Skips NAs: report separately how often one coder coded a value where the other coded NA |

- **Extreme base rates.** 20 cases, 19 coded 1 by each coder but not the same
  19: 90% agreement, κ = −0.05, α = −0.03. Report positive and negative
  agreement, 2a/(2a+b+c) and 2d/(2d+b+c) with a = both 1, d = both 0, b and c
  the splits (here 0.95 and 0), and the base rate.
- **Adjudicate after computing**, by the rule; record each disagreement and
  its resolution in `.qualstack/review-cache/coding-<date>/agreement.md`;
  final values get `coder` = `adjudicated`. A disagreement exposing an
  ambiguous rule is a rule change: new version, full recode.
- **An LLM may be the blind second coder** only within `privacy.ai_processing`
  in `.qualstack/config.yaml` (`none`: never; `pseudonymized`: pseudonymized
  `evidence/` text only; `restricted/`: never), logged as a research
  instrument with /qualstack:llm-checklist (model and version, date, prompt,
  settings, agreement). It sees rules and evidence, never outcome codes,
  hypothesis, or the author's codes; its values are adjudicated, never pasted
  in; `coder` = `llm:<task id in .qualstack/llm-usage.jsonl>`.

## Measurement error in the model

| Option | Use when | Cost |
|---|---|---|
| (a) Leave the node NA | The evidence meets neither the 1 bar nor the 0 standard | Information lost; harmless only if the NA does not depend on the value |
| (b) Code it, flip it in /qualstack:robustness | A few low-confidence values, each with a nameable alternative | The posterior treats the value as certain; report every flip that moves an answer |
| (c) Measurement node, true K → coded K | Error is systematic for a source type or across cases, or the clue carries the query | More nodal types; the error rate is a prior to justify and vary |

- **Building (c).** Add `K -> Kr`: `Kr` holds the codes, `K` stays NA except
  where a stronger source settles it. Of `Kr`'s types, `00` codes 0 regardless
  (a miss when K = 1), `01` is accurate, `11` codes 1 regardless (a false
  positive when K = 0), and `10` (inverted) is removed with
  `set_restrictions(decreasing("K", "Kr"))`. Sensitivity is P(01) + P(11), the
  false-positive rate P(11); set both as priors, e.g. `set_priors()` with
  `param_names = c("Kr.00", "Kr.01", "Kr.11")` and `alphas = c(20, 75, 5)` for
  .80 and .05. With these, Kr = 0 in the X → K → Y example gives 0.11, not 0.
- **The rate is learned only where K is observed.** Code K in validation cases
  and updating calibrates the rate (Humphreys & Jacobs 2023); elsewhere it is
  a prior from record-keeping practice or intercoder disagreement, weighted by
  the alphas' total (100 firm, 10 loose), varied in /qualstack:robustness.
- **Differential error.** Random misclassification of a cause pulls its effect
  toward zero (King, Keohane & Verba 1994); error that depends on the outcome
  (memoirs crediting bargaining when the transition succeeded) biases either
  way. Model it with the outcome as a second parent, `K -> Kr <- Y`; without
  that edge the error is assumed the same whatever the outcome.

## Case data format

`data/case-data.csv`: one row per case (IDs as in `evidence/log.csv`); header
`case,<node>,<node>,…` with names exactly as in the model statement,
case-sensitive, letters and digits only (`make_model()` rejects `_` and `-`);
every node present, latent ones NA unless observed; values `0`, `1`, `NA` only
(no blanks, `?`, `yes`, `0.5`, `-99`). Example: header `case,X,K,Y`, row
`case02,1,NA,1`.

- **What CausalQueries does with it.** `update_model()` keeps columns named as
  nodes and ignores `case`; it stops only if no column matches. A misspelled
  node column is dropped silently (that node becomes NA in every case); a cell
  outside 0/1/NA drops the whole case with only a message ("… data is
  inconsistent with model and ignored"). Rows become pattern counts per set of
  observed nodes, NAs marginalized as missing at random (Tietz, Medina,
  Syunyaev & Humphreys 2026). For case-level process tracing, a row's non-NA
  values are the `given` of `query_model(..., case_level = TRUE)`.
- **`code/03-data.R` asserts** after `read.csv(..., na.strings = "NA")`:
  `setequal(names(d), c("case", model$nodes))`,
  `all(unlist(d[model$nodes]) %in% c(0, 1, NA))`, `!anyDuplicated(d$case)`.
- **Cross-case data.** `data/raw/` is read-only, so `code/03-data.R`
  dichotomizes with the rule's cut (a comment cites node and version), under
  the node's name, only if the variable meets the node's systematized
  definition (else it is another node), joins on case ID with row-count
  assertions, and writes `data/clean/analysis-data.csv` for
  `code/04-update.R`. Where a traced case has a dataset value and a
  within-case code, the precedence clause decides and disagreements are
  reported: traced cases audit the dataset (Seawright 2016).

## What referees fault

| Complaint | Fix |
|---|---|
| Concept stretching: the label travels to cases lacking its attributes | Full definition in the rule; every 1 checked against every attribute; climb the ladder openly, rename, recode every case |
| Threshold chosen after the fact | Rule dated before coding (git, `prereg/`); theoretical reason stated; pre-stated alternative cuts run in /qualstack:robustness |
| Indicators that measure the outcome | Indicators dated before the outcome period; discriminant check against the outcome node; contaminated indicators dropped |
| Inconsistent coding across cases | Anchors; one rule version for every case; /qualstack:evidence-audit consistency pass; full recode after any change |
| Absence of evidence coded as evidence of absence | The 0 standard with the search in the log; NA otherwise; a measurement node when searches are only moderately strong |
| No reliability evidence | Double coding; per-node cross-tab, kappa or alpha, and specific agreement, all before adjudication |
| Coding by the author who knows the hypothesis | Clue nodes coded before outcomes; a blind second coder (human, or an LLM logged with /qualstack:llm-checklist); how adjudication moved values reported |
| Ambiguous cases coded NA, or a 0 pooling unlike cases | Hard-case clause and a robustness flip; split a heterogeneous node |
