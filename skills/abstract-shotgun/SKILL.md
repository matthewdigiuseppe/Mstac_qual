---
name: abstract-shotgun
description: Generates 4-6 abstract variants for a qualitative or multi-method paper with different positioning bets (puzzle-, case-, theory-, finding-, anomaly-, method-first), each carrying the query as a counterfactual, the cases and evidence base, and the finding sized to its posterior, tagged by audience and risk, and recommends one for the target journal. Use when a full draft exists and the user wants the abstract written, improved, shortened, or reframed.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# /qualstack:abstract-shotgun

**Stage:** write · **Voice:** writer, anchored to `voice.writing_style` in `.qualstack/config.yaml`

On a full draft. The abstract is the paragraph editors use to desk-reject or send out, and for case-based work it must also say what the case is a case of; generate variants rather than converging on the first, and let none claim more than the posterior.

## Procedure

1. **Load** `paper/sections/intro`, `cases`, `results`, `discussion`, and the current `abstract` (`.tex`, or `.qmd` when `paper.format: quarto`); `.qualstack/config.yaml` (target journals, `design.type`); `output/tables/queries.csv` and `case-answers.csv`; `evidence/log.csv` for the counts of evidence by type; the latest `.qualstack/journal-fit-*.md` for the target journal's abstract cap and the date it was checked. No recorded cap: use 250 words, label it unchecked, and say it must be checked against the journal's current guidelines.
2. **Voice:** invoke the `voice.writing_style` skill if set; otherwise clean academic prose (short sentences, active verbs, at most one hedge per claim).
3. **Generate 4–6 variants**, each leading differently:
   - **puzzle-first**: "Why did a regime that was winning agree to negotiate its exit?";
   - **case-first**: the event and its stakes, then what it is a case of;
   - **theory-first**: "We argue that X produces Y through M, and that …";
   - **finding-first**: "Tracing … through 212 archival documents, we find that the evidence raises the probability that X caused Y from 0.35 to 0.81";
   - **anomaly-first**: "The historiography attributes Y to W; contemporaneous records point to X";
   - **method-first**: only when the contribution is the method (a formal causal model of a classic case, a new way to integrate cases with cross-case data); never as decoration.
4. **Each variant meets the abstract bar** in `${CLAUDE_PLUGIN_ROOT}/references/writing-conventions.md`: the question as a counterfactual about a named cause; the case(s) and design; the evidence base in counts by kind; the finding with a number from `results` (the posterior on the primary query, with its prior when room allows, and enough words that the reader knows what it is a probability of); the portable lesson. Only the order varies. No citations, no `\ev{}`, no pseudonyms or places the paper withholds, no hedging stack; verbs from the hedging scale (never "proves", "confirms", "demonstrates").
5. **Check the numbers:** every number in every variant appears in `results` and in `output/tables/` (Grep each; with `model.formal: false`, in the process-trace memos); evidence counts match `evidence/log.csv`. A variant over the cap is cut, not kept as an option.
6. **Tag each** with lead style, implicit audience (comparative, IR, American political development, area specialists, historians, methods), and the framing's main risk: case-first reads as an area paper at a generalist; finding-first puts a probability before the reader knows its question; puzzle-first can look unengaged with the historiography; method-first invites a methods-journal desk reject.
7. **Write the file.** LaTeX: `paper/sections/abstract.tex`, variants as `%` comments and the recommended one uncommented as plain text (`paper/main.tex` already wraps the file in the abstract environment, so no `\begin{abstract}` here). Quarto: `paper/sections/abstract.qmd`, with `<!-- … -->` comments. An abstract the author wrote stays at the top as a commented `CURRENT` block.

   ```
   % CURRENT (author's):
   % <text>
   %
   % VARIANT 1 (puzzle-first; comparative; risk: …; 187 words):
   % <text>
   ...

   % --- RECOMMENDED: VARIANT n ---
   <recommended variant text, uncommented>
   ```

8. **Recommend** the variant that fits the top target journal (its row in `${CLAUDE_PLUGIN_ROOT}/references/journals.md` and the journal-fit memo), justified in one sentence.

## Outputs

- `paper/sections/abstract.tex` (or `.qmd`): variants as comments, one recommended, uncommented.
- Summary block: each variant's lead, word count, audience, and risk; the recommendation; the cap used, with its check date or "unchecked".

## Anti-patterns

- **Variants that open the same way.** That is not a shotgun.
- **Over the cap.** If the cap is 150, every variant is ≤ 150.
- **A probability without its question.** "0.81" means nothing until the reader knows what it is the probability of.
- **Overclaiming to sell.** The abstract answers to the same hedging scale as the results.
- **A topic, not a finding.** "Drawing on 40 interviews, we explore …" is not an abstract.
- **Ignoring the journal.** Area and historians' journals tend to lead with the case, generalists with the portable claim; the recent abstracts coded in the journal-fit memo decide.

## Next

`/qualstack:title-shotgun` to pair a title with the chosen framing; `/qualstack:draft-section abstract` gives a baseline beforehand; `/qualstack:journal-fit` if no target journal is set.
