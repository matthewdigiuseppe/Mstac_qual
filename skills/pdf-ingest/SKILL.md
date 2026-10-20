---
name: pdf-ingest
description: Converts PDFs into token-cheap, searchable Markdown — the literature (section-addressable, with citation front matter, a corpus index, and staged BibTeX) and archival evidence (scans OCR'd and named by evidence ID so quotations can be verified). Use when the user drops PDFs into a project, asks to read or summarize papers or documents, says reading is burning context, before /qualstack:lit-map so the map runs against text, or after archival documents are logged so their text can be searched and quote-checked.
argument-hint: "[path to a PDF or folder of PDFs]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

# /qualstack:pdf-ingest

**Stage:** model (literature) · collect (archival evidence) · **Voice:** archivist

A PDF handed straight to a model costs page renders on top of extracted text: a 40-page article runs to tens of thousands of tokens, and forty of them do not fit in a context window at all. Converted, the corpus is roughly a fifth of the size and, more importantly, **addressable**: one paper's methods section instead of the paper; sixty papers triaged from one index without opening any. Run before `/qualstack:lit-map` whenever the literature is on disk as PDFs, and again as PDFs arrive; conversion is incremental.

Layout (`/qualstack:qualstack-init` creates `lit/pdf/` and `lit/md/`; create them in older folders):

```
lit/pdf/                 source PDFs, read-only after ingestion (like evidence/raw/)
lit/md/                  one <citekey>.md per paper, plus <citekey>.refs.md
lit/index.md             triage table: metadata, abstracts, token costs
lit/refs-ingested.bib    staged BibTeX, for merging into paper/refs.bib
lit/.qualstack-pdf2md.json  conversion cache (sha256 → result); never hand-edit
```

## Procedure

1. **Locate the PDFs:** `$ARGUMENTS`, else `lit/pdf/`, else ask. PDFs outside the project (Zotero storage, Downloads) are **copied** into `lit/pdf/`, never converted in place: the project must own its inputs, as with `evidence/raw/`, or the reference rots.
2. **Toolchain, once:** `python3 "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-pdf2md" --doctor`. If only `builtin` is available, say so and recommend `pip install pymupdf4llm` (fast, ~30 MB, handles most born-digital articles), plus `pip install docling` when the pile contains scans. Install nothing without asking.
3. **Convert:** `python3 "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-pdf2md" lit/pdf`. Cached by file hash, so re-runs touch only new or changed PDFs. Flags: `--no-network` (air-gapped, or no Crossref lookups wanted), `--mailto you@example.edu` (Crossref's polite pool), `--backend docling` (force a layout backend on a stubborn document), `--keep-refs` (the reference list is itself the object of study), `--force` (re-convert after installing a better backend), `--json` (summary as data).
4. **Read the report, then `lit/index.md`**, not the papers. That one file is the corpus.
5. **Triage by `status`:** `ok` — nothing to do. `low-quality` — read the `defects` list in the front matter; `truncated` or `interleaved text` usually means a heavier backend: re-run that file with `--backend docling --force`. `needs-ocr` — a scan with no text layer, which no text backend will fix: install an OCR-capable backend (`docling`, `marker`, `mineru`) and re-run, or read the PDF natively and write `lit/md/<citekey>.md` by hand in the same shape as the others. `failed` — encrypted, corrupt, or not really a PDF; say so and move on, never leave a silent broken index entry.
   Backend trade-offs and the meaning of each quality-gate defect are in `${CLAUDE_PLUGIN_ROOT}/references/pdf-extraction.md`; read it only when the `defects` list is not enough to choose a backend.
6. **Fix the metadata that matters.** `metadata_source: "parsed"` (rather than `crossref` / `arxiv`) is a guess: for papers that will actually be cited, check title, authors, and year against page one and correct the front matter. A wrong citekey propagates into `refs.bib` and then the manuscript.
7. **Stage citations.** `lit/refs-ingested.bib` holds an entry per document; merge verified entries into `paper/refs.bib`, deduping by key. Entries carrying `% TODO verify` were parsed from the PDF rather than fetched from Crossref; never merge them unverified, the same rule `/qualstack:lit-map` applies to invented citations.
8. **Report:** documents converted, corpus token cost before and after (estimates), anything flagged, the next skill.

## Archival evidence mode

`$ARGUMENTS` pointing into `evidence/raw/` (or the user asking to make logged documents searchable) switches to evidence mode. The documents are already logged by `/qualstack:evidence-log`, one file per document named by evidence ID (`evidence/raw/archival/E014-cabinet-minutes.pdf`).

1. **Convert with the archival flags:** `python3 "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-pdf2md" evidence/raw/archival -o evidence/md --name-by-file --keep-refs --no-network --no-bib --index evidence/md/index.md`. The output keeps the evidence ID (`evidence/md/E014-cabinet-minutes.md`), which is how `qualstack-quotecheck` finds the text behind `\ev{E014}`. Crossref knows nothing about an archive, and a document's last section is not a reference list.
2. **Expect scans.** Archival PDFs usually have no text layer; `needs-ocr` means installing an OCR-capable backend (`docling`; `mineru` for CJK), with the user's consent, and re-running with `--force`. Handwriting defeats every backend: transcribe by hand into `evidence/md/<id>-transcription.md` with the transcriber and date in a header, and mark `[illegible]` rather than guessing.
3. **The scan is the record.** OCR text is a finding aid; a passage that will be quoted or that carries an inference is checked against the page image, and hand corrections go in `evidence/md/` with a note in the log's `notes` column, never into `evidence/raw/` (read-only; the guard hook enforces it).
4. **Never convert anything in `restricted/`.** Unredacted material stays outside Claude's reach; documents that identify participants go through `/qualstack:deidentify` (text) or stay out of the project.

Archival specifics, OCR failure modes, and translation conventions are in `${CLAUDE_PLUGIN_ROOT}/references/pdf-extraction.md` (section "Archival documents are a different problem").

## Reading the corpus afterwards

Say this at hand-off; it is the point of the conversion and easy to forget:

- **Triage from `lit/index.md`** (every paper's metadata, abstract, token cost; sixty papers cost a few thousand tokens to survey).
- **Open a paper only when the index is not enough; open one section when the paper is not needed whole.** The `sections` list in the front matter is the map; headings are normalized to `##`, so `sed -n '/^## 4\./,/^## /p' lit/md/key.md` pulls one section.
- **Leave `<citekey>.refs.md` alone** except to chase a citation; the lists are split out precisely so they stop costing anything on every read.

## Outputs

- `lit/md/<citekey>.md` per document (front matter: citekey, title, authors, year, container, DOI / arXiv, source PDF and hash, backend, quality score, status, section list, token accounting) and `<citekey>.refs.md`.
- `lit/index.md` — triage table plus abstracts; `lit/refs-ingested.bib` — staged BibTeX.
- Summary: counts, token savings, flagged documents, next step.

## Anti-patterns

- **Reading PDFs directly when conversion would work.** Native reading is the fallback for a `needs-ocr` document with no OCR backend, not the default.
- **Converting in place from outside the project.** Copy into `lit/pdf/` first, or the corpus is not reproducible.
- **Editing `lit/pdf/`.** Source PDFs are raw inputs and the guard hook enforces it; corrections belong in the Markdown.
- **Merging unverified BibTeX into `paper/refs.bib`.** A parsed entry is a hypothesis about a citation.
- **Reporting a token saving as exact.** The figures come from a character heuristic and a per-page constant, not a tokenizer.
- **Accepting a `low-quality` document silently.** A truncated extraction reads perfectly well and is missing half the paper; escalate the backend or say plainly the text is partial.
- **Deleting the source PDF.** The Markdown is a derivative; page numbers for quotations come from the PDF.

## Next

`/qualstack:lit-map` reads `lit/index.md` first and engages the converted text instead of searching the web blind. `/qualstack:theory-build` and `/qualstack:draft-section` read converted sections when they need a paper's actual argument. `/qualstack:archive` should include `lit/index.md` and `lit/refs-ingested.bib`; whether the PDFs ship depends on redistribution rights, which are usually not yours.
