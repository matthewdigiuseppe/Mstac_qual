# {PROJECT TITLE}

Scaffolded by [QualStack](https://github.com/matthewdigiuseppe/Mstac_qual).

## Layout

```
.qualstack/        # config, memos, learnings, review cache (do not delete)
paper/             # manuscript: main.tex + sections/ (cases.tex holds the process tracing)
lit/pdf/           # source PDFs of the literature (read-only after ingest)
lit/md/            # those PDFs as Markdown, via /qualstack:pdf-ingest
lit/index.md       # corpus triage table — read this before opening any paper
evidence/log.csv   # one row per evidence item: E001, E002, ... (cited as \ev{E001})
evidence/raw/      # documents, pseudonymized transcripts, field notes as received (read-only)
evidence/md/       # archival PDFs converted to searchable text
evidence/memos/    # dated analytic memos (yours and Claude's)
data/raw/          # cross-case datasets as acquired (read-only)
data/coding-rules.md  # what counts as 1, 0, and NA for every node
data/case-data.csv    # the coded cases: one row per case, one column per node
data/coding-log.csv   # every coded value with the evidence items behind it
code/              # numbered R scripts: 01-model → 06-figures (CausalQueries)
output/            # models, tables, figures
restricted/        # identifiable material — never read by Claude, never committed
submission/        # cover letter + response-to-reviewers
transparency/      # the transparency package's own files, built by /qualstack:archive
prereg/            # preregistration (locked once registered)
```

## Reproducing the formal results

```r
# From the project root in R — runs every numbered script in order:
scripts <- sort(list.files("code", pattern = "^[0-9].*\\.R$", full.names = TRUE))
for (f in scripts) source(f)
```

## Tracing the qualitative claims

Every evidence item cited in the paper (`\ev{E014}`) has a row in
`evidence/log.csv` giving its source, date, author, and access conditions;
every coded value in `data/case-data.csv` has a row in `data/coding-log.csv`
naming the evidence behind it. By submission time this README doubles as the
transparency-package README; `/qualstack:archive` extends it.
