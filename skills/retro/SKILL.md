---
name: retro
description: Structured retrospective for a qualitative or multi-method project — a timeline rebuilt from the artifacts, the plan set against the record (which clues delivered their expected learning and which did not, access surprises, where the model was wrong, coding disagreements, preregistration deviations), then six questions on where the time went, the biggest unforced error, surprises, wins, what to do differently in the field, and the one systematizable lesson. Use after acceptance, rejection, a major R&R round, or a field season, or when the user wants to debrief a finished project.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(date *)
  - Bash(python3 *)
  - Bash(git log *)
---

# /qualstack:retro

**Stage:** reflect · **Voice:** coach

After acceptance, rejection, a major R&R, or a field season, while memory is fresh. The retro is only as good as the record it reads, and the record is the artifacts, not the recollection.

## Procedure

1. **Load the record.** `python3 "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-status"` (every artifact with its date and verdict); `git log --reverse --date=short --format='%ad %s'` if the project is a git repo; `decisions:` in `.qualstack/config.yaml`; the decision letters in `submission/response-to-reviewers/`; then the `.qualstack/*.md` memos, `prereg/addendum-*.md`, and the dated memos in `evidence/memos/`, in date order.
2. **Timeline:** scaffold date; model review; preregistration; first and last item logged by type (the `accessed` column of `evidence/log.csv`); coding complete; first update; first draft; submission; each round; decision. Days between milestones, with the planned dates from `.qualstack/fieldwork-plan.md` beside the actual ones.
3. **Plan against record**, as a table, before any question is asked:
   - **Clues.** For each clue in `.qualstack/clue-plan.md`: the planned chance of finding it and its expected learning, against what happened (found 1, found 0, NA after search, never sought, from `data/coding-log.csv`) and how far it moved the primary query (`.qualstack/process-trace-*.md`, `.qualstack/robustness-*.md`). Which delivered, which did not, and whether the plan's numbers were wrong or the luck was.
   - **Access.** Archives closed or slower than planned, declassification refused, interviewees who declined or withdrew (`notes` starting `withdrawn:`), permits, security; categories of people sought against reached.
   - **The model.** Restrictions the evidence contradicted, nodes added or dropped, priors that drove an answer, the robustness verdict, gaps between the formal posterior and the author's informal one.
   - **Coding.** Rule-version bumps in the change logs of `data/coding-rules.md` and why; per-node agreement and the disagreements adjudicated (`.qualstack/review-cache/coding-*/agreement.md`); whether adjudication moved values toward the hypothesis.
   - **Preregistration.** Each addendum and deviation, and whether it was written before the affected evidence was coded.
4. **Six questions**, one paragraph each; push for specifics, vague retros are worth nothing:
   1. **Where did the time actually go?** Estimated against actual on the longest stage: access, fieldwork, transcription and de-identification, coding, the model.
   2. **The biggest unforced error?** Something that cost time or quality that you knew at the time you should not be doing.
   3. **What surprised you?** A clue, a source, an access failure, a model failure, a referee comment `/qualstack:referee-mock` did not anticipate.
   4. **What worked?** A practice, habit, or decision worth keeping; wins count.
   5. **What would you do differently in the field?** Concretely: the source sought earlier, the question put to every interviewee, the note written on the day, the consent opt-in added, the archive visited first.
   6. **The one systematizable lesson?** A rule for next time, concrete enough to become a skill, a checklist item, or a memory entry.
5. **Save** to `.qualstack/retro.md` (a new dated section if the file exists): timeline, plan-against-record table, the six answers. Pseudonyms and categories only; the retro may end up in the archive.
6. **Promote.** If the lesson generalizes beyond this project, suggest `/qualstack:learn` for the project and the user's global memory (`~/.claude/CLAUDE.md`) for every project: `.qualstack/learnings.jsonl` is project-local, and the plugin's own files are replaced on every update.

## Outputs

- `.qualstack/retro.md`.
- Summary block: the timeline in one line, the clue that most over- and most under-delivered, the field lesson, the one systematizable lesson, the suggested follow-up.

## Anti-patterns

- **Generic lessons.** "Plan fieldwork better" is not one; "file declassification requests for the decisive series eighteen months before the trip" is.
- **No timeline.** Without it the retro is vibes.
- **No wins.** A catalog of failures hides what to keep.
- **Blaming the archive for the odds.** A clue planned with a 0.2 chance of being found that was not found is the plan working; say whether the plan was wrong or the luck was.
- **Identifying details.** Pseudonyms and categories, as everywhere else.

## Next

`/qualstack:learn` for the lesson; `/qualstack:archive` if the transparency package is not yet built.
