---
name: query-design
description: Pins every question the project asks of its causal model to an exact CausalQueries query — the family (case-level effect, attribution, prevention, average or conditional effect, path, actual cause), the given, the level (named case, case type, population), which case-level question is meant (uninformative vs informative case), whether it is identified, what the model already implies before any evidence, and the decision the answer feeds. Writes .qualstack/queries.md and the QUERIES/GIVENS block of code/01-model.R. Use after /qualstack:causal-model, when the user's question is still "explain Y" or "the role of X", or before case or clue selection, which depend on the query.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Bash(Rscript *)
  - Bash(date *)
---

# /qualstack:query-design

**Stage:** model · **Voice:** methodologist

The same model and evidence answer different questions differently, and clue and case rankings change with the question (Humphreys & Jacobs 2023, ch. 4, 12–13). This skill refuses "what explains Y": every question becomes a string the model can answer, with its given, its level, and the conclusion it would change.

## Procedure

1. **Load** `.qualstack/research-question.md`, `.qualstack/theory.md`, `.qualstack/model.md`, `code/01-model.R`, `output/tables/prior-queries.csv`. Read the query section of `${CLAUDE_PLUGIN_ROOT}/references/causal-models.md`, the "three answers" section of `${CLAUDE_PLUGIN_ROOT}/references/mixed-methods.md`, and grep `${CLAUDE_PLUGIN_ROOT}/references/causalqueries-cookbook.md` for query syntax.
2. **One primary query**, then up to four secondary ones. For each, fill a row:

   | Field | Content |
   |---|---|
   | Words | The counterfactual question in one sentence |
   | Family | case-level effect · attribution · prevention · average · conditional average · path (indirect, X held at 0 or 1) · direct · actual cause |
   | String | e.g. `Y[X=1] > Y[X=0]`; path `Y[X=1, M=M[X=1]] > Y[X=1, M=M[X=0]]` |
   | Given | What is conditioned on, e.g. `X==1 & Y==1`; `TRUE` for none |
   | Level | named case(s) · case type · population |
   | Case question | For named cases: uninformative-case (π̂: the case is in the data or was chosen for its values; `case_level = FALSE`) or informative-case (φ̂: a new case drawn without regard to its values; `case_level = TRUE`). Never both for one case |
   | Using | `parameters` (untrained single-case process tracing at prior means) · `posteriors` (after updating on cross-case data) |
   | Identified? | The ATE in an unconfounded model is; the probability of causation for an X = Y = 1 case is not, and its posterior keeps a ridge whatever the N |
   | Prior answer | From `prior-queries.csv` |
   | Decision | The conclusion that changes, and the threshold (e.g. "attribution above .7 supports the claim in the abstract") |

3. **Convert the hard cases.** "Why did Y happen in case j?" becomes attribution queries about each named candidate cause (causes are not rivals; ask about each). "Did X work through M?" becomes a path query, never "did M occur". "What explains variation?" becomes average or conditional effects in a stated population. Preemption and overdetermination: say whether the claim is counterfactual or actual causation, and encode the latter in the model (ch. 4.6).
4. **Check what the model already says.** For each query: the prior mean, and whether it is fixed at 0 or 1 by a restriction (then it is an assumption, and no evidence can move it: drop it or relax the restriction). If the prior variance is zero, no design can teach anything about it.
5. **Update the code.** Write the QUERIES and GIVENS lists in `code/01-model.R` (names Q1, Q2 … matching `queries.md`), re-run `Rscript code/01-model.R`, and check the new `prior-queries.csv`. Set `model.primary_query` in `.qualstack/config.yaml` (string plus given, e.g. `Y[X=1] > Y[X=0] | X==1 & Y==1`).
6. **Save** `.qualstack/queries.md`: the table, the conversions made in step 3, the queries fixed by assumption, and the decision rule.

## Outputs

- `.qualstack/queries.md`; QUERIES/GIVENS in `code/01-model.R`; refreshed `output/tables/prior-queries.csv`; `model.primary_query` in config.
- Summary block: the primary query in words and as a string, its level and case question, its prior answer, the decision it feeds, any query answered by assumption.

## Anti-patterns

- **Effect for attribution.** That X would raise Y's chance is not that X caused Y here.
- **Mechanism as occurrence.** A path query asks how M would respond to X and Y to M.
- **Double counting.** A case whose data are in the update is never also asked a `case_level = TRUE` question.
- **A probability read as an effect size.** ".7 that X caused Y" is uncertainty about a yes-or-no estimand.
- **Queries without decisions.** If no answer would change a sentence in the paper, the query is decoration.

## Next

`/qualstack:model-review`, then `/qualstack:design-research`. Changing the primary query later makes the case and clue plans stale.
