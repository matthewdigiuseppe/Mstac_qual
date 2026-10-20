---
name: chronology
description: Builds a dated, sourced chronology for one case — every event with its date precision and the evidence items that attest it, conflicts between sources resolved or flagged, the time stamps of the model's nodes in that case, and a check that the order the causal model requires (cause before mediator before outcome) is the order the evidence shows — plus the clues that depend on sequence, recollection marked apart from record, and critical junctures or sequence arguments where the theory makes them. Use when a case's documents are logged and before coding or process tracing, when the user asks for a timeline, wants to know what happened when or what actors knew at the time, or when sources disagree about dates or order.
argument-hint: "<case>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(date *)
---

# /qualstack:chronology

**Stage:** collect · **Voice:** historian

The chronology is the event-history map the causal model must survive (Waldner 2015): for every arrow, the cause settled before the effect, in this case, on this evidence. The historian puts no event on the line without an evidence ID, never infers order from what the argument needs, and writes "order unknown" when the dates cannot fix it.

## Procedure

1. **The case**: `$ARGUMENTS`, the case ID used in `evidence/log.csv` and `data/case-data.csv`; ask if it is missing. Read the log rows whose `cases` include it, each node's `Period` in `data/coding-rules.md`, the model statement (`code/01-model.R`, or `model.statement` in `.qualstack/config.yaml`), and `.qualstack/clue-plan.md`. `Read ${CLAUDE_PLUGIN_ROOT}/references/evidence-and-sources.md`, section "Chronology discipline". An existing `.qualstack/chronology-<case>.md` is extended, not rewritten; say which log IDs are new. Today: `date +%Y-%m-%d`.
2. **Participant material checks `privacy.ai_processing`.** Empty or `none`: dates from interviews and field notes come only from the log rows and what the researcher reports. `pseudonymized`: the pseudonymized files in `evidence/raw/` that have a log row. Never `restricted/`.
3. **Read in the order written** (Trachtenberg 2006): the contemporaneous record first, sorted by document date, asking at each point what the actors knew and expected; then the retrospective sources (memoirs, interviews, histories), labeled as recollection.
4. **The event table comes first in the file** (`/qualstack:viz` plots it): `| # | Date | Event | Evidence | Document dates | Lag | Record or recollection | Node | Note |`, one row per event.
   - **Date**: ISO 8601 at the precision the evidence gives (`1989-05-01`, `1989-05`, `1989`), `?` appended when inferred (basis in the note), `A/B` for a span. Nothing else goes in the cell: relative evidence ("before the 12 June vote") narrows a span (`1989-06-01/1989-06-11`) and is explained in the note. A date in another calendar is converted, with the original in the note.
   - **Event**: what was done or said, neutrally; never why.
   - **Evidence**: the attesting IDs, `;`-separated. Every row cites a logged item; a background fact from a secondary work means logging the work first with `/qualstack:evidence-log`.
   - **Document dates** and **Lag**: each item's own date, and the lag from event to document.
   - **Order**: same-precision dates fix no order. Only relative evidence does (a reply cites its letter; minutes refer to the earlier meeting); otherwise the note says `order unknown` for the rows concerned.
5. **Conflicts.** Sources that disagree on a date, an order, or whether an event happened are resolved by the precedence clause in the coding rules' header and the s and f from `/qualstack:source-critique` (contemporaneous over retrospective, the placed witness over hearsay), with the reason written down; or flagged unresolved, with both versions and the search that would settle it. A conflict that touches a node's value or order goes to `/qualstack:robustness` as rival codings.
6. **Node time stamps in this case.** For each node, its rule's window anchored to this case's dated event ("B: 24 months before the founding election, 1987-06/1989-06; anchor 1989-06-04, E002") and the first evidence that the node's value was settled, or `unknown`.
7. **Order check against the DAG.** `| Arrow | Cause settled | Effect settled | Order shown |` for every arrow A → B in the statement: `yes`, `no`, or `unknown` (dates of the same month, an undated document). A `no` means the window, the coding, or the model is wrong: send it to `/qualstack:coding-rules` to re-anchor the window or to `/qualstack:causal-model` to rethink the arrow; never re-date an event to fit. An `unknown` stays unknown, with the search that could fix it. A clue realized after the outcome is a symptom or surrogate, not a mediator.
8. **Sequence-dependent clues.** List the clues whose value or meaning turns on order (the concession before the protest; the memo before the decision), the date precision each needs, and whether the evidence reaches it. A clue whose required order is unknown is coded NA, or by its rule's hard-case clause, never as if the order were known.
9. **Anachronism.** Flag every motive, intention, or expectation attested only by sources written after the outcome was known. That is recollection, evidence of what was said later: motives at time t come from documents written by t, or are coded with the lower s and higher f that `/qualstack:source-critique` gives recollection.
10. **Junctures and sequences, where the theory claims them.** A critical juncture (Capoccia & Kelemen 2007) needs dated, contemporaneous evidence of when choice opened and closed, which options actors weighed, and how near the road not taken came. A sequence argument (Falleti & Mahoney 2015) needs dates fine enough to fix the order and duration of each step. Say which of these the evidence supplies and which it does not.
11. **Write** `.qualstack/chronology-<case>.md`: a header line (case, date built, IDs read, highest log ID considered), then the event table, node time stamps, the order check, sequence-dependent clues, conflicts, anachronism flags, junctures or sequences, and open questions, each with the search that would answer it.

## Outputs

- `.qualstack/chronology-<case>.md`.
- Summary block: events and items read; the precision mix (day, month, year, inferred, span); conflicts resolved and flagged; arrows in order, out of order, and unknown; sequence-dependent clues and whether their order is established; the next step.

## Anti-patterns

- **The narrative timeline.** Events placed where the story needs them, without an ID.
- **Same month, assumed order.** Two dates in May fix no order.
- **Document dates as event dates.** A memo's date is when it was written, not when the decision was taken.
- **Hindsight as record.** A 1995 memoir on the aims of 1989 is evidence about 1995.
- **Silent conflict resolution.** Choosing the version that fits without saying so.
- **Re-dating to fit the DAG.** An order failure is a finding about the coding or the model.

## Next

Arrows out of order → `/qualstack:coding-rules` or `/qualstack:causal-model`. Order established → `/qualstack:code-evidence` for the case, then `/qualstack:process-trace`. Open questions → new searches, logged with `/qualstack:evidence-log`.
