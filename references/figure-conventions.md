# Figure conventions

Read by `/qualstack:viz` when it chooses the figure set and writes
`code/06-figures.R`, and by the skills that describe or check a figure
(`/qualstack:draft-section`, `/qualstack:referee-mock`,
`/qualstack:submission-pack`). The bundled
`${CLAUDE_PLUGIN_ROOT}/skills/viz/assets/theme_qualstack.R` implements the
mechanics (palette, theme, one helper per figure, and `qs_save()`, which
writes PDF, PNG, and the plotted data as CSV); this file is about which
figure makes which claim, how to draw a causal model and its evidence
without overstating either, and what a referee will fault. Humphreys &
Jacobs (2023) is cited as II.

## Figure by claim

| Claim | Figure | Construction rules | Helper (reads) |
|---|---|---|---|
| "These are the premises" | The DAG | From the saved model; left to right in time; every `<->` drawn; restrictions as + / − on arrows or stated in the caption | `qs_plot_dag()` (`model.rds`) |
| "The cases moved belief about the population this much" | Prior and posterior of the query | Both, always; intervals from `queries.csv`, or densities from the saved draws | `qs_plot_prior_posterior()` |
| "In this case, these clues moved the answer from p to q" | Evidence path | Prior first; one step per clue in the order sought; E-IDs under the clues; ends at the reported answer | `qs_plot_evidence_path()` (`trace-<case>.csv`) |
| "These clues are worth seeking" | Expected learning by clue or clue set | Share of prior variance removed; test type and chance of finding as labels | `qs_plot_clue_learning()` (`clue-diagnosis.csv`) |
| "Searching in sequence buys the same learning for less" | Cost–variance frontier | Undominated strategies filled and joined; prices stated | `qs_plot_frontier()` (`clue-frontier.csv`) |
| "These are the cases to trace" | Expected posterior variance by case-selection strategy | Prior variance as the line to beat; cells named | `qs_plot_case_strategies()` (`case-diagnosis.csv`) |
| "The answer does not hang on one assumption" | The answer under each model variant | Base model highlighted; one change per variant | `qs_plot_sensitivity()` (`robustness-*.csv`) |
| "It happened in this order" | Case chronology | Each event at its logged date precision, with its E-IDs | `qs_plot_timeline()` (`chronology-<case>.md`) |
| "More cases, or more clues per case?" | Breadth against depth | Expected posterior variance against deep cases, one line per breadth, costs labeled, simulation error shown | none: plot `qs_wide_deep()` output with the theme |

## The DAG

- **Drawn from the saved model**, never by hand: figure and
  `code/01-model.R` agree on every node, arrow, and `<->`, and the statement
  string goes in the caption or a footnote (`writing-conventions.md`).
- **Left to right in time.** Roots at left; no node sits left of one of its
  causes. The bundled layout places each node by its generation (longest
  path from a root); pass `x` when calendar time says otherwise (a root
  settled late, a moderator fixed just before the outcome). Vertical position
  carries no meaning.
- **Missing arrows are the claims** (II §2.3.1). No arrow the model lacks is
  drawn for emphasis; none it has is dropped for tidiness.
- **Every `<->` drawn**, as a dashed arc with two heads. A figure without the
  confounding the model allows misstates what the cases can identify.
- **Restrictions on the figure or beside it.** A sign a restriction fixes
  goes on the arrow (+: no negative effect remains; −: no positive one).
  Restrictions that are not signs ("Y only if both": one nodal type kept)
  go in the caption with counts ("Y keeps 1 of 16 nodal types") and in an
  appendix table from `qs_restrictions()`: node, parents, types kept and
  removed. An answer a restriction settles before any evidence is flagged
  in the text as an assumption (II §8.2.3).
- **Labels**: node names exactly as in code, so a reader can match them to
  the tables; descriptive labels under them; each node's 1 and 0 defined in
  the caption or the coding-rules table.
- θ and λ are not drawn unless the figure is about types. Rival models go
  side by side in the same layout, so the change is the only difference.
- Highlight sparingly (filled nodes: the clues sought within cases), and
  say so in the caption.

## Prior and posterior

- **The prior always.** A posterior alone hides how much the cases did and
  how much the prior did; with ten or fewer cases the prior is not
  overwhelmed (II §9.2.2.6).
- **Intervals from the table.** The 95% intervals are the equal-tailed
  intervals `query_model()` wrote to `queries.csv`; a figure whose numbers
  the text cites plots that table. Densities come from the saved posterior
  and a seeded prior, and their means must equal the table's.
- **Which answer.** Population and subgroup shares carry intervals. A named
  case's probability is one number, shown on its evidence path or in a
  table, never with an interval; the caption says whether it is the share
  of cases like it (π̂, `case_level = FALSE`) or a new case's probability
  (φ̂), II §9.3.2.1.
- **Non-identified queries keep a ridge** (II §9.3.3): show the whole
  posterior, never trim it to look settled, and pair it with the
  sensitivity figure.
- **An answer fixed by a restriction** is the same spike at 0 or 1 in both
  distributions; caption it as an assumption.
- **A headline that barely moves can hide learning** (II §10.1.4): plot the
  nodal-type shares in `parameters.csv`, prior against posterior, in the
  appendix.
- Densities are bounded (0 to 1 for probabilities, −1 to 1 for effects); at
  most four queries as densities, more as intervals.

## Evidence paths

- The prior first, then one step per clue in the order sought (the clue
  plan), each labeled with its value and E-IDs. The last point equals the
  case's reported answer, computed with the same `using` and `case_level`.
- **Order changes the steps, not the end** (II §5.3.3). The largest step is
  not "the decisive clue": what a clue does depends on what was already
  seen, and in II's reanalysis international pressure was worthless once
  mobilization had been observed (II ch. 8). "What if it had come out the
  other way" is the counterfactual table's job; keep it a table.
- Absence is a value: a clue sought and not found is 0, a step like any
  other; a clue that could not be observed is NA and moves nothing.
- Informal traces: the posterior at both ends of the likelihood ranges as
  bars. Weights of evidence in decibels (Fairfield & Charman 2022) go in
  the table, not on a second axis.
- A threshold line only if the text uses one. Beyond six cases, a table:
  prior, final posterior, the clue that moved it most.

## Design figures

- Clues are chosen by expected learning, not by probative value
  (`bayesian-process-tracing.md`): the bar is expected learning; the label
  gives the test type (Van Evera 1997) as the shape of the evidence, never
  its strength.
- A query the model already answers (prior variance 0) offers nothing to
  learn; report it, do not plot it (II ch. 14).
- **Frontier**: prices from the clue plan, elicited before the search;
  strategies labeled in words ("M; P if M=1"). The most probative first clue
  need not be on the frontier (II §12.2).
- **Case strategies**: the prior variance is the line to beat; cells named
  (X1Y1); a strategy the data cannot supply (too few untraced cases in a
  cell) is dropped, not drawn; a low effective sample size is marked.
- **Breadth against depth** (II ch. 14): the reduction relative to the
  cheapest design, one line per number of wide cases, costs labeled,
  simulation error shown, the chosen design marked.

## Sensitivity

- One change per variant against the base, named by the change ("no
  monotonicity, X → M"); the base model highlighted and listed first. The
  variants come from the model review, not from the results
  (`/qualstack:robustness`).
- Intervals where they exist; single-case answers at fixed parameters are
  points.
- Mark answers that change sign or cross .5, and answers fixed by the base
  model's restrictions.
- Probabilities compared across panels share the 0–1 axis, so a shift of
  .03 does not look like a collapse.

## Timelines

- The event date, not the document date (`evidence-and-sources.md`). Each
  event at its logged precision: a point only for a day; a bar for a month,
  a year, or a stated span, with no point inside it, which would claim a
  day.
- Overlapping bars mean the order is not established. The caption says so;
  the text names the relative evidence that fixes an order, if any.
- Inferred dates (`?`) and events attested only by recollection are marked;
  every event carries its E-IDs; people appear only as pseudonyms.
- Reference events (the outcome, a juncture) are labeled vertical lines,
  not legend entries. Compared sequences get one panel per case on a shared
  axis (Falleti & Mahoney 2015); a juncture shows when choice opened and
  when it closed (Capoccia & Kelemen 2007).
- The timeline tests the model: for every arrow A → B, A is settled before
  B (Waldner 2015). A figure that shows otherwise goes back to
  `/qualstack:chronology`, not into the paper.

## Tables or figures

| Prefer a table for | Prefer a figure for |
|---|---|
| Numbers the text cites: posteriors by case, likelihoods, test types | How far belief moved, and from what prior |
| The counterfactual table | One case's path, or up to six side by side |
| Restrictions, priors, nodal types | The DAG |
| More than six cases | The shape of a frontier or a sensitivity profile |
| The sources behind each event | The order of events in time |

## Titles and captions

- The title states the claim, in a sentence a reader could repeat. Where the
  journal sets no titles in the image, the claim opens the caption.
- The caption's first sentence says what the reader should see, with its
  number ("rises from .38 to .81 on finding the minutes"); then the notes:
  model statement, cases and clues used, which answer (π̂ or φ̂), draws and
  seed, the source table. Captions are generated in code, so their numbers
  follow the outputs.
- The text cites each figure by its claim, never only as "Figure 3".

## Accessibility

- Roles keep distinct gray levels and a second encoding: prior dashed or
  hollow, posterior solid or filled, base model a diamond, dominated
  strategies hollow. The bundled palette is colorblind-safe and survives
  grayscale printing; at most four series in a panel.
- Direct labels over legends; text 8 pt or more and lines 0.5 pt or more
  after scaling to print size.
- Alt text where the journal or the repository asks for it: the caption's
  first sentence plus what each axis shows. Check whether it is required.
- No dual axes, 3D, pies, gradient fills, or decorative gridlines.

## Formats and submission

- `qs_save()` writes a vector PDF (fonts embedded through cairo where
  available), a 300-dpi PNG for slides, and the plotted data as CSV; the
  CSV and `06-figures.R` go into the replication package
  (`/qualstack:archive`).
- Common sizes are about 3.3 in for one column and 6.5–7 in for two.
- File formats (PDF, EPS, TIFF), resolution, color charges or color online
  only, embedded or separate files, titles inside the image, and limits on
  the number of figures differ by journal and change: check the journal's
  current artwork and author guidelines (`journals.md`) before the final
  export, never from memory.

## What referees fault

| Complaint | Fix |
|---|---|
| The DAG differs from the model estimated | Generate it from the saved model |
| Restrictions invisible in the model figure | Signs on arrows; the caption; an appendix table |
| A posterior shown without its prior | Overlay them |
| An interval on one case's probability | One number, and say which question it answers |
| A path ending at a number the text does not report | The same `using` and `case_level` as the table |
| "The decisive clue" read off the largest step | Order, dependence, and the counterfactual table |
| Dates more precise than the sources | Logged precision; bars; inferred dates marked |
| Colors that need a legend, or vanish in print | Roles with a second encoding |
| A figure the text never cites | Cite it by its claim, or cut it |
