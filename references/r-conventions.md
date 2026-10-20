# R conventions

Read by every skill that writes the pipeline's R code:
`/qualstack:causal-model` (`code/01-model.R`), `/qualstack:clue-select` and
`/qualstack:case-select` (`code/02-design.R`), `/qualstack:analyze`
(`code/03-data.R`, `code/04-update.R`), `/qualstack:robustness`
(`code/05-robustness.R`), and `/qualstack:viz` (`code/06-figures.R`); and by
`/qualstack:model-review` and `/qualstack:evidence-audit`, which check these
rules in code. What CausalQueries does is in `causalqueries-cookbook.md`
(verified against 1.4.6), which wins on any package detail; if the user has
an `r-coding-skills` skill installed, it wins on style. Start scripts from
`${CLAUDE_PLUGIN_ROOT}/skills/causal-model/assets/01-model-template.R`,
`${CLAUDE_PLUGIN_ROOT}/skills/analyze/assets/03-data-template.R`, and
`${CLAUDE_PLUGIN_ROOT}/skills/analyze/assets/04-update-template.R`.

## The pipeline: one script per stage

| Script | Written by | Reads | Writes |
|---|---|---|---|
| `01-model.R` | `/qualstack:causal-model` | nothing: the model is declared, not estimated | `output/models/model.rds`, `output/models/queries.rds`, `output/tables/nodal-types.csv`, `output/tables/prior-queries.csv` |
| `02-design.R` | `/qualstack:clue-select`, `/qualstack:case-select` | `model.rds`; `data/clean/analysis-data.csv` if cross-case data exist | `output/tables/clue-diagnosis.csv`, `output/tables/case-diagnosis.csv` |
| `03-data.R` | `/qualstack:analyze` | `model.rds` (node names), `data/case-data.csv`, `data/raw/` | `data/clean/analysis-data.csv` |
| `04-update.R` | `/qualstack:analyze` | `model.rds`, `queries.rds`, `analysis-data.csv` | `output/models/model-updated.rds`, `output/models/stan-warnings.txt`; `output/tables/queries.csv`, `queries.tex`, `case-answers.csv`, `parameters.csv`, `clue-value.csv` |
| `05-robustness.R` | `/qualstack:robustness` | `model.rds`, `analysis-data.csv` | `output/models/robustness.rds`, `output/tables/robustness.csv` |
| `06-figures.R` | `/qualstack:viz` | `output/models/*.rds`, `output/tables/*.csv`, `.qualstack/chronology-*.md` (timelines) | `output/figures/*.pdf`, `*.png`, `*-data.csv` |

- **The number is the run order, and each script does one stage.** Cleaning
  never models; modeling never cleans. `03` alone turns coded and raw values
  into analysis data; `04` alone produces the numbers the paper reports as
  the analysis; `05` never overwrites a `04` output; `06` never refits a
  model or computes a number the tables lack.
- **Data flow is one way**: `data/raw/` (read-only) and `data/case-data.csv`
  → `03-data.R` → `data/clean/analysis-data.csv` → `04`, `05`. Nothing after
  `03` reads `data/raw/`.
- **`data/case-data.csv` is not R's to write.** `/qualstack:code-evidence`
  generates it from `data/coding-log.csv` (`coding-tools.py build`); no
  script and no hand edits it.
- **Helpers are unnumbered.** Bundled helpers (`clue-diagnosis.R`,
  `case-diagnosis.R`, `trace-case.R`, `model-checks.R`) are copied into
  `code/` and loaded with `source(here("code", "trace-case.R"))` by the
  numbered script that uses them. The rebuild runs only `code/0[1-6]-*.R`, so
  a helper never runs alone.
- **Each script stands alone.** It reads what earlier scripts saved, never
  objects left in a session; `Rscript code/04-update.R` from the project root
  is the test.

## Paths and walls

- `library(here)`, and every path is `here("output", "tables",
  "queries.csv")`: `here()` finds the root from the project's `.here` file
  whatever the working directory. Never `setwd()`, an absolute path, or `~`.
- **No code reads `restricted/`.** No `here("restricted", ...)`, no path
  built from `privacy.key` or `privacy.originals`, no recursive
  `list.files()`, `dir()`, or `Sys.glob()` from the project root (they list
  `restricted/`, and file names identify people). The guard hook reads
  command lines, not what a script opens: `Rscript code/03-data.R` passes it
  even if the script opens the key. Only `bin/qualstack-redact` crosses.
- **No code reads evidence text.** Evidence enters R as coded values in
  `data/case-data.csv`, nothing else; a script that opens `evidence/raw/` or
  `evidence/md/` prints source text into output Claude reads, whatever
  `privacy.ai_processing` allows.
- `data/raw/` and `evidence/raw/` are read-only (the hook denies edits): a
  recode is code in `03-data.R`; a correction is a new file.
- Scripts write only to `output/` and `data/clean/`. The paper `\input`s
  `output/tables/*.tex` and includes `output/figures/*.pdf`; no script writes
  into `paper/`.

## Script anatomy

```r
# 04-update.R — update the model on the data once; answer every query.
# Inputs:  output/models/model.rds, output/models/queries.rds,
#          data/clean/analysis-data.csv
# Outputs: output/models/model-updated.rds, output/tables/queries.csv, ...
# Run after: 01-model.R, 03-data.R

library(CausalQueries)
library(here)

SEED <- 20250101            # model.seed in .qualstack/config.yaml
ITER <- 4000; CHAINS <- 4   # raise ITER until stan-warnings.txt reads "none"
```

- A header block: purpose, inputs, outputs, run order. Comments say why;
  labels (R1, P1, C1) tie each modeling choice to its justification in
  `.qualstack/model.md`, and the two change together.
- `library()` calls at the top, one per line; no `require()`; no
  `install.packages()` in a pipeline script (renv installs).
- Constants a reader may change in UPPER_CASE at the top (`SEED`, `ITER`,
  `CHAINS`, `STATEMENT`, `QUERIES`, `CLUES`); otherwise tidyverse style:
  `snake_case`, 2-space indent, `<-`, native pipe `|>` one step per line.
- `SEED` equals `model.seed`. A new seed is a config change, recorded under
  `decisions`, never an edit to one script.
- Assert before writing: a failed check stops the script with the previous
  outputs still in place.

## Seeds: before every stochastic call

`set.seed(SEED)` immediately before each call below, not once at the top. A
seed set once makes every draw depend on every earlier call, so a call added
upstream silently changes the numbers downstream.

| Call | Why it draws |
|---|---|
| `update_model()` | Stan sampling; rstan's default seed comes from R's RNG |
| `query_model()`, `query_distribution()` with `using = "priors"` | Fresh Dirichlet draws on every call, unless `set_prior_distribution()` stored them |
| `make_data()`, `make_events()` | Simulation |
| `set_prior_distribution()`; `param_type = "prior_draw"` or `"posterior_draw"`; `draw_causal_type()` | Parameter draws |
| `grab(model, "prior_distribution")` or `grab(model, "type_prior")` with nothing stored | Generated on the fly |
| Helpers that simulate: `qs_wide_deep()`, `qs_ppc()`, `qs_loo()` | They take `seed =`: pass `SEED` |

- **No seed needed**: `query_model(using = "posteriors")`, at either
  `case_level`, and `using = "parameters"` are deterministic.
- **What the seed buys** (verified on 1.4.6): a seeded `update_model()`
  reproduces the posterior draws bit for bit; with chains in parallel the
  draws return in another order but every query summary is identical; a
  seeded prior query repeats, an unseeded one does not. Another machine or
  Stan build may draw differently from the same seed, and the tables then
  agree only to Monte Carlo error (tolerance: `audit-catalog.md`, N3).

## CausalQueries calls (the cookbook's section 0 has the full list)

- **`using =` on every `query_model()` and `query_distribution()` call.** The
  default, `"parameters"`, evaluates one parameter vector (flat unless set),
  not the priors or the posterior, and returns `sd = NA`. Write `using =
  "parameters"` only for single-case answers at the prior means, after
  `set_parameters(model, param_type = "prior_mean")` as `01-model.R` does.
- **`expand_grid = TRUE`** whenever vector arguments should be crossed:
  equal lengths above 1 are zipped, so two queries with `using =
  c("priors", "posteriors")` return two rows, not four.
- **`case_level`**: `FALSE` (π̂) for every case whose data are in the
  update, which includes every traced case; `TRUE` (φ̂) only for a new case
  outside it, and it returns one number with no interval. Never both for one
  case (`mixed-methods.md`).
- **`as.data.frame()` on every query result, at once.** Printing a
  `model_query` hides `sd` and the interval when every row is case-level or
  at parameters, drops constant columns, and rounds to three digits;
  `write.csv()` happens to keep every column, but the printed log is what
  gets read.
- **`update_model()` restarts from the priors.** Pass all the data in one
  call; updating an updated model on more cases discards the first
  posterior.
- **Restriction statements name the types to remove**:
  `set_restrictions(model, decreasing("X", "M"))` imposes "X never lowers M".
- **Node names**: letters and digits, starting with a letter, matching the
  `data/case-data.csv` header exactly; `;` between sub-statements, because
  whitespace, newlines included, is deleted.
- **`grab()` in scripts** (silent); `inspect()` prints and needs `what`.

## Stan settings

- `update_model(model, data, iter = ITER, chains = CHAINS, refresh = 0)`:
  extra arguments go to `rstan::sampling`; `refresh = 0` silences progress
  and nothing else.
- Start at `CHAINS <- 4` and `ITER <- 4000` (half is warmup: 8,000 draws).
  On any warning raise `ITER` (8,000 to 10,000) or restrict the model.
  `adapt_delta` cannot be raised (`update_model()` resets it to 0.95);
  `control = list(max_treedepth = ...)` can (default 15).
- **Warnings are real.** Never `suppressWarnings()` around `update_model()`
  (`suppressMessages()` for the package's notes is fine). Write
  `grab(updated, "stan_warnings")` to `output/models/stan-warnings.txt`,
  `none` when clean; a run whose file is not `none` yields no reportable
  number. R-hat and `n_eff` are in `grab(updated, "stan_summary")`, a
  character vector to `writeLines()`.
- `options(mc.cores = parallel::detectCores())` before
  `library(CausalQueries)` runs chains in parallel and silences the startup
  note; summaries do not change.
- **Size before iterations.** Keep in-degree at 3 or less: a node with three
  binary parents has 256 nodal types, and in the cookbook's timing three
  parents into Y with 100 cases took about 90 s and still warned. Restrict,
  then add iterations.
- `keep_fit = TRUE` only to diagnose (`grab(updated, "stanfit")` for rstan
  and bayesplot); it enlarges the saved model.

## Saving models and tables

- **Models**: `saveRDS()` to `output/models/` (`model.rds`,
  `model-updated.rds`, `robustness.rds`); queries work on the object
  `readRDS()` returns. The script is the record; the `.rds` is a cache the
  rebuild replaces.
- **CSV first.** Every number the paper reports is in a CSV in
  `output/tables/`, written with `write.csv(df, here(...), row.names =
  FALSE)` from the data frame the analysis computed, at full precision, with
  the columns that say what each number is: `label`, `query`, `given`,
  `using`, `case_level`, `mean`, `sd`, `cred.low`, `cred.high`.
- **LaTeX from the same data frame**, two decimals, to
  `output/tables/<name>.tex` for the paper to `\input`: `knitr::kable(df,
  format = "latex", booktabs = TRUE, digits = 2, row.names = FALSE)` (knitr
  ships with CausalQueries; `paper/main.tex` loads booktabs; without
  `row.names = FALSE` a subset prints its row numbers), or a hand-built
  tabular as in the analyze template. No number is ever retyped.
- **Precision**: two decimals for probabilities. A digit that changes under
  a second seed is Monte Carlo noise: report one fewer or raise `ITER`.
- **Session**: `writeLines(capture.output(sessionInfo()), here("output",
  "session-info.txt"))` at the end of every script that loads CausalQueries,
  so the last script run leaves the record of the session that made the
  outputs.

## Data in R

- `03-data.R` asserts before writing: the node columns equal
  `grab(model, "nodes")` (a misspelled column is dropped silently and that
  node becomes NA in every case); every value is 0, 1, or NA (any other value
  drops the whole case with only a message); case IDs are unique.
- **Cross-case data** from `data/raw/`: dichotomize at the cut in
  `data/coding-rules.md`, with a comment naming node and version (`# rule X
  v1`); join on case ID with row counts before and after under
  `stopifnot()`; a clash between a dataset value and a coded one stops the
  script for resolution in the coding log, never a silent preference.
- Read with `na.strings = "NA"` and write with `na = "NA"`: NA means not
  observed, and an empty cell is ambiguous.
- **Never drop an untraced case**: it stays, clues NA; dropping it changes
  the likelihood (`mixed-methods.md`).
- **No sample statistic sets a cut**: a median split moves as cases are
  added (`concepts-and-coding.md`).

## Environment

- **renv**: `renv::init()` once; `renv::snapshot()` after any package
  change; `renv.lock` committed; `renv::restore()` installs the recorded
  versions on another machine.
- **Fresh sessions**: run scripts with plain `Rscript`, which never restores
  `.RData`. Never `Rscript --vanilla`: it also skips the project `.Rprofile`
  where renv activates, so the script runs against whatever library the
  machine has. Never save a workspace (`.RData` and `.Rhistory` are
  gitignored).
- **Version floor**: `stopifnot(packageVersion("CausalQueries") >= "1.4.3")`
  at the top of `01-model.R`, as the cookbook's verified script does; book
  code written for older releases needs the translations in its section 13.

## Figures

- ggplot2 (a CausalQueries import), `ggsave()` with explicit `width`,
  `height`, and `units`: `.pdf` for the paper, `.png` for slides, and the
  plotted data beside them as `output/figures/<name>-data.csv`.
- `plot(model)` returns a ggplot; pad it with `scale_x_continuous(expand =
  expansion(mult = 0.15))` and the y equivalent, or node labels are clipped.
- Every number a figure shows is in a table; `06` plots saved outputs only.
  Design rules are in `figure-conventions.md`.

## What the audit checks in code

| Rule | `audit-catalog.md` check |
|---|---|
| `SEED` equals `model.seed`; `set.seed()` before stochastic calls; `using =` on every query | N4, which parses every script |
| A fresh-session rerun reproduces the tables | N3 |
| `stan-warnings.txt` reads `none` | N5 |
| `renv.lock` committed; `output/session-info.txt` current | N6 |
| Case data generated from the coding log; `03` assertions | C1, C2 |
| No untraced case dropped | S3 |
| No φ̂ question asked of a case in the update | I1 |
