---
name: archive
description: Assembles the transparency package for a qualitative or multi-method paper at acceptance — model code and coded case data, the coding log and rules, the evidence log exported with access tiers (confidential rows keep metadata, never content), active-citation or ATI-style annotations for the evidence that can be shared, a QDR deposit plan and a withheld-items table, a statement of how far each answer depends on confidential evidence, and a README from the bundled template — then checksums every shared file, scans for keyed names, and rebuilds every formal result from a clean copy of the package. Use at acceptance, when the user asks for a replication or transparency package, or mentions a QDR deposit, ATI, active citation, or the journal's data policy.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebFetch
  - Bash(date *)
  - Bash(python3 *)
  - Bash(Rscript *)
  - Bash(sha256sum *)
  - Bash(cut *)
  - Bash(zip *)
  - Bash(unzip *)
  - Bash(mktemp *)
  - Bash(cd *)
  - Bash(git log *)
  - Bash(git show *)
---

# /qualstack:archive

**Stage:** reflect (at acceptance) · **Voice:** replicator

At acceptance, before the production deadline. The goal is not the journal's data policy; it is that in two years a stranger can trace every `\ev{}` to its log row, rerun every posterior from the coded data with the seed, and see how much of each answer rests on evidence they will never read. Protection wins every conflict with openness: what cannot be shared is described, counted, and routed, never quietly dropped.

## Procedure

1. **Load** `.qualstack/config.yaml` (title, `short_name`, the accepting journal, `model.seed`, `model.formal`, `privacy.*`, `design.prereg_url`); `Read ${CLAUDE_PLUGIN_ROOT}/references/transparency-and-ethics.md` ("Forms of transparency for qualitative work", "The transparency package at publication"); the journal's current data policy and QDR's current deposit terms and access options (WebFetch; never from memory). The `Verdict:` line of the newest `.qualstack/evidence-audit-*.md` must read `pass`.
2. **What ships is an allowlist**, never the project minus exclusions: `.here`; `README.md`; every numbered script in `code/` and the helpers they `source()`; `data/coding-rules.md`, `data/case-data.csv`, `data/coding-log.csv`, `data/clean/analysis-data.csv`, and the `data/raw/` files whose licenses allow redistribution (the rest cited with version and access route); `output/tables/`, `output/figures/`, `output/models/session-info.txt`; `renv.lock`, `renv/activate.R`, `.Rprofile`; `prereg/` with every addendum; `.qualstack/llm-usage.jsonl`, `.qualstack/llm-checklist.md`, and the prompt, brief, and agreement files the ledger names; the accepted manuscript and appendix, as the journal's terms allow; the `transparency/` files written below. Never `restricted/`, `evidence/raw/`, `evidence/md/`, or `lit/pdf/`; memos (`evidence/memos/`, `.qualstack/`) only after a read for identifiers; a brief or memo that quotes confidential evidence stays out and goes on the withheld list.
3. **Code, data, dependencies.** `set.seed()` with `model.seed` precedes every stochastic call (`update_model()`, `make_data()`, prior queries). Pin packages with renv (`renv::init()` if the project does not use it yet, then `renv::snapshot()`), so `renv.lock`, `renv/activate.R`, and `.Rprofile` ship and the clean room restores into its own library, never the user's; the README records the R, CausalQueries, and rstan versions and the C++ toolchain Stan needs. The `note` column of `data/coding-log.csv` reads as publication (no names, no confidential quotations). A rule whose text changed ships its earlier versions from the history (`git log --follow -- data/coding-rules.md`, then `git show <rev>:data/coding-rules.md` into `transparency/coding-rules-<date>.md`). With `model.formal: false` the analysis is the likelihood table: export it from `.qualstack/process-trace-*.md` to `transparency/likelihoods.md`, read for identifiers.
4. **Evidence log export** to `transparency/evidence-log.csv`: the same columns, every row, withdrawn ones included. `open`: the full row. `archive-restricted`: the full citation and the access route (archive, collection, reference code) in `source`. `confidential`: `id`, `type`, `author` (the pseudonym), `access`, `cases`, `clues`, the `reliability` numbers without their reasons, and `date` coarsened to the year in small populations; `title` a category ("interview, senior ministry official"), `source` a category, `file` set to `withheld`, `notes` the consent tier only. Every ID cited in the paper has a row.
5. **Excerpts and annotations** to `transparency/annotations.md`, in the form of active citation (Moravcsik 2010, 2014): one entry per claim, starting with the clues that move the primary query most (the counterfactual tables in `.qualstack/process-trace-*.md`): the claim and its place in the paper; the E-ID and full citation; an excerpt no longer than the access tier and consent permit (none for background or deep background); the analytic note (node, value, rule version, likelihoods or probative value, how far it moved the posterior). Check the excerpts with `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-quotecheck transparency/annotations.md`. Where QDR and the journal currently offer ATI for the article type, format the same entries for it.
6. **QDR deposit plan** to `transparency/qdr-deposit-plan.md`: per item, whether consent and the archive's terms allow deposit, the proposed access level from QDR's current options, the de-identification and coarsening done, the files; package metadata (title, authors, related publication, keywords, license), embargo, timeline. Whatever goes nowhere goes to `transparency/withheld-items.md`: the item or category, why, and the access route, even if "none".
7. **README** from `${CLAUDE_PLUGIN_ROOT}/templates/transparency-README.md` into `README.md`, every section filled: overview and runtime, tracing a claim, evidence and access, de-identification and consent, dependence, computational requirements, the code table, replicator instructions, the exhibits table mapping every table and figure in paper and appendix to its script and output, preregistration and deviations, LLM use, deviations from the published article, data and software citations.
8. **Leak check.** `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-redact check` on everything that ships, named explicitly (its default set misses `code/`, `transparency/`, and `README.md`), must exit 0, except for on-the-record names cleared in writing (a "no key file" failure is acceptable only when `design.human_subjects` is false and nobody is pseudonymized); no shipped path is under `restricted/` or `evidence/raw/`; document metadata stripped (PDF author fields, photo EXIF).
9. **Manifest and package.** `sha256sum` over every file in the sorted allowlist into `transparency-manifest.txt`; then `cut -c67- transparency-manifest.txt | zip -X submission/transparency-<short_name>.zip -@ transparency-manifest.txt` builds the zip from exactly those paths and nothing else.
10. **Clean-room rebuild, from the zip, not the project.** `mktemp -d` (note the path: outside the project, so `here()` resolves to the copied `.here`), `unzip` the package there, and from its root run `Rscript -e 'renv::restore(prompt = FALSE)'`, then `Rscript code/01-model.R` and every later numbered script in order (if a `data/raw/` file cannot ship, skip `code/03-data.R`, rebuild from the shipped `data/clean/analysis-data.csv`, and say so in the README), then `sha256sum -c transparency-manifest.txt`. Tables and `*-data.csv` files must match byte for byte (seeded, serial chains); PDFs, `.rds` files, and `session-info.txt` carry timestamps or machine details, so read those differences rather than count them. **Refuse to mark the package ready while any divergence is unexplained or any exhibit lacks a producing script.**
11. **Dependence statement**, in the same clean room. In `data/clean/analysis-data.csv`, the file `code/04-update.R` reads, set to NA every value whose current row in `data/coding-log.csv` (the latest per case and node) cites only items whose `access` is `confidential` in `transparency/evidence-log.csv` (values taken from a cross-case dataset stay); rerun `Rscript code/04-update.R`; write `transparency/dependence.md`: each query's prior, posterior with all evidence, and posterior without; the values set to NA (case, node, E-IDs); the count of values coded from mixed evidence (kept); the one-at-a-time results from the newest `.qualstack/robustness-*.md`. Repeat with `archive-restricted` added if the journal or QDR asks what rests on evidence a reader cannot download. With `model.formal: false`, recompute the informal posterior with those items' likelihood ratios set to 1. The README states the headline: "N of M coded values rest only on confidential evidence; without them the primary answer moves from a to b." The package changed, so regenerate the manifest and the zip; code and data did not, so the rebuild stands.
12. **Config:** `paper.status: "archived"`; once the user has the deposit DOI, add it to `README.md` and append a dated line to `decisions:`.

## Outputs

- `transparency-manifest.txt`; `README.md`; `renv.lock`; `transparency/` (`evidence-log.csv`, `annotations.md`, `qdr-deposit-plan.md`, `withheld-items.md`, `dependence.md`); `submission/transparency-<short_name>.zip`.
- Summary block: files shipped and withheld, counts by access tier, redact and quotecheck results, rebuild divergences (should be none), exhibits without a script (should be none), the dependence headline, the deposit destination and the next manual step.

## Anti-patterns

- **Zipping the project and excluding.** Build from the allowlist; one forgotten exclusion ships an identity key.
- **Skipping the clean-room rebuild.** Without it this is not a transparency package.
- **A confidential row that leaks content.** Metadata and categories only; an interview's title is a category, not a summary.
- **Excerpts past the consent tier.** An annotation is publication.
- **Hiding the dependence.** "Some evidence is confidential" is not a statement; the posterior with and without it is.
- **"Available upon request."** Not a package, whatever the journal allows.
- **An exhibit with no script.** Every table and figure maps to code.

## Next

`/qualstack:retro` before the lessons fade; `/qualstack:learn` for conventions that generalize (global memory, not the project's `learnings.jsonl`).
