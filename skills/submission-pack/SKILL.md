---
name: submission-pack
description: Builds the submission bundle for a qualitative or multi-method paper and front-runs the desk and the ethics board — evidence-audit gate; anonymization sweep that catches fieldwork narration, acknowledgments, and "my interviews in X"; keyed-name scan; every quotation checked against its cited source; consent compliance for every quoted confidential item; the transparency appendix; the data-availability statement and QDR deposit status; LLM-use disclosure; word-count and format checks against the journal's current rules — and writes a pass/fail checklist. Use when the user is about to submit, asks to anonymize or format the manuscript for a journal, or asks whether the paper is ready to send.
argument-hint: "[journal name]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebFetch
  - Bash(date *)
  - Bash(python3 *)
  - Bash(texcount *)
  - Bash(wc *)
  - Bash(latexmk *)
  - Bash(quarto render *)
  - Bash(pdfinfo *)
  - Bash(mkdir *)
  - Bash(cp *)
---

# /qualstack:submission-pack

**Stage:** submit · **Voice:** production-editor

After `/qualstack:journal-fit` and a final manuscript. Everything else front-runs the reviewers; this front-runs the desk and the ethics board: the mechanical checks that bounce a paper before anyone reads it, and the ones that, missed, expose a participant. It does not fix the science; a failed gate sends the paper back to the skill that owns the problem.

`$ARGUMENTS` is the journal; default the `tier: 1` journal in `.qualstack/config.yaml`.

## Procedure

1. **Gate.** The `Verdict:` line of the newest `.qualstack/evidence-audit-*.md` must read `pass`, and `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-status` must not list it as stale. Otherwise stop: `/qualstack:evidence-audit` first.
2. **Journal requirements.** WebFetch the author guidelines and the data policy, or ask the user; never trust memory. Record each with its page and fetch date: word cap and what counts toward it; abstract cap; anonymity of review; appendix and supplement rules (length, reviewed or not); reference style; the data-availability and qualitative-transparency policy (deposit required, encouraged, or silent; the exemption route for confidential human-subjects data; ATI or active citation); human-subjects statement; AI-use disclosure; how a preregistration link is shared under anonymous review.
3. **Anonymization sweep** (anonymous review). `Read ${CLAUDE_PLUGIN_ROOT}/references/transparency-and-ethics.md`, section "Anonymous review". Grep `paper/` and every supplementary file for each author name and affiliation in config, `privacy.protocol`, and grant numbers; then for fieldwork tells: "my interviews in", "my fieldwork", "during my time in", "I interviewed", "I spent", "I was told", "my informants"; thanks to archives, hosts, assistants, interpreters, or interviewees; a QDR DOI or registry page that shows the author; first-person self-citation. Recast self-citations in the third person per the journal's convention, never deleting the reference; recast narration impersonally ("fieldwork in X", "interviews with officials in X"); move acknowledgments, `\thanks{}`, `\author{}`, grant and protocol numbers into `paper/title-page.tex`, leaving placeholders ("approved by the author's review board"); in Quarto, drop `author:` from the anonymized build. Re-grep to zero hits and keep the proof.
4. **Participant protection** (every journal). `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-redact check paper submission` must exit 0 (its "no key file" failure is acceptable only when `design.human_subjects` is false and nobody is pseudonymized; record it): a hit is fixed at the source with the pseudonym, never waived, unless the person is on the record and cleared in writing. Every P-ID in the paper is an `author` in `evidence/log.csv`, used for one person throughout. Every attribution passes the insider test (could a colleague of P07 name P07?): at most one precise indirect identifier, never role + date + place in a small population.
5. **Quotations.** `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-quotecheck --json`: `verified` passes; `near` is checked by eye and corrected to the source; `elsewhere` (misattributed) and `not-found` block; `uncited` gets its `\ev{}` (`[E014]` in Quarto); `unchecked` items are listed for the author to confirm against the pseudonymized text.
6. **Consent compliance**, item by item. For every evidence ID cited at a quotation or close paraphrase, take `access` and the consent tier recorded in `notes` of `evidence/log.csv` and set what the paper does against what the tier permits: on the record (quotation; name and title only if the form says so in writing); not for attribution (verbatim, with a role category); background (paraphrase, no quotation); deep background (never cited, never the sole basis of a value in `data/coding-log.csv`). Withdrawn items (`notes` starting `withdrawn:`) are neither cited nor coded. Any excess blocks: paraphrase, coarsen, or cut.
7. **Transparency appendix** (`paper/sections/appendix.tex` or `.qmd`): the evidence table (every cited item with type, date, source category, access tier); the interview-methods table (Bleich & Pekkanen 2013: frame; sought, interviewed, declined; format, length, recording, transcription; saturation), coarsened for small populations; the coding rules or a versioned pointer; the model (DAG, restrictions, priors, with justifications; code in the replication files); the sensitivity results from `.qualstack/robustness-*.md`, including the answers with values coded only from confidential items set to NA; deviations beside the registered plan if `design.prereg_url` is set. A missing piece goes to `/qualstack:draft-section appendix`.
8. **Data availability.** Draft the statement against the policy fetched in step 2: what is shared and where (model code, `data/case-data.csv`, `data/coding-log.csv`, `data/coding-rules.md`, the evidence log with tiers); what is withheld, why, and the access route, even if "none"; the QDR deposit status (not started, in preparation, deposited, embargoed) from `transparency/qdr-deposit-plan.md` if `/qualstack:archive` has run, else the planned date. Restricted evidence is disclosed to the editor now, not at acceptance.
9. **LLM use.** `/qualstack:llm-checklist report`: zero missing required items for every logged task, plus the AI-use disclosure the fetched policy asks for.
10. **Compliance.** Word count against the cap (`texcount -inc -total paper/main.tex` if available, else `wc -w` on the sections, method stated), with what counts toward it and the margin; abstract length; appendix within the policy; reference style as the bibliography produces it; figures and tables: count, placement, resolution.
11. **Bundle.** Compile the anonymized manuscript and the title page separately (`latexmk -pdf`, or `quarto render`); without a toolchain, stage the sources and list the compile steps. `pdfinfo` must show no author; clear tracked changes and comments. Stage under `submission/<journal-slug>/`: anonymized PDF, title page, appendix and supplement, figures at spec, the data-availability statement, the LLM disclosure, the preregistration link in the form step 2 found.
12. **Checklist** to `submission/submission-checklist-<YYYY-MM-DD>.md`: every check above with pass / fail / waived and its evidence (grep counts, redact exit status, quotecheck tallies by status, the consent table, word counts, the bundle's file list).
13. **Not ready** while the audit is not `pass`, any identifying string or keyed name remains, any quotation is `not-found` or `elsewhere`, any quoted item exceeds its consent tier, or any other check fails without a waiver the user acknowledged in writing in the checklist.

## Outputs

- `submission/<journal-slug>/` bundle; `paper/title-page.tex`; `submission/submission-checklist-<date>.md`.
- Summary block: gate status, word count against the cap, anonymization and redact results, quotecheck tallies, consent excesses fixed, remaining manual steps (portal fields, deposit, the editor's disclosure).

## Anti-patterns

- **Anonymizing by deletion.** Use the journal's anonymous convention; never drop the reference.
- **Remembered journal rules.** Fetch them; caps and data policies change between volumes.
- **"Probably fine" on identity.** One grep hit is a desk reject; one identifiable informant is worse; the sweep ends at zero hits.
- **Quoting past the consent tier.** A background interview quoted verbatim is a broken promise, whatever the journal allows.
- **Packaging a failed audit.** A failed `/qualstack:evidence-audit` is fixed, not waived.
- **"Available upon request."** Say what is shared, what is withheld, and the route.

## Next

`/qualstack:cover-letter` for the same journal, then submit; set `paper.status: "submitted"` in `.qualstack/config.yaml` once the portal confirms. Failed gates go to `/qualstack:evidence-audit`, `/qualstack:deidentify`, `/qualstack:draft-section appendix`, `/qualstack:llm-checklist`, or `/qualstack:archive` for the deposit.
