---
name: referee-mock
description: Mock first-round referee report on a qualitative or multi-method paper from one of four reviewers such work actually draws — a historian or area specialist (sources, historiography, missed archives, anachronism), a process-tracing methodologist (Bayesian logic, test labels versus probative value, likelihoods set after the fact, dependence among sources), a quantitative skeptic (case selection, selection on the outcome, generalizing from one case, external validity), or the editor (fit, contribution per page, desk-reject risks) — calibrated to the target journal, with summary, major and minor comments, and an honest recommendation saved as a verdict in the review cache. Use when a draft is near submission-ready, or the user asks how reviewers will react.
argument-hint: "[historian|methodologist|quant-skeptic|editor]"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash(date *)
  - Bash(git rev-parse *)
  - Bash(wc *)
---

# /qualstack:referee-mock

**Stage:** write (pre-submission) · **Voice:** referee, anchored to `voice.reviewer_style` in `.qualstack/config.yaml`

When every section exists and the draft is "submission-ready": the last line of defense before real reviewers, who for case-based work come from different tribes and read the same paper for different failures. Be the reviewer the author fears, not the one they hope for.

`$ARGUMENTS` picks the persona (default `methodologist`; unrecognized → default):

| Persona | Presses hardest on | Never |
|---|---|---|
| `historian` | The area specialist or historian of the case: who produced each decisive source, when, and for whom; the historiography and whose account the paper adopts; archives not consulted (the other side's, the series that would record the clue); anachronism (later testimony for earlier motives, categories the period did not use); translation; facts and dates | Redoes the Bayesian arithmetic (flags it at most) |
| `methodologist` | Process tracing and the causal model: the query, the DAG and its restrictions, priors, test labels versus probative value, likelihoods set after the evidence was seen, dependence among sources, mediator evidence offered for a path, uninformative versus informative case, the counterfactual tables | Critiques prose style |
| `quant-skeptic` | Case selection and its rule, selection on the outcome, generalizing from one case, scope and external validity, how far the priors drive a non-identified answer, coding reliability, confounders left out of the model | Asks for p-values, standard errors of a case-level probability, or "more cases" without saying which and what they would show |
| `editor` | Contribution per page, fit with the target journal, "a case of what?" on page one, headline against evidence, length against the fetched cap, the transparency appendix the journal's recent qualitative articles carry, anonymization | Proposes a new research design |

## Procedure

1. **Load** `paper/main.tex` (or `main.qmd`) and every file in `paper/sections/`; `output/tables/` and `output/figures/` to verify the numbers in the prose; `evidence/log.csv` (type, date, author, access, reliability; never the participant files in `evidence/raw/`, never `restricted/`) to verify `\ev{}` citations and profile the evidence; `.qualstack/config.yaml` for the target journal, which sets the bar, and `design.type`; the latest `.qualstack/journal-fit-*.md` for fetched caps and policies.
2. **Prior reports** in `.qualstack/review-cache/`: if this persona reviewed an earlier draft, say what improved and what did not; list coauthor-review failures still standing.
3. **Reviewer style.** If `voice.reviewer_style` names an installed skill, use it for voice, tone, and structure; otherwise read `${CLAUDE_PLUGIN_ROOT}/references/referee-report-conventions.md` (structure, the layer table, persona lanes, resolvable asks, calibration).
4. **Persona ammunition.** Raise every fault in the listed tables that the paper does not address:
   - `historian`: "What referees fault", "Secondary sources and historiography", and "Chronology discipline" in `${CLAUDE_PLUGIN_ROOT}/references/evidence-and-sources.md`. Profile the evidence from `evidence/log.csv`: counts by `type`; each decisive item's `date` against the event it attests (memoirs and interviews carrying motives at the time); the `secondary` items and whose account they represent; the archives named in `design` against those that would record each clue; quoted translations without originals.
   - `methodologist`: "What referees fault" in `${CLAUDE_PLUGIN_ROOT}/references/bayesian-process-tracing.md` and `${CLAUDE_PLUGIN_ROOT}/references/causal-models.md`. Check concretely: each test label against its two likelihoods; the date each likelihood was fixed (`.qualstack/clue-plan.md`, `prereg/prereg.md`) against the `accessed` date of the evidence that resolved the clue; items whose `notes` say `derivative of` cited as independent corroboration; the restrictions the answer leans on; each case-level number's question.
   - `quant-skeptic`: "What referees fault" and the selection-rule table in `${CLAUDE_PLUGIN_ROOT}/references/mixed-methods.md`; the selection log in `.qualstack/case-selection.md`; the latest `.qualstack/robustness-*.md` (priors, restrictions, leave-one-case-out, confidential evidence set to NA). Ask every large-N question in the paper's terms: how far the priors drive the answer, not where the standard errors are.
   - `editor`: the target journal's row, the qualitative fit signals, and the desk-reject risks in `${CLAUDE_PLUGIN_ROOT}/references/journals.md`; the complaints table in `${CLAUDE_PLUGIN_ROOT}/references/writing-conventions.md`; "Anonymous review" in `${CLAUDE_PLUGIN_ROOT}/references/transparency-and-ethics.md`. A cap or policy not recorded in a journal-fit memo is "to be checked against the current guidelines", never a remembered number.
5. **Write the report** in the standard structure:
   - **Summary** (one paragraph): the query, the cases, the evidence base, and the claim with its posterior, in the reviewer's words, not the abstract's.
   - **Major comments** (3–6): problems that change the headline if unaddressed; each says what is wrong, why it matters for the inference, and what would resolve it (a clue to seek and what it would show under each hypothesis, a series to consult, a node recoded under the rival historiography and rerun, a robustness run, a resized claim).
   - **Minor comments** (5–15): clarity, presentation, missing citations, table and figure issues, a date or name to verify; each cites a section, table, or evidence ID.
   - **Recommendation**: `Reject`, `Major revisions`, `Minor revisions`, or `Accept`, consistent with the majors.
   Never ask for a participant's identity, for transcripts beyond what consent covers, or for a withheld place; ask for the access route and the robustness run without the item. Never assert a historian, archive, or date that appears nowhere in the paper or `lit/`; phrase it as a question to verify.
6. **Save** to `.qualstack/review-cache/referee-mock-<YYYY-MM-DD>.md` (`date +%Y-%m-%d`; if today's file exists from another persona, add `-<persona>`). Header, in this order: `Verdict: <accept|minor-revision|major-revision|reject>` first (`/qualstack:paper-status` reads the first line that says "verdict" or "recommendation"), persona, target journal, draft commit (`git rev-parse --short HEAD` in a git repository) or word count (`wc -w paper/sections/*`), date. The same `Verdict:` line ends the memo.

## Outputs

- `.qualstack/review-cache/referee-mock-<date>.md`: the report and its verdict.
- Summary block: the top 3 major comments, the recommendation, and the persona to run next.

## Anti-patterns

- **Sycophancy.** No major comment means you did not read hard enough.
- **Generic comments.** "More theory", "more interviews"; cite the section, clue, or evidence ID and say what the new evidence would show.
- **The quantitative template.** Significance, standard errors, and "n = 1" as a verdict misread a case-level Bayesian inference.
- **Breaking persona.** The historian does not redo the Bayes; the methodologist does not critique prose; the editor does not redesign the study.
- **Invented expertise.** A historiography, archive, or date the reviewer cannot point to; ask, do not assert.
- **Asking for a different paper.** A large-N study or another country is the editor's call, not a major comment.
- **Asking past consent.** Names, transcripts, the village.

## Next

`Major revisions` or worse → `/qualstack:evidence-audit` and `/qualstack:robustness`, plus the skill each major comment points to (`/qualstack:process-trace`, `/qualstack:source-critique`, `/qualstack:case-select`, `/qualstack:clue-select`), then revise with `/qualstack:draft-section`; after revision, re-run with a different persona to triangulate. `Minor revisions` or `Accept` → `/qualstack:journal-fit`, then `/qualstack:submission-pack`.
