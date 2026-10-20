---
name: draft-section
description: Drafts one section of a qualitative or multi-method paper (abstract, intro, theory, design, cases, results, discussion, appendix) to paper/sections/ in the user's configured writing voice, to the bar each section owes the reader — the query stated as a counterfactual, the causal model shown and defended (DAG, restrictions, priors), case narratives organized around clues with every factual claim cited to the evidence log and every quotation verbatim, priors beside posteriors using only numbers on disk, claims sized to the posterior, pseudonyms and consent tiers respected — then runs the quotation and real-name checks. Use when the user asks to write, draft, or revise any part of the paper, a case narrative or the process-tracing write-up, the results, or the transparency appendix.
argument-hint: "abstract|intro|theory|design|cases [case]|results|discussion|appendix"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(python3 *)
  - Bash(wc *)
---

# /qualstack:draft-section

**Stage:** write · **Voice:** writer, anchored to `voice.writing_style` in `.qualstack/config.yaml`

Writes what the model, the evidence, and the numbers on disk support, and nothing more: no number that is not in `output/` or a memo, no evidence ID that is not a row of `evidence/log.csv`, no quotation that is not verbatim in its source, no name that is not a pseudonym. Draft `theory` and `design` once the model review and the clue plan are settled, and `cases`, `results`, `intro`, and `discussion` once the update and the robustness run are stable; prose written earlier gets rewritten.

`$ARGUMENTS` is the section: `abstract`, `intro`, `theory`, `design`, `cases` (optionally followed by one case ID from `data/case-data.csv`, to draft only that case), `results`, `discussion`, or `appendix`. If missing or unrecognized, list these and stop.

## Procedure

1. **Privacy first.** Read `privacy.ai_processing` (empty means `none`) and `design.human_subjects`. `none`: open nothing derived from participants (`evidence/raw/interviews/`, `evidence/raw/fieldnotes/`, pseudonymized or not); work from the process-trace memos and the coding log, and leave each participant quotation as `% TODO(quote): E031, <the passage's gist>, <consent tier>` for the author. `pseudonymized`: the pseudonymized files in `evidence/` only. `full`: what the protocol cleared. Never `restricted/`, under any setting; an `archive-restricted` item whose `notes` bar copying or processing is treated the same way.
2. **Gate.** If an upstream artifact is missing, name the skill that makes it and stop:

   | Section | Needs | Missing → |
   |---|---|---|
   | `intro` | `.qualstack/research-question.md`, `.qualstack/lit-map.md`, `.qualstack/queries.md`, the primary query's posterior (`output/tables/queries.csv` or `case-answers.csv`, or the process-trace memo when `model.formal: false`) | `/qualstack:analyze` |
   | `theory` | `.qualstack/theory.md`, `.qualstack/model.md`, `.qualstack/queries.md`, `code/01-model.R`, a `.qualstack/model-review-*.md` | `/qualstack:model-review` |
   | `design` | `.qualstack/design.md`, `.qualstack/case-selection.md`, `.qualstack/clue-plan.md`, `data/coding-rules.md`; `prereg/prereg.md` if `design.prereg`; `.qualstack/fieldwork-plan.md` if `design.fieldwork` | `/qualstack:case-select`, `/qualstack:clue-select` |
   | `cases` | `.qualstack/process-trace-<case>.md` for each case, `.qualstack/chronology-<case>.md`, `evidence/log.csv`, `data/coding-log.csv`, `data/case-data.csv` | `/qualstack:process-trace` |
   | `results` | `output/tables/queries.csv` and `case-answers.csv` (unless `model.formal: false`), the latest `.qualstack/robustness-*.md`, the process-trace memos | `/qualstack:analyze`, `/qualstack:robustness` |
   | `discussion` | drafted `results` and `cases`; `.qualstack/theory.md`; the latest robustness memo | `/qualstack:draft-section results` |
   | `abstract` | drafted `intro`, `results`, `discussion` | `/qualstack:draft-section <missing section>` |
   | `appendix` | `evidence/log.csv`, `data/coding-rules.md`, `data/coding-log.csv`, `code/01-model.R`, `code/04-update.R`, the latest robustness memo; `.qualstack/llm-checklist.md` if `.qualstack/llm-usage.jsonl` logs tasks | `/qualstack:llm-checklist` |

3. **Load** `.qualstack/config.yaml` (title, `paper.format`, target journals, `design.type`, `model.formal`), `.qualstack/learnings.jsonl`, every existing file in `paper/sections/` (consistency across sections is a referee's first check), the keys in `paper/refs.bib` (Grep `^@\w+\{`), and the upstream artifacts above.
4. **Read** `${CLAUDE_PLUGIN_ROOT}/references/writing-conventions.md` (section bars, result tables, the hedging scale, quotation and pseudonym rules), and by section: `theory` → `${CLAUDE_PLUGIN_ROOT}/references/causal-models.md`; `cases` → `${CLAUDE_PLUGIN_ROOT}/references/bayesian-process-tracing.md` and `${CLAUDE_PLUGIN_ROOT}/references/evidence-and-sources.md`; `design`, `results` → `${CLAUDE_PLUGIN_ROOT}/references/mixed-methods.md`; `appendix` → `${CLAUDE_PLUGIN_ROOT}/references/transparency-and-ethics.md`.
5. **Voice.** If `voice.writing_style` names a skill, invoke it for tone, rhythm, and vocabulary. If unset, write clean academic prose (short sentences, active verbs, at most one hedge per claim) and tell the user once that a style skill can be set in `.qualstack/config.yaml`.
6. **Draft to the section's bar:**
   - **`intro`**: the question and its stake; the primary query as a counterfactual about a named cause in a named case or population; "a case of what?" answered on page one; the contribution paragraph (what we do: the model, the cases, the evidence in counts by type; what we find: prior → posterior on the primary query; what changes if believed); the two or three closest works and the case's historiography; roadmap in one sentence or none.
   - **`theory`**: the argument as a causal model, from `.qualstack/theory.md` and `.qualstack/model.md`: nodes with one-line definitions; the DAG figure from `output/figures/` (if none, a placeholder and a TODO naming `/qualstack:viz`) with a note that missing arrows are claims; one table of restrictions, priors, and confounding, labeled as in `code/01-model.R` (R1, P1, C1 …), each with a one-line justification and the source of the belief; the query from `.qualstack/queries.md` in words as a counterfactual, with its CausalQueries string; rivals as alternative causes in the model; any answer a restriction settles before evidence, flagged. With `model.formal: false`: the exhaustive, mutually exclusive hypotheses and the prior on each with its reason.
   - **`design`**: why these cases (population, the selection rule and the values it used, the strategy, the expected learning, the cases not traced and why, from `.qualstack/case-selection.md`); the selection log and whether selection is ignorable or on the outcome, and the remedy; which clues and why (the clue-plan table: node, where sought, likelihoods or test shape, expected learning, date recorded); sources and access (archives, series, date ranges, closures; the interview frame with counts sought, obtained, refused); the coding rules in summary (the 0 standard, versions, agreement from `.qualstack/review-cache/coding-*/agreement.md`); preregistration and deviations; the hedging scale, stated once in a footnote; an ethics paragraph ("approved by the author's institutional review board", the protocol number left for the title page; consent tiers; pseudonymization; the AI processing the protocol allowed) with nothing that unblinds the author or identifies a participant. If `/qualstack:design-research` drafted the file, revise it in place.
   - **`cases`**: one `\subsection` per case, built around the clues and the query, not the chronology: the case's observed values, its query, and its prior; a short dated anchor from the chronology memo; then clue by clue in the order of `.qualstack/process-trace-<case>.md`: what was sought and where, what was found (every factual claim cites `\ev{E###}`), the source's reliability where it moves the likelihood, the likelihood under each hypothesis and where it comes from (the model or the source critique), the running posterior, and what would have been concluded had the clue come out the other way (the memo's counterfactual table, also set as a table here or in the appendix); each rival met with the clue that separates it; dependent sources counted once; evidence that cut against the argument reported; the case posterior and the unmade observation that would move it. Quotations are copied verbatim from the evidence file, within the consent tier in the item's `notes`: not for attribution, verbatim with a coarse role; background, paraphrase only; deep background, not cited; no tier recorded, paraphrase and flag it.
   - **`results`**: the posterior table: every query in `.qualstack/queries.md`, prior beside posterior at two decimals, from `output/tables/queries.csv` (population and subgroup answers) and `output/tables/case-answers.csv` (named cases), nowhere else; a named case's answer sits beside the same query given only what was known before the clues. For every case-level number, say which question it answers: uninformative case (`case_level` FALSE: chosen for its pattern, or already in the update) or informative case (`case_level` TRUE: a new case), never both for one case; under fixed parameters (`using` = parameters) they coincide. Then what the clues moved (in multi-method designs, the trained-versus-untrained table from `output/tables/clue-value.csv`; a query that barely moved, with the shares that did, from `output/tables/parameters.csv`); restriction-driven answers labeled as assumptions; claims sized by the hedging scale, never "proves", "confirms", "establishes"; the robustness paragraph from the latest `.qualstack/robustness-*.md` with its verdict and what does not survive. With `model.formal: false`: the evidence-weight table from the memos, posteriors with their ranges.
   - **`discussion`**: the contribution with its posterior; what the answer is not (one case's attribution is not an average effect; a mediator's occurrence is not a path); the strongest rival and how far the evidence moved against it; specific limitations (the restriction leaned on, the single-source decisive clue, the closed archive, values coded only from confidential items); generalization only through the model or scope conditions; one next study, the clue or case with the most expected learning left.
   - **`abstract`**: a baseline (the query as a counterfactual, cases and design, evidence in counts, the finding with its posterior, the portable lesson) within the cap in the latest `.qualstack/journal-fit-*.md`; no citations, no `\ev{}`. `/qualstack:abstract-shotgun` writes the variants.
   - **`appendix`**: the evidence table from `evidence/log.csv` (ID, type, date, archive route or category, access tier, cases, clues; confidential rows by pseudonym, role category, and year; never the `notes` column); the interview methods table after Bleich & Pekkanen (2013), by category; the coding rules by node and version, and agreement before adjudication; the model code (`code/01-model.R`, `code/04-update.R`) with seed and package version; the likelihood and counterfactual tables per case; the sensitivity tables from the latest robustness run; originals of translated quotations; the withheld-items table; preregistration deviations; the LLM-use report (`\input{sections/llm-checklist}`, from `/qualstack:llm-checklist latex`).
7. **Citations.** Literature: only keys in `paper/refs.bib`; a missing one becomes `\cite{TODO-author-year-keyword}` with `% TODO: add ref — <one line>`; never an invented author-year-title. Evidence: only IDs that are rows of `evidence/log.csv` and not `withdrawn:`. Quarto: `[E014]` and `[@key]`.
8. **Write** to `paper/sections/<section>.tex` (`.qmd` when `paper.format: quarto`). Overwrite only an empty file or the template's placeholder comment; otherwise show the candidate and ask: overwrite, append, or save as `paper/sections/<section>.candidate.tex`. `cases <case>` replaces only that case's subsection. After the first substantive section, set `paper.status: "writing"`.
9. **Self-check before saving:** every number Grep-found in `output/tables/`, the robustness memo, or a process-trace memo, and every evidence count tallied from `evidence/log.csv` (a number not on disk becomes a TODO, never an estimate); every `\ev{}` a live log row; the query and restrictions in the text identical to `.qualstack/queries.md` and `code/01-model.R`; every "hoop" or "smoking gun" beside its two likelihoods; every verb within the hedging scale; no invented key.
10. **Run the checks** on the file written:
    - `python3 "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-quotecheck" paper/sections/<section>.tex`. Fix every row not `verified`: `near` → recopy from the source; `elsewhere` → correct the citation; `uncited` → add the `\ev{}` in the same sentence; `not-found` → find it or delete it; `unchecked` → state why (confidential, or an archival PDF not yet converted: `/qualstack:pdf-ingest`). Re-run until it exits 0.
    - `python3 "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-redact" check paper/`. A hit prints a file, a line, and the pseudonym the leaked name belongs to: put the pseudonym at that line and re-run. "No key file" is expected when `design.human_subjects` is false; when it is true, stop and send the user to `/qualstack:deidentify`.
    - Read every attribution against the insider test: no combination of role, date, and place that fits one person.

## Outputs

- `paper/sections/<section>.tex` (or `.qmd`); `paper.status: "writing"` in `.qualstack/config.yaml` after the first substantive section.
- Summary block:

  ```
  SECTION:   <section> → paper/sections/<file> (<n> words, wc -w)
  NUMBERS:   <k> checked against output/ and memos | not on disk: <list>
  EVIDENCE:  <m> \ev{} citations to <i> items | unresolved: <list>
  QUOTES:    verified <a> · near <b> · elsewhere <c> · uncited <d> · not-found <e> · unchecked <f>
  NAMES:     redact check clean | <n> fixed | no key (no human subjects)
  TODOS:     <missing refs, figures, author-inserted quotations>
  NEXT:      <skill>
  ```

## Anti-patterns

- **Chronology as structure.** A year-by-year story with the clues buried in it; the reader cannot see what discriminated.
- **Illustrative cases.** Narratives that could not have changed the conclusion; if no clue could have gone the other way, say so or drop the claim.
- **Test labels as verdicts.** "It passes a hoop test" with no prior, no likelihoods, no posterior.
- **Likelihoods asserted in prose.** Each comes from the model, the dated clue plan, or the source critique, and the text says which.
- **Numbers from nowhere.** A posterior, count, or share not on disk, or rounded differently from the table.
- **Quotations from memory or memos.** Verbatim from the evidence file, or a TODO for the author.
- **Quoting past consent.** A background interview quoted; a confidential item attributed by role, date, and place.
- **One number, two questions.** A case-level probability with an interval sold as the case verdict, or a population share sold as what happened in the case.
- **Fabricated citations or evidence IDs.** TODO markers, never inventions.
- **Generic voice over a configured style.**

## Next

Before `theory`, `/qualstack:model-review`; before `design`, `/qualstack:case-select` and `/qualstack:clue-select`; before `cases`, `/qualstack:process-trace` for every case; before `results`, `/qualstack:analyze` and `/qualstack:robustness`; before `appendix`, `/qualstack:llm-checklist latex` if an LLM coded or assessed evidence. After all sections, `/qualstack:evidence-audit` (every `\ev{}`, quotation, and coded value against the logs), then `/qualstack:abstract-shotgun`, `/qualstack:title-shotgun`, `/qualstack:coauthor-review`, and `/qualstack:referee-mock`.
