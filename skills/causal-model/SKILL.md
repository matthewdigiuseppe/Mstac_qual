---
name: causal-model
description: Turns the theory memo into an executable causal model in CausalQueries — nodes with time stamps, the DAG with every missing arrow defended, unobserved confounding as <->, restrictions (monotonicity, necessity, exclusions) and priors each labeled and justified, measurement nodes for noisy sources — then counts nodal types, prints what the model believes before any evidence, and checks for unintended structure. Writes code/01-model.R and .qualstack/model.md. Use after /qualstack:theory-build, when the user wants to formalize an argument, draw or code a DAG, set priors or restrictions, or asks what their model implies; also when a clue or node is added later.
argument-hint: "[revise]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(Rscript *)
  - Bash(date *)
---

# /qualstack:causal-model

**Stage:** model · **Voice:** modeler

The model is the researcher's background knowledge written down so that it can be disputed: every probative value the project later claims comes from here (Humphreys & Jacobs 2023, ch. 2–3, 6). Write it before the evidence, defend every arrow that is missing and every type that is ruled out, and never let a convenient restriction pass unlabeled.

## Procedure

1. **Load** `.qualstack/theory.md` (nodes, arrows, functional claims, rivals, clue positions), `.qualstack/research-question.md`, `.qualstack/config.yaml` (`model.formal`, `model.seed`), and any existing `code/01-model.R` and `.qualstack/model.md` (with `revise`, change only what the user asks and re-run the checks). Read `${CLAUDE_PLUGIN_ROOT}/references/causal-models.md` and grep `${CLAUDE_PLUGIN_ROOT}/references/causalqueries-cookbook.md` for every function you use.
2. **If `model.formal: false`**, write `.qualstack/model.md` as a verbal model only (nodes, arrows, functional claims, rivals, the hypotheses process tracing will weigh) and stop: `/qualstack:process-trace` will use the informal route. Say what the project gives up (derived likelihoods, design diagnosis, integration with cross-case data).
3. **Nodes.** Each binary, named with letters and digits only (no underscores, dots, or spaces), with a one-line definition and a **time stamp** fine enough that the arrow directions are facts ("mobilization, 1990–1994", not "the 1990s"). A noisy source gets a measurement node (true `K` → reported `Kr`) when its error rates matter (`evidence-and-sources.md`).
4. **The DAG**, as a CausalQueries statement (`;` between clauses). Apply the drawing rules: an arrow wherever a direct effect is *possible*; the whole knowledge base, not the argument (if X could reach Y another way, draw X → Y); no excluded common causes (add the node or `<->`); feedback time-stamped, never cyclic. Fill the **arrow audit** in `model.md`: every absent arrow with why there is no chance of a direct effect; every pair of root nodes with whether anything causes both.
5. **Count before restricting.** A node with n parents has 2^(2^n) nodal types: print the count; four parents (65,536) needs restriction or simplification by the rules in `causal-models.md` (drop a mediator, merge a common cause into `<->`), saying how each simplification changes what the θ's mean.
6. **Restrictions and priors**, each with a label used in both the code and `model.md`: R1, R2 … (`set_restrictions()`, which removes the types for which the statement is true), P1 … (`set_priors()`), C1 … (confounding). For each: the claim in words, the nodal types it removes or weights, and its **ground** (theory, expert belief, experimental or prior data, `model-justification.md`). A restriction with no ground is flagged for `/qualstack:model-review`; prefer a quantitative prior ("negative effects are rare", e.g. small prior mass) over a logical zero when the ground is soft.
7. **Write `code/01-model.R`** from `${CLAUDE_PLUGIN_ROOT}/skills/causal-model/assets/01-model-template.R`: statement, restrictions, priors, `set_parameters(param_type = "prior_mean")`, the QUERIES and GIVENS block (from `.qualstack/queries.md` if it exists; otherwise the primary query from the research question, to be refined by `/qualstack:query-design`), `SEED` from `model.seed`. Run `Rscript code/01-model.R` from the project root and read `output/tables/nodal-types.csv` and `output/tables/prior-queries.csv`.
8. **Check for unintended structure** (`model-justification.md`) and record each result in `model.md`:
   - the implied prior on the primary query, overall and in each case type: does it match what the researcher believes? Flat priors on X → M → Y put .125, not .25, on a positive X → Y effect; adjust priors deliberately, not by accident;
   - every answer already fixed by the restrictions (probability exactly 0 or 1): an assumption to report, not a finding;
   - every clue's causal position (mediator, moderator, alternative cause, symptom, surrogate) and whether the model makes it informative for an untrained single case (it often does not: `bayesian-process-tracing.md`, "A DAG alone gives nothing");
   - for any test type the theory claims for a clue ("K is a smoking gun"), whether the model reproduces it.
9. **Write `.qualstack/model.md`**: statement and a rendered ASCII DAG; node table (name, definition, time stamp, range); arrow audit; restriction and prior table (label, statement, types affected, ground); confounding table; nodal-type counts; implied priors; restriction-determined answers; clue positions; open questions for `/qualstack:model-review`. Set `model.statement` in `.qualstack/config.yaml` and append a `decisions` line for every contested choice.

## Outputs

- `code/01-model.R`; `output/models/model.rds`, `output/models/queries.rds`, `output/tables/nodal-types.csv`, `output/tables/prior-queries.csv`.
- `.qualstack/model.md`; `model.statement` in config.
- Summary block: the statement, nodal-type counts, restrictions with grounds (and any without), the implied prior on the primary query, answers fixed by assumption, next step.

## Anti-patterns

- **Drawing the argument instead of the knowledge base.** A DAG with only the favored path asserts independencies nobody believes.
- **Unlabeled restrictions.** Monotonicity assumed in code but never defended in prose.
- **Restrictions chosen for their consequences.** A restriction added because it makes a clue informative is the conclusion smuggled into the premises.
- **Coarse time stamps.** If the order of two nodes is not a fact, the arrow between them is not either.
- **Editing the model after seeing the case evidence without a record.** Every revision gets a `decisions` line and a re-run of `/qualstack:model-review`.

## Next

`/qualstack:query-design` (if the queries are not yet sharp), then `/qualstack:model-review`. After any revision: re-run `/qualstack:model-review`; the design memos built on the old model are stale (`/qualstack:paper-status` lists them).
