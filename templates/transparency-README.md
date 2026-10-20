# Transparency package: "<paper title>"

<Authors> · Contact: <email> · Package version: <YYYY-MM-DD> · Article DOI: <> · Package DOI: <> · Evidence deposit DOI (QDR): <none | DOI>

## Overview

<One paragraph: the question, the causal model, the cases, and the answer. What this package lets a reader do: trace every evidence citation in the article to its log row and access route; rerun every formal result (the query table and the figures) from the coded case data; see how far each answer depends on evidence that cannot be shared. Expected runtime and the machine it was last run on.>

## Contents

| Path | What it is |
|---|---|
| `code/` | R scripts, run in numbered order (table below) |
| `data/coding-rules.md` | What counts as 1, 0, and NA for every model node, with each rule's version history |
| `data/coding-log.csv` | One row per coded value: case, node, value, the evidence IDs behind it, rule version, coder, confidence, note, date |
| `data/case-data.csv` | One row per case, one column per node; 0, 1, or NA (NA = not observed); generated from the coding log |
| `data/clean/analysis-data.csv` | The data the model is updated on, built by `code/03-data.R` |
| `transparency/evidence-log.csv` | Every evidence item with its access tier; confidential rows carry metadata only |
| `transparency/annotations.md` | Excerpts and analytic notes for the claims the conclusions rest on most |
| `transparency/dependence.md` | Every answer with and without the values coded only from confidential evidence |
| `transparency/withheld-items.md` | What is not shared, why, and how it can be accessed |
| `transparency/qdr-deposit-plan.md` | What is deposited at the Qualitative Data Repository, under which access conditions |
| `output/` | Tables and figures as reported |
| `prereg/` | The preregistration and its dated addenda <or: not preregistered> |
| `transparency-manifest.txt` | SHA-256 checksum of every file in the package |

## Tracing a claim

1. A citation in the article, e.g. `[E014]`, names a row of `transparency/evidence-log.csv`: type, date, author or pseudonym, source, access tier.
2. The rows of `data/coding-log.csv` whose `evidence_ids` include E014 give each value it supports, the rule version applied, the coder, and the coder's confidence.
3. The rule is in `data/coding-rules.md` under the node's name; the value enters `data/case-data.csv`.
4. `code/04-update.R` updates the causal model on those values; `output/tables/queries.csv` holds every answer, prior next to posterior.

## Evidence and access

| Type | Open | Archive-restricted | Confidential | Total |
|---|---|---|---|---|
| <archival / interview / fieldnote / secondary / press / official / memoir / dataset / other> | | | | |

- **Open:** <files included, or the full citation where copyright bars redistribution>.
- **Archive-restricted:** obtainable by qualified researchers from the holding archive under its terms; the `source` column gives archive, collection, and reference code.
- **Confidential:** withheld to protect participants; rows give the pseudonym, a role category, the date at a precision that does not identify, the consent tier, and the nodes coded from the item. <Deposited at QDR under <access conditions>, applied for by <procedure> | Not deposited: consent did not cover deposit.>

## De-identification

<Who and what was pseudonymized (participants P01, P02, ...; places and organizations in brackets); what was coarsened (roles, dates, places) and to what; what was removed; how (an identity key held only by the authors, applied by script, with every output read before use); the residual risk, stated plainly.>

## Consent and ethics

<Approval by <board>, protocol <number>; the consent procedure (written or oral) and the attribution tiers offered; which tiers permit quotation, deposit, and processing by third-party software; how withdrawals were handled.>

## Dependence on confidential evidence

<N of M coded values rest only on confidential evidence. Setting them to not observed moves the primary answer from <a> to <b>; `transparency/dependence.md` gives every query, and each value set aside one at a time.>

## Computational requirements

- Software: R <version>; CausalQueries <version>, rstan <version>, and the other packages pinned in `renv.lock` (`renv::restore()` installs them); a C++ toolchain for Stan.
- Randomness: every stochastic step is preceded by `set.seed(<seed>)`; with serial chains, posterior draws are identical across runs.
- Hardware and time: <cores, memory>; wall time per script in the table below.

## Code

| Script | Purpose | Inputs | Outputs | Runtime |
|---|---|---|---|---|
| `code/01-model.R` | The causal model: DAG, restrictions, confounding, priors | none | `output/models/model.rds`, `output/tables/nodal-types.csv`, `output/tables/prior-queries.csv` | |
| `code/02-design.R` | Clue and case diagnosis | `output/models/model.rds` | `output/tables/clue-diagnosis.csv`, `output/tables/case-diagnosis.csv` | |
| `code/03-data.R` | Analysis data from the coded cases | `data/case-data.csv`, `data/raw/...` | `data/clean/analysis-data.csv` | |
| `code/04-update.R` | Update the model; answer every query | `output/models/model.rds`, `data/clean/analysis-data.csv` | `output/models/model-updated.rds`, `output/tables/queries.csv` | |
| `code/05-robustness.R` | Sensitivity to priors, restrictions, confounding, cases, sources | `output/models/model.rds`, `data/clean/analysis-data.csv` | `output/tables/robustness.csv` | |
| `code/06-figures.R` | Figures | `output/models/*.rds`, `output/tables/*.csv` | `output/figures/*` | |

## Instructions for replicators

1. Unzip the package and open R at its root (the folder holding `.here`).
2. `renv::restore()`.
3. Run every numbered script in order:
   ```r
   scripts <- sort(list.files("code", pattern = "^[0-9].*\\.R$", full.names = TRUE))
   for (f in scripts) source(f)
   ```
   or `Rscript code/01-model.R`, then each later script in turn.
4. Check the results against the checksums: `sha256sum -c transparency-manifest.txt`. Tables and figure data files (`*-data.csv`) match exactly; PDF figures, `.rds` files, and `session-info.txt` carry timestamps or machine details, so compare those by eye.

## Exhibits

| Exhibit | Script | Output file | Notes |
|---|---|---|---|
| Table 1 | | | |
| Figure 1 | | | |

## Preregistration and deviations

<Registry and link, date filed, addenda with their dates; each deviation beside the registered plan, with its effect on the primary answer; or "not preregistered".>

## Use of large language models

<Each task in which an LLM coded evidence, assessed likelihoods, transcribed, translated, or extracted text: the compiled checklist (`.qualstack/llm-checklist.md`), the ledger (`.qualstack/llm-usage.jsonl`), the verbatim prompts, and the agreement with human coders; or "none".>

## Deviations from the published article

<Any exhibit that differs from the published version, and why; or "none".>

## References

<Data citations (archives and collections, datasets with versions, the QDR deposit) and software citations (R; CausalQueries, Tietz, Medina, Syunyaev & Humphreys 2026; rstan) in the article's style.>
