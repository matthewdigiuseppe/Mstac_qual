---
name: theory-build
description: Builds the argument as a causal account a model can encode — the query as a counterfactual, the mechanism in one sentence and its steps, nodes with time stamps, the arrows the whole knowledge base allows (not just the favored path), functional claims (monotonicity, necessity, sufficiency, interaction) stated as claims about types, rival explanations restated as mutually exclusive claims about the case, scope conditions, and the causal position of every candidate clue. Writes .qualstack/theory.md. Use after /qualstack:lit-map, when the user wants to state or formalize an argument, mechanism, or DAG, or asks what evidence would bear on their explanation.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# /qualstack:theory-build

**Stage:** model · **Voice:** theorist

After `/qualstack:lit-map`, before `/qualstack:causal-model`. A theory here is a lower-level model that implies a higher-level one (Humphreys & Jacobs 2023, ch. 6): its job is to say which causal relations are possible, which are not, and how the parts combine, precisely enough that evidence can discriminate. A story every observation fits is not yet a theory.

## Procedure

1. **Load** `.qualstack/research-question.md` (the query), `.qualstack/lit-map.md` (claims as candidate relations, rivals, the historiography), and for any argument that matters its converted text in `lit/md/` rather than the abstract. Read `${CLAUDE_PLUGIN_ROOT}/references/causal-models.md`.
2. **The query, restated** as a counterfactual about named variables: case-level effect, attribution, average effect, path, or actual cause. One primary query; others are secondary.
3. **Mechanism in one sentence** ("X caused Y because Z"), then Z unpacked into steps: who does what, in response to what, when, and what each step assumes (information, incentives, capacity, institutions). A sentence that will not come is usually two mechanisms or none.
4. **Nodes.** Every variable the account names, as a yes/no property of a case with a time stamp and a definition the coding rules can build on (`concepts-and-coding.md`). Include the observable steps of the mechanism (they are where the leverage is), the conditions under which it operates (moderators), the alternative causes, and the plausible common causes.
5. **Arrows: the whole knowledge base.** List every possible direct effect, including routes the argument does not use; an argument X → M → Y with X able to affect Y otherwise needs X → Y too. Then the **missing-arrow claims**, each with its reason, and the common-cause audit (anything that could cause two nodes goes in, or the pair is marked confounded). Draw the result as an ASCII DAG, earlier nodes left.
6. **Functional claims** as claims about types, separately from the arrows: "never a negative effect" (monotonicity), "X is necessary for Y" (no Y = 1 when X = 0), "only if both" (complements: 0001), "if either" (substitutes: 0111). For each: how sure, and why (theory, prior evidence, experiments, expert knowledge). Putting all weight on the theory's types is certainty; say which types would embarrass the theory and how plausible they are.
7. **Rivals.** The two to four accounts a reviewer will raise. Restate them as mutually exclusive claims about the case or population (Zaks 2017): "X was a difference-maker for Y here" vs. "it was not", or the combinations of two candidate causes; causes are not rivals by default. For each rival: the nodes and types it implies, and where it and the main account predict different observations.
8. **Counterfactual discipline** for case-level claims: the change to X, when, with what held fixed; cotenable and minimal (Fearon 1991; Tetlock & Belkin 1996). A counterfactual that needs a different world is not about this case.
9. **Clue positions.** For each observation the project might seek (a document, a decision, a statement, an event), its position relative to the query: mediator, moderator, alternative cause, symptom of the query, surrogate for X or Y, instrument; and its time stamp relative to Y. The positions decide when it can be informative (`bayesian-process-tracing.md`); an observation with no coherent position cannot enter the model (ch. 17).
10. **Scope.** The population the claims cover (cases where the outcome was possible: Mahoney & Goertz 2004), the period, the institutional setting, and where the mechanism should break.
11. **Formal theory**, if the argument is game-theoretic: primitives and actions as nodes, the equilibrium as the causal functions, and what selects among multiple equilibria (ch. 6.3).
12. **Save** `.qualstack/theory.md`; optionally stub `paper/sections/theory.tex` with the mechanism sentence and scope (full drafting is `/qualstack:draft-section theory`).

## Outputs

- `.qualstack/theory.md` — query, mechanism and steps, node table with time stamps, ASCII DAG with an arrow table (present and missing, each with a reason), functional claims with grounds, rivals table (implied types, discriminating observations), counterfactual statement, clue-position table, scope.
- Summary block: mechanism sentence, the rival a reviewer will raise first and the observation that separates it, the clue most likely to discriminate, next step.

## Anti-patterns

- **The favored path only.** No alternative routes, no common causes: the DAG asserts independencies no one believes.
- **Arrows as certainties.** An arrow says an effect is possible; functional claims are separate.
- **Rivals that are not rivals.** Two causes that can both have mattered are not competing hypotheses.
- **Mechanism by occurrence.** "M happened" is not "X worked through M".
- **Universal scope.** A theory that holds everywhere predicts nothing in particular here.

## Next

`/qualstack:causal-model`, then `/qualstack:query-design` and `/qualstack:model-review`.
