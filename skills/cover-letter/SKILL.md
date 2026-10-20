---
name: cover-letter
description: Drafts the submission cover letter for a qualitative or multi-method paper in three paragraphs and 400 words or fewer — fit to this journal with named recent articles, the contribution and the inference that delivers it, and declarations (preregistration, what evidence is shared and what is withheld with its access route, human-subjects approval, other papers from the same fieldwork, AI use). Use after a target journal is chosen, when the user asks for a cover letter or submission materials.
argument-hint: "[journal name]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - WebFetch
  - Bash(wc *)
---

# /qualstack:cover-letter

**Stage:** submit · **Voice:** the author addressing the editor

After `/qualstack:journal-fit` and `/qualstack:submission-pack`. Read in 30 seconds; precision beats warmth. The letter is also where restricted evidence is disclosed to the editor: at submission, not at acceptance.

`$ARGUMENTS` is the journal; default the `tier: 1` journal in `.qualstack/config.yaml`.

## Procedure

1. **Load** `.qualstack/config.yaml` (journal, authors, `design.prereg`, `design.prereg_url`, `design.human_subjects`), `paper/sections/abstract.tex`, the contribution sentence in `.qualstack/research-question.md`, the primary answer (`output/tables/queries.csv`, or the newest `.qualstack/process-trace-*.md` when `model.formal` is false), the newest `.qualstack/journal-fit-*.md` (the articles coded there), and the newest `submission/submission-checklist-*.md` (the data-availability statement, counts by access tier).
2. **Editor.** Ask the user for the handling editor's name and salutation, or fetch the journal's current masthead and confirm with the user; teams rotate, so never from memory.
3. **Three paragraphs, ≤ 400 words:**
   - **Fit**: what the paper does in one sentence and why it belongs in *this* journal, naming one or two articles from its recent volumes (from the journal-fit coding, never from memory) that the paper speaks to; not "builds on the journal's strong tradition in X".
   - **Contribution**: the contribution sentence; the headline answer stated as what the evidence did (the probability that X caused Y in the case, prior to posterior; or the population share with its interval), never stronger than the posterior; the design that delivers it (the model, the cases and why they were chosen, the decisive clues). No hedging, no inflation.
   - **Declarations**: preregistration status and link (an anonymized link if the portal passes letters to reviewers); data and transparency in the words of the data-availability statement: what is shared and where, what is withheld and why, and the access route; human-subjects approval (board and protocol, since the letter is not anonymized); other papers or chapters drawing on the same fieldwork or archive, and what this one adds; not under review elsewhere; conflicts of interest; AI use where the journal asks; word count; prior presentations or earlier versions.
4. **Sign-off:** author name(s) and affiliation(s), one line.
5. **Save** to `submission/cover-letter.md` (Markdown; convert to what the portal takes).
6. **Cross-check:** editor current; journal name spelled right throughout; `wc -w submission/cover-letter.md` at most 400, and within any limit the journal sets; the data, preregistration, and approval declarations match the paper and the checklist word for word; no participant detail beyond what the paper discloses.

## Outputs

- `submission/cover-letter.md`.
- Summary block: word count, editor addressed, declarations covered; remind the user to set `paper.status: "submitted"` once the portal confirms.

## Anti-patterns

- **Sycophancy.** Editors do not need to hear their journal is excellent.
- **Generic fit.** "Of interest to your readership" with no recent article named.
- **Five paragraphs.** Three.
- **Repeating the abstract.** The letter situates the paper for this editor; the abstract cannot.
- **A posterior inflated into a verdict.** "Proves" for a probability of 0.8 is the first thing a methodologist reviewer quotes back.
- **Hiding the restricted evidence.** An editor who learns at acceptance that the interviews cannot be deposited has grounds to stop the paper.
- **Silence about sibling papers.** Undisclosed papers from the same interviews look like duplication when a reviewer finds them.

## Next

Submit. On decision: `/qualstack:r-and-r` for a revise-and-resubmit; `/qualstack:journal-fit` again after a rejection (the backup is already scored).
