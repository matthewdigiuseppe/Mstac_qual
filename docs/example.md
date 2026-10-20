# Worked example: inequality and democratization

What the formal skills produce on a real multi-method problem: Humphreys and Jacobs's reanalysis of Haggard and Kaufman's study of inequality and democratization (*Integrated Inferences*, chs. 8, 10, 12, 16), using `CausalQueries::democracy_data` (84 countries not democratic at the start of the period). Every number below came out of QualStack's templates and R tools in an end-to-end run; the book's own values agree to the reported precision.

## The question and the model (`/qualstack:query-design`, `/qualstack:causal-model`)

Did low inequality (I = 0) help bring democratization (D = 1), and in which cases? Nodes: I (inequality), M (mass mobilization), P (international pressure), D (democratization).

```r
model <- make_model("I -> M -> D <- P; I -> D") |>
  set_restrictions("(M[I=1] < M[I=0])") |>                                          # R1
  set_restrictions("(D[I=1] > D[I=0]) | (D[M=1] < D[M=0]) | (D[P=1] < D[P=0])")    # R2
```

R1: inequality never reduces mobilization. R2: inequality has no positive direct effect on democratization; mobilization and pressure never hinder it. The model has 2, 2, 3, and 20 nodal types at I, P, M, D (240 causal types). Before any data, flat priors over the remaining types imply an average effect of I on D of −0.22, a −0.44 effect among I = 0, D = 1 cases (low inequality caused democratization in 44% of them), and 0.13 among I = 1, D = 1 cases.

`/qualstack:model-review` flags what a referee would: R1 and R2 are theory, not data; the answer "I could not have caused D through M when M = 0 in an I = 1, D = 1 case" is fixed at 0 by R1, an assumption to report rather than a finding.

## What to look for in a case (`/qualstack:clue-select`)

For an I = 1, D = 1 case (`qs_clue_table`, untrained model):

| Clue | Chance of finding | Posterior if found | if not | φ1 | φ0 | Test | Expected learning |
|---|---|---|---|---|---|---|---|
| M (mobilization) | .85 | .15 | 0 | 1.00 | .83 | hoop | .026 |
| P (pressure) | .72 | .09 | .23 | .50 | .76 | smoking gun if absent | .037 |

The alternative cause beats the mediator. With prices M = 1 and P = 1.5 (`qs_two_step`), four strategies are undominated; the lowest expected variance (.1049, expected cost 2.28) comes from seeking M first and P only if M = 1, not from starting with the more informative clue.

## Which cases to trace (`/qualstack:case-select`)

`qs_case_strategies` updates once on the 84 cases and compares tracing two more cases by cell. Here every option teaches little about the average effect (expected learning under 0.4%): the 39 traced democratizers already carry the clue information. That is a finding about the design, reported as such.

## Updating once (`/qualstack:analyze`)

`code/03-data.R` keeps all 84 cases (clues missing for the 45 non-democratizers); `code/04-update.R` updates once:

| Query | Prior | Posterior |
|---|---|---|
| Average effect of I on D | −0.22 [−0.43, 0.01] | −0.23 [−0.35, −0.11] |
| Among I = 0, D = 1 cases | −0.45 [−0.74, −0.21] | −0.44 [−0.58, −0.29] |
| Among I = 1, D = 1 cases | 0.13 [0.00, 0.42] | 0.07 [0.00, 0.19] |

The clue-value table shows which pulls are theory-derived: in an I = 1, D = 1 case, M = 0 sets the answer to 0 in both the untrained and the trained model (R1 at work), while P's pull shrinks after training (from .23 vs. .09 to .09 vs. .04).

## A named case (`/qualstack:process-trace`)

Malawi (1994): I = 1, D = 1, with mobilization and pressure both present. `qs_trace_case` on the untrained model:

| Step | Clue | Posterior that inequality mattered |
|---|---|---|
| 0 | none | .128 |
| 1 | M = 1 | .150 |
| 2 | P = 1 | .107 |

Counterfactual table: had M been 0, the answer would be 0 (by R1); had P been 0, .25. The reader sees what the evidence could have shown.

## How much hangs on the model (`/qualstack:robustness`)

- **Implied independencies** (P ⊥ I; M ⊥ P | I): untestable in these data, because the clues were gathered only where democratization occurred and D is a collider. `qs_ci_tests` says so instead of reporting a pass. (The book tests them on an expanded data set and finds P and M correlated.)
- **Predictive checks** with the observed missingness: no warning on mean(D) or cor(I, D) (Bayesian p about .6 for both).
- **Sensitivity**: dropping every monotonicity restriction moves the average effect from −0.23 to −0.01 and the share of I = 1, D = 1 cases where inequality mattered from .07 to .50; softening R1 to a small prior on negative I → M effects barely moves either (−0.24, .09). Verdict: **sensitive**, with R2 the assumption most in need of defense.

## Reproduce

```bash
qualstack-init demo && cd demo
# code/01-model.R from the causal-model template with the statement and restrictions above
# data/case-data.csv from CausalQueries::democracy_data (case, I, P, M, D)
Rscript code/01-model.R && Rscript code/03-data.R && Rscript code/04-update.R
```

`tests/r/verify-book.R` checks the clue, case, trace, and model-check functions against the book's published values.
