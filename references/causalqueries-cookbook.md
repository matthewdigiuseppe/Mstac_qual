# CausalQueries cookbook (current API, verified against 1.4.6)

Read by every skill that writes or reviews R code: `/qualstack:causal-model`,
`/qualstack:query-design`, `/qualstack:clue-select`, `/qualstack:case-select`,
`/qualstack:design-research`, `/qualstack:analyze`, `/qualstack:robustness`,
`/qualstack:viz`, `/qualstack:evidence-audit`, and `/qualstack:model-review`.
CausalQueries (Tietz, Medina, Syunyaev & Humphreys 2026) is the companion
package to *Integrated Inferences*. Every signature, default, and behavior below
was read from the 1.4.6 source and checked by running the installed package;
statements marked **(verified)** were run. Read section 0 always, then only the
section the task needs (§4 restrictions, §5 priors, §7 data, §8 updating, §9
querying, §10 plotting, §13 when adapting the book's own code). The bundled
templates (`skills/causal-model/assets/01-model-template.R`,
`skills/clue-select/assets/clue-diagnosis.R`, `skills/analyze/assets/`)
already follow these rules.

## 0. Rules a script-writer must never break (summary)

1. **Always pass `using =` to `query_model()` and `query_distribution()`.** The default is `using = "parameters"`. That evaluates the query at the model's single "true" parameter vector, which is flat unless you called `set_parameters()`. It does **not** use the priors or the posterior. The output then has `sd = NA`.
2. **Pass `expand_grid = TRUE` whenever you want every query × using × given × case_level combination.** If the vector-valued arguments all have the *same* length greater than 1, `expand_grid = NULL` pairs them element-wise instead. For example, 2 queries with `using = c("priors","posteriors")` returns **2 rows, not 4** (verified).
3. **Restriction statements name the types to *remove*.** `set_restrictions(decreasing("X","Y"))` removes negative effects, so it *imposes* "Y is monotonically increasing in X". Pass `keep = TRUE` to keep the matched types instead.
4. **A statement means different things in different functions.**
   - In `set_restrictions()`, `set_priors(statement=)`, `set_parameters(statement=)` and `get_query_types(map = "nodal_type")`, a statement such as `"Y[X=1] > Y[X=0]"` is a *nodal-type* statement. The node's other parents are held fixed at each of their values, and the results are combined with `|`. Only *parents* of `Y` may appear inside `[]`.
   - In `query_model()` the same string is a *causal-type* query. Mediators then take their natural values, so it is the total effect.
5. **Name nodes with letters and digits only, starting with a letter.**
   - `-`, `_`, `<`, `>`, `[`, `]`, `^`, `/`, `exp(`, `log(` and `:|:` all make `make_model()` stop.
   - Names that start with a digit, or contain a dot, are accepted but **break queries** (the dot is the wildcard). Dots are also rejected in any model with `<->`.
   - Separate sub-statements with `;`. **Whitespace, including newlines, is deleted**, so `"X -> Y\n X -> M"` silently creates a node called `YX` (verified).
6. **Digit order in nodal types: the first parent varies fastest.** Parents are ordered by causal depth, with ties broken alphabetically (locale-dependent for mixed case). Read the guide from `inspect(model, "nodal_types")` and never assume the order.
7. **`update_model()` always starts from the priors.** Updating an already-updated model with new data *replaces* the posterior and does not accumulate it (verified). Pass all the data in one call.
8. **Reproducibility needs `set.seed()` before every stochastic call.** That means before `make_data()`, `update_model()`, and any `using = "priors"` query, because prior draws are regenerated on each call.
   - With serial chains, `set.seed()` makes posterior draws bit-identical.
   - With parallel chains (`mc.cores` above 1) the draws are identical up to row order, and all summaries are identical (verified).
   - **Never call `set_prior_distribution()` before `set_priors()`.** The stored prior draws are not refreshed, so later prior queries silently use the old priors (verified).
9. **`case_level = TRUE` returns one number with no interval** (`sd = NA`, `cred.low = cred.high = mean`). It treats the `given` as *new* evidence about the population.
   - Use it for a *new* case whose data were **not** used in `update_model()`.
   - Use the default `case_level = FALSE` for the share of such cases in the population, or for cases already in the data.
10. **Data must be 0/1/NA, one column per node.** Other values (e.g. `2`, `"yes"`/`"no"`) are dropped with only a *message* (`"... data is inconsistent with model and ignored"`). Use `NA` for "not observed". Non-node columns are ignored.
11. **`set_priors()` changes only the `priors` column.** It does not change `param_value`, which is what `make_data()` and `using = "parameters"` use. `make_data()` has **no `using` argument**: `make_data(m, n, using = "parameters")` silently ignores it.
12. **`adapt_delta` cannot be raised.** `update_model()` forces `control$adapt_delta = 0.95` even if you pass `control = list(adapt_delta = .99)` (verified via `stanfit@stan_args`). `max_treedepth` (default 15) can be changed. For divergences or low ESS, increase `iter`.

---

## 1. Exported functions (NAMESPACE, v1.4.6)

The package exports 33 functions, defines 10 S3 methods, and ships 3 datasets.

### 1.1 Make
| Function | Signature (exact) | What it does |
|---|---|---|
| `make_model` | `make_model(statement = "X -> Y", add_causal_types = TRUE, nodal_types = NULL)` | Builds a `causal_model` from a DAG string, with flat priors (alpha = 1) and flat parameters. |

### 1.2 Restrict, plus statement helpers
| Function | Signature | What it does |
|---|---|---|
| `set_restrictions` | `set_restrictions(model, statement = NULL, join_by = "\|", labels = NULL, param_names = NULL, given = NULL, keep = FALSE)` | Drops nodal types, or keeps only the matched ones. Give exactly one of `statement`, `labels` or `param_names`. |
| `increasing` | `increasing(X, Y)` | Returns the string `"(Y[X=1] > Y[X=0])"`, i.e. the positive-effect types. |
| `non_decreasing` | `non_decreasing(X, Y)` | Returns `"(Y[X=1] >= Y[X=0])"`. |
| `decreasing` | `decreasing(X, Y)` | Returns `"(Y[X=1] < Y[X=0])"`, i.e. the negative-effect types. **Use this in `set_restrictions()` to impose monotone increasing.** |
| `non_increasing` | `non_increasing(X, Y)` | Returns `"(Y[X=1] <= Y[X=0])"`. |
| `interacts` | `interacts(X1, X2, Y)` | Statement that the effect of X1 on Y differs between X2 = 1 and X2 = 0 (`!=`). |
| `complements` | `complements(X1, X2, Y)` | Statement that the effect of X1 is larger when X2 = 1 (`>`). |
| `substitutes` | `substitutes(X1, X2, Y)` | Statement that the effect of X1 is smaller when X2 = 1 (`<`). |
| `te` | `te(X, Y)` | Returns `"(Y[X=1] - Y[X=0])"`. This is numeric, so it works as a query but **errors** in `set_restrictions()`. |

### 1.3 Priors and parameters
| Function | Signature | What it does |
|---|---|---|
| `set_priors` | `set_priors(model, alphas = NA, distribution = NA, alter_at = NA, node = NA, nodal_type = NA, label = NA, param_set = NA, given = NA, statement = NA, join_by = "\|", param_names = NA)` | Sets the Dirichlet hyperparameters (`parameters_df$priors`). |
| `make_priors` | same arguments as `set_priors` | Returns the named alpha vector without changing the model. |
| `set_parameters` | `set_parameters(model, parameters = NULL, param_type = NULL, warning = FALSE, ...)` | Sets the "true" parameter vector (`parameters_df$param_value`), renormalised within each `param_set`. |
| `make_parameters` | `make_parameters(model, parameters = NULL, param_type = NULL, warning = TRUE, normalize = TRUE, ...)` | Returns a named parameter vector. |
| `set_prior_distribution` | `set_prior_distribution(model, n_draws = 4000)` | Stores `n_draws` × parameter prior draws in `model$prior_distribution`. |
| `set_parameter_matrix` | `set_parameter_matrix(model, P = NULL)` | Stores or overrides the parameter-to-causal-type matrix `P`. It is exported but tagged internal, and you rarely need it. |
| `draw_causal_type` | `draw_causal_type(model, ...)` | Draws one unit's nodal types. It returns `parameters_df` plus a 0/1 `causal_type` column; `...` goes to `set_parameters`. |

`make_par_values()` is **not exported**. It is the internal engine behind `make_priors()` and `make_parameters()`.

### 1.4 Confounding
| Function | Signature | What it does |
|---|---|---|
| `set_confound` | `set_confound(model, confound = NULL)` | Adds unobserved confounding, e.g. `list("X <-> Y", "M <-> Y")`. The same can be declared directly with `<->` in `make_model()`. |

### 1.5 Update
| Function | Signature | What it does |
|---|---|---|
| `update_model` | `update_model(model, data = NULL, data_type = NULL, keep_type_distribution = TRUE, keep_event_probabilities = FALSE, keep_fit = FALSE, censored_types = NULL, ...)` | Runs the precompiled Stan model. `...` is passed to `rstan::sampling`. |

### 1.6 Query
| Function | Signature | What it does |
|---|---|---|
| `query_model` | `query_model(model, queries = NULL, given = NULL, using = list("parameters"), parameters = NULL, stats = NULL, n_draws = 4000, expand_grid = NULL, case_level = FALSE, query = NULL, cred = 95, labels = NULL)` | Returns a summary table (class `model_query`). |
| `query_distribution` | `query_distribution(model, queries = NULL, given = NULL, using = "parameters", parameters = NULL, n_draws = 4000, join_by = "\|", case_level = FALSE, query = NULL)` | Returns a data.frame of draws, one column per query. |
| `get_query_types` | `get_query_types(model, query, map = "causal_type", join_by = "\|")` | Shows which causal or nodal types satisfy a query. |
| `realise_outcomes` | `realise_outcomes(model, dos = NULL, node = NULL, add_rownames = TRUE)` | Gives node values for every causal type, optionally under `do()` interventions. |

### 1.7 Inspect and grab
| Function | Signature | What it does |
|---|---|---|
| `inspect` | `inspect(model, what = NULL, ...)` | Prints a labelled summary of one component and returns it invisibly. **`what` is required.** |
| `grab` | `grab(model, what = NULL, ...)` | Returns the same component silently. Use this in scripts. |
| `interpret_type` | `interpret_type(model, condition = NULL, position = NULL, nodes = model$parents_df[!model$parents_df$root, 1])` | Explains what each digit of a nodal type means. |

### 1.8 Data helpers
| Function | Signature | What it does |
|---|---|---|
| `make_data` | `make_data(model, n = NULL, parameters = NULL, param_type = NULL, nodes = NULL, n_steps = NULL, probs = NULL, subsets = TRUE, complete_data = NULL, given = NULL, verbose = FALSE, ...)` | Simulates long data, one row per unit, with optional multi-step data strategies. |
| `make_events` | `make_events(model, n = 1, w = NULL, P = NULL, A = NULL, parameters = NULL, param_type = NULL, include_strategy = FALSE, ...)` | Simulates compact complete data (`event`, `count`). |
| `collapse_data` | `collapse_data(data, model, drop_NA = TRUE, drop_family = FALSE, summary = FALSE)` | Converts long data to compact form (`event`, `strategy`, `count`). |
| `expand_data` | `expand_data(data_events = NULL, model)` | Converts compact data to long form. |
| `get_all_data_types` | `get_all_data_types(model, complete_data = FALSE, possible_data = FALSE, given = NULL)` | Lists every possible data pattern, including NA patterns. |
| `get_event_probabilities` | `get_event_probabilities(model, parameters = NULL, A = NULL, P = NULL, given = NULL)` | Gives the probability of each complete data type at one parameter vector, as a one-column matrix. |

### 1.9 Plotting
| Function | Signature | What it does |
|---|---|---|
| `plot_model` | `plot_model(model = NULL, x_coord = NULL, y_coord = NULL, labels = NULL, title = "", textcol = 'white', textsize = 3.88, shape = 16, nodecol = 'black', nodesize = 12, parse = FALSE, strength = .3)` | Draws the DAG as a ggplot/ggraph object. Confounding arcs are drawn dashed. |

### 1.10 S3 methods
- `print.causal_model`, `summary.causal_model(object, include = NULL, ...)`, `print.summary.causal_model(x, what = NULL, ...)`
- `plot.causal_model(x, ...)`, which is the same as `plot_model(x, ...)`
- `print.model_query` (prints a `knitr::kable` and may drop columns, see §9.7), `summary.model_query` (adds the call and date), `print.summary.model_query`
- `plot.model_query(x, ...)`: a coefficient plot of mean ± credible interval, coloured by `using` and faceted by model
- `print.causal_types_query` and `print.nodal_types_query`, used for `get_query_types()` output

### 1.11 Datasets (lazy-loaded)
- `democracy_data`: 84 × 5, columns `Case, P, I, M, D`. P and M are NA in many rows. Used with `make_model("I -> M -> D <- P; I -> D")`.
- `institutions_data`: tibble, 79 × 5, columns `Y, R, D, M, country`. Used with `make_model("M -> R -> Y <- D; R <-> Y")`.
- `lipids_data`: compact data (`event, strategy, count`) for `make_model("Z -> X -> Y; X <-> Y")`.

### 1.12 Not exported, deprecated, or removed (do not write these)
| Old or internal call | Status in 1.4.6 | Use instead |
|---|---|---|
| `get_nodal_types()`, `get_causal_types()`, `get_parameters()`, `get_priors()`, `get_parameter_matrix()`, `get_ambiguities_matrix()`, `get_parmap()`, `get_param_dist()`, `get_type_prob_multiple()`, `get_parameter_names()` | Unexported in 1.1.0. Calling them gives "could not find function" (verified for `get_parameters` and `get_priors`). | `grab(model, "nodal_types" / "causal_types" / "parameters" / "prior_hyperparameters" / "parameter_matrix" / "ambiguities_matrix" / "parameter_mapping" / "prior_distribution" / "type_prior" / "parameter_names")` |
| `get_prior_distribution()`, `get_posterior_distribution()` | Internal and `.Deprecated("grab")` | `grab(model, "prior_distribution")`, `grab(model, "posterior_distribution")` |
| `simulate_data()` | Internal and `.Deprecated("make_data")`. Calling it without `:::` gives "could not find function" (verified). | `make_data()` |
| `reveal_outcomes()` | Internal and `lifecycle::deprecate_warn` (since 0.0.3.2) | `realise_outcomes()` |
| `set_confounds()` | Internal alias | `set_confound()` |
| `inspect(model, "type_distribution")` | Renamed in 1.3.3 | `"type_posterior"` |
| `CausalQueries:::get_type_prob(model)`, `CausalQueries:::perm()`, `CausalQueries:::prep_stan_data()`, `CausalQueries:::map_query_to_causal_type()`, `CausalQueries:::get_nodal_types(model, collapse = FALSE)` | Still work through `:::` (verified for `get_type_prob`, `get_nodal_types`) but are not API. | `query_model`/`grab`; `get_query_types()` |
| `causal_type_query` / `nodal_type_query` classes | Removed in 1.3.2 | The list returned by `get_query_types()` |

`get_all_data_types()` and `get_event_probabilities()` were unexported in 1.1.0 but **are exported again** in 1.4.6.

---

## 2. Model statements and the `causal_model` object

### 2.1 Statement syntax (verified)
```r
make_model("X -> Y")                         # directed edge
make_model("Y <- X")                         # same model; stored as "X -> Y"
make_model("X -> M -> Y")                    # chain
make_model("X -> M -> Y <- X")               # chain plus direct path
make_model("X -> M -> Y; X -> Y")            # ';' separates sub-statements
make_model("X -> Y; X <-> Y")                # <-> = unobserved confounding
make_model("Z -> X -> Y <-> X")              # mixed edges in one chain (IV)
make_model("X")                              # single-node model
make_model("Z -> D -> Y;
            D <- X -> Y;
            D <-> Y")                        # multi-line is OK *because* each line ends with ';'
```
- **`<->` is confirmed.** Each confounded node must also appear in a directed edge. `make_model("X <-> Y")` and `make_model("X -> M <-> Y")` stop with `"Graph should not contain isolates."`.
- `statement` must be **one** string. `make_model(c("X -> Y","M -> Y"))` errors.
- Cycles error (`"Cycling at generation ..."` or `"No root nodes provided."`).
- Whitespace is deleted, which includes newlines. Use `;` between sub-statements.
- The statement is normalised: duplicate edges are removed, edges are sorted, and the result goes in `$statement`.
  - `make_model("X -> M -> Y; X -> Y")$statement` is `"M -> Y; X -> M; X -> Y"`.
  - `"X -> Y; X<->Y; Y<->X"` becomes `"X -> Y; X <-> Y"`.
- **Nodes are binary only (0/1).** Represent a variable with more than two levels by several binary nodes. The book does this in Ch. 9, coding a 4-level X as two nodes `X1`, `X2`.

### 2.2 Node-naming rules
| Name pattern | `make_model()` | Queries |
|---|---|---|
| Letters and digits, starting with a letter (`X`, `X1`, `Income`, `PolInequality`) | OK | OK |
| Contains `-` `_` `<` `>` `^` `/` `[` `]` `:\|:` `exp(` `log(` | **error** | n/a |
| Starts with a digit (`1X`) | accepted | **parse error in queries** (verified) |
| Contains `.` (`A.b`) | accepted, but **error if the model has confounding** | **broken**, because `.` is the wildcard (verified) |
| Contains a space (`X 1`) | silently becomes `X1` | n/a |
| `T`, `F`, `c`, `q` | OK | OK (verified) |

The package's own error message suggests "try dots?" for hyphens. **Ignore that advice**: dots break queries. Use CamelCase instead.

### 2.3 What `make_model()` returns
An object of class `"causal_model"`, which is a list with these components:

| Slot | Type | Content |
|---|---|---|
| `statement` | chr | Normalised DAG string. |
| `nodes` | chr vector | Nodes in **causal order**: roots first (alphabetical), then by generation. This order is used for data event names, column order and plot coordinates. |
| `parents_df` | data.frame | Columns `node`, `root` (lgl), `parents` (count), `parent_nodes` (e.g. `"X, M"`, in digit order, see §3). |
| `nodal_types` | named list of chr | e.g. `$Y = c("00","10","01","11")`. Has attribute `"interpret"`, a list of data.frames with columns `index` and `interpretation`. |
| `parameters_df` | data.frame | Columns `param_names`, `node`, `gen`, `param_set`, `nodal_type`, `given`, `param_value`, `priors`. |
| `causal_types` | data.frame | One row per causal type, with row names like `X0.M01.Y0011`. Omitted when `add_causal_types = FALSE`. |

Slots added later:
- `P`, the parameter × causal-type matrix, added by `set_restrictions`, `set_confound` and `set_parameter_matrix`.
- `prior_distribution`, added by `set_prior_distribution`.
- `posterior_distribution` and `stan_objects`, added by `update_model` (see §8).

Attributes: `root_nodes`, `nonroot_nodes`, and `restrictions` (a list of removed nodal types per node, set by `set_restrictions`).

Example: the default `parameters_df` for `make_model("X -> Y")`:
```text
  param_names node gen param_set nodal_type given param_value priors
1         X.0    X   1         X          0              0.50      1
2         X.1    X   1         X          1              0.50      1
3        Y.00    Y   2         Y         00              0.25      1
4        Y.10    Y   2         Y         10              0.25      1
5        Y.01    Y   2         Y         01              0.25      1
6        Y.11    Y   2         Y         11              0.25      1
```
- `param_set` is a simplex: values sum to 1 within each set, and each set gets its own Dirichlet prior.
- `given` is `""` unless the model has confounding.

### 2.4 Printing and inspecting
```r
model <- make_model("X -> M -> Y; X -> Y")
print(model)          # statement, # nodal types by node, # causal types (+ rstan info after update)
summary(model)        # statement, nodal types (first 16/node) + interpretation guide, counts, restrictions
print(summary(model), what = c("statement", "parents_df"))   # selected parts
inspect(model, "nodal_types")   # prints, returns invisibly
nt <- grab(model, "nodal_types")  # silent: use grab() in scripts
```
`inspect(model)` with no `what` **errors** ("argument is of length zero"). `inspect()` both prints and returns, so `print(inspect(...))` prints twice.

**Valid `what =` values for `inspect()` and `grab()`.** There are 23. Anything else errors. Results below were checked on an `X -> Y` model.

| `what` | Returns | Needs |
|---|---|---|
| `"statement"` | chr | |
| `"nodes"` | chr vector | |
| `"parents_df"` | data.frame | |
| `"parameters"` | named numeric (`param_value`) | |
| `"parameter_names"` | chr | |
| `"parameters_df"` | data.frame | |
| `"nodal_types"` | named list | |
| `"causal_types"` | data.frame | |
| `"parameter_matrix"` | data.frame, params × causal types | |
| `"parameter_mapping"` | matrix, params × data types | |
| `"ambiguities_matrix"` | matrix, causal types × data types | |
| `"data_types"` | data.frame | extra arguments `complete_data =`, `possible_data =`, `given =` |
| `"prior_hyperparameters"` | named numeric (alphas) | optional `nodes = "Y"` |
| `"prior_distribution"` | data.frame, draws × params | Generated on the fly (message `"Prior distribution added to model"`, but nothing is stored) unless `set_prior_distribution()` was called. Optional `n_draws =`. |
| `"type_prior"` | matrix, **causal types × draws** | generated on the fly |
| `"prior_event_probabilities"` | one-column matrix | optional `parameters =`, `given =` |
| `"posterior_distribution"` | data.frame, draws × params | `update_model()`. **Errors** on a model that has not been updated. |
| `"type_posterior"` | matrix, **draws × causal types** | `update_model(keep_type_distribution = TRUE)` (the default) |
| `"posterior_event_probabilities"` | matrix, draws × data types | `update_model(keep_event_probabilities = TRUE)` |
| `"data"` | data.frame (`event, strategy, count`) used for updating | `update_model()` |
| `"stan_summary"` | **character vector**, printed by `cat(x, sep = "\n")` | `update_model()` |
| `"stanfit"` | `stanfit` object | `update_model(keep_fit = TRUE)` |
| `"stan_warnings"` | chr (`""` if none) | `update_model()` |

On a model that has not been updated, `grab()` returns `NULL` for `type_posterior`, `stan_summary`, `data` and `stanfit`.

`summary(model, include = c(...))` accepts the large objects (`"parameter_matrix"`, `"parameter_mapping"`, `"causal_types"`, `"prior_distribution"`, `"ambiguities_matrix"`, `"type_prior"`). `print(summary(model), what = ...)` also accepts `"parents"`. `inspect()` does not accept `"parents"`.

---

## 3. Nodal-type notation

- **Root node** (no parents): the nodal types are `"0"` and `"1"`, which are the node's value.
- **A node with k parents** has nodal-type labels of 2^k digits. Digit *j* is the node's value when its parents take the *j*-th combination. Combinations are enumerated with the **first parent varying fastest**, like binary counting with the first parent as the lowest bit.
- **Parent order** is the order in `parents_df$parent_nodes`: sorted by causal generation, with ties broken alphabetically by `order()`, which depends on the locale for mixed case.

| Model | Y's parent order | Digit 1 | Digit 2 | Digit 3 | Digit 4 |
|---|---|---|---|---|---|
| `X -> Y` | X | X=0 | X=1 | | |
| `X -> Y <- W` | W, X | W=0,X=0 | W=1,X=0 | W=0,X=1 | W=1,X=1 |
| `X -> M -> Y; X -> Y` | X, M (X is a root, M is generation 2) | X=0,M=0 | X=1,M=0 | X=0,M=1 | X=1,M=1 |
| `Z -> A -> Y; Z -> Y` | Z, A | Z=0,A=0 | Z=1,A=0 | Z=0,A=1 | Z=1,A=1 |

With three parents `A, B, C`, digit 1 is A=0,B=0,C=0; digit 2 is A=1,B=0,C=0; digit 3 is A=0,B=1,C=0; and so on.

**One-parent labels** (the book's a/b/c/d naming):

| Label | Meaning | Book name |
|---|---|---|
| `"00"` | Y = 0 always | c, chronic |
| `"10"` | Y = 1 iff X = 0 (negative effect) | a, adverse |
| `"01"` | Y = 1 iff X = 1 (positive effect) | b, beneficial |
| `"11"` | Y = 1 always | d, destined |

**Two-parent examples** (parents X, M):

| Label | Meaning |
|---|---|
| `"0001"` | Y = 1 iff X = 1 & M = 1 (complements) |
| `"0111"` | Y = 1 iff X = 1 or M = 1 |
| `"0101"` | Y = 1 iff X = 1 (first parent) |
| `"0011"` | Y = 1 iff M = 1 (second parent) |

Ways to list and read nodal types (all verified):
```r
model <- make_model("X -> M -> Y; X -> Y")
grab(model, "nodal_types")            # list: $X "0" "1"; $M "00" "10" "01" "11"; $Y 16 labels
inspect(model, "nodal_types")         # same + interpretation guide, e.g.
#   index          interpretation
# 1  *---  Y = * if X = 0 & M = 0
# 2  -*--  Y = * if X = 1 & M = 0
# 3  --*-  Y = * if X = 0 & M = 1
# 4  ---*  Y = * if X = 1 & M = 1
interpret_type(model)                                   # guide for all non-root nodes
interpret_type(model, position = list(Y = 2))           # meaning of digit 2 of Y's types
interpret_type(model, condition = "Y | X = 1 & M = 0")  # which digit position = that parent profile
realise_outcomes(model, node = "Y")                     # Y for every (parent values x nodal type)
grab(model, "parents_df")                               # parent_nodes column gives the digit order
```
- **Parameter names** are `node.nodal_type`, e.g. `"Y.01"`. With confounding they become `"Y.01_X.1"`, meaning the Y type 01 given X type 1.
- **Causal-type names** look like `"X0.M01.Y0011"`.
- **Data event names** look like `"X1M0Y1"`: node then value, in `model$nodes` order, with unobserved nodes omitted (`"X1Y1"`).

**Model size.** A node with k parents has 2^(2^k) nodal types: 2, 4, 16, 256, 65,536 for k = 0..4. The number of causal types is the product of nodal-type counts over nodes. Measured examples:
- `X -> M -> Y; X -> Y`: 128 causal types, 22 parameters.
- Three parents into Y: 2,048 causal types, 262 parameters.
- Four parents into Y: 65,544 parameters.

---

## 4. Restrictions

```text
set_restrictions(model, statement = NULL, join_by = "|", labels = NULL,
                 param_names = NULL, given = NULL, keep = FALSE)
```
- **Give exactly one of** `statement`, `labels` or `param_names`. Supplying more than one errors ("Provide *either* a causal statement or nodal type labels or param_names.").
- `keep = FALSE` (the default) **removes** the matched nodal types. `keep = TRUE` keeps **only** the matched types, for the node(s) named.
- **Statements** may be a character vector or list. Each element must refer to exactly one outcome node.
  - Only that node's **parents** may appear inside `[]` (otherwise: `"X is not a parent of Y"`).
  - Unspecified parents are expanded over 0/1 and joined with `join_by` (`"|"` by default: true for at least one value of the other parents; `"&"`: true for all values).
  - Wrap each statement in parentheses, as the docs recommend. Without them you get the message `"No parentheses indicated. Global expansion assumed."`.
  - Root nodes use empty brackets: `"(X[] == 1)"`. Writing `X == 1` errors: "No outcome variable specified. If required, specify roots as X[]==1 not X==1".
  - `"(Y == 1)"` is not allowed in restrictions.
- **Labels**: `labels = list(Y = c("01","11"), M = "10")`. The wildcard `?` matches either digit, so `list(Y = "?0")` matches `"00"` and `"10"`. An unknown label errors.
- **param_names**: `param_names = c("Y.10")`.
- **given** applies to confounded models only. It restricts within the parameter sets for that conditioning type, e.g. `given = "X.1"`. Pass one entry per statement or label, using `NA` for "no given".
- Restricting removes any stored `prior_distribution`, `posterior_distribution` and `stan_objects`, so you must update again. Alphas of the remaining types are unchanged, so probability mass is redistributed among them.
- Restricting **all** types of a node does not error. It leaves a model with 0 causal types, so check `print(model)` (verified).

```r
m <- make_model("X -> M -> Y; X -> Y")

# Monotonicity (no negative effects anywhere): statements = types to REMOVE
m1 <- set_restrictions(m, statement = c(
  "(M[X=1] < M[X=0])",
  "(Y[X=1] < Y[X=0]) | (Y[M=1] < Y[M=0])"))
grab(m1, "nodal_types")$Y        # "0000" "0001" "0101" "0011" "0111" "1111"  (verified)

# Same via helpers (decreasing() = negative-effect types = what you remove)
m2 <- m |>
  set_restrictions(decreasing("X", "M")) |>
  set_restrictions(c(decreasing("X", "Y"), decreasing("M", "Y")))
# (sequential calls accumulate; each statement is evaluated with join_by = "|")

# By labels; keep = TRUE keeps only the listed types
m3 <- make_model("X -> Y") |> set_restrictions(labels = list(Y = c("01", "11")), keep = TRUE)
m4 <- make_model("X -> Y") |> set_restrictions(labels = list(Y = "?0"))   # drops "00","10"
m5 <- make_model("X -> Y") |> set_restrictions("(X[] == 0)")              # X always 1

# "&" vs "|" over unspecified parents (model X -> Y <- W)
mw_or  <- make_model("X -> Y <- W") |> set_restrictions("(Y[X=1] < Y[X=0])")                 # drop if negative for SOME W (9 Y types left)
mw_and <- make_model("X -> Y <- W") |> set_restrictions("(Y[X=1] < Y[X=0])", join_by = "&")  # drop only if negative for ALL W (15 left)

# Confounded model, restriction inside one conditioning set
mc <- make_model("X -> Y; X <-> Y") |> set_restrictions(decreasing("X", "Y"), given = "X.1")
```

**Checking the result:**
```r
print(m1)                                  # "Number of nodal types by node: X 2 M 3 Y 6"; causal types 36
grab(m1, "nodal_types")
attr(m1, "restrictions")                   # removed types per node
summary(m1)                                # "Restrictions: X: 0 restricted types ... Y: 10 restricted types"
get_query_types(m, "(Y[X=1] < Y[X=0]) | (Y[M=1] < Y[M=0])", map = "nodal_type")  # which types a statement hits
```

You cannot write "Y is non-decreasing in X" in `X -> M -> Y` directly, because X is not a parent of Y. Restrict X→M and M→Y instead. This is documented behaviour: restrictions act on nodal types, not causal types.

---

## 5. Priors and parameters

### 5.1 Priors: `set_priors()` / `make_priors()`
```text
set_priors(model, alphas = NA, distribution = NA, alter_at = NA, node = NA,
           nodal_type = NA, label = NA, param_set = NA, given = NA,
           statement = NA, join_by = "|", param_names = NA)
```
- **Values.** Give one of:
  - `alphas`: non-negative Dirichlet hyperparameters, recycled if length 1.
  - `distribution`: exactly `"uniform"` (alpha = 1), `"jeffreys"` (0.5) or `"certainty"` (10000). Anything else (e.g. `"certain"`) errors.
  - Giving both errors ("values and distribution cannot be declared at the same time").
- **Selectors.** If none is given, *all* parameters change, with the message `"Altering all parameters."`.
  - `node`, `nodal_type`, `param_set` and `given` can be combined; matching uses the Cartesian product of the values given.
  - `statement` is a nodal-type statement (§0 rule 4). Only one statement is allowed, and it cannot be combined with `node` or `nodal_type`.
  - `param_names` (e.g. `c("Y.01","Y.10")`) cannot be combined with the other selectors.
  - `alter_at` is a filter string over `parameters_df` columns, e.g. `"node == 'Y' & nodal_type %in% c('00','01')"`. It cannot be combined with the other selectors. **Bug:** `alter_at` rejects `param_names == ...` (the whitelist says `parm_names`), so use the `param_names =` argument instead (verified).
  - `label` is deprecated: it warns `"label is depreciated, use nodal_type instead"`. Use `nodal_type`.
- **Order.** When several values are given, they are applied in the order the selectors are specified. For example, `nodal_type = c("10","00"), alphas = c(3,4)` gives `Y.10 = 3` and `Y.00 = 4` (verified). For a `statement`, values are applied in the model's nodal-type order.
- A full-length `alphas` vector with no selector replaces all priors in `parameters_df` order.
- **Flat priors** are the default (all alphas = 1), or set them explicitly with `set_priors(model, distribution = "uniform")`.
- `set_priors()` changes **only** `parameters_df$priors`. It does **not** change `param_value`, and it does **not** clear a stored `prior_distribution`.

```r
m <- make_model("X -> M -> Y; X -> Y") |>
  set_restrictions(c("(M[X=1] < M[X=0])", "(Y[X=1] < Y[X=0]) | (Y[M=1] < Y[M=0])"))

m <- set_priors(m, distribution = "jeffreys")                         # all alphas 0.5
m <- set_priors(m, node = "M", nodal_type = "01", alphas = 3)         # informative prior on ONE nodal type
m <- set_priors(m, param_names = c("Y.0011", "Y.0001"), alphas = c(2, 1.5))
m <- set_priors(m, statement = "(Y[M=1] > Y[M=0])", alphas = 2)       # all Y types where M matters for some X
make_priors(m, node = "X", alphas = c(1, 3))                          # returns the vector only
grab(m, "prior_hyperparameters")                                      # current alphas (named)
grab(m, "prior_hyperparameters", nodes = "Y")
```
Alphas are pseudo-counts within each `param_set`. With alphas (3, 0.5, 0.5) for M's three types, the prior mean of `M.01` is 3/4. Setting `alphas = 100` on a whole node (as in the book) makes that node's distribution nearly fixed.

### 5.2 Parameters ("true" values): `set_parameters()` / `make_parameters()`
```text
set_parameters(model, parameters = NULL, param_type = NULL, warning = FALSE, ...)
make_parameters(model, parameters = NULL, param_type = NULL, warning = TRUE, normalize = TRUE, ...)
```
- **Full-length vector**, in `parameters_df` order: `set_parameters(m, c(.5,.5,.1,.2,.6,.1))`. It is normalised within each `param_set`, so `1:6` is allowed.
- **Partial vector plus selectors.** `...` takes the same selector arguments as `set_priors`: `node`, `nodal_type`, `param_set`, `given`, `statement`, `param_names`, `alter_at`.
  - Example: `set_parameters(m, node = "Y", nodal_type = "01", parameters = .7)`.
  - The values you give are kept, and the other members of the set are rescaled to fill the remainder (`normalize = TRUE`).
- **`param_type`** is one of `"flat"`, `"prior_mean"` (the default if nothing else is given), `"prior_draw"`, `"posterior_mean"`, `"posterior_draw"` or `"define"`.
  - `"posterior_*"` needs an updated model.
  - `"define"` is implied when `parameters` plus selectors are supplied.
- **Watch the argument name.** `set_parameters(m, type = "flat")` is **silently ignored**, because `type` is not an argument; you get prior means. Write `param_type =`.
- A partial `parameters` vector with only `node =` (e.g. `set_parameters(m, node = "Y", parameters = c(.2,.1,.6,.1))`) works, but it warns "Possible ambiguity: use additional arguments ...". That warning is harmless when the length matches the node's types.
- Parameters drive `using = "parameters"` queries, `make_data()` and `make_events()`. They do **not** affect updating.

```r
truth <- make_model("X -> Y") |>
  set_parameters(node = "Y", nodal_type = c("10", "01"), parameters = c(.1, .6))
grab(truth, "parameters")            # X.0 .5 X.1 .5 Y.00 .15 Y.10 .10 Y.01 .60 Y.11 .15  (verified)
make_parameters(truth, param_type = "prior_draw")   # one Dirichlet draw from the priors
```

### 5.3 Prior distribution snapshot
`set_prior_distribution(model, n_draws = 4000)` stores draws so that later prior queries reuse them, which makes them reproducible. **Call it last**, after every `set_priors()` call: `set_priors()` does not refresh the snapshot. `set_restrictions()` and `set_confound()` delete it.

---

## 6. Confounding

**Syntax.** Declare confounding in the statement:
```r
make_model("X -> Y; X <-> Y")
```
or add it afterwards with `set_confound()`. Multiple confounds must be passed as a list (`list("X <-> Y", "M <-> Y")`); a string containing `;` errors.
```r
m  <- make_model("X -> M -> Y; X <-> Y")
m2 <- make_model("X -> M -> Y") |> set_confound(list("X <-> Y"))        # identical parameters_df (verified)
m3 <- make_model("A -> B -> C") |> set_confound(list("A <-> B", "B <-> C"))
```

**Effect on `parameters_df`.** The *later* node in causal order (here Y) gets a separate parameter set (simplex) for each nodal type of the earlier node. The joint distribution of the two nodes' types is then unrestricted.
```text
   param_names node param_set nodal_type given
1          X.0    X         X          0
2          X.1    X         X          1
3         M.00    M         M         00
...
7     Y.00_X.0    Y     Y.X.0         00   X.0
8     Y.10_X.0    Y     Y.X.0         10   X.0
9     Y.01_X.0    Y     Y.X.0         01   X.0
10    Y.11_X.0    Y     Y.X.0         11   X.0
11    Y.00_X.1    Y     Y.X.1         00   X.1
...   (Y.xx_X.1 rows)
```
- `param_set` becomes `"Y.X.0"` or `"Y.X.1"`.
- `given` holds the conditioning type (`"X.0"`, `"X.1"`).
- `param_names` gets the suffix `"_X.0"`.

The model also gains `model$P`, the parameter matrix: 14 × 32 for this example. Degrees of freedom for `X -> Y; X <-> Y` are 1 + 3 + 3 = 7.

**Rules (verified):**
- Node names **may not contain dots** in confounded models.
- Confounds can be declared **only once**. A second `set_confound()` on a model that already has `<->` errors ("Confounds have already been declared").
- `set_confound()` after `set_restrictions()` is fine.
- To target one conditioning set, add `given =` or `param_set =` in `set_priors()`, `set_parameters()` and `set_restrictions()`. Without it, `node =` / `nodal_type =` alter **all** conditioning sets.
```r
m <- make_model("X -> Y; X <-> Y")
set_priors(m, node = "Y", nodal_type = "01", alphas = 3)                 # Y.01_X.0 and Y.01_X.1
set_priors(m, node = "Y", nodal_type = "01", given = "X.1", alphas = 3)  # only Y.01_X.1
set_priors(m, param_set = "Y.X.1", alphas = 2)                           # whole set Y.X.1
```
Plots draw `<->` as a dashed curved arc.

---

## 7. Data

### 7.1 Format accepted by `update_model()`
- **Long data** (`data_type = "long"`):
  - A data.frame or tibble with **one column per node**, named exactly as the nodes, with values `0`, `1` or `NA`. `NA` means not observed and is treated as missing at random.
  - Each pattern of observed nodes is treated as a separate "strategy" (family).
  - Columns that are not nodes are ignored, and missing node columns are treated as all `NA`.
  - Integer, double, or character `"0"`/`"1"` all work, and `""` counts as `NA`.
  - Any other value is **dropped with only a message**.
  - Data with no node columns errors: "Data should contain columns corresponding to model nodes".
- **Compact data** (`data_type = "compact"`):
  - Columns `event` and `count` (integer), with optional `strategy`. The output of `collapse_data()` is the safe source.
  - Event names must follow `model$nodes` order: `"Y0X0"` errors with "Malformed event names ...".
  - A non-integer `count` is coerced with a warning.
- **Auto-detection:** if `data_type = NULL`, the data is treated as `"compact"` when it has both an `event` and a `count` column, and as `"long"` otherwise.

### 7.2 `make_data()`
```text
make_data(model, n = NULL, parameters = NULL, param_type = NULL, nodes = NULL,
          n_steps = NULL, probs = NULL, subsets = TRUE, complete_data = NULL,
          given = NULL, verbose = FALSE, ...)
```
- Returns a data.frame with **double** columns in `model$nodes` order, and `NA` for anything not observed.
- **Parameters used:** the model's parameter vector (`grab(model, "parameters")`) by default, **not** the priors. Alternatives:
  - `parameters =`: a full-length vector, normalised per set.
  - `param_type =`: `"prior_draw"` or `"posterior_draw"` (one parameter draw for the whole data set), or `"flat"`, `"prior_mean"`, `"posterior_mean"`.
  - There is **no `using` argument**. It is swallowed by `...` and ignored.
- **`n`**: if missing, n is `max(n_steps)`; if both are missing, n is 1.
- **`given = "X==1 & Y==1"`**: draws units only from data types consistent with the condition.
- **Multi-step strategies**:
  - `nodes = list(c("X","Y"), "M")`: which nodes are revealed at each step. A plain vector means a single step.
  - `n_steps = list(50, 5)`: how many units are revealed at each step. This overrides `probs`. It **errors** ("cannot take a sample larger than the population") if the subset has fewer units than requested.
  - `probs = list(1, .5)`: each eligible unit is revealed with this probability.
  - `subsets = list(TRUE, "X==1 & Y==1")`: a condition evaluated on the data observed so far, e.g. `"is.na(M)"` or `"X==1 & Y==0"`.
  - `verbose = TRUE` prints the step roster.
  - Plain vectors such as `c(TRUE, "X==1")` also work, but the documented form is a list.
```r
m <- make_model("X -> M -> Y; X -> Y")
make_data(m, n = 5)                                             # complete data
make_data(m, n = 3, nodes = c("X", "Y"))                        # M never observed
d <- make_data(m, n = 50, nodes = list(c("X","Y"), "M"),
               n_steps = list(50, 5), subsets = list(TRUE, "X==1 & Y==1"))   # "wide + deep"
make_data(m, n = 20, nodes = list(c("X","Y"), "M"), probs = list(1, .5),
          subsets = list(TRUE, "X==1 & Y==1"))                  # robust when subset may be small
make_data(m, n = 4, given = "X==1 & Y==1")
make_data(m, n = 3, param_type = "prior_draw")
```

### 7.3 `collapse_data()`, `expand_data()`, `make_events()`
```r
collapse_data(d, m)                 # data.frame(event, strategy, count), e.g. X1M1Y1 / XMY / 5 ; X0Y0 / XY / 24
collapse_data(d, m, drop_family = TRUE)   # without the strategy column
collapse_data(d, m, summary = TRUE)       # list(data_events, observed_events, unobserved_events)
e <- make_events(m, n = 10, include_strategy = TRUE)   # compact complete data
expand_data(e, m)                                       # back to long form
get_all_data_types(m, complete_data = TRUE)             # 8 complete patterns (27 incl. NA patterns)
get_event_probabilities(m)                              # Pr(each complete data type | parameters)
```
- `drop_NA = TRUE` (the default) drops strategy families whose total count is zero.
- Strategy names concatenate the observed nodes, e.g. `"XMY"`, `"XY"`.

---

## 8. Updating

```text
update_model(model, data = NULL, data_type = NULL, keep_type_distribution = TRUE,
             keep_event_probabilities = FALSE, keep_fit = FALSE, censored_types = NULL, ...)
```

**Arguments:**
- `data`: long or compact data (§7). `NULL`, zero rows, or all-`NA` data gives the message "No data provided", and the posterior equals the prior.
- `data_type`: `"long"`, `"compact"`, or `NULL` to auto-detect.
- `keep_type_distribution = TRUE` stores `stan_objects$type_posterior` (draws × causal types), which `query_model(using = "posteriors")` uses directly. Setting it to `FALSE` saves memory: 4.6 MB versus 0.7 MB for a 128-type model. Queries still work, because type probabilities are then computed from the parameter draws.
- `keep_event_probabilities = TRUE` stores `stan_objects$event_probabilities` (draws × data types). Read it with `grab(m, "posterior_event_probabilities")`.
- `keep_fit = TRUE` stores the raw `stanfit` (`grab(m, "stanfit")`). Its parameter names are raw: `lambdas[i]`, `types[j]`, `w[k]`.
- `censored_types = c("X1Y0")` names data types that could never have been observed (selection). Updating conditions on that selection.
- `...` is passed to **`rstan::sampling`**:
  - `chains` (default 4), `iter` (2000), `warmup` (`floor(iter/2)`), `thin`, `seed`.
  - `refresh` (use **0 to silence** sampler progress) and `cores` (default `getOption("mc.cores", 1L)`).
  - `control = list(max_treedepth = ...)`; the default set by CausalQueries is 15.
  - **`control$adapt_delta` is always reset to 0.95.** `save_warmup` is forced to `FALSE`.
- There is no Stan compilation at run time: the Stan model `simplexes` is precompiled when the package is installed.

**Return value:** the same `causal_model` plus two new slots.
- `$posterior_distribution`: a data.frame of draws × parameters, with column names equal to `param_names`. By default there are 4000 rows (chains × (iter − warmup)); `iter = 4000` gives 8000.
- `$stan_objects`: a list with
  - `data` (the compact data used),
  - `stan_warnings` (a single string, `""` if there were none),
  - `stan_summary` (a character vector: the printed `stanfit` summary with readable names; rows are parameters, then event probabilities if kept, then causal types if kept, then `lp__`),
  - `type_posterior`, `event_probabilities` and `stanfit` when requested.

**Accessing results:**
```r
m <- make_model("X -> Y")
d <- data.frame(X = rep(0:1, 10), Y = rep(0:1, 10))
set.seed(1)
u <- update_model(m, d, refresh = 0)
post <- grab(u, "posterior_distribution")       # 4000 x 6 data.frame
colMeans(post)
cat(grab(u, "stan_summary"), sep = "\n")         # mean, sd, quantiles, n_eff, Rhat
inspect(u, "stan_summary")                       # same, printed
grab(u, "type_posterior")[1:3, ]                 # draws x causal types
grab(u, "data")                                  # event / strategy / count actually used
grab(u, "stan_warnings")                         # "" if clean
```

**Diagnostics.** Stan warnings (divergent transitions, R-hat, bulk/tail ESS) appear in four places:
- They are raised as ordinary R warnings during `update_model()`.
- They are stored in `stan_warnings`.
- They are re-printed by `print(model)`.
- They are re-printed when you print or plot a posterior `query_model()` result.

For advanced checks, use `keep_fit = TRUE` and then `rstan`/`bayesplot` on `grab(u, "stanfit")`.

**Reproducibility (verified):**
- `set.seed(k)` immediately before `update_model()`, with serial chains, gives a bit-identical posterior. rstan's default `seed` and the draw permutation both come from R's RNG.
- With `options(mc.cores = 2+)`, the *set* of draws is identical but row order differs. All query summaries are identical.
- `update_model(..., seed = 123)` without `set.seed()` gives the same draws in a different row order.

**Re-updating.** `update_model(updated_model, new_data)` **discards** the earlier posterior and refits from the priors with only `new_data`. Verified: data A followed by data B gives the same result as data B alone. Combine all data into one call (`rbind` the long data).

**Saving.** `saveRDS(u, "model.rds")` and `readRDS()` round-trip, and queries work on the reloaded object (verified). Size is about 1.4 to 2.9 MB for a 36-causal-type model with `type_posterior`; `keep_fit = TRUE` makes it larger.

---

## 9. Querying

### 9.1 Signatures
```text
query_model(model, queries = NULL, given = NULL, using = list("parameters"), parameters = NULL,
            stats = NULL, n_draws = 4000, expand_grid = NULL, case_level = FALSE,
            query = NULL, cred = 95, labels = NULL)
query_distribution(model, queries = NULL, given = NULL, using = "parameters", parameters = NULL,
                   n_draws = 4000, join_by = "|", case_level = FALSE, query = NULL)
```
- `model` can be one `causal_model` or, for `query_model` only, a list of models. Name the list, otherwise the models are called `model_1`, `model_2`, .... The output then has a `model` column. `query_distribution` accepts one model only.
- `queries` / `query` are aliases; giving both errors.
  - Pass a character vector or a (named) list.
  - Names become the `label` column in `query_model()` and the column names in `query_distribution()`.
  - Without names, the label is the query text, with `" :|: given"` appended when there is a given.

### 9.2 Query syntax (all verified)
| Intent | Query string |
|---|---|
| Potential outcome | `"Y[X=1]"` (do X=1; descendants recomputed) |
| ATE | `"Y[X=1] - Y[X=0]"`, or `te("X","Y")` |
| Share with a positive effect | `"Y[X=1] > Y[X=0]"` |
| Share with any effect | `"Y[X=1] != Y[X=0]"` |
| Complement (no positive effect) | `"!(Y[X=1] > Y[X=0])"` or `"Y[X=1] <= Y[X=0]"` |
| Several dos | `"Y[X=1, M=0]"`, **comma-separated** |
| Nested | `"Y[X=1, M=M[X=0]]"`, `"Y[M=M[X=1]]"`, `"D[C=C[B=B[A=1]], A=0]"` |
| Indirect effect (X=1 baseline) | `"Y[X=1, M=M[X=1]] - Y[X=1, M=M[X=0]]"` |
| Direct effect (M at M[X=0]) | `"Y[X=1, M=M[X=0]] - Y[X=0, M=M[X=0]]"` |
| Joint / path ("X→M and M→Y") | `"(M[X=1] > M[X=0]) & (Y[M=1] > Y[M=0])"` |
| Observational event | `"X==1 & Y==1"`, `"M==1"` |
| Compliers (IV) | `"X[Z=1] > X[Z=0]"` |
| Interaction | `interacts("X","W","Y")`, `complements("X","W","Y")`, `substitutes(...)` |
| Wildcard over a parent | `"(Y[X=1, M=.] > Y[X=0, M=.])"`. It always expands with OR (`\|`) in `query_model`. **`query_distribution(join_by = "&")` is ignored (bug)**, so write out the `&` version by hand. |

- **Operators:** use `=` *inside* brackets (the do-operation) and `==` / `!=` / `>` / `<` / `>=` / `<=` / `&` / `|` / `!` / `-` / `+` *outside*.
  - Write `"Y[X=1]==1"`. The package auto-fixes `Y[X==1]` and `Y[X=1]=1` with a warning.
  - `"Y[X=1 & M=1]"` is auto-fixed to `"Y[X=1, M=1]"`, with the warning "Query syntax error detected!".
- Dos on non-parents are allowed in queries; the effect propagates through the DAG. A query like `"Y[X=1]"` in `X -> M -> Y` is the *total* effect.
- Non-linear transforms (`log(`, `exp(`, `^`, `/`) give the warning "Non-linear transformations ... not supported".
- Decimals work but trigger the message "Generated expanded expression:", because of the `.` check.

### 9.3 `given`
- Use the `given =` argument (a vector or list) **or** `:|:` inside the query, **not both**. Both together errors: "please specify givens either via the `given` argument or via `:|:` ...".
- `:|:` is used (not `|`) because `|` means logical OR.
- A given is any logical statement, observational or counterfactual:
  - `"X==1 & Y==1"`
  - `"X==1 & Y==1 & M==0"`
  - `"(X==1 & Y==1) | (X==0 & Y==0)"`
  - `"Y[X=1] != Y[X=0]"`
  - `"Y[X=1] > Y[X=0] & M==1"`
  - `"X[Z=1] > X[Z=0]"`
- A single `=` (as in `"X=1 & Y=1"`) is auto-corrected to `==` with a warning.
- **No conditioning:** `given = TRUE`, `"TRUE"`, `""`, `"ALL"`, `"All"`, `"all"`, `"None"`, `"none"` or `"NONE"`. The output shows `given = "-"`.
- In `query_distribution`, `given` must have the same length as `queries`.
- A given that no type satisfies returns `NA`, with the message "No units given. `NA` estimand.".

### 9.4 `using`
- `"priors"`: the type distribution under the Dirichlet priors, drawn **fresh at each call** (`n_draws` draws) unless `set_prior_distribution()` stored draws.
- `"posteriors"`: requires `update_model()`; otherwise it errors with "Model does not contain a posterior distribution".
- `"parameters"` (the **default**): one parameter vector, `grab(model, "parameters")`, or the `parameters =` argument.
  - In `query_model`, `parameters` must be a **list** of vectors, one per model, e.g. `parameters = list(c(...))`.
  - In `query_distribution`, a vector is fine.
  - Giving `parameters` makes the default `stats` mean-only.
- The singular forms `"prior"` and `"posterior"` are accepted. Anything else errors.

### 9.5 `case_level`: precise semantics
Let G be the given and Q the query, and let λ_s index the parameter draws (prior or posterior). Type probabilities are computed per draw. From `get_estimands()` in `R/query_model.R`:

- **`case_level = FALSE` (default; the book's "uninformative-case query", π̂):**
  - For each draw, compute π_s = Pr(Q & G | λ_s) / Pr(G | λ_s), the *share* of G-units in the population for which Q holds.
  - The output summarises the distribution of π_s: `mean`, `sd`, `cred.low`, `cred.high`.
  - Use this for population-level conditional estimands, such as CATEs or the probability of causation in X=1,Y=1 cases. It is also the right answer for a case selected *because* it shows G, or a case whose data are already in the updating data.
- **`case_level = TRUE` (the book's "informative-case query", φ̂, Ch. 7 appendix and Ch. 9 §"Two Types of Case-Level Conditional Inferences"):**
  - Returns the single number φ = mean_s Pr(Q & G | λ_s) / mean_s Pr(G | λ_s). This is the ratio of averages, not the average of ratios.
  - It equals π̂ computed after re-weighting the draws by Pr(G | λ_s). In other words, observing G in a *new, randomly drawn* case also updates beliefs about λ.
  - Output: `sd = NA`, `cred.low = cred.high = mean`.
  - Use it for process tracing in a new case that was **not** part of the `update_model()` data. Using it on a case already in the data counts that case twice.
- The two coincide when:
  - there is no given;
  - `using = "parameters"` (a single λ);
  - Pr(G | λ) is constant across draws, e.g. G's distribution is known.
- Example from the worked script (posterior, X=1,Y=1,M=0): case_level FALSE gives mean 0.591 with 95% CI [0.066, 0.993]; case_level TRUE gives 0.619.
- `query_distribution(..., case_level = TRUE)` returns a one-row data.frame. It accepts only a single value of `case_level`.

### 9.6 `expand_grid`, `cred`, `labels`, `stats`, `n_draws`
- **`expand_grid = NULL`** guesses TRUE only if the multi-valued arguments (queries, models, using, given, case_level) have **two or more different lengths greater than 1**.
  - Equal lengths are **zipped** element-wise. This is useful for pairing each query with its own given, e.g. `given = c(rep(TRUE, 7), "X==1 & Y==1")` for 8 queries.
  - `expand_grid = FALSE` with unequal lengths errors.
  - When the given is written inside a query with `:|:`, it travels with that query.
- **`cred = 95`**: equal-tailed interval. `cred.low` is the (100 − cred)/200 quantile and `cred.high` is the 1 − (100 − cred)/200 quantile.
- **`labels`**: a character vector with one label per **output row**. Wrong length or duplicates are ignored, with a message.
- **`stats`**: a named list or vector of functions, e.g. `stats = c(mean = mean, median = median)`. It replaces `mean`, `sd`, `cred.low` and `cred.high`.
- **`n_draws`**: the number of prior draws; it has no effect on posteriors.

### 9.7 Output of `query_model()`
- An object of class `c("model_query","data.frame")`.
- Columns: `label`, `model` (only if there is more than one model), `query`, `given` (`"-"` if none), `using`, `case_level`, `mean`, `sd`, `cred.low`, `cred.high` (or your `stats` names; only `mean` when `parameters =` is supplied).
- Attributes: `call`, `date`, `stan_warnings`.
- **Printing hides columns.** It drops `sd`/`cred.*` when all rows are parameters or case-level, drops `given` if every row is `"-"`, and drops `case_level` if all are FALSE. Use `as.data.frame(res)` to see everything, and to write files:
```r
res <- query_model(make_model("X -> Y"), list(ATE = "Y[X=1] - Y[X=0]"), using = "priors")
write.csv(as.data.frame(res), "queries.csv", row.names = FALSE)
res$mean[res$label == "ATE" & res$using == "priors"]
```

### 9.8 `query_distribution()`
- Returns a **plain data.frame**: rows are draws (`n_draws` for priors, all posterior draws for posteriors, 1 for parameters); columns are queries.
- It has returned a data.frame, not a vector, since 1.0.0. Use `[[1]]` or `$name` to get a vector.
- Draws in one call are aligned by row, so cross-query comparisons are valid:
```r
m <- make_model("X -> Y")
qd <- query_distribution(m, list(PE = "Y[X=1] > Y[X=0]", NE = "Y[X=1] < Y[X=0]"), using = "priors")
mean(qd$PE > qd$NE)
query_distribution(m, "Y[X=1] > Y[X=0]", given = "X==1 & Y==1", using = "priors", case_level = TRUE)  # 1 x 1
```

### 9.9 `get_query_types()` and `realise_outcomes()`
```r
m <- make_model("X -> M -> Y; X -> Y")
x <- get_query_types(m, "Y[X=1] > Y[X=0]")                    # map = "causal_type" (default)
names(x)          # "types" "query" "evaluated_nodes" "type_list"; x$type_list = satisfying causal types (32 of 128)
y <- get_query_types(m, "(Y[X=1] > Y[X=0])", map = "nodal_type")
names(y)          # "types" "query" "expanded_query" "evaluated_nodes" "node"   (7 of 16 Y types: M held fixed)
get_query_types(make_model("X -> Y"), "Y[X=1] - Y[X=0]")$types  # numeric -1/0/1 weights per causal type
realise_outcomes(m)                         # node values for every causal type
realise_outcomes(m, dos = list(X = 1))      # under do(X=1)
realise_outcomes(m, dos = list(M = 1), node = "Y")   # Y for each (X, Y-type) with M set to 1
```

---

## 10. Plotting

```text
plot_model(model = NULL, x_coord = NULL, y_coord = NULL, labels = NULL, title = "",
           textcol = 'white', textsize = 3.88, shape = 16, nodecol = 'black',
           nodesize = 12, parse = FALSE, strength = .3)
```
- `plot(model, ...)` is the same as `plot_model(model, ...)`. It returns a **ggplot (ggraph) object**, so you can add layers and save it with `ggsave()`.
- The default layout is igraph's Sugiyama layout. `x_coord` and `y_coord` must **both** be given or neither (if only one is given, both are ignored with a message). Their length must equal the number of nodes, and they are given **in `model$nodes` order** (check `grab(model, "nodes")`).
- `labels` gives node labels in `model$nodes` order. Use `parse = TRUE` for plotmath, e.g. `c("alpha^2", "beta[1]")`.
- `nodecol`, `textcol`, `shape`, `nodesize` and `textsize` take a single value or one value per node, in `model$nodes` order.
- `strength` sets the curvature of the dashed `<->` arcs.
- Nodes and labels at the edge of the plot get clipped. A generic fix that needs no coordinates (verified):
  `+ ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0.15)) + ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = 0.15))`.
  `expand_limits()` also works when you set the coordinates yourself. The docs suggest `coord_cartesian(clip = "off")`, which still clips at the image edge.
- `plot(query_result)` gives a coefficient plot: points with credible-interval bars, coloured by `using` and faceted by model. Case-level rows are labelled "(case)".
```r
model <- make_model("Z -> X -> Y; X <-> Y")
grab(model, "nodes")                 # "Z" "X" "Y": the order for coords, labels and colours
p <- plot(model, x_coord = c(0, 1, 2), y_coord = c(0, 0, 0),
          labels = c("Instrument", "Treatment", "Outcome"),
          nodecol = "white", textcol = "black", title = "IV model") +
  ggplot2::expand_limits(x = c(-0.5, 2.5), y = c(-0.2, 0.6))   # room for long labels and the arc
ggplot2::ggsave("dag.png", p, width = 6, height = 3)
```
Edges start and stop 8 mm from the node centre (fixed in the code), so long labels can overlap arrows. Keep labels short, or break them with `"\n"`.
Plotting needs the `ggraph` and `ggplot2` packages, both of which are package imports.

---

## 11. Performance and gotchas

**Model size and run time.** Measured in this container (R 4.3.3, 4 chains, serial, default `iter = 2000` unless noted):

| Model | Causal types | Parameters | Update time |
|---|---|---|---|
| `X -> Y`, 20 obs | 8 | 6 | about 1 s |
| `X -> M -> Y; X -> Y`, 50 obs (M observed in 5) | 128 (36 after monotonicity) | 22 (11 after) | about 4.5 s (2.5 s restricted) |
| `democracy_data` model `I -> M -> D <- P; I -> D` + restrictions, 84 obs | | | about 10 s, with ESS warnings at the default iter |
| Y with 3 parents, 100 obs | 2,048 | 262 | about **90 s**, with R-hat/ESS warnings |
| Y with 4 parents | | 65,544 | `make_model(add_causal_types = FALSE)` takes about 1 s; updating is not practical |

- **Keep in-degree at 3 or less.** Use restrictions such as monotonicity to shrink the type space.
- `add_causal_types = FALSE` speeds up `make_model()` for plotting very large models.
- `options(mc.cores = parallel::detectCores())` runs chains in parallel. Set it *before* `library(CausalQueries)` to avoid the startup message, or load with `suppressPackageStartupMessages()`.
- Installing from source compiles C++/Stan, which takes several minutes. After that there is no per-model compilation.
- For divergences or low ESS: raise `iter` (4000–10000) and/or `chains`, and check Rhat and n_eff in `grab(m, "stan_summary")`. `adapt_delta` cannot be changed (§0 rule 12).

**Silencing output:**
- `refresh = 0` silences the sampler.
- `suppressMessages()` silences "Altering all parameters.", "No parentheses indicated...", "Prior distribution added to model", and dplyr's "Joining with `by = join_by(event)`", which appears with compact data that has no `strategy` column.
- Stan warnings are real warnings; inspect them rather than suppressing them.

**More gotchas** (from code, tests and NEWS, all verified):
1. `query_model()` and `query_distribution()` default to `using = "parameters"` (§0 rule 1).
2. Equal-length arguments are zipped, not crossed (§9.6).
3. `decreasing("X","Y")` names the negative types, so `set_restrictions(decreasing(...))` *imposes* monotone increasing (§4).
4. A statement is a nodal-type statement (other parents held fixed, joined by `|`) in restrictions, priors and parameters, but a causal-type query (mediators propagate) in `query_model()` (§0 rule 4).
5. `inspect()` prints and requires `what`; `grab()` is silent.
6. `type_prior` is types × draws, while `type_posterior` is draws × types.
7. Re-running `update_model()` replaces the posterior (§8).
8. `set_prior_distribution()` followed by `set_priors()` leaves the stored prior draws stale (§5.3).
9. `make_data()` uses parameters, not priors, and silently ignores `using`.
10. `make_data(n_steps = ...)` errors when the subset is smaller than the number requested; use `probs`.
11. Non-0/1 data values are dropped with a message only. Compact event names must follow `model$nodes` order.
12. Node naming and the `;`/newline issue (§2.1, §2.2).
13. Confounded models: no dots in names, confounds declared once, `given`/`param_set` needed to target one conditioning set.
14. `alter_at` cannot filter on `param_names` (bug). The `label=` argument is deprecated (use `nodal_type=`). `distribution` must be exactly `"uniform"`, `"jeffreys"` or `"certainty"`.
15. Wildcard `.` in queries always means OR; the `join_by` argument of `query_distribution` is ignored.
16. Restricting away every type of a node gives a model with 0 causal types and no error.
17. Printed `model_query` tables hide columns; use `as.data.frame()`.
18. Prior queries are random: call `set.seed()` before each one, or store draws with `set_prior_distribution()` as the last step.

---

## 12. Complete worked script (verified: runs top to bottom in about 10 s)

The script builds `X -> M -> Y; X -> Y`, imposes monotonicity, sets priors, inspects the nodal types, and computes prior queries: the ATE, the probability of causation (PoC) when X=1,Y=1, and the PoC given M. It then simulates 50 cases with X,Y and M observed in 5 X=1,Y=1 cases, updates the model, compares posterior and prior queries at population and case level, and saves the outputs.

```r
## =====================================================================
## CausalQueries >= 1.4.3 (verified on 1.4.6): end-to-end template
## Model: X -> M -> Y; X -> Y  (mediation + direct path), process tracing on M
## =====================================================================
suppressPackageStartupMessages({
  library(CausalQueries)
  library(ggplot2)
})
stopifnot(packageVersion("CausalQueries") >= "1.4.3")

options(mc.cores = parallel::detectCores())  # chains in parallel (draw ORDER then varies run-to-run; summaries do not)
set.seed(20241020)                           # governs prior draws, data simulation and rstan's default seed
out_dir <- "cq_output"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

## 1. Make the model -------------------------------------------------------
model <- make_model("X -> M -> Y; X -> Y")
print(model)                                  # 2 / 4 / 16 nodal types, 128 causal types

## 2. Monotonicity: REMOVE negative effects (statements name types to drop) ---
model <- set_restrictions(model, statement = c(
  "(M[X=1] < M[X=0])",                         # no negative X -> M effect
  "(Y[X=1] < Y[X=0]) | (Y[M=1] < Y[M=0])"))    # no negative X -> Y or M -> Y effect (other parent held fixed)
print(model)                                  # now 2 / 3 / 6 nodal types, 36 causal types

## 3. Priors (Dirichlet alphas; default is 1 = flat) -------------------------
model <- set_priors(model, distribution = "jeffreys")                    # all alphas 0.5 (message: "Altering all parameters.")
model <- set_priors(model, node = "M", nodal_type = "01", alphas = 3)    # a priori X usually raises M

## 4. Inspect --------------------------------------------------------------
inspect(model, "nodal_types")                 # labels + guide: digit order is (X=0,M=0),(X=1,M=0),(X=0,M=1),(X=1,M=1)
pdf <- grab(model, "parameters_df")           # grab() = silent accessor
print(pdf[, c("param_names", "node", "nodal_type", "param_set", "priors")])

## 5. Queries, evaluated on the priors -----------------------------------------
queries <- list(
  ATE    = "Y[X=1] - Y[X=0]",                              # average effect (total, via M and direct)
  PoC    = "Y[X=1] > Y[X=0] :|: X==1 & Y==1",              # did X=1 cause Y=1?
  PoC_M1 = "Y[X=1] > Y[X=0] :|: X==1 & Y==1 & M==1",       # ... if we also see M=1
  PoC_M0 = "Y[X=1] > Y[X=0] :|: X==1 & Y==1 & M==0")       # ... if we also see M=0
prior_q <- query_model(model, queries = queries, using = "priors")
print(prior_q)

## 6. Fake data: 50 cases with X,Y; M observed in 5 of the X=1,Y=1 cases ------
truth <- model |>
  set_parameters(node = "M", nodal_type = "01",   parameters = 0.7) |>   # true share with X -> M positive
  set_parameters(node = "Y", nodal_type = "0011", parameters = 0.6)      # true share with Y = M
print(query_model(truth, queries, using = "parameters"))                  # estimands under the truth
data <- make_data(truth, n = 50,
                  nodes   = list(c("X", "Y"), "M"),          # step 1: X,Y for all; step 2: M
                  n_steps = list(50, 5),                     # 50 then 5 units
                  subsets = list(TRUE, "X==1 & Y==1"))       # step-2 units drawn from X=1,Y=1 cases
## Real data instead: data <- read.csv("cases.csv")  # one column per node, values 0/1/NA (NA = not observed)
print(colSums(!is.na(data)))
print(collapse_data(data, model))             # compact view: event / strategy / count

## 7. Update (rstan args go through ...) -------------------------------------
updated <- update_model(model, data, chains = 4, iter = 4000, refresh = 0)
print(updated)                                # also reprints any rstan warnings
cat(grab(updated, "stan_summary"), sep = "\n")   # Rhat / n_eff per parameter and causal type
if (nzchar(grab(updated, "stan_warnings"))) warning("Sampler warnings: check Rhat/ESS, raise iter")
post <- grab(updated, "posterior_distribution")  # data.frame: draws x parameters
print(dim(post))

## 8. Posterior (and prior) queries, population- vs case-level ---------------
results <- query_model(updated,
                       queries     = queries,
                       using       = c("priors", "posteriors"),
                       case_level  = c(FALSE, TRUE),
                       expand_grid = TRUE)    # REQUIRED to cross all combinations
print(results)

draws <- query_distribution(updated, queries = queries, using = "posteriors")  # draws x queries
print(mean(draws$PoC_M1 > draws$PoC))         # Pr(observing M=1 raises the PoC)

## 9. Save -------------------------------------------------------------------
saveRDS(updated, file.path(out_dir, "model_updated.rds"))
write.csv(as.data.frame(results), file.path(out_dir, "query_results.csv"), row.names = FALSE)
dag_plot <- plot(updated) +                                     # ggplot object; pad so nodes are not clipped
  scale_x_continuous(expand = expansion(mult = 0.15)) +
  scale_y_continuous(expand = expansion(mult = 0.15))
ggsave(file.path(out_dir, "dag.png"), dag_plot, width = 5, height = 4)
ggsave(file.path(out_dir, "queries.png"), plot(results), width = 8, height = 5)
```

**Notes for adapting the script:**
- **Which `case_level` to read.** The 5 process-traced cases are *in* the updating data. For "did X cause Y in one of *those* cases?", read the `case_level = FALSE` rows. Read the `case_level = TRUE` rows for a *new* case in which you will observe M.
- **Observed output** (this seed, posterior): ATE 0.590 [0.369, 0.771]; PoC 0.705; PoC_M1 0.709; PoC_M0 0.591 at population level versus 0.619 at case level. Priors: ATE 0.582, PoC 0.738.
  - One divergent transition was reported. The script catches it through `stan_warnings`; raise `iter` if this happens.
- **To add 5 *extra* cases with full X, M, Y data** instead of nesting them, `rbind()` two `make_data()` calls with the same columns, e.g. `rbind(make_data(truth, 50, nodes = c("X","Y")), make_data(truth, 5))`.
- **Quick extraction:** `subset(as.data.frame(results), using == "posteriors" & !case_level)[, c("label", "mean", "cred.low", "cred.high")]`.

---

## 13. Book (`ii-book/*.qmd`) code that differs from the current package

Most book code (`make_model`, `set_restrictions`, `query_model(..., given =, using =, case_level =, expand_grid =)`, `update_model(..., data_type = "compact", keep_fit =, keep_event_probabilities =)`, `grab()`, `get_query_types()$types/$type_list`, `draw_causal_type()`) already uses the current API. The table lists every call whose name or arguments differ, or that relies on internals or accidental behaviour.

| Book location | Book code | Status now | Current equivalent |
|---|---|---|---|
| `helpers/_tools.R` 682, 1309 (examples) | `simulate_data(model, n = 4)` | Not exported; deprecated internal alias. **Errors.** | `make_data(model, n = 4)` |
| 09-mixing 836; 11-fusion 74; 16-evaluating 69, 72 (also package vignette c-canonical-models) | `make_data(model, n, using = "parameters")` | `using` is not an argument; it is silently ignored (the result happens to be the same) | `make_data(model, n = n)`. For draws use `param_type = "prior_draw"` or `"posterior_draw"` |
| 13-case-selection 553 | `set_parameters(type = "flat")` | `type` is not an argument; ignored, giving prior means | `set_parameters(param_type = "flat")` |
| 13-case-selection 640 | `set_parameters(type = "jeffreys")` | Ignored; `"jeffreys"` is not a `param_type` | Priors: `set_priors(distribution = "jeffreys")`. Then if needed `set_parameters(param_type = "prior_mean")` |
| 13-case-selection 552, 639 | `set_restrictions(...) \|> set_parameter_matrix()` | Redundant; `set_restrictions()` already builds `P` | Drop `set_parameter_matrix()` |
| 09-mixing 683–684, 697–698; 14-wide-deep 46; 17-conclusion 100 | `set_priors(alpha = ...)` | Works only through R partial matching | `set_priors(alphas = ...)` |
| 07-process-tracing 837 | `set_priors(given = "Y.0001", nodal_type = "11", 10)` | Positional third argument is `alphas`; works | `set_priors(given = "Y.0001", nodal_type = "11", alphas = 10)` |
| 12-clue-selection 442 (commented out) | ``set_priors(alphas = list(M = c(`(M[I=0] > M[I=1])` = 0.5)))`` | Named-list `alphas` (old API) not supported | `set_priors(statement = "(M[I=0] > M[I=1])", alphas = 0.5)` |
| 02-causal-models 340 | `CausalQueries:::get_nodal_types(model, collapse = FALSE)$Y` | Internal (unexported since 1.1.0); still works with `:::` | Labels: `grab(model, "nodal_types")`. Digit meaning: `interpret_type(model)` or `realise_outcomes(model, node = "Y")` |
| 04-causal-questions 550; 07-process-tracing 208, 217 | `CausalQueries:::get_type_prob(model)` | Internal; works | Type probabilities at the parameter vector: `get_query_types()` plus `query_model(using = "parameters")`. For distributions: `grab(model, "type_prior")` (types × draws) / `grab(model, "type_posterior")` |
| 07-process-tracing 559 | `CausalQueries:::perm(rep(1, 9))` | Internal; works | (internal helper; fine for illustration) |
| 11-fusion 576 | `CausalQueries:::prep_stan_data(model = model, data = data_events[[1]])` | Internal; signature `prep_stan_data(model, data, keep_type_distribution = TRUE, censored_types = NULL)` with compact data | Not needed for normal use |
| `helpers/_tools.R` 348, 467, 572, 689, 1266 (also `:::perm` at 656, 710, 1083 and `:::get_all_data_types` at 339, 588, 733) | `CausalQueries:::map_query_to_causal_type`, `:::minimal_event_data`, `:::get_data_families` | Internal (`get_all_data_types` is exported, so its `:::` is unnecessary) | `get_query_types(model, q)$types`; `collapse_data()`; `get_all_data_types()` |
| `helpers/_tools.R` 1228–1234 (comments) | `get_parameters(model)` | Not exported. **Errors.** | `grab(model, "parameters")` |
| 09-mixing 250; 10-mixed 430–431, 656; 11-fusion 591 | `model$posterior_distribution` | Still a slot | `grab(model, "posterior_distribution")` |
| 13-case-selection 662; 16-evaluating 178 | `model$stan_objects$event_probabilities` | Still a slot (needs `keep_event_probabilities = TRUE`) | `grab(model, "posterior_event_probabilities")` |
| 09-mixing 203; 10-mixed 429 | `XY$parameters_df$param_value`, `model_id$parameters_df` | Slots | `grab(model, "parameters")`, `grab(model, "parameters_df")` |
| 10-mixed 207–294, 683–834; 14-wide-deep 63; 16-evaluating 94 | `query_distribution(...)` used as a vector | Returns a **data.frame** since 1.0.0 (the book's `[,1]` is correct) | `query_distribution(...)[[1]]` or `$name` |
| 11-fusion 449–452, 465–468 | `make_data(..., probs = c(1,1), subsets = c(TRUE, "Context == 0"))` | Vectors work; lists are the documented form | `probs = list(1, 1), subsets = list(TRUE, "Context == 0")` |
| 07-process-tracing 782–787 (`eval = FALSE`) | `query_model(query = c("Y[X=1] > Y[X=0]", "Y==1 & X==1 & M==0", ...), case_level = TRUE)` | Book slip: the conditions are passed as *queries* | `query_model(model, "Y[X=1] > Y[X=0]", given = c("X==1 & Y==1", "X==1 & Y==1 & M==0", "X==1 & Y==1 & M==1"), using = "priors", case_level = TRUE)`, as in the evaluated chunk at 795 |
| 16-evaluating 1147 | `update_model(RST_0, data = RST \|> uncount(10))` | Valid, but note it refits from the priors (RST_0's posterior is discarded) | Same; pass the full data set |
| `_setup.R` | `rstan_options(auto_write = TRUE)` | Irrelevant: the Stan model is precompiled | Omit; keep `options(mc.cores = ...)` |
| 09-mixing 316 | 8 queries with `given = c(rep(TRUE, 7), "X==1 & Y==1")` | Relies on equal-length **zipping** (intended) | Same; or write the given in the query with `:\|:` |

Package API changes that affect the book era (from NEWS):
- **1.0.0**: `query_distribution()` returns a data.frame; `query_model()` accepts several models and has `expand_grid`.
- **1.1.0**: `get_*()` accessors were unexported in favour of `inspect()`/`grab()`; `keep_fit` was added.
- **1.2.1**: `grab()`, the `summary()` `include` argument, and the `model_query` class with print/summary/plot methods were added.
- **1.3.0**: `:|:` givens inside queries.
- **1.3.2**: the `causal_type_query`/`nodal_type_query` classes were removed.
- **1.3.3**: `type_distribution` was renamed to `type_posterior`.
- **1.4.3**: `make_model()` errors on node names containing `[`, `]`, `:|:`, `^`, `/`, `exp(` or `log(`, and queries warn on non-linear transforms. NEWS lists a backslash, but the code checks `/`.
- **1.4.4**: `&`-inside-brackets query fixes; `plot_model(parse = TRUE)`.
- **1.4.5 and 1.4.6**: no API change.

---

## Appendix A. Messages: what they mean and what to do

| Message | Cause | Fix |
|---|---|---|
| `Graph should not contain isolates.` | A `<->` (or a node) is not connected by `->` edges | Add the directed edges |
| `Unsupported characters in variable names...` | `-`, `_`, `<`, `>` in a name | Rename using CamelCase |
| `No dots '.' in variable names for models with confounding.` | Dotted name and `<->` | Rename |
| `X is not a parent of Y` | A nodal-type statement (restriction, prior or parameter) does on a non-parent | Restrict each edge separately |
| `No outcome variable specified. If required, specify roots as X[]==1 not X==1.` | Root restriction written `X == 1` | Write `"(X[] == 1)"` |
| `Provide *either* a causal statement or nodal type labels or param_names.` | Two selector types given to `set_restrictions` | Make two calls |
| `distribution should be either 'uniform', 'jeffreys', or 'certainty'.` | e.g. `"certain"` | Use the exact string |
| `In alter_at statement: specified columns; param_names not in parameters_df` | Bug in `alter_at` | Use `param_names = c(...)` |
| `Trying to replace N parameters with M values.` | Value vector length does not match the matched parameters | Fix the length or the selectors |
| `Possible ambiguity: use additional arguments or check behavior in parameters_df.` | Multi-value set over an under-specified selection | Check `grab(m, "parameters_df")`; add `given`/`param_set` |
| `label is depreciated, use nodal_type instead` | `label =` argument | Use `nodal_type =` |
| `Model does not contain a posterior distribution` | `using = "posteriors"` before updating | Call `update_model()` first |
| `please specify givens either via the given argument or via :\|: ...` | Both used | Pick one |
| `No units given. NA estimand.` | Impossible given (e.g. ruled out by restrictions) | Check the given and the restrictions |
| `Query syntax error detected! ... Did you mean: X=1, M=1 ?` (warning) | `&` inside `[]` | Use commas inside brackets |
| `do operations should be specified with = not ==` (warning) | `Y[X==1]` | `Y[X=1]` |
| `... should be specified with == not =` (warning) | `Y[X=1]=1`, `given = "X=1"` | Use `==` outside brackets |
| `XnY0 data is inconsistent with model and ignored` (message) | Non-0/1 values, or data impossible under the restrictions | Recode to 0/1/NA; check the restrictions |
| `Malformed event names provided in data.` | Compact event names not in `model$nodes` order | Build them with `collapse_data()` |
| `count column should be integer valued...` (warning) | Non-integer `count` | `as.integer()` |
| `cannot take a sample larger than the population` | `make_data(n_steps = ...)` larger than the subset | Use `probs =`, or a smaller `n_steps` |
| `argument is of length zero` (from `inspect`) | `inspect(model)` without `what` | `inspect(model, "nodal_types")` etc., or `summary(model)` |
| `There were N divergent transitions...`, `Bulk/Tail ESS too low`, `largest R-hat` (warnings) | Sampler problems | Raise `iter`/`chains`; simplify or restrict the model; check `stan_summary` |
