---
name: deidentify
description: Pseudonymizes interview transcripts, post-interview memos, and field notes without Claude ever reading the originals — refuses unless privacy.ai_processing allows it, has the researcher build the identity key and place the originals in restricted/ by hand, runs bin/qualstack-redact (status, apply, check) so that only counts, file names, and pseudonyms cross the wall, sends the researcher to review the candidate names the key missed and to read every output, and hands cleared outputs to the evidence log. Use when the user has transcripts or notes that name people, asks to anonymize, pseudonymize, redact, or de-identify them, or wants to scan the project for leaked names before sharing it.
argument-hint: "[status|apply|check]"
allowed-tools:
  - Read
  - Write
  - Glob
  - Bash(python3 *)
  - Bash(date *)
---

# /qualstack:deidentify

**Stage:** collect · **Voice:** privacy-officer

Claude never sees an identity: not in `restricted/`, not on a command line, not in an output the researcher has not cleared. The officer refuses to run without the protocol's permission, never asks for a name, and never calls a pseudonymized file anonymous.

## Procedure

1. **Gate.** Read `privacy.ai_processing` in `.qualstack/config.yaml`. (`check` alone, step 8, runs under any setting: it prints no names.)
   - **Empty or `none`: refuse**, and say why. The setting records what the ethics approval and the consent forms allow; an empty setting is not permission; with `none`, nothing derived from participants, pseudonymized or not, may enter this folder, because whatever Claude reads goes to the model provider. `qualstack-redact` itself refuses only `none`, so this gate is what catches an empty setting. Two routes remain: the researcher keeps the material off this machine and enters each interview as a log row plus their own coded values, or amends the protocol and re-consents, then sets the value themselves. `Read ${CLAUDE_PLUGIN_ROOT}/references/transparency-and-ethics.md`, section "AI processing of research data", and walk them through its checks (the approval, each participant's form, data-protection law, the provider's terms). Stop.
   - **`pseudonymized`**: proceed. **`full`**: proceed all the same; the people participants mention never consented, and only on-the-record participants may keep their names.
   - Never change the setting yourself.
2. **What goes in the originals folder.** `qualstack-redact apply` processes everything under `privacy.originals` wholesale. The originals of any participant who did not consent to AI processing are kept outside that folder, by the researcher; such an interview enters the project only as a log row (`file withheld: no AI processing consented`) plus the researcher's own coded values, never a transcript.
3. **The researcher's part.** Claude never opens or lists anything in `restricted/` and never names a path inside it in a command.
   - **The key** at `privacy.key`: header `real,pseudonym,kind`; one row per person, organization, and place, including people the participants mention; spelling variants, nicknames, initials, titles with surnames, and transliterations in one cell separated by `|`; a one-word variant matches only as written and in capitals, so add the lowercase forms the transcripts use; pseudonyms (`P01`, `[Ministry A]`, `[Town 3]`) assigned in an order unrelated to identity.
   - **The originals** under `privacy.originals`, as UTF-8 `.txt` or `.md` (converting strips author fields, tracked changes, and comments), each named with the ID `/qualstack:evidence-log` reserved and otherwise only lowercase words and digits: the transcript `E014-p07-2025-03-14.txt` with the same-day memo `E014-p07-2025-03-14-memo.md` beside it, so the memo travels with the interview's record. Any other name (a capitalized word, initials) is withheld unprocessed, because file names are printed.
   - **Field notes** that name people take the same route; to land them in `evidence/raw/fieldnotes/`, run them as their own batch: the researcher points `privacy.originals` at a folder holding only notes (and back afterward), and step 5 uses `--out evidence/raw/fieldnotes`.
   - Never ask the researcher to type, paste, or spell a real name. If one appears in the conversation, say so and do not repeat it.
4. **Status**: `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-redact status`. Report the setting, the key (pseudonyms, name variants), and the originals (files, how many are `.txt` or `.md`). A missing key or folder, or no text files, sends the researcher back to step 3.
5. **Apply**: `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-redact apply --out evidence/raw/interviews`. Report what it prints and nothing more: files written; files skipped because the output exists (outputs are never overwritten); replacements per file; files WITHHELD for non-neutral names (the researcher renames them inside `restricted/` and re-runs); files with zero replacements (the wrong file, or a key that does not cover it); the number of review candidates. Open no output, and Grep none, until step 7 clears it.
6. **The researcher reviews the misses.** `restricted/redaction-review.txt` lists, by output file and line, capitalized words left that are neither keyed nor common: names the key may have missed. The researcher, not Claude, reads it. For each real identifier: the researcher extends the key and deletes the affected output by hand (`evidence/raw/` is read-only to Claude, and a leaked file must not be opened in the meantime); step 5 is re-run and writes only what is missing. Repeat until the list holds no identifier.
7. **The researcher reads every output in full**, because pseudonymization is not anonymization: titles, ranks, organizations, exact dates, places, ethnicity, age, an event one person witnessed, and a turn of phrase identify people. Checklist, for each output and for every later quotation: at most one precise indirect identifier per attribution; coarsen (deputy minister → senior official, an exact date → the year, a town → the region); apply the insider test (could a colleague of P07 name P07 from this?); broaden or paraphrase without attribution any combination that fits one person in a small elite ("the only woman on the negotiating team"). The output stays as written; coarsening happens where text is quoted or attributed, or in a corrected copy logged as a new file.
8. **Check**: `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-redact check` scans `paper/`, `evidence/`, `data/`, `.qualstack/`, `output/`, `submission/`, and `prereg/` for keyed real names and prints file, line, and pseudonym, never the name; it exits 1 on any hit. A hit in an output → step 6. A hit anywhere else is fixed by the researcher: Claude does not open that line, which would put the name in context. A keyed name in an archival document (a public record naming an official who was also interviewed) may stand, but nothing may tie it to the pseudonym. Run `check` again before anything is shared.
9. **Hand off** only cleared outputs: each interview to `/qualstack:evidence-log` (type `interview`, `author` the P-ID, `access` `confidential` unless the form's words allow more, `file` the transcript then the memo); field notes as type `fieldnote`. Logging is the clearance: other skills open a pseudonymized file only once its row exists. Write `evidence/memos/<date>-deidentification.md` with counts only: the date, key size, files written, withheld and zero-replacement files and how each was resolved, review candidates cleared, who read the outputs, what was coarsened. `/qualstack:archive` builds the de-identification statement from it.

## Outputs

- Pseudonymized files in `evidence/raw/interviews/` (or `evidence/raw/fieldnotes/`), written by `qualstack-redact`, never by Claude.
- `evidence/memos/<date>-deidentification.md`: counts and decisions, no names.
- Summary block: the setting; key size; files written, skipped, withheld, and with zero replacements; review candidates and whether cleared; the `check` result (files scanned, hits); outputs ready to log.

## Anti-patterns

- **Opening `restricted/`.** No Read, Grep, Glob, `ls`, `cat`, or script that opens it; the guard hook is a backstop, not the rule.
- **Asking for the missed name.** The researcher edits the key; Claude never needs to know it.
- **An empty setting read as consent.** Empty means `none`.
- **"Anonymized."** The output is pseudonymized; indirect identifiers survive until a person removes them.
- **Reading outputs before they are cleared.** A missed name in an output is a name in context.
- **One originals folder for everyone.** A participant who declined AI processing is processed anyway if their file sits there.
- **Identifying file names.** `jane-official.txt` is withheld, rightly.

## Next

`/qualstack:evidence-log` for each cleared output; `/qualstack:source-critique` for the interviews' positions, stakes, and recall; `/qualstack:deidentify check` again before `/qualstack:submission-pack` or `/qualstack:archive`.
