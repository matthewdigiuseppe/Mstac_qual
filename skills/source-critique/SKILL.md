---
name: source-critique
description: Critiques a batch of evidence items as sources — provenance, author and audience, timing relative to the events and to the outcome being known, incentives, access, original or derivative — groups items that share an origin so they count once, checks secondary sources for selective use of historians, and turns the critique into likelihoods (for each clue an item speaks to, the probability the source reports it if it is true, s, and if it is false, f), written with the reason to the reliability column of evidence/log.csv. Use when logged evidence has reliability pending, before coding or process tracing, when the user asks how far to trust a memoir, an interview, a leak, a historian, or an official statistic, worries that sources are self-serving or biased, or wants to know whether several sources really corroborate one another.
argument-hint: "[E-IDs|case|type]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(python3 *)
  - Bash(date *)
---

# /qualstack:source-critique

**Stage:** collect · **Voice:** source-critic

Source criticism is likelihood estimation: how likely is this source to report this clue if it is true, and if it is false? The critic refuses "reliable" and "credible" without an s and an f, refuses to count five copies of one leak as five sources, and refuses to read an account of motives written after the outcome as a record of them.

## Procedure

1. **The batch**: `$ARGUMENTS` (IDs, a case, or a type), else every row of `evidence/log.csv` whose `reliability` is `pending`. Read those rows, the node blocks of `data/coding-rules.md` (what each clue is, which sources the rule expects), and the planned likelihoods in `.qualstack/clue-plan.md`. `Read ${CLAUDE_PLUGIN_ROOT}/references/evidence-and-sources.md`, sections "Source criticism as likelihoods" (its two tables are the starting points) and "Secondary sources and historiography". Today: `date +%Y-%m-%d`.
2. **Participant material checks `privacy.ai_processing`.** Empty or `none`: critique interviews and field notes from the log row and the researcher's own account of the speaker's position, never from the text. `pseudonymized`: the pseudonymized files in `evidence/raw/` that have a log row. Never `restricted/`.
3. **Six questions per item** (who speaks to whom, for what purpose, in what circumstances; George & Bennett 2005), one line each:
   - **Provenance**: original, copy, draft, or translation; the chain of custody; what the archive's weeding and declassification let through (secret or embarrassing clues are under-reported).
   - **Author and audience**: was the author placed to know, or relaying hearsay; did insiders have to act on it, or was it written to persuade, to leak, or to protect the author on file?
   - **Timing**: before, during, or after the events, and before or after the outcome was known; the lag from event to document. Read the item where it falls among what was written then (Trachtenberg 2006): what did the author know and expect at the time?
   - **Incentives**: credit to claim, blame to shift, a position to defend. A statement against interest is the strongest kind.
   - **Access**: what the author could have seen, and, for an interview, what the researcher's position shaped in the telling (the post-interview memo's assessment).
   - **Original or derivative**: if derivative, of which ID.
4. **Dependence clusters.** Group items that share an origin: copies and wire reprints, a leak re-reported, an interviewee retelling a story others told, a memoir and the interviews drawn from it, a historian quoting minutes already logged. Each cluster counts once; mark `derivative of E031` in each derivative's `notes`. Corroboration requires errors that are independent given the clue; otherwise the second item is weighed given the first, P(E2 | E1, H) (Fairfield & Charman 2017).
5. **Secondary sources** (Lustick 1996): for every historian an inference leans on, their sources for each claim used (archive series, interviews, other secondaries, or their own inference), their school, and the rival accounts. State the debate, prefer accounts whose sources can be checked, follow the footnotes to the primary where it can be reached, and say whose account is used and why (Thies 2002). A contested node value becomes rival codings for `/qualstack:robustness`, never a choice of the historian who fits.
6. **Translate into s and f.** For each clue (node) the item speaks to: s = P(source reports K | K true) and f = P(source reports K | K false), both strictly between 0 and 1. Start from a disinterested, well-placed, contemporaneous witness and move each number with the answers above; give a range when unsure. Set them from the source's position, never from whether the item helps the argument, and before the clue is coded. Show what the item can do: a report multiplies the odds on K by at most s/f, a silence by (1 − s)/(1 − f); with s = .85 and f = .05, a report can multiply them by 17 and a silence divides them by about 6. Silence counts only from a source with reason and opportunity to speak. A smoking gun from a source with f = .2 is a straw in the wind, and a hoop is a hoop only if the source would have mentioned K (Van Evera 1997).
7. **Write the column.** `reliability` = `<node> s=<p> f=<p> (<reason>)`, one entry per clue joined by `; `, no semicolon inside a reason: `M s=.85 f=.05 (contemporaneous insider minute, author present)`. Edit only that cell and `notes` (for `derivative of`), and quote the cell.
8. **Fold or model.** Folding a source's s and f into the clue's likelihoods is defensible only if the error is the same whatever the outcome, one source cluster reports K, and K has no children in the model. Otherwise recommend a measurement node, true K → reported K (`K -> Kr`, plus `Y -> Kr` when the report was written knowing the outcome), with s = P(01) + P(11) and f = P(10) + P(11) (just P(11) once inverted reports, type 10, are ruled out) setting the priors on Kr's types: hand it to `/qualstack:causal-model`, and let `/qualstack:robustness` vary them. Flag every clue that carries the primary query and rests on a single cluster.
9. **The memo**, `.qualstack/source-critique-<date>.md`: per item the six answers and, per clue, s and f with reasons and ranges; the clusters (origin, members, effective count per clue); the secondary-source table; the measurement-node recommendations; the items left `pending` and what the researcher must supply. Then run `python3 ${CLAUDE_PLUGIN_ROOT}/skills/evidence-log/assets/check-log.py` and fix every reliability error it reports.

## Outputs

- `.qualstack/source-critique-<date>.md`.
- `evidence/log.csv`: the `reliability` column, and `derivative of` in `notes`.
- Summary block: items critiqued; clusters (n items → k origins); per clue, the independent origins and the best s and f; clues resting on one cluster; measurement nodes recommended; items still pending and why.

## Anti-patterns

- **Adjectives for numbers.** "Reliable" for which clue, at what s and f?
- **Counting echoes.** Five papers repeating one leak are one source.
- **Motives from memoirs.** A later account of a motive is evidence of what was said later.
- **Silence from the uninformed.** A source with no reason or opportunity to speak says nothing by its silence.
- **The historian who agrees.** Choosing the account that fits is selection on the conclusion.
- **Likelihoods tuned to the argument.** s and f come from the source's position, set before the clue is coded.

## Next

`/qualstack:causal-model` for recommended measurement nodes; `/qualstack:chronology` when timing questions surfaced; `/qualstack:code-evidence`, whose precedence clause uses these numbers; `/qualstack:process-trace` for likelihoods on evidence outside the model.
