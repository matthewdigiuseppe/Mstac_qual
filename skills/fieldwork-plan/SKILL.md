---
name: fieldwork-plan
description: Plans fieldwork as a search for the clues in the clue plan — a source map giving, for every case and planned clue, the archives, collections, interviewees, and sites that could reveal it and how likely each is to find it if it is there; archive logistics checked against current rules; the interviewee sampling frame, access route, and interview budget; ethics approval and consent, including the AI-processing clause that sets privacy.ai_processing; data management around restricted/; safety for the researcher, assistants, interpreters, and participants; timeline and budget; a stopping rule based on expected learning; and a contingency for every longest pole. Use when the user is planning a field trip, an archive visit, or an interview campaign, asks where to look for which evidence or how long fieldwork will take, needs ethics approval, consent, or a data-management plan, or wonders whether to keep searching an archive.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebSearch
  - WebFetch
  - Bash(date *)
---

# /qualstack:fieldwork-plan

**Stage:** design · **Voice:** field-director

A field season is a sampling plan for clues, not an itinerary. Every archive day and every interview is in the plan because it is the cheapest place a planned clue could turn up, and it leaves the plan when the expected learning it can still buy is worth less than its days. Refuse "soak and poke" time with no clue attached, and never assert an access rule, fee, permit, or declassification status from memory.

## Procedure

1. **Load.** `.qualstack/config.yaml`, `.qualstack/clue-plan.md` (clues, their φ's and expected learning, the two-step plan), `.qualstack/case-selection.md`, `.qualstack/queries.md`, `.qualstack/lit-map.md` (the evidence others used for which clues), and `evidence/log.csv` if anything is logged. Read, from `${CLAUDE_PLUGIN_ROOT}/references/`, `evidence-and-sources.md` (archives, interviews, absence of evidence), `transparency-and-ethics.md` (human subjects, confidentiality, AI processing, the before-fieldwork checklist), and `design-diagnosis.md` (clue and case selection by expected learning). Then ask, in one message, only what the files leave open: field window and total days, budget ceiling, languages, affiliation and letters available, approvals in hand, contacts by role, security conditions at each site. No clue plan or case selection → plan a **scoping trip** only: its job is to measure access, detection, and days per source for `/qualstack:clue-select`, and the plan lists everything seen on it so `/qualstack:preregister` can disclose it.
2. **Source map,** the core of the plan: one row per case × planned clue × source.

   | Case | Clue (node) | Source | Type | P(found \| K) | f | Days | Access | Independent of |
   |---|---|---|---|---|---|---|---|---|

   - **Source** at the finest grain known: archive › collection › series › boxes; an interviewee category; a site; a published document collection or press run. **Type** and **Access** use the `evidence/log.csv` vocabularies.
   - **P(found | K)** = P(recorded or witnessed) × P(survived and released, or remembered and willing to say at a usable tier) × P(the search reaches it) × P(recognized), each factor with its reason. It is the source's s.
   - **f** = the chance the source reports K when K is false, from its author's incentives (credit, self-protection, a public audience): the first draft of what `/qualstack:source-critique` will estimate.
   - Every planned clue in every planned case gets a row, or is declared unobservable there: it will be NA, and `/qualstack:clue-select` recomputes without it.
   - **Absence must be codable.** If no source for a clue has a high P(found | K), finding nothing will be NA, not 0: the clue cannot fail a hoop test in that case, and the clue plan overstates its value. Flag it.
   - **Independent errors.** A second source counts only if its errors are independent given K: the minutes and the memoir written from them are one source; the other side's files (a foreign ministry, a lender) are another. A decisive clue gets two independently placed sources or is flagged single-source.
   - **Contemporaneous over retrospective** for motives and timing: an interview about 1989 is evidence of what is said now. From the lit map: series the historiography has mined add little unless read for a clue it ignored; series never consulted or newly released are where new evidence is.
   - **What a source is worth.** Through a source the clue's likelihoods become φ' = s·φ + f·(1 − φ), and its expected learning follows from φ' and the prior (`bayesian-process-tracing.md`). Detection costs more than proportionally: a source that finds K half the time turns a doubly decisive clue (φ = .9 vs .1, prior .5) into a smoking gun and buys a third of its expected learning (.21 vs .64).
3. **Archive logistics,** one block per archive:
   - **Access:** accreditation and letters of introduction; application lead times; the finding aids (online or reading room only) and which series exist for the period, were never transferred, or are closed; the declassification status of each needed series and any request route with its current lead time (no decisive clue rests on a pending request without a plan B); reading-room rules on photography (allowed, with which device, at what fee), daily request and box limits, pull times, closures; language and script.
   - **Check, never assert:** take each rule from the archive's current website or a written reply (WebSearch, WebFetch), record the source and date, and carry it as `to check: <rule>, with <whom>, by <date>` until confirmed in writing. A photography ban multiplies the days.
   - **Terms:** reproduction and upload terms decide whether scans may go through `/qualstack:pdf-ingest` or any AI service; where they forbid it, log the items `archive-restricted` with the call number and work from the researcher's own notes as the terms allow.
   - **In the field:** one PDF per document, named by E-ID and logged that day; every search logged that day in `evidence/raw/searches/` (series and boxes opened and not, terms, hours, withdrawal slips).
4. **Interviewee frame and access,** per category in the source map:
   - **Frame:** positional first (every holder of the post in the period), then reputational, snowball last; population, number sought, expected obtained, and why. Prospective interviewees appear by post and years, never by name, in the plan, in web searches, and in prompts; the researcher matches posts to people offline and keeps names in the identity key (`privacy.key`).
   - **Access route** (affiliation, letters, introductions) and each gatekeeper by role: what they want, and how their hand shapes who talks and what is said. Never recruit through a superior or an armed gatekeeper, so refusal stays safe. Snowball over-samples the connected and the winners and spreads one story: log who referred whom.
   - **Who is missing** (the dead, exiled, purged, defeated, junior, and refusers) and which clue their absence biases.
   - **Interview budget:** N per category justified by clues (each decisive clue from two differently placed people, not a saturation count), at the full cost of an interview: preparation, travel, interpreter, transcription, and the same-day write-up.
5. **Ethics approval and consent.**
   - **Approvals** for every site, with lead times: home board, local review where it exists, research permits and visas (check current requirements); amend before, not after. `design.human_subjects: true` when living people will be interviewed or observed, elites included; exemption is the board's call, not the plan's. Archival work alone usually leaves it false; confirm with the board when documents hold identifiable private information about living people, and protect people named in documents either way.
   - **Consent** with separate opt-ins (recording, attribution tier, deposit with access controls, reuse, third-party and AI processing), oral where a signed form endangers; consent cannot be retrofitted.
   - **The AI-processing clause:** draft it with the user for the protocol and the form, worded so its answers map onto `none | pseudonymized | full` (what would be processed, at what identifiability, by what kind of service, for what purpose, with its own yes/no). Set `privacy.ai_processing` to the most restrictive of the approved protocol, the consent as worded, data-protection law where it applies, archive and data-use terms, and the provider's terms for the account in use; while approval is pending, write `none` and say why. Record `privacy.protocol` once issued.
   - **Narrower consents:** a participant who agreed to less than the setting stays out of the folder. Their originals are kept outside `privacy.originals` (which `/qualstack:deidentify` processes wholesale), and the interview enters only as a log row (file withheld, said in `notes`) and the researcher's coded values.
6. **Data management,** by category, never by content:
   - `restricted/` holds the identity key (`privacy.key`), unredacted transcripts and notes as `.txt` or `.md` (`privacy.originals`), recordings, consent forms, photographs showing faces, and contact lists. The researcher moves material there; Claude never reads it.
   - Full-disk encryption on every device; `restricted/` outside cloud sync unless the protocol names the service, and git-ignored before the first commit (the researcher confirms); recorder to encrypted storage the same day, wiped after a verified copy; the key backed up, encrypted, apart from the transcripts; travel with minimal data and no list of names; neutral file names carrying the E-ID; retention and destruction dates from the protocol in a calendar; the funder's current data-management requirements checked.
   - **Flows:** scans → `evidence/raw/archival/` the day captured, terms permitting; interview originals and field notes naming people → `restricted/` → `/qualstack:deidentify` → `evidence/raw/interviews/` or `evidence/raw/fieldnotes/`, only if `privacy.ai_processing` allows.
7. **Safety and risk** (Kapiszewski, MacLean & Read 2015; Fujii 2012), for the researcher, assistants, interpreters, and each participant group:
   - The harms (retaliation, prosecution, stigma, retraumatization, lost livelihood, seized devices), what being seen with you or asked your questions signals, and the mitigation for each.
   - Scheduled check-ins with a named contact, a detention and device-seizure plan, institutional travel registration and insurance (check current requirements), a local affiliation; participants choose the place.
   - Assistants and interpreters stay after you leave: never hand them the dangerous interviews; pay, train, and bind them by confidentiality agreements; tell participants they are present.
   - Exit criteria decided now: what deterioration ends a site or the trip. Contact details and operational specifics stay out of the plan. Before departure, a dated positionality memo in `evidence/memos/`.
8. **Timeline and budget.** A week-by-week table built from the source map: approvals and visas, archive applications, archive days per series, interview windows (legislative sessions, elections, holidays), same-day write-ups, transcription, buffer. Order the itinerary by the two-step plan: the first clue's best sources first, second-step sources booked tentatively and released when the branch says stop. Budget lines (travel, subsistence, archive fees, assistants and interpreters paid fairly, transcription, encrypted devices, insurance, participant compensation the protocol allows): every amount sourced or marked `to check`.
9. **Stopping rule** (Humphreys & Jacobs 2023, §12.2). Days are the currency; expected learning about the primary query is the return.
   - **The bar:** what the time costs is the expected learning the same days would buy at the next-best item in the plan (once the plan is exhausted, a floor the user sets per field day). Keep a source in the itinerary while its expected learning per day clears the bar; stop seeking clue K in case j when no remaining source for it does, code what the searches support (0 only if their P(found | K) was high; else NA, or the search as a source, `K -> Kf` with f ≈ 0), and move the days on. The same rule ends interviewing in a category.
   - **The two-step plan:** after the first clue, its branch says whether the second is sought; an NA takes neither branch, so fall back to the best strategy without that clue. Clues condition each other: after each find, have `/qualstack:clue-select` recompute with the coded values added to `given`.
   - **Legitimacy:** a dynamic rule is sound only if every search, the failed ones included, is logged and coded; stopping when the favored clue appears and dropping the misses manufactures the finding. Saturation and "nothing new" are not the rule. Pre-commit it in `/qualstack:preregister`.
10. **Contingencies,** one per longest pole (approval, archive access or declassification, a key interviewee category, visa, security, language): the trigger (a date or an event); plan B (another source for the same clue from the source map, the other side's archive, a published document collection, remote interviews, the next case in `.qualstack/case-selection.md`); and the inference cost, meaning which case × clue cells go NA and how much expected learning is lost. If a decisive clue becomes unobservable in every case, return to `/qualstack:clue-select` or `/qualstack:case-select` before buying the ticket. After registration, each change is a dated addendum.
11. **Write and set.** Write `.qualstack/fieldwork-plan.md`. In `.qualstack/config.yaml`, set `design.fieldwork: true` (interviews, archives, or observation planned), `design.human_subjects`, `privacy.ai_processing`, and `privacy.protocol` as above; append a `decisions:` line dated with `date +%Y-%m-%d` (e.g. `"<date>: fieldwork plan, 3 archives and 2 interview categories; ai_processing none until approval"`); set `paper.status: "designing"` if it is earlier.

## Outputs

- `.qualstack/fieldwork-plan.md`: source map; archive logistics; interview frame, access, and budget; ethics, consent, and the AI clause; data management; safety; timeline and budget; stopping rule; contingencies; **open checks** (every `to check` item with owner and date).
- `.qualstack/config.yaml`: `design.fieldwork`, `design.human_subjects`, `privacy.ai_processing`, `privacy.protocol`, a decisions line.
- Summary block: case × clue cells covered, single-source, and unobservable; the longest pole and its plan B; `privacy.ai_processing` and its basis; days and cost; open checks; the next skill.

## Anti-patterns

- **Soak and poke.** An archive day or an interview with no clue attached.
- **Rules from memory.** Photography rules, declassification, fees, permits, and visas change; check and date each.
- **Silence coded as 0.** A thin search supports NA, not absence.
- **Snowball as the frame.** It finds the connected winners and their shared story.
- **The convenient privacy setting.** `privacy.ai_processing` follows approval and consent, never the workflow.
- **A safety plan for the researcher alone.** Assistants, interpreters, and participants carry more of the risk and stay behind.
- **Searching until the clue appears.** A stopping rule that forgets the misses manufactures the finding.

## Next

Interviews planned → `/qualstack:interview-guide`. Detection or days changed the clue plan's numbers → `/qualstack:clue-select`, with the source map's days as prices. Then `/qualstack:coding-rules` and `/qualstack:preregister` before the decisive evidence; in the field, `/qualstack:evidence-log` the day each item arrives and `/qualstack:deidentify` for transcripts and notes.
