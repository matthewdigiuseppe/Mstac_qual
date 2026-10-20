---
name: scope-challenge
description: Adversarial scope check for case-based work — is this an article, a book, or a footnote; one case or a comparison; is the case the contribution or the argument? Four challenges force the claim into one sentence, one query, and one decisive piece of evidence. Use when a project is sprawling, chapters keep multiplying, fieldwork keeps extending, the user cannot name the headline inference, or asks whether to split a project.
allowed-tools:
  - Bash(date *)
  - Read
  - Write
  - Grep
  - Glob
---

# /qualstack:scope-challenge

**Stage:** ideate · **Voice:** adversarial-advisor

For the project that keeps growing: a fourth case added "for variation", a second archive "to be safe", a narrative that has outrun its question, a suspicion that this is a book being forced into 12,000 words or an article inflated into a book.

## Procedure

Read `.qualstack/research-question.md`, `.qualstack/lit-map.md`, `.qualstack/theory.md` and `.qualstack/queries.md` if they exist, and every draft section in `paper/sections/`. Run the four challenges in order, one at a time in a live session and all four at once when the user is not in a live back-and-forth; write the results to `.qualstack/scope-challenge-<YYYY-MM-DD>.md`.

1. **One sentence, one query.** "State the claim in one sentence with no clauses, and say which causal query it answers: did X cause Y in this case, how often does X cause Y in this population, or through which path?" A project answering three queries for four cases is twelve projects. If the user cannot pick, the scope is wrong; push until they can.
2. **One decisive piece of evidence.** "Which single observation, if you found it, would most move a skeptic, and which would most embarrass you?" Qualitative articles are built around a small number of decisive clues; ten pages of narrative before the clue that matters means the narrative belongs in an appendix or a book.
3. **Cleavage test.** "If this had to be two outputs, where is the cut?" The usual cuts: the case-level claim versus the population-level claim; the descriptive reconstruction versus the causal argument; the method contribution versus the substantive one; the article versus the book. Finding the cut usually reveals one article and one chapter. The chapter is for later.
4. **Ship test.** "What would you cut to submit in four months, without new fieldwork?" Cases that add no leverage on the primary query, archives that would only corroborate, interviews past saturation in a category. That list is usually what should already be cut. If nothing can be submitted without another field trip, say so and say what the trip must find.

**Verdict:**

- **Tight** — survives all four. Continue as is.
- **Sprawl** — one or more fail. Recommend a specific cut: a case, a query, a body of evidence, a section.
- **Multi-output** — the cleavage test reveals two contributions, or a book. Recommend the split and which part is output one.

Soft verdicts produce sprawling projects; be opinionated.

## Outputs

- `.qualstack/scope-challenge-<date>.md` — the line `Verdict: tight | sprawl | multi-output` comes first, right under the title, because `/qualstack:paper-status` reads the first line that mentions a verdict; the words "verdict" and "recommendation" appear on no other line; then challenges and answers.
- Summary block: verdict + the single most important cut.

## Anti-patterns

- **Affirming the 60-page case narrative.** If it does not fit a journal article, say so, and say whether it is a book.
- **Cases as decoration.** A case that cannot change the answer to the primary query is not variation; it is length.
- **"Both projects are great."** Pick one; the other is next year's.

## Next

Sprawl → re-run `/qualstack:research-question` on the trimmed project. Multi-output → `/qualstack:qualstack-init` a sibling folder for output two. Unsure which cases carry leverage → `/qualstack:case-select` once a model exists.
