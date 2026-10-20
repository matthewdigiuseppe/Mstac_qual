# Causal models for case-based research

Read by `/qualstack:theory-build`, `/qualstack:causal-model`,
`/qualstack:query-design`, `/qualstack:model-review`,
`/qualstack:process-trace`, and `/qualstack:referee-mock`. It condenses
Humphreys & Jacobs (2023, chs. 1–4 and 6), cited as II with section numbers:
what a causal model is, how to draw and read one, how a theory becomes a
model, and how to ask a causal question of it. CausalQueries syntax is in
`causalqueries-cookbook.md`; how evidence then moves the answer is in
`bayesian-process-tracing.md`.

## Why write a model at all

- The probative value of within-case evidence "always depends on researcher
  beliefs that come from outside the case in question" (II §1.1.2). A causal
  model is those beliefs written down, so that they can be inspected,
  disputed, and checked.
- The workflow is **form, update, query**: build the model, update it with
  whatever data exist (one case or many, qualitative or quantitative), then
  ask it the question. The model, not an estimator, is what learns (II ch. 1).
- "Using a model does not require a commitment to it" (II §1.3): the model is
  a map, and `/qualstack:robustness` checks how much the answer depends on
  where the map could be wrong.

## The objects

| Object | Meaning | Note |
|---|---|---|
| Node | A variable, with a range; in CausalQueries every node is binary | A concept becomes a yes/no property of a case at a stated time (`concepts-and-coding.md`) |
| θ^J, the **nodal type** | How node J responds to every combination of its parents' values | The thing a case-level causal question is about; not noise (II §2.2.2.2) |
| **Causal type** | One nodal type per node: everything there is to know about a case | Unobservable; data narrow it down |
| λ^J | Population shares of J's nodal types | Fixed inputs in single-case work; learned from many cases (`mixed-methods.md`) |
| Restriction | A nodal type ruled out (λ = 0) | Certainty that a pattern never occurs |
| Prior | A distribution (Dirichlet) over λ | Degrees of belief among the types that remain |
| Confounding (`A <-> B`) | Nodal types of A and B may be correlated | Drawn as a two-headed arrow |

**Reading nodal types.** With one parent X, θ^Y_{ij} gives Y when X = 0, then
Y when X = 1:

| Type | Y if X=0 | Y if X=1 | Meaning |
|---|---|---|---|
| 10 | 1 | 0 | X has a negative effect ("adverse") |
| 01 | 0 | 1 | X has a positive effect ("beneficial") |
| 00 | 0 | 0 | Y is 0 whatever X ("chronic") |
| 11 | 1 | 1 | Y is 1 whatever X ("destined") |

With two parents the four digits give Y at (0,0), (1,0), (0,1), (1,1), the
first-listed parent changing fastest: 0001 is "Y only if both" (complements),
0111 "Y if either" (substitutes), 0101 "Y if and only if the first parent".
Which parent is first follows the model's internal order; print the nodal
types and check before reading a label.

**Counting.** A binary node with n binary parents has 2^(2^n) nodal types: 4
for one parent, 16 for two, 256 for three, 65,536 for four. A model whose
outcome has four parents is not usable without heavy restrictions; that count
is the first thing `/qualstack:causal-model` prints.

## Drawing the DAG: the rules (II §2.3.1)

1. **Directed and acyclic.** Draw A → B if and only if A can have a direct
   effect on B. Feedback is time-stamped: A1 → B → A2, never A ↔ B.
2. **Missing arrows are the strong claims.** An arrow says an effect is
   *possible*; a missing arrow says there is *no chance* of a direct effect,
   not merely no average effect. The model with fewer arrows is the stronger
   one.
3. **No excluded common causes.** Any cause of two nodes in the model must be
   in the model, or the two nodes joined by `<->`. A factor may be left out
   only if it affects at most one node.
4. **The whole knowledge base, not the argument.** If the argument is
   X → M → Y but X could reach Y by any other route, draw X → Y too; otherwise
   the DAG asserts that X is independent of Y given M, which the researcher
   does not believe (II ch. 3).
5. **Granularity is a choice.** Mediators can be omitted, but keep the ones
   that could be observed in a case: they are where the leverage is.
6. **A DAG shows no functional form.** Whether effects are monotonic,
   interactive, necessary, or sufficient is stated separately, as
   restrictions and priors.

**Audits every model owes its reader:** for every absent arrow, the reason
there is no chance of a direct effect; for every pair of root nodes, whether
anything causes both; for every hypothesized path, the other routes.

## Reading conditional independence (II §2.3.2)

| Structure | Unconditionally | Given the middle node |
|---|---|---|
| Chain A → B → C | Information flows | Blocked |
| Fork A ← B → C | Information flows | Blocked |
| Collider A → B ← C | Blocked | **Opened** (also by observing any descendant of B) |

Two node sets are **d-separated** given what is observed when every path
between them is blocked. This decides what can be learned from what: a clue
d-separated from the query, given what is already known, cannot be
informative (`bayesian-process-tracing.md`). Every d-separation the DAG
implies is also a testable claim about data (`model-justification.md`).
Selecting or conditioning on a collider (cases chosen because the outcome
occurred and some other condition held) manufactures dependence between its
causes.

## From theory to model

**Recipe** (II ch. 3, ch. 6): name the nodes and ranges; draw the DAG with
the whole knowledge base; audit missing arrows and common causes; decide where
the model starts (root nodes with no common causes); state the functional
claims (monotonicity, necessity, sufficiency, interaction) as restrictions or
priors; put a distribution over every θ.

- **A theory is a lower-level model that implies a higher-level one**
  (II §6.1). Adding a mediator splits θ^Y into θ^K and a new θ^Y; adding a
  moderator extracts a named condition from θ^Y. Lower-level models make
  stronger, more specific claims and need their own defense.
- **Consistency across levels.** If X → K → Y theorizes X → Y, the share of
  positive X → Y effects must equal λ^K_01·λ^Y_01 + λ^K_10·λ^Y_10 (linked
  positive steps plus linked negative steps). A higher-level prior that the
  lower-level beliefs cannot produce is incoherent (II §6.1.2).
- **Flat is not neutral across levels.** Flat priors on X → M → Y imply an
  X → Y effect of either sign a quarter of the time, not half, and a
  positive effect an eighth of the time, not a quarter (II §9.2.2.6, ch. 17).
- **Verbal arguments map onto types.** "Retrenchment only if it is on the
  agenda *and* blame can be avoided" is θ^R = 0001 (II §3.1, Pierson);
  "never a negative effect" removes type 10; "X is necessary for Y" removes
  every type with Y = 1 when X = 0. Putting all probability on the theory's
  types is complete certainty; a real prior spreads weight to the types that
  would embarrass the theory.
- **Formal theory** fits too (II §6.3): a game becomes nodes for primitives
  and actions with the equilibrium as the causal function, and the model
  forces the questions the verbal version skips: what selects among multiple
  equilibria, what happens when actors are not rational.

## Simplifying without lying (II §2.3.3)

- Dropping a common cause: join its children with `<->`.
- Dropping a mediator: draw the direct arrow it carried.
- Dropping a root node with a single child: free.
- Every simplification changes what the remaining θ terms mean: say how.

## Queries: what exactly is being asked (II ch. 4)

| Family | Question | Potential outcomes | CausalQueries |
|---|---|---|---|
| Case-level effect | Would changing X change Y in this case? | Y(X=1) ≠ Y(X=0) | `"Y[X=1] != Y[X=0]"` |
| Attribution | Given X = 1 and Y = 1, did X cause Y? | Pr(Y(X=0) = 0 given X=1, Y=1) | `"Y[X=1] > Y[X=0]"`, given `"X==1 & Y==1"` |
| Prevention | Given X = 1 and Y = 0, did X prevent Y? | Pr(Y(X=0) = 1 given X=1, Y=0) | `"Y[X=1] < Y[X=0]"`, given `"X==1 & Y==0"` |
| Average effect | By how much would Y change if X changed for everyone? | λ^Y_01 − λ^Y_10 | `"Y[X=1] - Y[X=0]"` |
| Conditional average | The average effect where W = 1 | | `"Y[X=1] - Y[X=0]"`, given `"W==1"` |
| Path (indirect, X held at x) | Did X's effect run through M? | Y(x, M(1)) vs Y(x, M(0)) | `"Y[X=1, M=M[X=1]] > Y[X=1, M=M[X=0]]"` |
| Direct | The effect with M held where X=0 would put it | Y(1, M(0)) vs Y(0, M(0)) | `"Y[X=1, M=M[X=0]] > Y[X=0, M=M[X=0]]"` |
| Actual cause | In an overdetermined or preempted sequence, which condition produced Y? | Halpern–Pearl definition | encode the preemption in the model (II §4.6.1) |

Rules that follow:

- **Effect is not attribution.** That poison would make you sick does not
  mean you are sick because of poison. Explaining an observed outcome is an
  attribution query, conditioned on what was observed (II §4.2).
- **A cause, not the cause.** Causes are not rivals: several conditions can
  each have been difference-makers for one outcome (II §2.1.2).
- **A path is a counterfactual claim.** Finding that M occurred does not show
  that X worked through M; the query is about how M would respond to X and Y
  to M (II §4.4). Path effects can exist without an overall effect.
- **Say which indirect effect**: with X held at 0 or at 1. Total =
  Direct 0 + Indirect 1 = Direct 1 + Indirect 0.
- **Actual causes need not be counterfactual causes.** Tracing "how it
  actually happened" can identify a producing cause whose removal would not
  have changed the outcome (the bomb and the invasion; Suzy and Billy). Say
  which concept a claim uses (II §4.6.1).
- **A probability is a belief about a yes-or-no estimand.** "0.7 that X
  caused Y" describes the analyst's uncertainty, not a 70% effect.

## Counterfactual discipline

- The counterfactual is a **controlled change in the same case**, everything
  else held at what it was: not a comparison with cases that happened to have
  a different X (II §2.1, the Switzerland example).
- State it concretely: which X, changed to what, when, with what held fixed.
  Fearon (1991) and Tetlock & Belkin (1996): a counterfactual must be
  cotenable (the change does not require other changes that would themselves
  affect the outcome) and minimal (as small a rewrite of history as the
  question allows). A counterfactual that needs a different world is not
  about this case.
- The model makes the counterfactual explicit: the query string *is* the
  counterfactual, and the nodal types say what would have happened.

## What referees fault

| Complaint | Fix |
|---|---|
| The DAG draws only the favored path | Add the routes the knowledge base allows; justify each missing arrow |
| Arrows treated as claims that effects always operate | Arrows mean possible effects; functional claims are restrictions and priors |
| A confounder named in the text but missing from the model | Add the node or `<->` |
| "X explains Y in case j" with no stated counterfactual | The attribution query, conditioned on observed values |
| Mechanism claimed because the mediator occurred | The path query and the evidence on M's and Y's responses |
| Monotonicity or necessity assumed silently | List every restriction with its justification; test sensitivity |
| A model with 4+ parents per node and no restrictions | Simplify by the rules above, or restrict |
| Causes treated as rivals ("equality or international pressure?") | Ask about each cause's difference-making separately |
