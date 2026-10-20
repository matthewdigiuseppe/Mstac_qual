---
name: viz
description: Designs the paper's figures as code, each matched to the claim it carries — the causal model as a DAG drawn from the saved model (left to right in time, confounding as dashed arcs, restrictions marked or stated), prior against posterior for every reported query, the evidence path of each traced case clue by clue, expected learning by clue, the two-step cost–variance frontier and case-selection strategies, the answer under each model variant, and case chronologies at the precision of their dates — in code/06-figures.R with a bundled grayscale-safe ggplot theme that writes PDF, PNG, and the plotted data as CSV to output/figures/, plus captions that say what the reader should see. Use when the user asks for figures, plots, a DAG or causal-graph figure, a prior/posterior plot, an evidence-path or process-tracing figure, a timeline or chronology figure, or slide-ready graphics from QualStack results.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(Rscript *)
  - Bash(python3 *)
  - Bash(cp *)
---

# /qualstack:viz

**Stage:** analyze · **Voice:** figure-designer

After `/qualstack:analyze`, `/qualstack:process-trace`, and `/qualstack:robustness`, before `/qualstack:draft-section`: the figures lock the visual argument, then the prose describes them. A reader who skips every table should see the model, what the evidence did to belief, and how much of the answer the model's assumptions carry. This skill draws nothing by hand, types no number into a figure, and shows no posterior without its prior.

## Procedure

1. **Load** `.qualstack/config.yaml` (`model.formal`, `model.primary_query`, `model.seed`, `target_journals`), `.qualstack/queries.md`, `.qualstack/clue-plan.md`, the saved outputs (`output/models/model.rds`, `model-updated.rds`; `output/tables/queries.csv`, `case-answers.csv`, `trace-<case>.csv`, `robustness-*.csv`, `clue-diagnosis.csv`, `clue-frontier.csv`, `case-diagnosis.csv`), and the `.qualstack/chronology-<case>.md` memos. `Read ${CLAUDE_PLUGIN_ROOT}/references/figure-conventions.md`; R rules in `${CLAUDE_PLUGIN_ROOT}/references/r-conventions.md`. Run `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-status`: if `queries.csv` or the robustness memo is stale or missing, stop and send the user to `/qualstack:analyze` or `/qualstack:robustness`, because a figure drawn from stale numbers contradicts the table beside it. With a target journal set, ask for its current artwork guidelines (column width, file formats, color policy); never assume them.
2. **Choose the figure set** from "Figure by claim" in the reference. Of each candidate ask: which sentence of the paper does this figure prove? No sentence, no figure.
   - Formal model: the DAG (main text); prior against posterior for the primary query and every query the abstract reports; the evidence path of each traced case whose verdict the text states (small multiples up to six, a table beyond); the sensitivity figure for the primary query.
   - Design figures (expected learning, the two-step frontier, case-selection strategies) when the design section argues for its choices, usually in the appendix.
   - A timeline when a claim turns on order, sequence, or a juncture.
   - `model.formal: false`: evidence paths with likelihood-range bars, and timelines; a DAG only as a picture of the argument (`make_model(model.statement)`, never updated), captioned as such.
3. **Write `code/06-figures.R`.** `cp ${CLAUDE_PLUGIN_ROOT}/skills/viz/assets/theme_qualstack.R code/theme_qualstack.R` once per paper; the copy stays verbatim (project styling goes in 06-figures.R). Skeleton:

```r
# 06-figures.R — the paper's figures. Every number comes from output/.
library(CausalQueries)
library(ggplot2)
library(here)
source(here("code", "theme_qualstack.R"))
options(qs.fig_dir = here("output", "figures"))
SEED <- 20250101                                   # model.seed
model <- readRDS(here("output", "models", "model.rds"))
qtab  <- read.csv(here("output", "tables", "queries.csv"))
fig_1_model <- qs_plot_dag(model, labels = c(X = "Reform", M = "Mobilization", Y = "Turnover")) +
  labs(title = "Reform can raise turnover directly or through mobilization")
qs_save(fig_1_model, "fig-1-model", data = qs_dag_data(model), height = 3)
fig_2_posterior <- qs_plot_prior_posterior(qtab, queries = "PoC") +
  labs(title = "The cases raise the probability that reform caused turnover")
qs_save(fig_2_posterior, "fig-2-posterior", height = 2.5)
```
   - One ggplot object per figure, `fig_<n>_<descriptor>`, saved with `qs_save()` (PDF for the paper, PNG for slides, the plotted data as `<name>-data.csv`). Every figure regenerates from `Rscript code/06-figures.R` alone: none edited after export or drawn in another tool. The **title states the claim**; the subtitle names the query and the data (cases, clues observed); the helper's caption is the key to the encodings.
   - **No figure from numbers not in `output/`.** Intervals from `queries.csv`; densities only from the saved posterior (`qs_plot_prior_posterior(updated, ..., seed = SEED)`), and their means must equal the table's; evidence paths from `trace-<case>.csv` (`prior =` for an informal trace), with E-IDs from `data/coding-log.csv`; design figures from the `02-design.R` tables; sensitivity from `robustness-*.csv`; timelines from `qs_read_chronology()`. No code reads `evidence/` or `restricted/`; labels carry E-IDs and pseudonyms, never names.
4. **Captions.** 06-figures.R also writes `output/figures/captions.md`: per figure, one sentence saying what the reader should see, its numbers built with `sprintf()` from the same tables ("The probability that reform caused turnover in Chile rises from .38 to .81, most of it on finding the strike committee's minutes, M = 1, E014"), then the notes: model statement, cases and clues used, which answer (π̂ or φ̂), source table.
5. **Run** `Rscript code/06-figures.R` from the project root; then Read every PNG and look at it.
6. **Check**, and fix before reporting:
   - the DAG comes from the saved model, every arrow and `<->` in it; every restriction is drawn (+/−) or stated in the caption, with the full list in an appendix table (`qs_restrictions()`);
   - every posterior shows its prior; plotted means and intervals match `queries.csv`;
   - each evidence path ends at the answer the paper reports for that case; a named case's probability carries no interval;
   - no answer fixed by a restriction appears as a finding;
   - dates at their logged precision, inferred dates marked, every event with its E-ID;
   - only `qs_colors`, one meaning per color across figures, nothing encoded by hue alone;
   - width set to the journal's column; text 8–10 pt after scaling.

## Outputs

- `code/06-figures.R`, `code/theme_qualstack.R`.
- `output/figures/fig-<n>-<descriptor>.pdf`, `.png`, `-data.csv` per figure; `output/figures/captions.md`.
- Summary block: per figure, its file, its claim (the title), the table it reads, main text or appendix; any failed check.

## Anti-patterns

- **A posterior without its prior.** The reader cannot see what the evidence did.
- **Drawing the argument, not the model.** A hand-drawn DAG, a missing `<->`, a restriction left unstated.
- **Typed numbers.** A value in 06-figures.R that a table in `output/` already holds.
- **False precision in time.** A month-dated event as a point; an inferred date drawn as attested.
- **Intervals on a named case.** A case's probability is one number; the share of cases like it has an interval.
- **Order read as evidence.** The path shows what each clue did in the order sought; the final answer does not depend on the order.
- **Decoration.** Default ggplot, hue-only encodings, dual axes, 3D, pies, a figure no sentence needs.

## Next

`/qualstack:draft-section results` (and `cases`, `design`) cites each figure by its claim and takes its caption from `captions.md`; `/qualstack:evidence-audit` if outputs changed since its last run; `/qualstack:submission-pack` checks artwork against the journal's current guidelines.
