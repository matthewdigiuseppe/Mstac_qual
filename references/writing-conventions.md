# Writing conventions for case-based and multi-method papers

Read by `/qualstack:draft-section`, `/qualstack:abstract-shotgun`,
`/qualstack:title-shotgun` (the hedging scale), `/qualstack:coauthor-review`,
and `/qualstack:referee-mock` (editor persona). Voice, rhythm, and vocabulary
come from the user's writing-style skill (`voice.writing_style`); this file
covers what each section owes the reader, how evidence is cited and quoted,
how models and process-tracing results are shown, and what referees enforce
on qualitative and multi-method work built on a causal model (Humphreys &
Jacobs 2023, cited as II).

## The shape of a case-based paper

| Section | Job | Built from (memos in `.qualstack/`) |
|---|---|---|
| `intro` | The question as a counterfactual, the answer with a number, a case of what | `research-question.md`, `queries.md`, `output/tables/queries.csv` |
| `theory` | The argument as a causal model: DAG, restrictions, priors, query, rivals | `theory.md`, `model.md`, `queries.md`, `code/01-model.R` |
| `design` | Why these cases, which clues and why, sources and access, coding, ethics | `design.md`, `case-selection.md`, `clue-plan.md`, `data/coding-rules.md` |
| `cases` | One narrative per case, organized around the clues and the query | `process-trace-<case>.md`, `chronology-<case>.md`, `evidence/log.csv` |
| `results` | Prior beside posterior for every query; what the clues moved; robustness | `output/tables/queries.csv`, `case-answers.csv`, `robustness-*.md` |
| `discussion` | What was learned, what it is not, the strongest rival, the next clue | `theory.md`, `robustness-*.md`, `model-review-*.md` |
| `appendix` | Evidence, interview methods, coding, model code, sensitivity, LLM use | `evidence/log.csv`, `data/`, `code/`, `llm-checklist.md` |

- **Single case**: `cases` carries the inference; `results` is one posterior
  table and the robustness paragraph. **Comparison**: parallel subsections
  (same clues, same order), then a cross-case table. **Multi-method**:
  `results` leads with the population answer from the joint update and the
  cases show what the clues moved; cases that only illustrate a regression
  are the commonest complaint.
- **A starting allocation**, until the journal's current cap decides: intro
  10%, theory 15%, design 10–15%, cases 35–45%, results 10%, discussion
  5–10%; chronologies and evidence tables move to the appendix first.

## Introduction

- Open with the question and its stake (a puzzle, a live dispute), never
  "scholars have long debated"; then the query as a counterfactual about a
  named cause: "had the army not split, would the regime have negotiated?",
  not "this paper explores the role of the military" (Fearon 1991).
- The contribution paragraph: what we do (model, cases, evidence in counts:
  "212 documents from four archives and 31 interviews"), what we find with a
  number ("the evidence raises the probability that the split caused the
  talks from 0.35 to 0.81"), what changes if it is believed.
- **A case of what**, on page one: the population and the route (the model,
  scope conditions, cross-case data), or why the case matters in itself
  (Gerring 2017); then the two or three closest works and the
  historiography, and where this evidence disagrees. Roadmap: one sentence.

## Reporting the causal model

`theory` shows the model the inference used, so that a reader could rebuild
`code/01-model.R` (II chs. 2–4); the code and seed go in the appendix.

- The argument in one sentence, then its steps as nodes, each with a
  one-line definition naming its rule in `data/coding-rules.md`.
- **The DAG** as a figure (`/qualstack:viz`) titled by the claim, with a note:
  arrows are possible effects, missing arrows claim no direct effect, dashed
  arcs are unobserved confounding; the statement string in a footnote.
- **Restrictions, priors, confounding** in one table, labeled as in
  `code/01-model.R`; each absent `<->` with a plausible common cause defended:

| Label | In words | Nodal types affected | Justification (one line) | Source of the belief |
|---|---|---|---|---|
| R1 | Conscription (`X`) never makes the equal-sacrifice argument (`C`) less likely | `C`: 10 removed | No faction argued that conscription weakened the case for taxing wealth | Parliamentary debates; prior studies |
| P1 | A positive effect of `C` on the surtax (`Y`) gets twice the prior weight of each other type | `Y` types with a positive `C` effect | Equal-sacrifice appeals preceded surtaxes in earlier wars | Secondary literature on earlier wars |
| C1 | `X <-> W`: conscription and fiscal need (`W`) share a cause | confounding | Both follow the scale of the war | Theory |

- **The query** in words as a counterfactual, its family (case-level effect,
  attribution, path, average, actual cause), and its CausalQueries string
  with the `given`; for a path, which indirect effect (X held at 0 or 1).
- **What the model settles before evidence**: the prior at the case's X and
  Y, and any answer a restriction fixes, as an assumption ("if X acts only
  through C, C = 0 rules out an effect, whatever the archive"; II §8.2.3).
- **Rivals as model claims**: an alternative cause is a node with its own
  arrow into Y; causes are not rivals, so "X or W?" becomes two queries.
- **Informal route** (`model.formal: false`): an exhaustive, mutually
  exclusive set of hypotheses about the case, each prior from stated
  background knowledge, and how and when likelihoods were elicited.

## Research design

- **Why these cases**: the population; the selection rule as applied, with
  the values it used; the strategy named against the query (typical,
  deviant, most or least likely, diverse; Seawright & Gerring 2008); the
  expected learning that justified them; the cases not traced and why.
- **The selection log**: each traced case and the rule that put it there;
  whether selection is ignorable or on the outcome (Geddes 1990; Collier &
  Mahoney 1996), and the remedy (`mixed-methods.md`).
- **Which clues and why**: the clue plan as a table (node, where sought, the
  two likelihoods or the model's equivalent, test shape, expected learning,
  date recorded), chosen by expected learning before collection.
- **Sources and access**: archives and series with date ranges, closures,
  and withdrawals; the interview frame with counts sought, obtained, and
  refused; secondary works coded as evidence, and why those historians.
- **Coding**: the 1 / 0 / NA standard (a 0 needs a search that would have
  found the clue), versions, coders, agreement before adjudication, LLM
  coders disclosed; **preregistration** with deviations beside the plan.
- **Ethics**: approval "by the author's institutional review board" (the
  number on the title page), consent tiers, pseudonymization, the AI
  processing allowed; nothing naming the institution, hosts, or participants.

## Case narratives built around clues

- **Clues, not chronology, are the units**: a short dated anchor or timeline
  figure places events, then one block per clue in the order of the
  process-trace memo; a year-by-year story buries what discriminated.
- Open each case with its observed values, the query for this case, and
  the prior: the answer given only what was known before the clues.
- Each clue block: what was sought and where; what was found, every factual
  claim cited; the source's position where it moves the likelihood; the
  likelihood under each hypothesis and its origin (the model, or the source
  critique); the running posterior; and **the counterfactual**, what would
  have been concluded had the clue come out the other way.
- **Rivals**: restate them as mutually exclusive claims about the case
  (Zaks 2017); for each, the clue that separates it and which way it went.
- Report what cut against the argument (the contrary clue or source, the
  search that found nothing, by its E-ID); count dependent items (one leak,
  one recollection retold) once and say so. Close with the case posterior
  and the unmade observation that would move it across the threshold.

```latex
\paragraph{Clue: the equal-sacrifice argument in cabinet (node $C$).}
If conscription drove the surtax, ministers should have argued for it as
equal sacrifice before the vote; if fiscal need did, only afterward. The
minutes of the week before the vote record the finance minister proposing
it ``so that wealth bears its share as men bear theirs'' \ev{E014}, a
private record written before the outcome. With $\Pr(C{=}1)$ of 0.80 if
conscription caused the surtax and 0.30 if not, finding it raises the
probability from 0.40 to 0.64; silence would have cut it to 0.16.
```

## Citing evidence

- `\ev{E014}` (macro in `paper/main.tex`; `[E014]` in Quarto) inside the
  sentence it supports, several as `\ev{E014, E031}`; every factual claim
  about a case carries one ("interviews with officials" is not a citation).
- Every ID is a live log row, never `withdrawn:`; confidential items are
  cited like any other, tier and access route in the appendix. For full
  archival citations in notes, redefine `\ev` at submission.
- `\cite{}` for literature engaged as argument, an E-ID for a secondary work
  coded as evidence; cite the primary, not the historian quoting it.
- A quotation's `\ev{}` sits in its sentence (`qualstack-quotecheck` reads
  300 characters after it). Counts beat adjectives: "six of eight finance
  officials interviewed", with their IDs, not "officials agreed".

## Presenting process-tracing results

Every number comes from `output/tables/` (`queries.csv`, `case-answers.csv`,
`clue-value.csv`, `parameters.csv`), a robustness table, or a process-trace
memo; probabilities to two decimals.

| Table | Rows | Columns | Rule |
|---|---|---|---|
| Posterior | each query × given | query in words, given, prior, posterior, interval (population) or one probability (named case), the question answered | The prior always beside the posterior |
| Likelihood | each clue | value found, Pr(K \| H), Pr(K \| not H), source of the numbers (model, clue plan, source critique), likelihood ratio, test shape | A shape label only beside its two numbers |
| Counterfactual | each clue, and each data strategy (none, each alone, all) | value found, posterior as found, posterior had it come out the other way (others as found) | Shows what the evidence could have shown |
| Evidence weight (informal) | each item, in an order fixed before reading | Pr(E \| H), Pr(E \| not H), ratio, weight in decibels, 10·log10(ratio) (Fairfield & Charman 2022), running posterior, ranges | Dependent items combined before weighing |
| Trained vs. untrained clues (multi-method; `clue-value.csv`) | each clue × case type | answer with no clue, K = 0, K = 1, prior-only and trained model | Each clue labeled theory-derived, data-derived, absent, or contradicted |
| Robustness | each perturbation | what changed, posterior, shift | Includes confidential-only values set to NA |

- **Name the question** for every case-level number: uninformative case
  (`case_level` FALSE; chosen for its pattern, or already in the update) or
  informative case (`case_level` TRUE; a new case), never both for one case
  (II §9.3.2); with fixed parameters (`using` = parameters) they coincide.
  A named case gets one probability; a `case_level` FALSE interval is about
  the share of cases like it, and is labeled so.
- Restriction-driven answers are flagged as assumptions; a query that barely
  moved is reported with the type shares that did (`parameters.csv`;
  II §10.1.4). Figures: the DAG, prior-to-posterior plots, case timelines.

## Hedging calibrated to posteriors

State the scale once (design or a footnote); apply it to every claim, title
and abstract included; read "X did not cause Y" at 1 minus the posterior.

| Posterior on the claim | Write | Never |
|---|---|---|
| ≥ 0.95 | "very likely"; "the evidence strongly supports" | "proves", "establishes", "confirms", "demonstrates" |
| 0.80–0.95 | "likely"; "the evidence favors" | "clearly shows" |
| 0.60–0.80 | "more likely than not"; "modest support" | "strong support" |
| 0.40–0.60 | "the evidence does not settle it"; "about as likely as not" | "mixed but supportive" |
| 0.20–0.40 | "less likely than not"; "modest evidence against" | "refutes" |
| 0.05–0.20 | "unlikely"; "the evidence weighs against" | "rules out" |
| ≤ 0.05 | "very unlikely" | "disproves"; "rules out", unless a restriction does it: then "by assumption" |

- **Movement is a finding**: "raises it from 0.35 to 0.81", "barely moves it
  (0.40 to 0.44)"; a large move from a low prior can leave a claim unlikely.
- **A belief, not an effect size**: "0.8 that the split caused the talks",
  never "the split explains 80% of the outcome" (II ch. 4).
- **Causal verbs** only for the query the posterior answers; "preceded" where
  only sequence is known; a mediator that occurred is not a path.
- **One hedge per claim** ("may possibly suggest" is two); informal
  posteriors carry their range. "Hoop" and "smoking gun" are shapes, not
  strengths (Van Evera 1997; Collier 2011).

## Discussion and abstract

- **Discussion**: the contribution with its posterior; what the answer is
  not (one case's attribution is not an average effect); the strongest
  rival and the clue that moved the evidence against it; specific limits
  (the restriction leaned on, the single-source clue, the closed archive,
  confidential-only values); generalization only through the model or
  scope conditions; one next study, the clue or case with most to teach.
- **Abstract**: the query as a counterfactual, cases and design, evidence in
  counts, the finding with its posterior, the portable lesson; within the
  target journal's current cap; no citations, no `\ev{}`, no hedging stack.

## Quotations and translation

- Quote when the wording is the evidence (a commitment, a framing, an order,
  a statement against interest); otherwise paraphrase, still cited.
- Verbatim from the file in `evidence/` (`evidence/md/` for converted PDFs),
  never from memory or a memo, until `qualstack-quotecheck` says `verified`.
  An ellipsis marks every cut, never across a negation, qualifier, or
  condition; brackets for insertions; `[sic]`, not silent correction.
- Context and denominator: how many sources in the category address the
  point and how many agree; the strongest disconfirming quotation; for a
  contested quote, the surrounding passage in the appendix or an active
  citation or ATI annotation (Moravcsik 2010).
- **Translation**: the original-language text is the record; give each
  quoted passage's original in a note or the appendix, name the translator
  in the log, gloss key terms once with the original word.
- **Within consent**: on the record, a name only with written consent; not
  for attribution, verbatim with a coarse role; background, paraphrase only;
  deep background, never cited; `archive-restricted`, within its terms.

## Pseudonyms and anonymity

- People are `P01`, `P02`, … with a coarse role ("P07, a senior finance
  official"); places and organizations as in the key (`[Town 3]`,
  `[Ministry A]`); one pseudonym per person across text, tables, appendix.
- At most one precise indirect identifier per attribution, never role +
  date + place in a small population; the insider test: could a colleague
  of P07 name P07? (Fujii 2012; APSA 2020).
- Real names only for public figures acting publicly and on-the-record
  interviewees with written consent; `qualstack-redact check paper/` clean
  before sharing. For review, self-reference, acknowledgments, protocol and
  grant numbers go to the title page (`transparency-and-ethics.md`).

## The transparency appendix

| Part | Content | From |
|---|---|---|
| Evidence table | ID, type, date, archive route or category, access tier, cases, clues; confidential rows by pseudonym, role category, year | `evidence/log.csv` (never the `notes` column) |
| Interview methods (Bleich & Pekkanen 2013) | Per category: sought, obtained, refused, saturation, format, length, recording, transcription | log rows of type interview; `.qualstack/fieldwork-plan.md` |
| Coding | Rules by node and version; agreement before adjudication | `data/coding-rules.md`, `data/coding-log.csv` |
| Model | Statement, restrictions, priors, code, seed, package version | `code/01-model.R`, `code/04-update.R` |
| Case tables | Likelihood and counterfactual tables per case | `.qualstack/process-trace-<case>.md` |
| Sensitivity | Each robustness run and its shift | `output/tables/`, latest `.qualstack/robustness-*.md` |
| Originals and withheld items | Original-language text of translated quotations; what is not shared, why, and the access route | `evidence/`; `access` tiers in the log |
| Deviations and LLM use | Preregistration deviations; the GUIDE-LLM block | `prereg/`; `/qualstack:llm-checklist` |

## What referees fault, by section

| Section | Complaint |
|---|---|
| Introduction | A topic, not a query; no number; "a case of what?" unanswered |
| Theory | DAG of the favored path only; restrictions unstated or unjustified; causes treated as rivals; the query never written as a counterfactual |
| Design | No selection rule; selection on the outcome unaddressed; clues picked after reading the archive; an ethics paragraph that unblinds |
| Cases | Chronology in place of inference; test labels without likelihoods; every observation fits; a decisive clue on one source; memoirs for motives; quotations without denominators |
| Results | A posterior with no prior; case-level and population answers conflated; restriction-driven answers sold as findings; "confirms" |
| Discussion | Generalizing from the case's vividness; boilerplate limitations; implications beyond the query |
| Appendix | No evidence or interview methods table; translations without originals; LLM coding undisclosed |
