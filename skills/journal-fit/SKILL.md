---
name: journal-fit
description: Scores 6-8 candidate journals for a qualitative or multi-method paper on impact, fit with the paper's conversation, receptivity to case-based and process-tracing work (coded from the last three years of articles, not reputation), length fit for the case narrative, turnaround, desk-reject risk, and the transparency policy for confidential evidence, with every cap and policy fetched from the journal's current guidelines and dated, then sets reach, realistic, and backup in config. Use when the user asks where to submit, which journal fits the paper, whether a case study belongs at a generalist, a field, an area, or a historians' journal, or whether the project is an article or a book.
argument-hint: "[journals to include]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(date *)
  - Bash(wc *)
  - Bash(texcount *)
  - WebFetch
  - WebSearch
---

# /qualstack:journal-fit

**Stage:** submit · **Voice:** editor

When the manuscript has passed `/qualstack:evidence-audit`, `/qualstack:coauthor-review`, and `/qualstack:referee-mock`. Pick a journal, a backup, and the backup's backup. No cap or policy is stated from memory: word limits, appendix rules, data and transparency policies, open-access terms, and turnaround are fetched from the journal's current pages and dated, or recorded as unknown.

`$ARGUMENTS` (optional) names journals the user wants scored; they join the candidate set.

## Procedure

1. **Load** the abstract (`paper/sections/abstract.tex` or `.qmd`); the contribution and the primary query (`.qualstack/research-question.md`, `.qualstack/queries.md`); the positioning (`.qualstack/lit-map.md`: where the must-engage works appeared); `design.type` and `model.formal` from `.qualstack/config.yaml`; the evidence profile (rows of `evidence/log.csv` by `type` and by `access`; the `confidential` and `archive-restricted` counts drive the policy gate); the length the paper needs (`texcount -inc -total paper/main.tex`, else `wc -w paper/sections/*`, with `paper/sections/cases.*` counted apart). `Read ${CLAUDE_PLUGIN_ROOT}/references/journals.md`.
2. **Candidate set of 6–8** from the reference: the subfield table, the regional table when the cases sit in one region, Methods only when the method is the point, and the "Matching paper type to venue" row for `design.type`. Cover an aspirational generalist, an aspirational field journal, a realistic field journal with good fit, an area or topic journal where the case is core, and a backup with low desk-reject risk; a historians' or methods journal only when the framing is in that register.
3. **Code recent volumes before scoring.** For each candidate, WebSearch / WebFetch the last three years of research articles (skip editorials, symposia, book reviews) and code method (quantitative, formal, case-based, multi-method, historical, interpretive), evidence (archives, interviews, fieldwork, secondary), and appendix practice (evidence tables, interview-methods tables, active citation, ATI, QDR deposits); note whether the must-engage authors publish there and what the current editors' statement asks for. The coding beats remembered reputation.
4. **Fetch the rules**, each with the page it came from and the fetch date: word cap and what counts toward it (notes, references, appendices); online-appendix policy; abstract cap; anonymity of review; the data and transparency policy for qualitative evidence (deposit required, encouraged, or silent; the exemption route for confidential human-subjects data; pre-publication verification); AI-use disclosure; a results-free or registered-report track if `design.prereg` is true. A figure the journal does not publish is "unknown", never a guess.
5. **Score** each candidate on the reference's "Scoring dimensions" (impact, fit, method receptivity, length fit, review turnaround, desk-reject risk; transparency policy as a note), and list the reference's desk-reject risks that apply, each as one line the user can fix before submitting.
6. **Policy gate.** No journal enters a tier while its policy has no route for the paper's confidential evidence. Where the policy is ambiguous, draft a pre-submission query to the editor naming the constraint (counts by access tier, what consent allows, what can be deposited with access controls) and keep it in the memo.
7. **Book or article.** If the argument needs several full case narratives at archival depth, say so, and score the article version: the theory plus one decisive case, or the cross-case pattern plus compressed evidence.
8. **Tier the top three** by the reference's rules: **Reach** (highest impact with fit and method receptivity ≥ 3), **Realistic** (highest fit × receptivity × low desk-reject risk), **Backup** (low desk-reject risk, length fit ≥ 4, a policy the evidence meets).
9. **Write** `.qualstack/journal-fit-<YYYY-MM-DD>.md` (date from `date +%Y-%m-%d`): the recent-volume coding, the scoring table with a source and fetch date in every policy cell, the applicable desk-reject risks, the tiers, any draft editor query. Set `target_journals` in `.qualstack/config.yaml` to the three journals in submission order (`tier: 1` is submitted first; `why:` opens with reach, realistic, or backup, then the one-line reason) and append a dated line to `decisions:`.
10. **Recommend** the submission journal in two sentences, tied to the framing chosen in `/qualstack:abstract-shotgun` and to the lead time its policy implies (deposit, transparency appendix, anonymization).

## Outputs

- `.qualstack/journal-fit-<date>.md`; `.qualstack/config.yaml` (`target_journals`, a `decisions:` line).
- Summary block: the three tiers with one-line justifications, the recommended journal, the policy steps to start now (deposit, appendix, editor query).

## Anti-patterns

- **One-tier strategy.** Always reach, realistic, backup; fieldwork-based papers take too long to bet on one journal.
- **Impact-only ranking.** 5/5 impact with 1/5 fit has zero expected value.
- **Remembered caps and policies.** Fetch and date them; positions on qualitative data moved with JETS, DA-RT, and the Qualitative Transparency Deliberations, and still differ by journal.
- **Receptivity from reputation.** Code the volumes; one process-tracing article a decade ago is not receptivity.
- **The wrong register.** A hypothesis-testing paper at a historians' journal, a substantive paper at a methods journal, narrative history without a theoretical payoff at a political science journal.
- **Ignoring the confidential evidence.** A journal that requires full deposit with no exemption route is not an option for interview-based work.
- **A book in an article's clothes.** Say so, and score the article version.

## Next

`/qualstack:submission-pack`, then `/qualstack:cover-letter` for the chosen journal. `/qualstack:referee-mock` with the editor persona stress-tests fit beforehand; `/qualstack:archive` early if the journal wants a deposit at submission; `/qualstack:draft-section appendix` if its recent qualitative articles carry evidence or interview-methods tables.
