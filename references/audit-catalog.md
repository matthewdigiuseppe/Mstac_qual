# Evidence audit catalog

Read by `/qualstack:evidence-audit`, after `/qualstack:analyze` and
`/qualstack:robustness` and again before submission. Each check: an ID the
audit memo uses, a severity, how it is verified (a command, a snippet at the
end, or a named reading), the failure it typically finds, the fix. The audit
runs on the files, in code and with the bin scripts, never on the author's
account of them; a check not run is FAIL.

## Severity and the verdict

| Severity | A FAIL means | Effect on the verdict |
|---|---|---|
| blocking | The trail is broken, an inference is wrong, or a participant is exposed | Any one makes it `fail` |
| must-explain | A defect a reader will find; fixed, or explained in the paper or appendix | Counts toward `fix-then-pass` |
| advisory | Weakens the paper without making a claim wrong | Listed; never decides it |

- **pass**: no blocking or must-explain FAIL.
- **fix-then-pass**: no blocking FAIL; at most three must-explain FAILs, each
  fixable without changing a coded value, the model, or a reported posterior.
  The memo lists each fix; the next audit confirms it.
- **fail**: any blocking FAIL; more than three must-explain FAILs; or a fix
  that would change a coded value or a reported number. Drafting
  (pre-writing) or submission (pre-submission) stops until a re-audit passes.
- **N.A.** needs a reason: `model.formal: false` (N3 to N5); no human
  subjects and no interview or field-note rows (P1 to P3); no
  `design.prereg_url` (G1, G2); a section not yet drafted at pre-writing.

## Evidence trail (T)

| ID | Check | Severity | How verified | Typical failure | Fix |
|---|---|---|---|---|---|
| T1 | Every `\ev{E###}` or `[E###]` in `paper/` names a row of `evidence/log.csv` | blocking | Snippet T (LaTeX comments excluded) | An ID typed from memory; a row deleted instead of withdrawn | Log the item (/qualstack:evidence-log) or correct the ID |
| T2 | No cited item is withdrawn | blocking | Snippet T (`notes` starting `withdrawn:`) | A withdrawn interview still cited in the cases section | Another item for the claim, or drop the claim; codes resting on it go to NA |
| T3 | Every logged file exists; no ID twice; no row points into `restricted/` | blocking | `qualstack-status` EVIDENCE TRAIL line; `check-log.py` errors on files and IDs | A scan renamed after logging; an original logged by its `restricted/` path | Restore the file or fix `file`; log the pseudonymized copy, never the original |
| T4 | Every file in `evidence/raw/` has a row; rows complete | must-explain | `qualstack-status` unlogged files; `check-log.py`'s other errors and its warnings | The last archive day's photos never logged; `reliability` blank | Log each, dated the day received; finish /qualstack:source-critique |
| T5 | Every cited archival PDF has its text in `evidence/md/` | must-explain | quotecheck `unchecked` rows naming archival items | Scans converted without `--name-by-file` | /qualstack:pdf-ingest with the archival flags (`pdf-extraction.md`) |

## Quotations (Q)

| ID | Check | Severity | How verified | Typical failure | Fix |
|---|---|---|---|---|---|
| Q1 | No quotation `not-found` | blocking | `qualstack-quotecheck` (exit 1 on Q1, Q2) | Quoted from notes, not the source; a paraphrase in quotation marks | Quote the source verbatim, or paraphrase without quotation marks |
| Q2 | No quotation `elsewhere` | blocking | Same | Two cables from one week swapped | Cite the item that holds it; check the claim still follows |
| Q3 | No quotation `uncited` | must-explain | Same; uncited and found nowhere counts as Q1 | A quotation followed only by a secondary's `\cite` | Add the `\ev{}` of the item it comes from |
| Q4 | Every `near` checked by eye | must-explain | The source at the passage; OCR text against the PDF page image | An ellipsis that drops "not"; OCR reading "now" for "not" | Requote from the source, `[sic]` where meant; fix OCR in `evidence/md/` and note it in the log |
| Q5 | Every `unchecked` resolved | must-explain | Not converted (convert, re-run), or participant text Claude may not open | Interview quotes under `privacy.ai_processing: none` | The author checks each on the memo's hand-check list against the transcript and confirms |
| Q6 | Short decisive quotations checked | advisory | `--min-words 3` on `paper/sections/cases.*` | A three-word phrase from a cable that carries a clue | As Q1 to Q4 |

## Coding (C)

| ID | Check | Severity | How verified | Typical failure | Fix |
|---|---|---|---|---|---|
| C1 | `data/case-data.csv` equals the log's row of record (last row per case and node), cell for cell | blocking | Snippet C | Case data edited by hand after a recode | Regenerate with `coding-tools.py build` (/qualstack:code-evidence) |
| C2 | Every row of record has evidence IDs that resolve and are not withdrawn, the node's current `rule_version`, coder, confidence, date; every case has a row for every node | blocking | `coding-tools.py build --dry-run` exits 0 | A rule bumped to v3 and only the cases that hurt recoded | Recode every case on the node under the current version; old rows stay |
| C3 | No 0 coded from silence | blocking | Snippet C prints every 0 with its note; read each against the rule's `0 if` | "Not mentioned in the minutes"; a search that never reached the series that would record the clue | NA, or cite the search record and argue the miss probability in a memo (`concepts-and-coding.md`) |
| C4 | NA means not observed and does not depend on the value | must-explain | NA notes by node: "never looked" vs. "searched short of the 0 standard"; NAs bunched in cases that would hurt the hypothesis | Clues sought only where expected | Seek the clue across the whole cell, or model detection (`K -> Kf`) |
| C5 | Second-coder agreement computed before adjudication and reported | must-explain | `.qualstack/review-cache/coding-<date>/agreement.md` (`coding-tools.py agree`); per-node cross-tab, kappa or alpha, specific agreement in the appendix | Agreement after adjudication; percent agreement alone at a 90% base rate | Recompute on pre-adjudication codes; report all three and how adjudication moved values |
| C6 | An LLM coder is a logged instrument | must-explain | Every `coder` = `llm:<id>` has its task in `.qualstack/llm-usage.jsonl` | Batch coding with an unlogged model version | /qualstack:llm-checklist `log` |

## Numbers and reproduction (N)

| ID | Check | Severity | How verified | Typical failure | Fix |
|---|---|---|---|---|---|
| N1 | Every number in the paper's text matches `output/tables/*.csv` at its reported precision | must-explain | Snippet N1 (decimals, percentages); counts by hand (cases = rows of `data/clean/analysis-data.csv`, interviews = interview rows of the log) | A number from an earlier run; 66% written for a share of 0.62 | Copy from the current table; a derived number shows its inputs |
| N2 | Each number comes from the row its sentence claims | blocking | Find the row: `using` (posteriors unless the text says prior), `given` (the case's observed values), `case_level` (the question named) | A prior reported as the finding; a `using = "parameters"` row reported as a posterior | Quote the right row, or rewrite the sentence to the question the row answers |
| N3 | The tables reproduce from a clean session with the seed | blocking | Snippet N3a (snapshot; `01-model.R`, `03-data.R`, `04-update.R` rerun with `Rscript`, all numbered scripts pre-submission), then N3b | `model.rds` older than `01-model.R`; data rebuilt by hand; an unseeded prior query | Fix the script, rerun, re-audit |
| N4 | `SEED` equals `model.seed`; `set.seed(SEED)` before every stochastic call; `using =` on every query | must-explain | Snippet N4 (parses the scripts; calls span lines) | `query_model()` without `using`: evaluated at flat parameters, `sd` NA | `r-conventions.md`; a reported number from such a call also fails N2 |
| N5 | The sampler converged | blocking | `output/models/stan-warnings.txt` reads `none` | ESS warnings at the default iterations, numbers reported anyway | Raise `ITER` until it reads `none`; rerun N1 to N3 |
| N6 | The environment is recorded | must-explain (advisory pre-writing) | `renv.lock` committed; `output/session-info.txt` from the last run | Package versions known only from memory | `renv::snapshot()`; rerun |

**Tolerance for N3.** On the machine and `renv.lock` that made the tables the
rerun is identical (a seeded `update_model()` is bit-identical; a seeded prior
query repeats), so any difference there is an unseeded call or a changed
input. Elsewhere the rerun is a second Monte Carlo draw: allow 4 × sd/√ESS on
means and sds (sd the largest posterior sd in `queries.csv`, ESS the smallest
`n_eff` in the stan summary), twice that on interval endpoints and case-level
rows. Four, because a difference of two draws has √2 times the error and
dozens of numbers are compared: with sds near 0.2 and `n_eff` near 1,300 the
tolerance is 0.026, and five reseeded reruns moved by at most 0.028, on
interval endpoints. State it in the memo; a larger gap is a bug. A reported
digit that changes under a second seed is noise: one digit fewer, or more
`ITER`.

## Inference (I)

| ID | Check | Severity | How verified | Typical failure | Fix |
|---|---|---|---|---|---|
| I1 | Every case-level claim names its question and uses no case twice | blocking | Read each: the share of cases like this one (uninformative case, π̂, `case_level = FALSE`) or a case drawn blind (informative case, φ̂, `case_level = TRUE`, one number, no interval); snippet I lists posterior φ̂ rows whose given is a case in the update; case IDs unique in `analysis-data.csv` | A φ̂ answer for a case already in the update; a population share stated as the verdict on one case | π̂ for cases in the data (`output/tables/case-answers.csv`); φ̂ only for a new case, said so (`mixed-methods.md`) |
| I2 | No restriction-driven answer reported as a finding | blocking | Snippet I lists exact 0s and 1s; for each, logic (the given contradicts the query) or a restriction; the unrestricted run in the robustness memo | "Inequality never caused democratization without mobilization" when monotonicity forces it | Report it as an assumption, the restriction named, beside the unrestricted answer |
| I3 | Test labels never stand in for stated likelihoods | must-explain | Grep list I3 in `paper/`; each hit beside its φ's or its prior and posterior | "The mediator passes a hoop test", no numbers | State Pr(K \| H), Pr(K \| not H), the prior, the posterior (`bayesian-process-tracing.md`) |
| I4 | Claims sized to posteriors | must-explain | Grep list I4 in `paper/`; each hit against its number; every posterior beside its prior | "Proves" for a posterior of 0.71 | The number in the sentence and a verb that matches it; never "proves" |
| I5 | A counterfactual table for every traced case | must-explain | Each `.qualstack/process-trace-<case>.md` and the paper or appendix: per clue, the posterior had it come out the other way; no clues, each alone, all | Only the path the evidence took, never what it could have shown | /qualstack:process-trace (`qs_trace_case()`) |
| I6 | Dependence among sources handled | blocking | Log `notes` with `derivative of`; one participant's story told twice; a memoir and the interview built on it: counted once in the coding log and the trace | Five press reports of one leak as five confirmations | Trace reports to origins; count origins; condition later items on earlier ones |
| I7 | Informal updating is disciplined (`model.formal: false`, or evidence outside the model) | must-explain | Priors stated with reasons before the evidence; likelihoods as ranges with the posterior at both ends; order fixed before reading | Likelihoods tuned until the posterior reaches 0.9 | `qs_informal_trace()`; likelihoods dated in the clue plan |

## Selection (S)

| ID | Check | Severity | How verified | Typical failure | Fix |
|---|---|---|---|---|---|
| S1 | The selection log covers every case with within-case data | must-explain | `.qualstack/case-selection.md` against the cases with any non-NA clue in `data/clean/analysis-data.csv` | A case added because an archive opened, never logged | Log the rule that actually put it there and the values it used |
| S2 | The rule is ignorable, modeled, or the claim narrowed | blocking | `mixed-methods.md` selection table: chosen on recorded values or at random with every case kept is ignorable; chosen on the outcome with others dropped, or on promise, is not | Only the democratizers kept; access followed success | Keep every case with NA clues; `censored_types`, or the selecting variable as a node; or narrow the population claim |
| S3 | No untraced case dropped | blocking | Rows of `analysis-data.csv` against the frame in `case-selection.md` | Non-traced cases removed for having "no evidence" | Restore them with NA clues; rerun |

## Privacy and consent (P)

| ID | Check | Severity | How verified | Typical failure | Fix |
|---|---|---|---|---|---|
| P1 | No keyed real name anywhere | blocking | `qualstack-redact check` exits 0; with human subjects and `qualstack-redact status` reporting no key, FAIL | A name in a coding-log note or a memo | The pseudonym; check copies already shared |
| P2 | Nothing quoted or cited beyond its consent tier | blocking | Snippet P (quoted interviews whose tier is background or deep background); snippet T (deep background cited) | A background interview quoted verbatim | Paraphrase without attribution (background); find a citable source (deep background) |
| P3 | No indirect identifiers | blocking | Grep list P3 in `paper/`; each attribution a pseudonym plus a coarse role, at most one precise indirect identifier; the insider test (`transparency-and-ethics.md`) | "P07, deputy finance minister, in the capital the week of the devaluation" | Coarsen to a category at least five people fit |
| P4 | Shared files carry no participant text beyond the tier | must-explain | `data/coding-log.csv` notes, `output/`, memos bound for deposit | Quotations pasted into coding-log notes | E-ID and a paraphrase |

## Robustness (R)

| ID | Check | Severity | How verified | Typical failure | Fix |
|---|---|---|---|---|---|
| R1 | The newest `.qualstack/robustness-*.md` exists and is current | blocking | Absent from `qualstack-status` STALE (older than `code/01-model.R`, `code/04-update.R`, `code/05-robustness.R`, `data/case-data.csv`) | Robustness run before the last recode | /qualstack:robustness |
| R2 | Its conclusion is in the paper | must-explain | Each answer it calls sensitive (priors, restrictions, a coding flip, one case, one source) reported as such; its sensitivity sentence in results; reliance on confidential-only codes reported | A headline that holds under one prior, unqualified | Qualify the headline; carry the sentence into results |

## Preregistration (G)

| ID | Check | Severity | How verified | Typical failure | Fix |
|---|---|---|---|---|---|
| G1 | Every departure has a dated addendum written before the affected evidence was coded | blocking | `prereg/prereg.md` and `prereg/addendum-*.md` against `code/01-model.R`, `.qualstack/queries.md`, `.qualstack/case-selection.md`, `.qualstack/clue-plan.md`, and `sha256sum data/coding-rules.md` against the registered hash; addendum dates against the first coding-log `date` on each affected node | A rule revised after the clue was seen, no addendum | Results under both versions, the change labeled post hoc |
| G2 | The paper lists every deviation beside the original plan | must-explain | `paper/sections/design.*` or the appendix | Deviations in a footnote, the plan omitted | A table: planned, done, why, when |

## Detection snippets

Run from the project root, R snippets as `Rscript -e '<snippet>'` (none
contains a single quote); none reads `restricted/` or opens an evidence file.
The ID prefix `E` follows `evidence.id_prefix`. Two validators other skills
ship run as they are:

- `python3 "${CLAUDE_PLUGIN_ROOT}/skills/evidence-log/assets/check-log.py"`: T3, T4.
- `python3 "${CLAUDE_PLUGIN_ROOT}/skills/code-evidence/assets/coding-tools.py" build --dry-run`: C2 (writes nothing).

```r
# T: citations in paper/ against evidence/log.csv
x <- unlist(lapply(Sys.glob(c("paper/main.*", "paper/sections/*")), function(f) {
  l <- readLines(f, warn = FALSE)
  if (grepl("[.]tex$", f)) sub("(^|[^\\\\])%.*", "\\1", l, perl = TRUE) else l }))
cit <- unlist(regmatches(x, gregexpr("\\\\ev\\{[^}]*\\}|\\[E[0-9]+([;, ]+E[0-9]+)*\\]", x)))
ids <- unique(unlist(regmatches(cit, gregexpr("E[0-9]+", cit))))
lg <- read.csv("evidence/log.csv", colClasses = "character")
cat("items cited:", length(ids), "\nnot in the log:", setdiff(ids, lg$id),
    "\nwithdrawn:", intersect(ids, lg$id[grepl("^withdrawn", lg$notes)]),
    "\ndeep background:", intersect(ids, lg$id[grepl("deep background", lg$notes, ignore.case = TRUE)]), "\n")
```

```r
# C: case data against the row of record; every 0 with its note
cd <- read.csv("data/case-data.csv", colClasses = "character", na.strings = "")
lg <- read.csv("data/coding-log.csv", colClasses = "character", na.strings = "")
rec <- lg[!duplicated(lg[c("case", "node")], fromLast = TRUE), ]
for (n in setdiff(names(cd), "case")) for (i in seq_len(nrow(cd))) {
  r <- rec$value[rec$case == cd$case[i] & rec$node == n]
  if (!identical(r, cd[[n]][i])) cat(cd$case[i], n, ": case data", cd[[n]][i], "| log", c(r, "(no row)")[1], "\n")
}
print(rec[rec$value == "0", c("case", "node", "evidence_ids", "note")], row.names = FALSE)
```

```r
# N1: numbers in the paper that match no table value at their reported precision
v <- unlist(lapply(Sys.glob("output/tables/*.csv"), function(f) {
  d <- read.csv(f); unlist(d[vapply(d, is.numeric, TRUE)]) }))
v <- v[is.finite(v)]
for (f in Sys.glob("paper/sections/*")) {
  l <- readLines(f, warn = FALSE)
  if (grepl("[.]tex$", f)) l <- sub("(^|[^\\\\])%.*", "\\1", l, perl = TRUE)
  l <- gsub("\\\\(ev|cite[a-z]*|ref|label|input|include[a-z]*|[hv]space)\\*?(\\[[^]]*\\])*\\{[^}]*\\}|\\[E[0-9][^]]*\\]", " ", l)
  m <- regmatches(l, gregexpr("(?<![\\w.])(\\d*\\.\\d+|\\d+)(\\s*(\\\\%|%| percent))?", l, perl = TRUE))
  for (i in seq_along(l)) for (s in m[[i]]) {
    pct <- grepl("%|percent", s); x <- sub("\\s*(\\\\%|%| percent)$", "", s)
    if (!pct && !grepl(".", x, fixed = TRUE)) next          # integers: years, counts (by hand)
    h <- 0.5 * 10^-nchar(sub("^[^.]*\\.?", "", x)) + 1e-9    # half a unit in the last digit
    ok <- any(abs(v - as.numeric(x) / if (pct) 100 else 1) <= h / if (pct) 100 else 1) ||
          (pct && any(abs(v - as.numeric(x)) <= h))
    if (!ok) cat(sprintf("%s:%d  %s\n", f, i, s))
  }
}
```

```r
# N3a: snapshot the tables, then rerun, each script its own fresh Rscript session
# (pre-writing 01, 03, 04 as here; pre-submission every script: "code/0[1-6]-*.R")
s <- file.path(".qualstack", "review-cache", paste0("evidence-audit-", Sys.Date()))
dir.create(s, recursive = TRUE, showWarnings = FALSE)
file.copy(Sys.glob("output/tables/*.csv"), s, overwrite = TRUE)
for (f in sort(Sys.glob("code/0[134]-*.R"))) if (system2("Rscript", f) != 0) stop("failed: ", f)
```

```r
# N3b, after the rerun: compare with the snapshot, at the tolerance above
s <- file.path(".qualstack", "review-cache", paste0("evidence-audit-", Sys.Date()))
ss <- CausalQueries::grab(readRDS("output/models/model-updated.rds"), "stan_summary")
tok <- strsplit(trimws(ss[-seq_len(grep("n_eff", ss)[1])]), "\\s+")
ess <- min(suppressWarnings(as.numeric(sapply(tok, function(t) t[max(1, length(t) - 1)]))), na.rm = TRUE)
tol <- 4 * max(read.csv("output/tables/queries.csv")$sd, na.rm = TRUE) / sqrt(ess)
cat(sprintf("smallest n_eff %.0f; tolerance %.3f on means, %.3f on intervals and case-level rows\n", ess, tol, 2 * tol))
for (f in list.files(s, "[.]csv$")) {
  a <- read.csv(file.path(s, f)); b <- read.csv(file.path("output", "tables", f))
  n <- vapply(a, is.numeric, TRUE)
  if (!identical(dim(a), dim(b)) || !identical(a[!n], b[!n])) { cat(f, ": rows or labels differ\n"); next }
  d <- abs(as.matrix(a[n]) - as.matrix(b[n])); d[is.na(d)] <- 0
  lim <- matrix(2 * tol, nrow(d), ncol(d), dimnames = dimnames(d))
  if ("sd" %in% names(a)) lim[!is.na(a$sd), intersect(c("mean", "sd"), colnames(d))] <- tol
  cat(sprintf("%-20s max |diff| %.3f  %s\n", f, max(d), if (all(d == 0)) "identical" else
      if (all(d <= lim)) "within Monte Carlo error" else paste("FAIL:", paste(unique(colnames(d)[which(d > lim, arr.ind = TRUE)[, 2]]), collapse = " "))))
}
```

```r
# N4: seeds and using = in every script
seed <- sub("^\\s*seed:\\s*([0-9]+).*", "\\1", grep("^\\s+seed:", readLines(".qualstack/config.yaml"), value = TRUE))
for (f in Sys.glob("code/*.R")) {
  pd <- getParseData(parse(f, keep.source = TRUE))
  fn <- pd[pd$token == "SYMBOL_FUNCTION_CALL", ]
  txt <- vapply(pd$parent[match(fn$parent, pd$id)], function(i) getParseText(pd, i), "")
  for (t in txt[fn$text %in% c("query_model", "query_distribution") & !grepl("using\\s*=", txt)])
    cat(f, ": no using = in ", substr(gsub("\\s+", " ", t), 1, 60), "\n", sep = "")
  rand <- fn$text %in% c("update_model", "make_data", "make_events", "set_prior_distribution",
                         "draw_causal_type") | grepl("using\\s*=[^)]*\"priors?\"", txt)
  if (any(rand) && !any(fn$text == "set.seed")) cat(f, ": stochastic calls, no set.seed()\n")
  s <- sub("^SEED\\s*<-\\s*([0-9]+).*", "\\1", grep("^SEED\\s*<-", readLines(f), value = TRUE))
  if (length(s) && any(s != seed)) cat(f, ": SEED ", s, ", model.seed ", seed, "\n", sep = "")
}
```

```r
# I: posterior case-level rows whose given is a case in the update; answers pinned at 0 or 1
q <- read.csv("output/tables/queries.csv"); d <- read.csv("data/clean/analysis-data.csv")
v <- setdiff(names(d), "case")
obs <- lapply(seq_len(nrow(d)), function(i) { r <- unlist(d[i, v]); sort(paste0(names(r), "==", r)[!is.na(r)]) })
for (i in which(q$case_level %in% TRUE & q$using == "posteriors" & q$given != "-")) {
  hit <- d$case[vapply(obs, setequal, TRUE, sort(gsub("[() ]", "", strsplit(q$given[i], "&")[[1]])))]
  if (length(hit)) cat(q$label[i], "|", q$given[i], "| case_level = TRUE, but in the update:", hit, "\n")
}
for (f in Sys.glob("output/tables/*.csv")) { t <- read.csv(f)
  if ("mean" %in% names(t) && any(t$mean %in% c(0, 1))) { cat(f, "\n"); print(t[t$mean %in% c(0, 1), ], row.names = FALSE) } }
```

```bash
# P: quotations of interviews whose consent tier allows none
python3 "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-quotecheck" --json | python3 -c '
import csv, json, sys
log = {r["id"]: r for r in csv.DictReader(open("evidence/log.csv", newline="", encoding="utf-8-sig"))}
for q in json.load(sys.stdin)["quotes"]:
    for i in q["cites"]:
        r = log.get(i, {})
        if r.get("type") == "interview" and "background" in r.get("notes", "").lower():
            print(q["file"] + ":" + str(q["line"]), i, "quoted; its consent tier allows no quotation")'
```

Grep lists (case-insensitive, Grep tool over `paper/`; read each hit in context):

- **I3**: `hoop|smoking gun|doubly decisive|straw in the wind`
- **I4**: `prov(e|es|ed|en)\b|conclusive|definitiv|beyond (any )?doubt|establish(es|ed)? that|confirm(s|ed)? that|demonstrat(es|ed) that|undeniabl`
- **P3**: `\bP[0-9]{2}\b`, then the attribution around each hit
