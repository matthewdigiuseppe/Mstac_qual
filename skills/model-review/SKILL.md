---
name: model-review
description: Prosecutes the causal model before any design or fieldwork depends on it — the DAG against the drawing rules (missing arrows, common causes, time order), the ground of every restriction and prior, whether anything makes the planned clues informative ("nothing from nothing"), priors and likelihoods that come from one model, unintended structure from added detail, answers fixed by assumption, the testable independencies the model implies and the data that could test them, and the rival models robustness must carry — with a pass / conditional pass / fail verdict. Use after /qualstack:causal-model and /qualstack:query-design, after any model revision, or when the user asks whether the model is defensible.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(Rscript *)
  - Bash(date *)
---

# /qualstack:model-review

**Stage:** model · **Voice:** design-critic

The prosecution of the model; the user is the defense. Every case-level conclusion the project draws will be "a conditional application of a model" (Humphreys & Jacobs 2023, §15.1), so the model is where a hostile referee will aim. Graded on whether such a referee could add a charge you missed.

## Procedure

1. **Load** `.qualstack/theory.md`, `.qualstack/model.md`, `.qualstack/queries.md`, `code/01-model.R` (the code is the truth; the memo is the claim), `output/tables/prior-queries.csv`, `output/tables/nodal-types.csv`. Read `${CLAUDE_PLUGIN_ROOT}/references/model-justification.md` and the DAG rules in `${CLAUDE_PLUGIN_ROOT}/references/causal-models.md`.
2. **Structure charges.** One row each: every missing arrow without a reason why a direct effect is impossible; any pair of nodes with a plausible unmodeled common cause (add the node or `<->`); arrows whose direction depends on coarse time stamps; the favored path drawn without the other routes the knowledge base allows; nodes with more than three parents left unrestricted; nodes without a definition a coder could apply.
3. **Ground of every restriction and prior.** For each label (R1, P1, C1 …): theory, expert belief, experimental or prior data, or none. "None" is a charge. Ask of each: would the author accept a quantitative prior (small mass) instead of a logical zero? Restrictions that exist to make a clue informative are the conclusion in the premises.
4. **Nothing from nothing.** For each planned clue: what in the model makes it informative for the primary query in an untrained single case? Run the screen and table (copy `${CLAUDE_PLUGIN_ROOT}/skills/clue-select/assets/clue-diagnosis.R` to `code/clue-diagnosis.R`; `qs_clue_screen`, `qs_clue_table` with `using = "parameters"`). A clue whose probative value is zero under the model will be zero in the paper; if the author expects it to matter, the model is missing the belief that makes it matter, or the belief must be learned from cross-case data (say which).
5. **Coherence.** Priors on hypotheses and likelihoods of clues must come from one model; any hand-set Pr(K | H) next to a model-based prior is a charge. A claimed mediator smoking gun in a chain model is a charge unless a moderator or restriction delivers it (`model-justification.md`).
6. **Unintended structure.** The implied prior on the primary query against what the author believes (flat priors on detail shift it); claimed test types re-derived after every added node; answers fixed at 0 or 1 by restrictions (assumptions, to be reported as such).
7. **Testable implications.** Copy `${CLAUDE_PLUGIN_ROOT}/skills/robustness/assets/model-checks.R` to `code/model-checks.R` and list `qs_implied_independencies(model)`. For each, the data that could test it, and whether the data the project will have are selected on a collider (clues gathered only where the outcome occurred cannot test unconditional independencies).
8. **Rival models.** Name the variants `/qualstack:robustness` must run: each soft restriction dropped or softened to a quantitative prior; each plausible missing arrow added; each exclusion relaxed with `<->`; the rival theories as alternative models. Name the assumption most in need of defense.
9. **Verdict.** **Pass** (every charge answered; restrictions grounded; clues informative for a stated reason), **Conditional pass** (named fixes: a missing arrow, a softened restriction, a measurement node; list them), **Fail** (clues uninformative under the model with no plan to learn their value, ungrounded restrictions doing the work, or a structure the theory contradicts: return to `/qualstack:causal-model`).
10. **Save** `.qualstack/model-review-<YYYY-MM-DD>.md`: the line `Verdict: pass | conditional | fail` comes first, right under the title, because `/qualstack:paper-status` reads the first line that mentions a verdict; the words "verdict" and "recommendation" appear on no other line.

## Outputs

- `.qualstack/model-review-<date>.md` — structure charges, restriction-ground table, clue informativeness (screen and table), coherence findings, unintended structure, implied independencies and their testability, rival-model list, the assumption most in need of defense, verdict.
- `code/clue-diagnosis.R`, `code/model-checks.R` (copied assets).
- Summary block: verdict, top three charges with fixes, rival models for robustness.

## Anti-patterns

- **Reviewing the memo, not the code.** The restriction in `01-model.R` is the one under review.
- **Generic charges.** "Confounding may exist" is not a charge; "elite splits plausibly cause both repression and defection, and the model has no node or `<->` for it" is.
- **Accepting "theory says so" for a restriction the theory does not entail.**
- **Defending instead of prosecuting.**

## Next

Fail → `/qualstack:causal-model`. Pass or conditional (with fixes made) → `/qualstack:design-research`. Rival models carry forward to `/qualstack:robustness`.
