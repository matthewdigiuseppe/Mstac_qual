---
name: r-and-r
description: Builds the response-to-reviewers document for a qualitative or multi-method paper — every comment quoted verbatim, answered, and mapped to a located manuscript change, with an editor summary and change log — and routes the qualitative requests to the right analysis — more cases or evidence answered with the expected learning of the addition, model changes rerun as robustness, disputed readings of a source through source critique, new evidence logged and coded under the current rules before it enters. Use when the user has a revise-and-resubmit decision letter or referee reports to answer, or pastes reviewer comments and asks how to respond.
argument-hint: "[r1|r2|r3]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(date *)
  - Bash(git log *)
  - Bash(python3 *)
---

# /qualstack:r-and-r

**Stage:** submit (R&R) · **Voice:** the author addressing editor and reviewers

Decision letter in hand: plan the revision, then write the response that gets the paper across the line, not the one that argues with the reviewer. A request for more is answered with what the addition would teach, not with a field trip booked by reflex or a refusal by reflex.

`$ARGUMENTS` is the round (`r1` default; `r2`, `r3` for later rounds).

## Procedure

1. **Decision letter.** Read `submission/response-to-reviewers/r<N>-decision.md`; if absent or empty, create it, ask the user to paste the editor's letter and every report there, and stop until they do.
2. **Parse** into a numbered list: editor comments (top-level, then specific); each reviewer's comments numbered as the reviewer numbered them (R1.3); tag each `Major`, `Minor`, or `Editor`, and note the reviewer's register (area expert, methodologist, theorist), since the same words ask for different things from each. Where reviewers contradict each other, name the conflict and follow the editor's steer, or ask the editor.
3. **Triage by what each comment needs:**
   - **More cases or more evidence.** Before promising fieldwork, compute what the addition would teach: the expected learning on the primary query of the requested case (`/qualstack:case-select`) or clue (`/qualstack:clue-select`), beside the clues already sought, and its cost. Large and feasible: do it. Small: report the number and what was done instead ("the requested case would reduce expected posterior variance on the primary query by 3%; the archival series we added, by 22%"). A case added in revision enters the selection log in `.qualstack/case-selection.md` with the request as its reason, and the answers are reported with and without it.
   - **Drop or change a model assumption** (a restriction, a prior, no confounding, a missing node). Rerun with the reviewer's version through `/qualstack:robustness`; report the answers under both models in the appendix and the response. If the answer moves, the claim moves with it.
   - **A disputed reading of a source** (the memo means something else, the memoir is self-serving, the interviewee shades). `/qualstack:source-critique` states the likelihoods under the reviewer's reading; report how far the posterior moves under it; quote the source in the response only within its access tier.
   - **New evidence**, from any of the above: logged with `/qualstack:evidence-log`, coded under the current rule version with `/qualstack:code-evidence` before it enters the analysis. A rule that has to change is a rule change: new version, every case recoded on that node, both versions reported. If `design.prereg_url` is set, a dated addendum (`prereg/addendum-YYYY-MM-DD.md`) comes before the coding. Then rerun `/qualstack:analyze` and `/qualstack:robustness`.
   - **Requests to reveal confidential material** (names, transcripts): decline, citing the consent terms, and offer what can be checked: the coding-log rows, the answers without the confidential evidence, the QDR access route.
   - **Clarity** gets rewritten text; **misreadings** get the misread passage fixed in the manuscript, not only in the response, because the next reader will misread it the same way.
4. **Respond to each comment** in three parts, in this order:
   1. **Quote the comment verbatim** (blockquote), so response and comment stay aligned.
   2. **Respond.** Concede where conceding is right, defend where defending is right, never concede the contribution to placate. Keep "we appreciate / we agree" sparse; the structure is enough.
   3. **Point to the change**: section, page or paragraph, and the new text quoted. If nothing changed, say so and why.
5. **Editor opener:** thank the editor and reviewers once, briefly; the three most consequential changes; new evidence in one line (items added, by type and access tier); the structure of the document.
6. **Change log** table at the end: `Comment ID | Change made | Location`.
7. **Cross-checks:** every comment has a response; every claimed change cites a location; new numbers come from rerun code (`output/tables/queries.csv`) and sit in the appendix with a pointer, not loose in the response; new quotations pass `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-quotecheck`; `git log --since="<submission date>" --stat -- paper/ data/ code/` matches the changes claimed; the contribution sentence in abstract and introduction has not weakened against the submitted version unless the evidence moved it; the tone is the same for the reviewer you agree with and the one you do not.
8. **Save** `submission/response-to-reviewers/r<N>-response.md`; append `- "<date>: r<N> <decision>, response drafted"` to `decisions:` in `.qualstack/config.yaml` and set `paper.status: "r-and-r"`.

## Outputs

- `submission/response-to-reviewers/r<N>-decision.md` (created if missing) and `r<N>-response.md`.
- Summary block: response count, the most consequential changes, requests answered with expected learning instead of new fieldwork, open items (comments without a manuscript change).

## Anti-patterns

- **Conceding the contribution to placate R2.** Eroding the headline is worse than defending it well.
- **A field trip by reflex.** Another case or archive is promised only once its expected learning is known.
- **Evidence straight into the analysis.** Unlogged, uncoded, or coded under a rule written after it was read, it is an anecdote with a number attached.
- **Defending an assumption without rerunning it.** The reviewer's version, run and reported, settles more than a paragraph.
- **Combat.** Reviewers respond to deferential confidence.
- **Hand-waving.** "Addressed throughout the manuscript" is not a response; cite the page.
- **Rewriting comments.** Verbatim; the reviewer's words are the contract.

## Next

`/qualstack:evidence-audit` after any change to evidence, codes, or the model (it must pass again before resubmission); `/qualstack:referee-mock` to stress-test the response; `/qualstack:coauthor-review` on the revised manuscript; `/qualstack:submission-pack` before resubmitting.
