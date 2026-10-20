# restricted/ — for the researcher's eyes only

This folder holds what must never leave your control: the identity key, consent
forms, unredacted transcripts and notes, audio and video. QualStack's guard
hook stops Claude from reading, searching, listing, or writing anything here,
and `.gitignore` keeps it out of version control. You manage it by hand.

## What goes here

```
restricted/
  key.csv          real,pseudonym,kind   — one row per person, place, or organization
  originals/       unredacted transcripts and notes as .txt or .md, named by neutral ID
  consent/         signed forms
  recordings/      audio / video
```

`key.csv` example:

```
real,pseudonym,kind
Jane Q. Official,P07,person
Ministry of the Interior,[Ministry A],organization
Villa Esperanza,[Town 3],place
```

## Rules that keep the wall standing

- **Name files by neutral ID** (`int-07.txt`, never `jane-official.txt`): a
  directory listing elsewhere can still show file names.
- **Pseudonymization is not anonymization.** Job titles, dates, and places
  identify people too. Review every redacted transcript before it moves on.
- **Check your protocol.** Set `privacy.ai_processing` in
  `.qualstack/config.yaml` to what your ethics approval and consent forms
  allow (`none`, `pseudonymized`, or `full`). If it is `none`, nothing derived
  from these transcripts belongs anywhere in this project folder.
- **This is a backstop, not a vault.** If your protocol forbids any
  third-party processing, keep identifiable material off the machine Claude
  runs on altogether.

`/qualstack:deidentify` runs `bin/qualstack-redact`, which reads `key.csv`
and `originals/` itself, writes pseudonymized copies to
`evidence/raw/interviews/`, and prints only counts.
