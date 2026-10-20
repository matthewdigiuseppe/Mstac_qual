---
name: evidence-audit
description: Staff-methodologist audit of a qualitative or mixed-method project on disk, after analysis and before submission. Checks that every evidence citation resolves to a logged item whose files exist; every quotation matches its source; every coded value traces to evidence under the current rule, with no 0 coded from silence and second-coder agreement reported; every number matches output/tables and reproduces from a clean R session with the seed; case-level claims name their question and use no case twice; no restriction-driven answer is reported as a finding; case selection is ignorable or modeled; nothing exceeds a consent tier or identifies a participant; the robustness memo is current and reflected; preregistration deviations are reported. Writes a dated memo with PASS, FAIL, or N.A. and evidence per check, and a pass / fix-then-pass / fail verdict. Use after /qualstack:robustness, before drafting results, again before submission, or when the user asks to check the evidence trail, quotes, coding, or numbers.
argument-hint: "[pre-writing|pre-submission]"
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
  - Bash(date *)
  - Bash(python3 *)
  - Bash(Rscript *)
  - Bash(sha256sum *)
  - Bash(git rev-parse *)
---

# /qualstack:evidence-audit

**Stage:** analyze (post-analysis and pre-writing; again pre-submission) · **Voice:** staff-methodologist

Finds what the area-expert referee, the replicator, or a participant reading the published article would otherwise find. The audit runs on the files, in code and with the bin scripts, never on the author's account of them. It diagnoses and does not fix, and a check that was not run is FAIL.

## Procedure

1. **Scope and gates.** `$ARGUMENTS` is `pre-writing` or `pre-submission`; if empty, infer it from `paper.status` in `.qualstack/config.yaml` (`analyzing` or earlier: pre-writing; `writing` or later: pre-submission). Read `privacy.ai_processing` before anything else: with `none` or empty, open nothing derived from participants (transcripts, field notes, excerpts of them) and put every check that would need them on the author's hand-check list. Never read, grep, or list `restricted/`, and run nothing that names it. Note `model.formal`, `model.seed`, `design.prereg_url`, the date (`date +%Y-%m-%d`), and the commit (`git rev-parse --short HEAD`, if under git).
2. **Load.** Read `${CLAUDE_PLUGIN_ROOT}/references/audit-catalog.md` (check IDs, severities, detection snippets, fixes), then `concepts-and-coding.md`, `mixed-methods.md`, `bayesian-process-tracing.md`, `transparency-and-ethics.md`, and `r-conventions.md` as the checks need them. Then the project: `paper/sections/*`, `evidence/log.csv`, `data/coding-rules.md`, `data/coding-log.csv`, `data/case-data.csv`, `data/clean/analysis-data.csv`, `code/0[1-6]-*.R`, `output/tables/`, `.qualstack/queries.md`, `.qualstack/case-selection.md`, `.qualstack/process-trace-*.md`, the newest `.qualstack/robustness-*.md`, and `prereg/` if registered.
3. **Run the checks** in this order, each recorded as PASS, FAIL, or N.A. with its evidence (counts, command output, file:line, case and node); an N.A. carries the catalog's reason. Run the catalog's snippets from the project root as `Rscript -e '<snippet>'`.
   - **Evidence trail (T1–T5).** Snippet T: every `\ev{E###}` (or `[E###]`) in `paper/` resolves to a row of `evidence/log.csv`, and no cited item is withdrawn. `python3 "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-status"`: the EVIDENCE TRAIL section is clean (no unlogged file, missing file, duplicate ID, or row pointing into `restricted/`); `python3 "${CLAUDE_PLUGIN_ROOT}/skills/evidence-log/assets/check-log.py"` exits 0.
   - **Quotations (Q1–Q6).** `python3 "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-quotecheck"`: zero `not-found`, `elsewhere`, and `uncited`. Open every `near` at its passage and check it by eye (archival OCR text against the PDF page image; an interview only if `privacy.ai_processing` allows, else the hand-check list); resolve every `unchecked`; then rerun with `--min-words 3` on `paper/sections/cases.*`, where short decisive phrases live.
   - **Coding (C1–C6).** `python3 "${CLAUDE_PLUGIN_ROOT}/skills/code-evidence/assets/coding-tools.py" build --dry-run` exits 0 (current `rule_version`, evidence IDs that resolve, a row for every case and node). Snippet C: `data/case-data.csv` equals the coding log's row of record, cell for cell. Read every 0's note: positive evidence of absence, or a search that would have found the clue; silence is a FAIL. NA notes say why the value was not observed. Second-coder agreement (per-node cross-tab, kappa or alpha, before adjudication) is on file and reported; an LLM coder is logged in `.qualstack/llm-usage.jsonl`.
   - **Numbers (N1–N6).** Snippet N1: every number in the paper's abstract, introduction, cases, and results matches a value in `output/tables/` (`queries.csv` first) at its reported precision; counts match the data and the log. Each number comes from the row its sentence claims (`using`, `given`, `case_level`). Snippet N3a snapshots the tables and reruns `01-model.R`, `03-data.R`, and `04-update.R` (pre-submission: the glob `code/0[1-6]-*.R`), each as its own `Rscript` process, which never restores a workspace (never `--vanilla`, which skips renv's `.Rprofile`); the rerun rewrites `data/clean/` and `output/`, so under an active `/qualstack:freeze` elsewhere ask first. Snippet N3b compares: identical on the machine that made the tables, otherwise within the catalog's Monte Carlo tolerance, stated in the memo. Snippet N4 (seeds, `using =`); `output/models/stan-warnings.txt` reads `none`; `renv.lock` and `output/session-info.txt` exist. With `model.formal: false`, compare numbers against the process-trace memos; N3 to N5 are N.A.
   - **Inference (I1–I7).** Each case-level claim says which question it answers: the share of cases like this one (uninformative case, `case_level = FALSE`) or a case drawn blind (informative case, `case_level = TRUE`: one number, no interval). Snippet I flags an informative-case answer for a case already in the update, which uses its data twice, and every exact 0 or 1: one forced by a restriction is an assumption, never a finding. Test labels (hoop, smoking gun) never stand in for stated likelihoods; claims are sized to posteriors with priors beside them, and nothing "proves" (the catalog's Grep lists). Every traced case has its counterfactual table. Sources that share an origin count once.
   - **Selection (S1–S3).** `.qualstack/case-selection.md` gives the rule for every case with within-case data; the rule is ignorable or modeled by `mixed-methods.md`'s table, or the population claim is narrowed; no untraced case is missing from `data/clean/analysis-data.csv`.
   - **Privacy and consent (P1–P4).** `python3 "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-redact" check` exits 0 (with no key file it stops: FAIL if `design.human_subjects` is true, else N.A.). Snippet P: no interview quoted beyond its consent tier, no deep-background item cited. Every attribution is a pseudonym with a coarse role that passes the insider test; no indirect identifiers in the text; no participant text in shared files.
   - **Robustness (R1–R2).** The newest `.qualstack/robustness-*.md` exists and is absent from the status script's STALE list; the paper reflects its conclusion: every answer it calls sensitive is reported as such, with its sensitivity sentence.
   - **Preregistration (G1–G2; N.A. without `design.prereg_url`).** Every departure from `prereg/prereg.md` (model, priors, queries, case selection, clue plan, decision rules, coding rules via `sha256sum data/coding-rules.md` against the registered hash) has a dated addendum written before the affected evidence was coded, and the paper lists each beside the original plan.
4. **Diagnose each FAIL** in one paragraph: what is wrong, where (file:line, or case and node), what it does to the inference (which posterior moves, which claim falls, who is exposed), and the fix with the skill that makes it.
5. **Decide** by the catalog's rule: **pass** (no blocking or must-explain FAIL); **fix-then-pass** (no blocking FAIL, and at most three must-explain FAILs, each fixable without changing a coded value, the model, or a reported posterior); **fail** (anything worse: drafting or submission stops until a re-audit passes).
6. **Save** `.qualstack/evidence-audit-<YYYY-MM-DD>.md`: a header (scope, date, commit, `privacy.ai_processing`, the N3 tolerance), the table (ID, check, severity, result, evidence), one paragraph per FAIL, the author's hand-check list, and as the last line `Verdict: pass`, `Verdict: fix-then-pass`, or `Verdict: fail`. The words "verdict" and "recommendation" appear on no other line: `/qualstack:paper-status` reads the first line containing either.

## Outputs

- `.qualstack/evidence-audit-<date>.md` — the check table with its evidence, the diagnoses, the hand-check list, the verdict line.
- `.qualstack/review-cache/evidence-audit-<date>/` — the tables as they stood before the rerun; the rerun rewrites `data/clean/` and `output/`, and the audit writes nothing else.
- Summary block: scope; PASS / FAIL / N.A. counts; the top three failures with their fixes; the verdict; the next skill.

## Anti-patterns

- **Auditing the author's account.** "All quotes were checked" is not a check; the script's output is.
- **N.A. as a hiding place.** Every N.A. names its reason; a check not run is FAIL.
- **Opening what the protocol forbids.** A near-match in a transcript under `privacy.ai_processing: none` goes on the hand-check list, unopened.
- **Monte Carlo as an excuse.** On the machine that made the tables the rerun is identical; a difference there is an unseeded call or a changed input.
- **Fixing during the audit.** The audit diagnoses; the skill that owns the file fixes it, then the audit runs again.
- **Auditing only what is already right.** When everything passes, reread every 0's note and every case-level sentence; that is where errors hide.
- **Soft verdicts.** A fix-then-pass with five items is a fail.

## Next

- **fail** → the owner of each failure: trail `/qualstack:evidence-log`; quotations `/qualstack:draft-section` (unconverted scans `/qualstack:pdf-ingest`); coding `/qualstack:code-evidence` (an ambiguous rule `/qualstack:coding-rules`); numbers and reproduction `/qualstack:analyze`; inference `/qualstack:process-trace` or `/qualstack:analyze`; selection `/qualstack:case-select`; privacy `/qualstack:deidentify`; robustness `/qualstack:robustness`; preregistration `/qualstack:preregister` (an addendum). Then `/qualstack:evidence-audit` again.
- **fix-then-pass** → make the listed fixes, then rerun only the failed checks into a new dated memo that cites this one and ends in its own verdict line.
- **pass**, pre-writing → `/qualstack:viz` if figures are missing, then `/qualstack:draft-section` (cases, results). Pre-submission → `/qualstack:submission-pack`, then `/qualstack:archive`.
