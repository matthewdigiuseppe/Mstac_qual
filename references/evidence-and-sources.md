# Evidence and sources — archives, interviews, field notes, secondary accounts

Read by `/qualstack:evidence-log`, `/qualstack:source-critique`,
`/qualstack:chronology`, `/qualstack:interview-guide`,
`/qualstack:fieldwork-plan`, `/qualstack:process-trace`, and
`/qualstack:referee-mock` (area-expert persona): how evidence is recorded,
weighed, and dated. The evidence is the report, not the event. A clue's
probative value comes from the model (Humphreys & Jacobs 2023); the source
decides how much of it survives. Check archive rules, consent terms, and
repository access tiers against their current versions.

## The evidentiary chain

- **Claim → item → file → place.** `\ev{E014}` and the data/coding-log.csv
  rows citing E014 lead to row E014 of evidence/log.csv, its file in
  evidence/raw/, and its place: archive, collection, series, box/folder, or
  for an interview a pseudonymized transcript whose identity key stays in
  restricted/. Every link resolves for a stranger (Moravcsik 2014).
- **Record on the day what cannot be reconstructed:** location, reference
  code, access date, withdrawal slips, which photos make which document;
  who was present, mode, recording, language, consent tier; when notes were
  written; what was searched and not found (Kapiszewski, MacLean & Read
  2015). `clues`, `reliability`, and the coding can come later.
- **A corrected transcript or cleaned note is no longer the record:** it
  resolves ambiguity (an inaudible passage, a slip, a note made coherent)
  with what you know now. evidence/raw/ is read-only, so a correction is a
  new file (`…-corrected-2025-04-02.txt`) listed after the original in
  `file`, with `notes` saying what changed, why, and from what.
- **Memos are not records.** Readings and critiques go in dated memos
  (`evidence/memos/YYYY-MM-DD-<topic>.md`) citing E-IDs; a memo is never
  evidence of what happened, and a changed reading gets a new memo.

## Logging an item

- **One row per item** (a document with enclosures, an interview session, a
  day's notes, an article, a work, a dataset version). IDs are never
  reused; a withdrawn item keeps its row, with `notes` starting `withdrawn:`.
- **Files** go in evidence/raw/ by kind (`archival/`, `interviews/`,
  `fieldnotes/`, `searches/`, …) as `E014-<slug>-<date>.<ext>`, never under
  restricted/; raw files cannot be renamed, so name interview originals
  this way before /qualstack:deidentify runs. Lists in a field use `;`.
- **Dates** are ISO 8601 at the known precision (`1989-05`); an inferred date
  gets `?` and its basis in `notes`. `accessed` is when the item reached you
  or your notes were written up; `accessed` − `date` is then the write-up lag.
- **`clues`** names nodes (values go in data/coding-log.csv); `reliability`
  gives `node s=… f=…` per clue with the reason, or `pending` before
  /qualstack:source-critique; interviews default to `confidential` access.

| `type` | `author`; `date` vs. `accessed` | `source` | `notes` must add |
|---|---|---|---|
| archival | author → recipient(s), with roles; document date vs. date consulted | archive, collection or record group, series, box/folder/item, reference code verbatim | classification at creation; declassification date and review number; redactions; draft or sent copy; enclosures; annotations in another hand |
| interview | P-ID; interview date vs. date the transcript or write-up was finished | mode (in person, phone, video, written) and setting category | coarse role category; recorded or notes only; consent tier as worded on the form; who was present (researcher, interpreter, minders, others by P-ID); language, translator, and date; referral source |
| fieldnote | researcher; date observed vs. date the full note was written | setting category | what was observed and the researcher's role; jottings and full note as separate files; a lag over one day flagged in `reliability` |
| secondary | historian(s); year of the edition used vs. date consulted | full citation or `paper/refs.bib` key, edition, pages | the historian's own sources for each claim used (archive series, interviews, other secondaries, none); the historian's school |
| press | byline, `unsigned`, or wire service; publication date (time, zone, and version online) vs. retrieval | outlet, edition, section and page, or the URL as published | wire copy vs. original reporting; the story's sourcing (named, anonymous, documents); the origin's E-ID if derivative; ownership or state control |
| official | issuing body; release date (reference period in `title`) vs. retrieval | gazette or series, table identifier, vintage | revisions and methodological breaks; what the producer gained from the number |
| memoir | author (and ghostwriter); publication date vs. date consulted | full citation | writing period; before or after the outcome was known; built on diaries and papers or on memory; offices sought afterward |
| dataset | producer; version release date vs. download date | name, version, DOI or distributor as the provider gives it | one row per version (a re-download is a new row); variables by exact name and the nodes and `cases` they code; file read-only in data/raw/, recodes in code/03-data.R, cut-points to 0/1 in data/coding-rules.md |
| other | as fits | as fits | what the item is (a search record, a photograph, a web capture) and why no type fits |

Archival citation, assembled from the row, smallest unit first:

```
Author (role) to Recipient (role), "Subject line," 1989-05-01 [Secret].
Item, folder, box, series, collection, archive (city), reference code as
given. Declassified YYYY-MM-DD (review no.); consulted YYYY-MM-DD. [E014]
```

## Source criticism as likelihoods

Per source and clue K: s = P(source reports K | K true) and f = P(source
reports K | K false). Every classic question moves one of them; George &
Bennett (2005) ask who is speaking to whom, for what purpose, and in what
circumstances.

| Question | Moves | Because |
|---|---|---|
| Provenance: original, copy, draft, translation, custody | f ↑; s and f closer | forgery, later insertion, copying error |
| Contemporaneity | s ↓ for detail; f ↑ for motives | memory fades and hindsight supplies tidy reasons |
| Author's position | s and f converge when the author was not placed to know | hearsay relays an original you cannot assess |
| Author's incentives | f ↑ for creditable claims; s ↓ for discreditable ones | a statement against interest has low f, hence a high likelihood ratio |
| Intended audience | f ↓ if insiders must act on it; f ↑ if written to persuade, leak, or protect the author | insiders pay for errors; audiences reward spin |
| Private vs. public | two sources, not one | the gap between them is evidence of strategy |
| Internal consistency | both ↑ with contradictions | accounts that agree too well suggest rehearsal or a shared origin |
| Corroboration | counts only if errors are independent given K | see double counting |
| The archive's selection | s ↓ for secret or embarrassing K | weeding and declassification act before you arrive |

| Situation (↑/↓ vs. a disinterested witness) | s | f | Why, and what to check |
|---|---|---|---|
| Contemporaneous private memo among insiders | ↑ for what the author knew and the reader needed | ↓ | Written to be acted on, before the outcome; check that the author was present and that it is not a self-protective memo for the file |
| Public speech | ↓ for discreditable motives | ↑ for creditable motives | Near-certain evidence of what was said (a commitment, a signal), weak evidence of why; code the act of saying when that is the node |
| Memoir after vindication | ↓ for own doubts and wrong calls | ↑ for own foresight and decisive role | Written knowing the outcome; check against the author's contemporaneous papers |
| Memoir after defeat | ↓ for own errors | ↑ for constraints and others' blame | An admission of error is against interest (f ↓) |
| Participant interviewed on own role | ↓ for discreditable acts, abandoned positions, detail | ↑ for credit-claiming and coherent motives | Self-serving recall, hindsight, strategic presentation; anchor in specific episodes |
| Interview with an opponent | ↓ for the rival's internal deliberations | ↑ for claims that discredit the rival; ↓ for concessions | A concession that the rival was right is against interest |
| Journalist with anonymous sourcing | middling: only what sources chose to leak | rises as sources get fewer and less independent | Leaks are strategic; check independent confirmation vs. re-reporting, and later corrections |
| Official statistic | set by the producer's autonomy | ↑ where the number serves the producer | Error that tracks the outcome or treatment (growth figures before elections) is differential: model it |
| Historian's synthesis | its sources'; ↓ for facts that fit no thesis | its sources'; ↑ by narrative smoothing | Not independent of the primaries it cites; check the footnotes and the school |

- **Into the model.** If reporting depends on K alone, P(report | type) =
  s·P(K | type) + f·(1 − P(K | type)): a report's likelihood ratio lies
  between f/s and s/f, a silence's between (1 − s)/(1 − f) and its inverse,
  however decisive K is. A smoking gun from a source with f = .2 is a straw
  in the wind; a hoop is a hoop only if the source would have mentioned K
  (Van Evera 1997; Collier 2011). In X → K → Y (monotonic, uniform type
  shares), K = 0 in an X = 1, Y = 1 case rules out an effect of X; silence
  from a source with s = .85, f = .05 only cuts it from .20 to .10.
- **Fold or model.** Fold reliability into the clue (flatten its priors;
  in Humphreys & Jacobs 2015, each φ becomes s·φ + f·(1 − φ)) only if the
  error is non-differential, one source reports K, and K has no children.
  Otherwise add `K -> Kr` (plus `Y -> Kr` for a report written knowing the
  outcome) and let /qualstack:robustness vary its shares. In CausalQueries:
  `make_model("X -> K -> Y; K -> Kr")`, then
  `set_restrictions(model, "(Kr[K=1] < Kr[K=0])")` against inverted
  reports, then `set_parameters()` or `set_priors()` with `node = "Kr"` for
  the shares of `00` (miss), `01` (faithful), and `11` (false report):
  s = P(01) + P(11), f = P(11). Node names take no underscores; code Kr in
  data/case-data.csv and leave K NA unless observed directly.
- **Double counting.** A leak reported by five papers is one source
  (`K -> L; L -> P1; …`), as are interviewees repeating one story. Mark
  copies `derivative of E031` in `notes`, count origins, and condition on
  the items in hand: P(E2 | E1, H) (Fairfield & Charman 2017; 2022).

## Absence of evidence

- **0 or NA.** Code K = 0 from an empty search only if P(found | K) =
  P(written down) × P(survived and released) × P(search reached it) ×
  P(recognized) was high: the archive holds the series that would record K
  for the whole period, the documents are the kind that mention K (minutes
  record decisions, often not reasons), and nothing was withheld. Else code
  NA, or treat the search as a source (`K -> Kf`, s = detection, f ≈ 0) and
  code Kf = 0; a false 0 favors whichever hypothesis predicts K's absence.
- **Log each search the day it happens** (`type` other, record in
  `evidence/raw/searches/`): archive, series and boxes opened and not,
  period covered, terms and variant spellings, hours, items withdrawn. Each
  0 or NA it supports cites its E-ID, and a memo argues the miss probability.
- **Silence** is evidence only from a source with reason and opportunity to
  speak (the opposition paper that would have trumpeted the scandal), not
  from one with reason to stay silent, no access, or K taken for granted.
  Silence in a censored press is evidence about the censor.

## Archival research

- **Finding aids first:** which series exist for the period, which were
  never transferred, which are closed; the arrangement is the archivist's.
- **Declassification and loss are selection.** Sensitive records are held
  longest, so open files under-represent deliberation (s ↓ for secret K);
  appraisal, purges, and shredding before transitions remove more. Log
  withdrawal slips as items (they prove a document exists), memo each gap,
  and recheck releases before submission.
- **Multiple archives:** the other side's files (a foreign ministry, a
  lender) record what your actors told outsiders, with independent errors.
- **Selecting among historians (Lustick 1996):** scholars tend to cite the
  historians whose accounts fit. State the historiographic debate,
  triangulate across schools, prefer works whose sources you can check, and
  say whose account you use and why (Thies 2002).
- **Read in sequence (Trachtenberg 2006),** in the order written, to see
  what actors knew and expected at each point rather than with hindsight.
- **Capture:** one PDF per document (all pages, enclosures, box and folder
  labels in frame), named by E-ID and logged that day:
  `evidence/raw/archival/E014-cabinet-minutes-1989-05-01.pdf`. Text for
  /qualstack:evidence-audit's quotation check comes from
  `${CLAUDE_PLUGIN_ROOT}/bin/qualstack-pdf2md evidence/raw -o evidence/md`
  `--name-by-file --keep-refs --no-network`, or for handwriting from a typed
  transcription saved under the same name in evidence/md/.

## Interviews

- **Sampling frame:** positional (all holders of the relevant posts;
  refusals countable), reputational (whom informants name; misses quiet
  actors), or snowball (reaches closed networks; over-samples the connected
  and the winners; log who referred whom). Start positional, then snowball.
- **Interview methods table (Bleich & Pekkanen 2013),** one row per
  category, in the appendix:

| Category | Sought | Obtained | Refused | Saturation | Format | Length | Recording | Transcription |
|---|---|---|---|---|---|---|---|---|
| Finance ministry officials | 12 | 8 | 2 (2 no reply) | yes, on M and R | semi-structured, in person | 45–90 min | 6 recorded, 2 notes | full; notes typed same day |
| Opposition legislators | 10 | 4 | 3 (3 no reply) | no | semi-structured, 1 by video | 30–60 min | notes only | notes typed same day |

- **Reliability (Berry 2002; Aberbach & Rockman 2002):** self-serving
  recall, hindsight, strategic presentation (for an elite the interview is
  a move in an ongoing game), interviewer effects (Fujii 2018). Ask about
  episodes, documents, and others' roles, not motives in general; check
  each claim that codes a node against a contemporaneous document or a
  differently placed interviewee.
- **Saturation by category (Guest, Bunce & Johnson 2006):** about twelve
  interviews in a homogeneous group with a fixed guide; it does not carry
  across categories or to facts about one case, where one insider can be
  decisive. Claim it per category and clue.
- **Translation:** the original-language transcript is the record; log the
  translator and date, and give originals of quoted passages in an appendix.
- **Quoting:** pseudonym plus coarse role ("P07, senior official, economic
  ministry"); no combination of role, date, place, or anecdote that picks
  out one person; only within the consent tier (Fujii 2012; APSA 2020).

## Field notes and observation

- **Jottings, then full notes the same day (Emerson, Fretz & Shaw 2011):**
  both under one E-ID, neither revised. Notes naming people go to
  restricted/ and reach evidence/raw/fieldnotes/ via /qualstack:deidentify.
- **Observation apart from interpretation:** who, where, what was done and
  said, in order, verbatim marked; interpretation in labeled asides.
- **Positionality:** a dated note on how the researcher was introduced and
  seen; people perform for observers, raising f for what they want seen.
- **Immersion (Schatz 2009)** yields actors' meanings, unwritten practice,
  and the sense of what is routine that makes an observation diagnostic.
- **Into the model:** an observation is evidence about a node; name it in
  `clues`, and say in the coding log which value it supports and why. An
  observation that prompted a model change cannot also test that change.

## Secondary sources and historiography

- **Evidence or literature:** literature when you engage its argument;
  evidence (an E-ID, full source criticism) when you code a node from it.
- **Check the footnotes:** follow each coded claim to an archive (code from
  the primary if you can reach it), another secondary (follow on), an
  interview, or nothing (the historian's inference); record it in `notes`.
- **A synthesis is not independent** of the primaries it cites: a historian
  quoting the minutes you cite adds nothing to the minutes.
- **Disputes as rival models:** a contested node value (run both in
  /qualstack:robustness) or a rival structure (/qualstack:causal-model);
  never settled by choosing the historian whose account fits.

## Chronology discipline

- **Event dates vs. document dates.** Each entry carries the event date and
  each attesting document's date; the gap is recall lag.
- **Anachronism.** A later document as evidence of an earlier motive is
  recollection, not record: a 1995 memoir on the aims of 1989 is evidence
  of what was said in 1995. Code motives at t from documents written by t,
  or code the recollection with lower s and higher f, and say which.
- **Precision.** Two same-month dates fix no order, and order is often the
  claim; use relative evidence (a reply cites its letter), and convert
  calendars (Julian in Russia before 1918) in `notes`, keeping the original.
- **Critical junctures (Capoccia & Kelemen 2007)** need dated,
  contemporaneous evidence of when choice opened and closed and which
  options actors weighed; **sequences (Falleti & Mahoney 2015)** need dates
  fine enough to fix order and duration.
- **Against the model.** The chronology is the event-history map (Waldner
  2015): for each arrow A → B, A is settled before B in every case, or the
  coding or the model is wrong; /qualstack:chronology flags it.

## What referees fault

| Complaint | What the area expert sees | Fix |
|---|---|---|
| Cherry-picked quotes | One vivid quote, no denominator, no context | The surrounding passage in an appendix or an ATI annotation at QDR (Moravcsik 2010); how many sources per category address the point and how many agree; the strongest disconfirming quote |
| Single-source claims | A decisive node value resting on one item | A second source with independent error; otherwise flag it single-source with its s and f, and show the result with the clue set to NA |
| Unexamined interviewee incentives | Testimony taken at face value | Per clue, the interviewee's position and stake; creditable claims corroborated elsewhere; statements against interest preferred |
| Unacknowledged archive gaps | Silence read as absence | Series, period, closures, and withdrawal slips reported from the search records; affected clues NA or modeled with detection below 1 |
| Reliance on one historian | The historiographic debate invisible | The debate stated; contested nodes coded under each account; footnotes checked (Lustick 1996) |
| Anachronistic evidence | Memoirs and interviews offered as proof of past motives | Every source dated; motives coded from contemporaneous records; recollection labeled and weighted as such |
| Translations without originals | Key passages only in English | Original-language text of quoted passages; translator named; key terms glossed |
| Unverifiable "interviews with officials" | Anonymous, uncounted, undated | The interview methods table; each interview an E-ID with date, role category, and mode; a deposit or confidential-access plan the consent tier allows (QDR; check current terms) |
| Echoes counted as corroboration | Five papers repeating one leak | Each report traced to its origin; origins counted, not reports |
