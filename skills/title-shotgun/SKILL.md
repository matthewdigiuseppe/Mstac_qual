---
name: title-shotgun
description: Generates 8-12 title candidates for a qualitative or multi-method paper across forms (declarative, question, colon, anomaly, mechanism, quotation, case-anchored, noun phrase), drops any that claims more than the posterior or exposes a participant or field site, scores the rest on hook x precision x searchability, and pairs the winner with the abstract framing. Use late in writing when the user asks for title ideas, a better title, or a subtitle.
allowed-tools:
  - Bash(date *)
  - Read
  - Write
  - Edit
  - Glob
---

# /qualstack:title-shotgun

**Stage:** write · **Voice:** writer

After `/qualstack:abstract-shotgun` settles a framing; editors, search engines, and area specialists read title and abstract together, so pair them deliberately. A title is a claim too, and answers to the posterior like any other.

## Procedure

1. **Load** `paper/sections/abstract.tex` (or `.qmd`) and the recommended variant's lead; `.qualstack/config.yaml` (`paper.title`, target journals); the posterior on the primary query from `paper/sections/results.tex`; the hedging scale in `${CLAUDE_PLUGIN_ROOT}/references/writing-conventions.md`.
2. **Generate 8–12 candidates** across forms:

   | Form | Example |
   |---|---|
   | Declarative | "Mass War Made the Income Tax Progressive" |
   | Question | "Did Conscription Make the Rich Pay?" |
   | Colon (general: specific) | "Conscripting Wealth: Mass Mobilization and Progressive Taxation in Two Wars" |
   | Anomaly | "Taxing the Rich in a Conservative Parliament" |
   | Mechanism | "Equal Sacrifice: How Conscription Arguments Moved Tax Votes" |
   | Quotation | "'Wealth Bears Its Share': Conscription and the Wartime Surtax" |
   | Case-anchored | "The Surtax Bargain of 1916: Conscription and Progressive Taxation" |
   | Single noun phrase | "The Sacrifice Bargain" |

3. **Screen before scoring**; a candidate that fails any of these is dropped:
   - **Sized to the posterior.** A declarative title asserts the answer: only when the primary query's posterior reaches "very likely" or "likely" on the hedging scale; otherwise a question, a mechanism, or a colon form.
   - **Quotation titles** only from a passage already quoted verbatim in the paper (so `/qualstack:evidence-audit` checks it), from an item whose access tier and consent permit quotation, attributed to no identifiable person; never from a background or deep-background interview.
   - **Nothing that exposes.** No pseudonyms (`P07`, `[Town 3]`) and no detail that identifies a field site, community, or participant the paper keeps anonymous.
   - **A case of what.** A title that names the case also names the phenomenon it is a case of, usually in the subtitle.
4. **Score 1–5** on hook (would a reader stop scrolling?), precision (does it convey the claim, not just the topic?), and searchability (would the right reader find it by the concept, the case, or the period?). Method vocabulary ("process tracing", "Bayesian") in a title is a register signal: right for a methods venue, noise elsewhere.
5. **Filter:** drop any title with a 1 in any dimension; rank by `hook × precision × searchability`; surface the top 3.
6. **Recommend one**, paired with the abstract framing: finding-first with declarative; puzzle-first with question or anomaly; case-first with case-anchored, or a colon whose subtitle names the phenomenon; theory-first with mechanism.
7. **Save** to `.qualstack/title-shotgun-<YYYY-MM-DD>.md` (`date +%Y-%m-%d`): every candidate with its form, scores, and screen notes; the top 3; the recommendation. Offer to set `paper.title` in `.qualstack/config.yaml` and `\title{}` in `paper/main.tex`; never change them unasked.

## Outputs

- `.qualstack/title-shotgun-<date>.md`: candidates, screens, scores, recommendation.
- Summary block: top 3 with scores, the recommendation, and the abstract variant it pairs with.

## Anti-patterns

- **Clever but vague.** Two readings to parse fails hook and precision.
- **Variables in the title.** "The Effect of X on Y in Z" is a placeholder.
- **A verdict on a 0.6 posterior.** "How X Caused Y" when X is only more likely than not to have caused Y.
- **Subtitle longer than title.** Reverse the colon.
- **Color at a participant's expense.** A vivid interview quotation or village name that identifies someone.
- **Only area specialists can parse it.** A local acronym or untranslated term with no general phenomenon beside it.

## Next

`/qualstack:journal-fit` to confirm the pair suits the target journal's style; `/qualstack:submission-pack` carries the title to the title page.
