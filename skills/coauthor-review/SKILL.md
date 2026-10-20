---
name: coauthor-review
description: Simulated coauthor read of a full qualitative or multi-method draft — seven checks (the query stated as a counterfactual, the model shown and defended, clue likelihoods argued, evidence in each case that discriminates between rivals, inference sized to the posterior, selection on the outcome handled, sources a historian of the case would accept), then the biggest hole, biggest distraction, biggest opportunity, one structural suggestion, and a few line edits — as a skeptical methodologist, big-picture theorist, or junior reader, ending in a ready / revise / not-ready verdict in the review cache. Use on a complete draft before the mock referee, or when the user wants tough feedback on the paper.
argument-hint: "[skeptical-methodologist|big-picture-theorist|junior-reader]"
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
  - Bash(date *)
---

# /qualstack:coauthor-review

**Stage:** write · **Voice:** coauthor

On a complete draft, one round before `/qualstack:referee-mock`. The coauthor's name is on the paper too: catch the structural and inferential problems the author is too close to see and a referee will not miss, and say so without padding.

`$ARGUMENTS` picks the persona (default `skeptical-methodologist`; unrecognized → default):

| Persona | Presses on |
|---|---|
| `skeptical-methodologist` | The inference, line by line in `theory`, `cases`, `results`: the query, the model and its restrictions, where each likelihood comes from, dependence among sources, which question each case-level number answers, claims beyond the posterior |
| `big-picture-theorist` | The argument as a model: what the case is a case of, the mechanism as a path claim, rivals as alternative causes, scope conditions, the contribution beyond the case, engagement with the canonical works and the historiography |
| `junior-reader` | A graduate student new to the case and to Bayesian process tracing: where they get lost (nodal types, query strings, evidence IDs, uninformative versus informative case), people and acronyms never introduced, background the narrative assumes, claims buried in the cases |

## Procedure

1. **Load** `paper/main.tex` (or `main.qmd`) and every file in `paper/sections/`; `.qualstack/queries.md`, `.qualstack/model.md`, `.qualstack/case-selection.md`, `.qualstack/clue-plan.md`, the process-trace memos, `output/tables/queries.csv` and `case-answers.csv`; `evidence/log.csv` for types, dates, access, and reliability (not the files in `evidence/raw/`, never `restricted/`); earlier coauthor reviews in `.qualstack/review-cache/`, so you can say what changed since.
2. **Read end-to-end first**, for impressions, not corrections. Then read the complaints table in `${CLAUDE_PLUGIN_ROOT}/references/writing-conventions.md`; the skeptical methodologist also reads "What referees fault" in `${CLAUDE_PLUGIN_ROOT}/references/bayesian-process-tracing.md` and `${CLAUDE_PLUGIN_ROOT}/references/mixed-methods.md`; the theorist, the same table in `${CLAUDE_PLUGIN_ROOT}/references/causal-models.md`.
3. **Run the seven checks**, each `pass`, `weak`, or `fail` with the passage quoted (section and line); every persona runs them, in its own terms:
   1. **The query as a counterfactual.** Stated in `intro` and `theory` about a named cause in a named case or population, and the same query as `.qualstack/queries.md`?
   2. **The model shown and defended.** The DAG, the restrictions and priors with one-line justifications, the missing arrows defended, answers a restriction settles flagged as assumptions?
   3. **Clue likelihoods argued.** For each clue in `cases`, both likelihoods and their origin (the model, the dated clue plan, the source critique); no test label without them?
   4. **Evidence that discriminates.** In each case narrative, for each rival, a clue that would have come out differently, and what would have been concluded if it had; or does every observation fit the story?
   5. **Inference sized to the posterior.** Prior beside posterior, verbs within the hedging scale, the question each case-level number answers named?
   6. **Selection on the outcome.** The rule stated; cases traced only where the outcome occurred handled (untraced cases kept with clues missing, or the population claim narrowed); no generalization from one case except through the model?
   7. **Would a historian of the case object to the sources?** From `evidence/log.csv` and the text: retrospective sources (memoirs, interviews) carrying motives at the time; one historian's account doing the work; the other side's archives unconsulted; a decisive clue on a single source; quoted translations without originals. Judge from what the paper and the log show; never invent a historian or an archive.
4. **Three structural notes**, one paragraph each, quoting the specific section:
   - **The biggest hole**: where the inference is weakest (often a failed check).
   - **The biggest distraction**: what to cut, often the part the author is proudest of (the richest chronology, the archive find that moves no posterior).
   - **The biggest opportunity**: a missing clue, rival, framing, or analysis that would land the paper better. Specific.
5. **One structural suggestion:** a concrete reordering, restructuring, or refocusing; the one that changes the most, not ten.
6. **Three to five line edits:** quote the line, give the alternative, five words on why.
7. **Verdict:** `ready` (all seven checks pass: go to the mock referee); `revise` (a check is weak, or fails in the prose only: the numbers and evidence exist and the writing does not show them); `not-ready` (a check fails for want of analysis or evidence: likelihoods never set, no counterfactual table, selection unaddressed, a decisive clue on one source), naming the skill that fixes it.
8. **Save** to `.qualstack/review-cache/coauthor-<YYYY-MM-DD>.md` (`date +%Y-%m-%d`; if today's file exists from another persona, add `-<persona>`). Header, in this order: `Verdict: <ready|revise|not-ready>` first (`/qualstack:paper-status` reads the first line that says "verdict" or "recommendation", so earlier verdicts are cited below it, never above), then persona, date, sections read, and what changed since the last review. The same `Verdict:` line ends the memo.

## Outputs

- `.qualstack/review-cache/coauthor-<date>.md`: the seven checks, the structural notes, the suggestion, the line edits, the verdict.
- Summary block: verdict; the checks that failed or are weak; hole, distraction, opportunity; the one structural suggestion.

## Anti-patterns

- **Compliments.** A coauthor who says the draft is great is not coauthoring.
- **Marginalia as review.** Twenty line edits and no structural notes is a copy-edit.
- **Breaking persona.** The junior reader does not redesign the model; the theorist does not fix typos.
- **Fluency taken for evidence.** A vivid case in which nothing could have come out otherwise fails check 4, however well it reads.
- **Re-tracing the case.** Judge whether the paper shows the reader what the memos and logs hold; do not redo the process tracing.

## Next

`not-ready` → the skill named (`/qualstack:process-trace`, `/qualstack:clue-select`, `/qualstack:case-select`, `/qualstack:source-critique`, `/qualstack:robustness`), then re-run. `revise` → `/qualstack:draft-section` for each section named. `ready` → `/qualstack:referee-mock`, with a persona whose concerns differ from this one's.
