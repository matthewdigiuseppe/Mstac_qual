---
name: evidence-log
description: Registers evidence items in evidence/log.csv — one row per document, interview, day of field notes, article, or dataset version, with IDs that are never reused, files named by ID under evidence/raw/<kind>/, access tiers, and the provenance that cannot be reconstructed later recorded the day the item arrives — logs searches that found nothing as items of their own, converts document PDFs to searchable text, and validates the log and the evidence trail. Use when the user has new documents, archive photographs, transcripts, field notes, clippings, or a dataset to record, says "log this" or "add to the evidence log", reports an archive search that came up empty, needs an evidence ID for an interview, or asks whether the evidence trail is intact.
argument-hint: "[files or a description of new items|search|check]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(python3 *)
  - Bash(cp *)
  - Bash(date *)
---

# /qualstack:evidence-log

**Stage:** collect · **Voice:** archivist

The evidence is the report, not the event, and the log is how a stranger gets from `\ev{E014}` to the page (Moravcsik 2014). The archivist logs on the day, never at write-up; never reuses or renumbers an ID; never edits a raw file; and keeps names, coded values, and unlogged searches out of the record.

## Procedure

1. **Load** `.qualstack/config.yaml` (`evidence.id_prefix`, `evidence.person_prefix`, `privacy.ai_processing`), `evidence/log.csv`, and the node names in `data/coding-rules.md`. `Read ${CLAUDE_PLUGIN_ROOT}/references/evidence-and-sources.md`, sections "Logging an item" (its per-type table says what `author`, `source`, and `notes` must carry) and "Absence of evidence". `$ARGUMENTS`: files or a description of new items (default), `search` (step 7), or `check` (step 10 only). Today: `date +%Y-%m-%d`.
2. **Participant material checks the setting first.** Interviews and field notes: `privacy.ai_processing` empty or `none` → the row is written from what the researcher says (pseudonym, role category, date, mode, consent tier), `file` stays empty with `notes` `file withheld: no AI processing`, and no transcript or note is opened; `pseudonymized` → `file` names only outputs `/qualstack:deidentify` wrote, once the researcher has read them; `full` → what the protocol and the consent clear. A participant who did not consent to AI processing gets a row and nothing more, whatever the setting (`notes`: `file withheld: no AI processing consented`); the values that rest on the interview are the researcher's own codes. Material that names people reaches `evidence/raw/` only through `/qualstack:deidentify`, never by copying. No real name enters any cell: `author` is the P-ID, roles are coarse ("senior official, economic ministry").
3. **The ID** is the highest existing number plus one (the validator in step 10 prints it), never a count of rows; three digits (E014). A withdrawn item keeps its row, with `notes` beginning `withdrawn: <date> <reason>`. People are P01, P02, … in an order unrelated to identity, matched to names only in the key the researcher keeps in `restricted/`. Reserve an interview's ID the day it is scheduled or held, so its originals can carry it.
4. **Name each file once.** Raw files are read-only once they exist (the guard hook denies edits, overwrites, and deletions) and are never renamed or moved, because citations point at them. Name: `evidence/raw/<kind>/E014-<slug>-<date>.<ext>`, kind one of `archival`, `interviews`, `fieldnotes`, `press`, `official`, `memoir`, `secondary`, `searches`, `other`; slug two to five lowercase words, no personal names; date the item's own, at its precision. Copy files in with `cp -n <source> <target>` (never move, never convert in place). One document per file: a folder photographed as one PDF is split before logging. Datasets go to `data/raw/`, one row per version.
5. **Originals that pass through `/qualstack:deidentify`** (interviews, and field notes that name people) are named by the researcher before it runs, with the evidence ID and otherwise only lowercase words and digits, because `qualstack-redact` processes only such neutral names (project IDs like E014 and P07 keep their capitals) and keeps them in its output: the transcript `E014-p07-2025-03-14.txt` and, beside it, the same-day post-interview memo `E014-p07-2025-03-14-memo.md`; a day's full field notes `E015-notes-2025-03-15.txt` and its jottings `E015-jottings-2025-03-15.txt`, two files under one ID. The memo is part of the interview's record, not an analytic memo: it reaches `evidence/raw/interviews/` with the transcript and is listed in the same row's `file` (transcript first, then memo), never in `evidence/memos/`. For an unrecorded interview the memo is the record.
6. **Fill the row**, all 13 columns: `id,type,title,date,author,source,file,accessed,access,cases,clues,reliability,notes`. `type` is one of archival, interview, fieldnote, secondary, press, official, memoir, dataset, other. `date` is ISO 8601 at the known precision (`1989-05`); an inferred date takes `?` and its basis in `notes`. `source` gives the place, smallest unit first, reference codes verbatim. `file` holds relative paths, `;`-separated. `accessed` is the day the item reached you or the notes were written up (`accessed` − `date` is the write-up lag; a field note written up more than a day late is flagged in `notes`). `access` is open, archive-restricted, or confidential; interviews and field notes are `confidential` unless the consent form's words, quoted in `notes`, allow more. `cases` lists case IDs and `clues` node names; values belong in `data/coding-log.csv`, never here. `reliability` stays `pending` until `/qualstack:source-critique`. `notes` carry what the per-type table demands: for an archival item, classification, declassification date and review number, redactions, draft or sent copy, enclosures, annotations in another hand; for an interview, role category, recorded or notes only, consent tier as worded, who was present by P-ID, language and translator, referral source; for a copy, `derivative of E031`. Append rows with Edit and quote any cell that contains a comma.
7. **A search that found nothing is an item.** `type` other, title `Search: <archive, series> for <clue>`, file `evidence/raw/searches/E0xx-search-<slug>-<date>.md`, written once, complete, the day of the search: archive, series and boxes opened and not opened, period covered, finding aids used, terms and variant spellings, hours, items withdrawn (a withdrawal slip is its own item: it proves a document exists), the clues it bears on, and the case for each factor of P(found | present): written down, survived and released, reached, recognized. Absence of evidence is evidence only if the search would have found the thing; `/qualstack:code-evidence` decides 0 or NA against the rule's 0 standard and cites this ID. An empty search left unlogged supports nothing, or a 0 nobody can defend.
8. **Corrections are new files.** A corrected transcription or a cleaned note is a new file (`…-corrected-2025-04-02.<ext>`) listed after the original in `file`, with `notes` saying what changed, why, and from what; corrected OCR text lives in `evidence/md/`. Analytic readings go to dated memos (`evidence/memos/YYYY-MM-DD-<topic>.md`), which are never evidence.
9. **Convert document PDFs**: `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-pdf2md evidence/raw -o evidence/md --name-by-file --keep-refs --no-network --no-bib --index evidence/md/index.md` (the same index `/qualstack:pdf-ingest` keeps). It converts only new or changed files, and the output keeps the ID, which is how `qualstack-quotecheck` finds the text behind `\ev{E014}`. First Glob `evidence/raw/interviews/` and `evidence/raw/fieldnotes/` for PDFs: unless `privacy.ai_processing` is `full`, any found there stop the run until the researcher removes them. For `needs-ocr` and backend choices, `/qualstack:pdf-ingest`; handwriting is typed into `evidence/md/<id>-transcription.md`. The scan is the record; the text is a finding aid.
10. **Validate**: `python3 ${CLAUDE_PLUGIN_ROOT}/skills/evidence-log/assets/check-log.py` (header; unique IDs and gaps; type and access values; required fields; ISO dates; accessed not before date; files present and none under `restricted/`; raw file names carrying their ID; pseudonymous interview authors, never echoed; tiers; the reliability format; `derivative of` targets; unlogged raw files), then `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-status` and read its EVIDENCE TRAIL lines. Fix every error in the log, never in `evidence/raw/`; an unlogged raw file gets a row, or the researcher removes it.

## Outputs

- `evidence/log.csv`: new rows, `notes` updates, `withdrawn:` markers; `paper.status: "collecting"` in `.qualstack/config.yaml` with the first row, if it is at an earlier stage.
- New files under `evidence/raw/<kind>/` (copied in, or search records written); `evidence/md/*.md` from the conversion.
- Summary block: items added (IDs, types, cases); the next free ID; files converted and flagged; validator errors and warnings; the EVIDENCE TRAIL line; rows still `pending` for reliability; interviews awaiting `/qualstack:deidentify`.

## Anti-patterns

- **Logging at write-up.** Reference codes, access dates, and who was present do not come back.
- **Reused or renumbered IDs.** Every `\ev{}` and every coding-log row points at them.
- **Fixing a raw file.** A correction is a new file with a note.
- **Unlogged empty searches.** "I looked and found nothing" with no record supports no 0.
- **Names in the log.** P-IDs, coarse roles, neutral slugs.
- **Values in the log.** `clues` names nodes; their values live in `data/coding-log.csv`.
- **One file, many documents.** Split before logging: one ID per document.

## Next

`/qualstack:deidentify` for transcripts, memos, and field notes that name people; `/qualstack:source-critique` for rows with `reliability` pending; `/qualstack:chronology` once a case's documents are in; `/qualstack:code-evidence` when the rules exist and the case's evidence is logged.
