# Transparency, human subjects, and data protection in qualitative research

Read by `/qualstack:fieldwork-plan` and `/qualstack:interview-guide`
(approval, consent, safety), `/qualstack:deidentify` (identifiability and
the AI-processing gate), `/qualstack:preregister`, `/qualstack:archive`
(the transparency package), `/qualstack:submission-pack` (anonymization),
and `/qualstack:evidence-audit` (access tiers, withheld items, leaks).
Ethics rules, data-protection law, and journal and repository policies
differ by place and change: this file says what to check, and the check is
made against the current version when the decision is made.

## Two obligations that pull against each other

| Obligation | What it covers | In QualStack |
|---|---|---|
| Data access | The evidence itself, or a statement of why it cannot be shared; under JETS (2014), authors with restricted data tell the editor at submission, not at acceptance | `evidence/log.csv` with an `access` tier per item; deposit at the Qualitative Data Repository (QDR) |
| Production transparency | How the evidence was generated: whom you sought and reached, which archives and series you searched | The interview methods table; `source` and `notes` in the log; dated memos |
| Analytic transparency | How the evidence licenses the conclusion | `data/coding-log.csv`, the CausalQueries model, ATI or active citation |
| Protection of participants | Retaliation, prosecution, stigma, retraumatization, lost livelihood | `restricted/`, pseudonyms, consent tiers, coarsened attributions |
| Protection of sources | People named by participants or in documents, who never consented; archives and providers whose terms bar reproduction or upload | The identity key covers them; `archive-restricted`, with the call number as the route |
| Protection of the researcher and team | Physical safety, seized devices and notes, future access to the field | A safety plan; minimal, encrypted devices |

The first three rows are the DA-RT/JETS vocabulary. The Qualitative
Transparency Deliberations (Jacobs, Büthe et al. 2021) reframed the
debate: transparency's demands depend on the inquiry and the setting;
protecting participants outranks openness when they conflict; and openness
takes many forms besides posting data. Repository access controls can
reconcile sharing with confidentiality (Elman, Kapiszewski & Lupia 2018).

**QualStack's defaults.** (1) Protection wins every conflict; the paper
says what was withheld, why, and how the claim can still be checked. (2)
Every evidence item, confidential ones included, has a log row with an
access tier: the path from `\ev{E014}` to its evidence is inspectable even
when the evidence is not. (3) The model code, `data/case-data.csv`, and
`data/coding-log.csv` carry no participant text and are always shared. (4)
Identifiable material stays in `restricted/`, outside Claude's context;
nothing is quoted, deposited, or sent to an AI service beyond what consent
and the protocol anticipated. (5) The paper says what cut against the
argument, where searches found nothing, and where you stood.

## Forms of transparency for qualitative work

| Form | What it makes inspectable | In QualStack | Rules and limits |
|---|---|---|---|
| Evidence log with access tiers | Which items each claim rests on, with provenance and access: `open` (anyone can obtain it), `archive-restricted` (a qualified researcher can, under an archive's or QDR's conditions; `source` names the route), `confidential` (no one else can) | `evidence/log.csv` via `/qualstack:evidence-log`; cited as `\ev{E014}` | Confidential rows carry pseudonyms and categories only; the deposited copy coarsens dates and roles in small populations |
| Excerpts | The words behind a contested claim | Quotations followed by `\ev{}`, checked by `qualstack-quotecheck` | Enough context to support the reading; never more than the attribution tier permits |
| Full documents | Context, including the passages that cut against the claim | A QDR deposit, or the archive's call number in `source` | Consent for deposit and the archive's reproduction terms decide |
| Active citation (Moravcsik 2010) | Per contested claim: the source excerpt, an annotation of how it supports the claim, the full citation | A transparency appendix keyed to the footnotes, drafted from the evidence and coding logs | Works in any journal; costly, so reserve it for the clues that move a posterior |
| Annotation for Transparent Inquiry (ATI, at QDR) | The same, attached to specific claims in the published article: excerpt, source information, analytic note | Annotations drafted from the same logs | Check that QDR and the journal currently offer it for the article type |
| Interview methods table (Bleich & Pekkanen 2013) | Production: the frame; who was sought, interviewed, or declined; format, length, recording, transcription; saturation | `paper/sections/appendix.tex`, by pseudonym or by category | The table can itself disclose: report categories, years, and regions in small populations |
| QDR deposit with access controls | The evidence itself, for approved users under stated access conditions | Assembled by `/qualstack:archive` | Only what consent anticipated; check QDR's current access options and deposit terms |
| Model code and coded case data | The inferential step: from coded clues to posteriors, rerunnable under other priors or codings | `code/`, `data/case-data.csv`, `data/coding-log.csv`, `data/coding-rules.md`, `model.seed` | Always shared; write the coding log's `note` column for publication (no names, no confidential quotes) |
| When nothing can be shared | The claim, still checkable in part | Describe the evidence (counts by type and role, date range, language), the coding (rules and log), and the access route, even if it is "none"; share the model and coded data | Report how far the conclusion leans on it (below) |

- **The Integrated Inferences advantage.** With a CausalQueries model the
  step from evidence to conclusion is code, not a judgment in the author's
  head (Humphreys & Jacobs 2023): a reader who never sees a transcript can
  rerun it, change a prior, or flip a coded value and see what survives.
- **Reliance on confidential evidence is a number.** `/qualstack:robustness`
  should set each value coded only from `confidential` items to NA, one at
  a time and together, and report how far the posterior moves.
- **Policies change**: at journal choice (`/qualstack:journal-fit`),
  submission, and deposit, check the current data policy, QDR terms, and ATI.

## Human subjects

APSA (2020) makes ethics the researcher's responsibility, not the board's,
and asks for openness about ethical choices: the appendix reports them.

| Principle (APSA 2020) | In a qualitative project |
|---|---|
| Respect for persons | Autonomy and dignity; the right to decline, stop, or withdraw without consequence, so never recruit through a superior or an armed gatekeeper |
| Consent appropriate to context | Informed and voluntary; where a signed form endangers (repression, irregular status, conflict) or literacy differs, an approved oral script, logged by pseudonym |
| Power and vulnerability | Elites can be harmed too (careers, prosecution); dependents of gatekeepers, detainees, refugees, the undocumented, and minors need added protection |
| Deception | Only with a justification stated in the protocol and the paper; an interview under a false pretext defeats consent |
| Harm and trauma | Questions about violence, loss, or persecution can retraumatize: plan breaks, the right to stop, and referral |
| Confidentiality | Promise only what you can keep against subpoena, device seizure, and deductive disclosure; keep it through publication and deposit |
| Impact on communities | Effects beyond participants: on communities, on political processes, on others' access to the field |
| Local law and review boards | Home approval plus local permits, research visas, and local review where it exists; approval is necessary, not sufficient |

**Consent** (`/qualstack:interview-guide` drafts the script). Attribution
tiers are agreed per interview and per passage ("this part is off the
record") and defined in the form, because journalistic usage varies:

| Tier | What may be used | Cited as | `access` |
|---|---|---|---|
| On the record | Quotation, name, and title | Name and title, only if the form says so in writing | `open` or `archive-restricted` as deposit was consented, else `confidential` |
| Not for attribution | Verbatim quotation | A described role: "P07, a senior ministry official" | `confidential`, or `archive-restricted` if deposit was consented |
| Background | Paraphrase, no quotation | A group: "officials involved in the negotiation" | `confidential` |
| Deep background | Nothing citable; it points the search | Not cited: find a citable source for the clue | `confidential`, noted "not citable"; never the sole basis of a coded value |

- **Separate opt-ins, written to anticipate deposit**: recording,
  quotation, deposit at QDR with access controls, reuse, third-party and AI
  processing. Consent cannot be retrofitted: "only the research team will
  see this" rules out deposit and AI processing without re-consent (check
  QDR's current guidance first). On withdrawal the log row stays with a
  note, the values coded from it go to NA, and the model is rerun.
- **Conflict settings and vulnerable groups.** Approval is the floor; the
  dilemmas arrive in the field (Fujii 2012): who sees you with whom, what
  your questions signal, what seized notes reveal. Recruit so refusal is
  safe, let participants choose the place, and carry no list of names.
- **Safety** (Kapiszewski, MacLean & Read 2015): check-ins, a detention
  plan, minimal encrypted devices. Assistants and interpreters stay after
  you leave: never hand them the dangerous interviews; pay and train them;
  tell participants they will be present; name them only with consent.
- **Positionality and reflexivity.** Who you are shapes access and what
  people say; interview data are co-produced (Fujii 2018). In a model this
  is a likelihood, not a confession: it moves the chance a source reports
  a clue when true and when false, and elites shade accounts (Berry 2002).
  Model it in `/qualstack:source-critique` (true K → reported K).

## Confidentiality in practice

| Identifiability | Examples | Rule |
|---|---|---|
| Direct identifiers | Name, nickname, face, voice, signature, phone, email, ID number, exact address | Only in `restricted/` (key, originals, recordings, consent forms); replaced by `P01`, `[Ministry A]`, `[Town 3]` via `qualstack-redact` |
| Indirect identifiers | Title or rank, organization, date, place, ethnicity, age, an event witnessed, a turn of phrase | Coarsen: deputy minister → senior official; an exact date → the year; town → region; at most one precise indirect identifier per attribution |
| Deductive disclosure | Combinations that fit one person in a small elite population: "the only woman on the negotiating team" | Test against insiders, not strangers: could a colleague of P07 name P07? If so, broaden the category or paraphrase without attribution |

| Practice | Rule |
|---|---|
| Identity key | Only in `restricted/key.csv` (`real,pseudonym,kind`, spelling variants separated by a vertical bar); it also covers people participants name who never consented, organizations, and places |
| Pseudonyms | `P01`, `P02`, … assigned in an order unrelated to identity (not alphabetical, not by rank) and used everywhere outside `restricted/`, including in what you type to Claude |
| Attribution | Never combine role + date + location in a quote attribution when the population is small; use a category at least five people fit: "P07, a senior official", not "P07, deputy finance minister, interviewed in the capital the week of the devaluation" |
| File names | Neutral IDs (`int-07.txt`, never `jane-official.txt`); `qualstack-redact` withholds originals named otherwise, because file names get printed and listed |
| Metadata | Author fields, tracked changes, comments, photo EXIF (GPS, time, device), audio tags, and voices identify: convert to `.txt` or `.md` before anything leaves `restricted/`, strip EXIF, deposit audio only if consent covers the voice |
| Storage and transfer | Full-disk encryption; `restricted/` outside cloud-sync folders unless the protocol names the service, and outside git (`git add -f` defeats `.gitignore`); the institution's encrypted channel, never email; transcribers sign confidentiality agreements and are covered by the consent |
| Retention and destruction | The protocol's schedule, dated in a calendar; each destruction logged (date, IDs, method, never names) in a dated memo in `evidence/memos/`; the key backed up, encrypted, apart from the transcripts until then |

## AI processing of research data

Sending transcripts or field notes to a cloud AI service discloses them to
a third party: in Claude Code, whatever Claude reads (a file, grep output,
printed R output) goes to the model provider, and cloud transcription and
translation disclose too. Before anything derived from participants enters
the project, check what each of these permits, at what identifiability:

| Check | What to look for |
|---|---|
| Ethics approval | Whether the protocol permits third-party processing; "stored on university servers only" does not cover a cloud model; amend before, not after |
| Consent forms | What each participant agreed to; a later form does not cover earlier interviews |
| Data-protection law where it applies (e.g. GDPR) | Pseudonymized data remain personal data for whoever holds the key; political opinions, ethnic origin, religion, and union membership are special categories; transfers outside the EEA have their own rules; ask the data-protection officer whether an agreement with the provider is needed |
| Data-use agreements, archive terms | Bans on copying, uploading, or processing outside an approved environment |
| Provider terms | Retention, training use, and where processing happens, for the account in use; any institutional agreement |

`privacy.ai_processing` in `.qualstack/config.yaml` records the answer. An
empty setting is not permission: Claude treats it as `none` and asks the
researcher to set it before opening anything derived from participants.

| Setting | May enter the project folder, and so Claude's context | Never | Basis |
|---|---|---|---|
| `none` | Nothing derived from participants; Claude works only from the researcher's own non-identifying summaries and coded values, if the protocol allows even that | Transcripts, notes, excerpts, recordings, pseudonymized or not; `/qualstack:deidentify` refuses and `qualstack-redact apply` writes nothing; keep the originals off this machine | Protocol or consent silent on, or forbidding, third-party processing |
| `pseudonymized` | Pseudonymized transcripts and notes that `qualstack-redact` writes to `evidence/raw/` | The key, the originals, recordings, consent forms | Processing of de-identified material approved and consented |
| `full` | Identifiable material, e.g. on-the-record elite interviews | Consent forms, recordings, anything not cleared for this use | Protocol and consent explicitly allow identifiable processing by third-party services |

| Mechanism | What it does | Limit |
|---|---|---|
| Guard hook (always on) | Denies Read, Grep, Glob, Write, and Edit on `restricted/`, and Bash commands that name it, glob into it, or scan the project root without excluding it; `.ignore` and `.gitignore` list it | A backstop, not a vault: it reads command lines, not what a script opens (`Rscript code/03-data.R` passes even if the script reads `restricted/`, so no code may touch it); copies outside `restricted/` are unprotected; if the protocol forbids any third-party processing, keep identifiable data off this machine |
| `qualstack-redact apply`, run by `/qualstack:deidentify` | Finds the key and originals through `privacy.key` and `privacy.originals`, so its command line never names `restricted/`; writes pseudonymized copies to `evidence/raw/interviews/`, never overwrites, prints only counts, file names, and pseudonyms; lists candidate names the key missed in `restricted/redaction-review.txt`, for the researcher | Pseudonymization is not anonymization: titles, dates, places, and turns of phrase survive; read every output before it is logged |
| `qualstack-redact check` | Scans `paper/`, `evidence/`, `data/`, `.qualstack/`, `output/`, `submission/`, and `prereg/` for keyed real names; reports file, line, and pseudonym, never the name; exits 1 on a hit | Knows only the names in the key; run it before anything is shared |

**Log AI use as part of the instrument.** An LLM that codes evidence or
assesses probative values is a measurement instrument: log each task with
`/qualstack:llm-checklist` (model, date, prompts, what it saw at which
`ai_processing` level, agreement with human coders, e.g. Cohen's (1960)
kappa); report it in the appendix and follow the journal's current rules.

## Preregistration of qualitative and process-tracing studies

- **Why.** Which clues count, and how much, are the forking paths of
  process tracing, and a registered plan fixes them (Jacobs 2020): a
  probative value set after the clue is seen is a specification chosen
  after the estimate. Plans are feasible for qualitative inference (Kern &
  Gleditsch 2017; Piñeiro & Rosenblatt 2016), inductive designs included
  (Haven & Van Grootel 2019). In a causal model probative value is
  P(K | type), so registering the model fixes it for every clue at once.
- **What** (`prereg/prereg.md`): the causal model with its code
  (`code/01-model.R`), restrictions, confounding, and priors; the queries,
  one primary; the case-selection rule and cases; the clue plan, with
  where each clue will be sought and its predicted probative value
  (P(K = 1) by type, from `code/02-design.R`); the coding rules (version
  and hash); decision rules, robustness, and data availability.
- **When.** Before collecting the decisive evidence; scoping fieldwork for
  access may come first if the plan says what was already seen. A public
  plan names cases and sources: describe sources by category or register
  under an embargo (check the registry's current options).
- **Surprises** go in a dated addendum (`prereg/addendum-YYYY-MM-DD.md`)
  written before the new evidence is coded. A closed archive or withdrawn
  participant leaves the clue NA; a new clue takes its probative value
  from the registered model before it is coded, with results reported with
  and without it; a wrong model is reported registered and revised, side
  by side. The paper lists every deviation beside the original plan.
- **In QualStack**, once `design.prereg_url` is set, the guard hook makes
  existing files in `prereg/` read-only; new dated addenda can be added.

## The transparency package at publication

`/qualstack:archive` assembles it; `/qualstack:evidence-audit` checks it.

1. `README.md`: layout, how to trace a claim from `\ev{}` to its log row,
   how to rebuild every formal result, software and package versions.
2. `evidence/log.csv` with access tiers; each item consent lets you deposit.
3. `data/coding-rules.md` (every version), `data/coding-log.csv`, and
   `data/case-data.csv` (NA means not observed).
4. `code/` with `model.seed`, and a clean-room rebuild: a fresh copy and a
   fresh R session run `code/01` to `06` and reproduce every number.
5. ATI annotations or active citations; the interview methods table.
6. A de-identification statement (what was pseudonymized, coarsened, or
   removed; the residual risk) and a consent and ethics statement.
7. A withheld-items table: what is not shared, why, and the access route.
8. The preregistration, addenda, and deviations; the LLM-use report from
   `/qualstack:llm-checklist` when an LLM coded or assessed evidence.

Before deposit: `qualstack-redact check` and `qualstack-quotecheck` pass,
document metadata are stripped, `restricted/` is absent, memos go in only
after a read for identifiers, and consent covers each item at its tier.

## Anonymous review

| Deanonymizes | Example | Fix |
|---|---|---|
| Fieldwork and archive acknowledgments | "I thank the staff of the national archive of X and my hosts at Y" | Title page |
| Interviewee thanks | "the officials of [Ministry A] who spoke with me" (exposes them as well as you) | Title page, as a group, if at all |
| Ethics protocol number | "approved by the [university] IRB, protocol no. [number]" | Title page; the text says "approved by the author's review board" |
| Fieldwork self-reference | "during my fieldwork in X", in a small field | "fieldwork in X"; first-person detail to the title page |
| Grant numbers | Funder and award number | Title page |
| Links and self-citation | A QDR DOI or registry page that shows the author; "as I showed in my earlier book" | An anonymized view-only link if offered, else "withheld for review"; self-citation in the third person |
| Files | PDF author metadata, file names, tracked changes | Clear before upload |

`/qualstack:submission-pack` moves these to a separate title page, leaves
placeholders, and keeps `privacy.protocol` out of the anonymized PDF.

## Checklist

**Before fieldwork**

1. Approval for every site: home board, local review, permits, visas.
2. Consent with separate opt-ins: recording, tier, deposit, reuse, AI use.
3. `privacy.ai_processing` set from the protocol, the consent, and the law.
4. `restricted/` built, encrypted, outside cloud sync and git, backed up.
5. Pseudonym scheme fixed: `P01`…, bracketed places, neutral file names.
6. A risk assessment per participant group, with mitigations.
7. A safety plan covering you, assistants, and interpreters.
8. Preregistration filed before the decisive evidence; `prereg_url` set.
9. Retention and destruction dates in a calendar.
10. A dated positionality memo in `evidence/memos/`; a deposit plan.

**Before submission**

1. `qualstack-redact check` clean, except on-record names cleared in writing.
2. Every attribution passes the insider test; the methods table coarsened.
3. `qualstack-quotecheck` passes for every quotation.
4. Every `\ev{}` logged with a tier; every coded value in the coding log.
5. The clean-room rebuild reproduces every formal result.
6. Reliance on confidential evidence reported (`/qualstack:robustness`).
7. Withheld-items table done; the editor told of restricted evidence.
8. Preregistration deviations reported beside the original plan.
9. LLM use logged and disclosed under the journal's current rules.
10. Identifying details on the title page; PDF metadata clean.
