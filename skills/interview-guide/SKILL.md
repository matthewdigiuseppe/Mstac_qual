---
name: interview-guide
description: Drafts an interview guide in which every question is mapped to the clue (model node) it targets and the rival it discriminates — neutral, non-leading wording; rapport, narrative, specifics, then sensitive questions; planned probes; elite and relational interviewing practice — together with the consent script (attribution tiers and the AI-processing clause), rules for notes and recordings, a same-day post-interview memo template, and a reporting plan built on the interview methods table. Use when the user is preparing elite, expert, or participant interviews, writing interview questions or a consent script, asks how to interview officials, how to record or write up interviews, or how many interviews are enough.
argument-hint: "[interviewee category]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(date *)
  - Bash(python3 *)
---

# /qualstack:interview-guide

**Stage:** design · **Voice:** interviewer

An interview measures clues through a witness who has a position and a stake, so the guide is an instrument: every question names the node it targets and the rival its answer would discriminate, and a question with no target is cut, however good the color. Refuse leading wording, questions about motives with no episode attached, and any handling that lets an original recording, transcript, or consent form into the project tree outside `restricted/`.

## Procedure

1. **Load.** `.qualstack/config.yaml`, `.qualstack/clue-plan.md`, `.qualstack/fieldwork-plan.md` (categories, frame, consent decisions), `.qualstack/queries.md`, `data/coding-rules.md` (what each value of a node requires), and `.qualstack/lit-map.md` (rivals). Read, from `${CLAUDE_PLUGIN_ROOT}/references/`, `evidence-and-sources.md` (interviews; source criticism as likelihoods) and `transparency-and-ethics.md` (consent tiers, confidentiality, AI processing). Ask only what the files leave open: languages and interpreters, mode, slot length per category. No clue plan → stop and run `/qualstack:clue-select`. No fieldwork plan → the consent script and AI clause are drafts marked `pending approval`. `$ARGUMENTS` names one interviewee category to draft or revise; default all.
2. **One module per interviewee category,** because what a person can report depends on where they sat; each module covers the clues the fieldwork plan's source map assigns to that category.
3. **The question map** opens each module:

   | ID | Wording | Target | Reveals, as the coding rule reads it | Under H / under the rival | Probes | Sensitivity | Stake |
   |---|---|---|---|---|---|---|---|

   - **Target** is a node. Rapport questions target the interviewee's position, which sets s and f for every later answer; the narrative question targets every clue an unprompted account can reveal, and a clue volunteered before any specific question has a lower f. Nothing else qualifies.
   - **Under H / under the rival:** the answer expected if the hypothesis holds and if the strongest rival does. Cut a question whose expected answer is the same under both: its likelihood ratio is 1.
   - **Stake:** creditable for this interviewee → f up; against interest → f down (`evidence-and-sources.md`).
   - Each clue gets a question whose answer can show its absence (who was in the room, what was on the agenda, what happened next), so a non-mention by someone placed to know means something under the coding rule.
   - Ask about the rival's path as specifically as the favored one; alternative-cause clues are often the most informative (Humphreys & Jacobs 2023, ch. 8).
   - Rank the specifics by the clue plan's expected learning and mark the top three **must-ask**, so a slot cut to twenty minutes still buys them.
4. **Wording.** Neutral, one thing per question, in the actors' vocabulary rather than the theory's; open, then narrow; no presupposition ("why did the Fund insist on…" assumes it insisted); never name the hypothesis or the rival before the interviewee does. Ask for episodes, documents, and others' roles, not motives in general: when, who was present, what was decided, what was written, and how do you know (witnessed, told, inferred). A "what if" question yields the interviewee's belief, recorded as such, never the counterfactual. Translate and back-translate, gloss key terms, and brief interpreters to render questions, not improve them.
5. **Sequence:** consent → rapport (role and career: where they sat fixes what they could know) → narrative (an uninterrupted "walk me through it", before any specific question signals what you are after) → specifics, by rank → sensitive (discreditable acts, opponents, violence: last, reminding them they may stop or go off the record) → close ("who else should I speak with?", logged as a referral; "are there documents?", into the source map; "what should I have asked?"; confirm the tier of any passage marked off the record).
6. **Probes,** one to three planned per specific question, aimed at what the coding rule needs: "what happened next?", "who else was there?", "how do you know?", "is there a document that would show that?", an echo, a silence. Never a suggestive probe ("so it was really about X?").
7. **Elite practice** (Berry 2002; Aberbach & Rockman 2002). Read the person's public record first (speeches, memoirs, press) and spend no interview time on it: the gap between the public and the private account is evidence of strategy. Prefer open-ended questions, which elites answer more fully, coded afterward against the rules. Expect self-serving recall, hindsight, and the interview as a move in an ongoing game; check every answer that would code a node against a contemporaneous document or a differently placed interviewee. **Relational practice** (Fujii 2018): answers are co-produced, so record who you were taken to be, who else was present, what the interviewee wanted from the exchange, and silences, evasions, and rumors as data about the interaction; positionality goes to `/qualstack:source-critique` as s and f, not as a confession.
8. **Consent script,** read before the first question and matching the approved form word for word: who you are and the purpose, described without the hypothesis; voluntary; the right to decline, stop, or withdraw, and what withdrawal does, said plainly and truthfully under the protocol (their words stop being used; in QualStack the log row stays with a note and the values coded from it go to NA); who else is present; separate opt-ins for recording, quotation, deposit with access controls, reuse, and AI processing; and the attribution tiers, defined in the script because usage varies, and renegotiable passage by passage:
   - **On the record:** quotation with name and title, only if agreed in writing.
   - **Not for attribution:** verbatim quotation, attributed to a described role.
   - **Background:** paraphrase only, attributed to a group.
   - **Deep background:** not citable; it points the search and never codes a node by itself.
   - **The AI-processing clause:** what would be processed (a transcript or notes with names replaced by codes), by what kind of service, for what purpose, with its own yes/no, worded so the answers map onto `privacy.ai_processing` (`none | pseudonymized | full`). The config may never be more permissive than the clause as approved; if it is, stop and lower it.
   - Oral consent where a signed form endangers, logged by pseudonym. Promise only the confidentiality you can keep against subpoena, seizure, and deductive disclosure.
9. **Notes and recordings.** Originals (recordings, handwritten notes, unredacted transcripts, signed forms) go to `restricted/` the same day, moved by the researcher, and nowhere else in the project tree; Claude never reads them. Transcripts are `.txt` or `.md` in `privacy.originals`, named neutrally with the E-ID before `/qualstack:deidentify` runs; the recorder is wiped after a verified encrypted copy; human transcribers sign confidentiality agreements and are covered by the consent; cloud transcription or translation is third-party processing the clause must cover, and any machine transcription or translation whose output is quoted or coded is logged with `/qualstack:llm-checklist`. Pseudonymized copies reach `evidence/raw/interviews/` only through `/qualstack:deidentify`, and only if `privacy.ai_processing` allows; an interviewee who declined AI processing has their originals kept outside `privacy.originals`, which `/qualstack:deidentify` processes wholesale.
10. **Post-interview memo, written the same day:** each day of lag costs detail (s) and invites tidying (f). The researcher writes it as a `.md` beside the originals, named with the interview's E-ID, so `/qualstack:deidentify` carries a pseudonymized copy into `evidence/raw/interviews/` with the transcript when the setting allows; with `none` it never enters the project and Claude sees only the researcher's coded values. For an unrecorded interview it is the record. What was said stays apart from the labeled assessment. Put this template in the guide:

    ```
    # E0NN · P0N · YYYY-MM-DD · guide vN
    Mode; setting category; length; language, interpreter; present (P-IDs); recorded or notes;
    tier as worded on the form; passages off the record
    Referred by P0N; referred me to (pseudonyms; the researcher adds new names to the key)
    ## Clues, one line per node
    question IDs | what was said (verbatim if recorded, else marked paraphrase) | value it supports,
    silent, or not asked | how they know: witnessed, told by P0N, inferred, a document
    ## Assessment
    position (placed to know which clues); stake in each (credit, blame, a rival's standing);
    public record vs. this account; signs of rehearsal; the interaction (rapport, evasions,
    silences, what they asked about me, effect of others present)
    ## Leads
    documents mentioned (to the source map); surprises (to a model memo: an observation that
    prompts a model change cannot also test it); clues still open in this case
    ```

11. **Reporting plan** (Bleich & Pekkanen 2013). The interview methods table by category (sought, obtained, refused or no reply, saturation, format, length, recording, transcription), its "sought" column filled now from the frame and the rest as interviews happen; the frame and the referral chains described; every interview an E-ID with date, role category, and mode; per coded clue, how many interviewees addressed it, how many agreed, and the strongest disconfirming quote; quotations by pseudonym and coarse role within the tier, each passing the insider test (could a colleague of P07 name P07?); originals of translated quotations in the appendix; categories coarsened where the population is small.
12. **Saturation is not the stopping rule.** Guest, Bunce & Johnson (2006) found about twelve interviews enough to saturate themes in a homogeneous group with a fixed guide; that does not carry across categories or to a fact about one case, where one well-placed insider can settle a clue. Stop interviewing a category when the clues its members could still reveal hold less expected learning about the query than the next interview costs (the rule in `.qualstack/fieldwork-plan.md`); report saturation in the methods table per category and clue, never as the reason to stop.
13. **Pilot and version.** Pilot with someone outside the sample, or with the least sensitive category first: timing, whether the answers give each coding rule what it needs, translation. Version the guide (v1, v2, dated, with what changed); each memo records the version used.
14. **Write and check.** Write `.qualstack/interview-guide.md`, naming people only by category or pseudonym, then run `python3 "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-redact" check .qualstack/interview-guide.md`: it reads the key itself and prints only pseudonyms; "no key file" means nothing is keyed yet, and any hit is fixed before the guide is shared. Set `design.human_subjects: true` in `.qualstack/config.yaml` and append a `decisions:` line dated with `date +%Y-%m-%d`.

## Outputs

- `.qualstack/interview-guide.md`: per category, the question map and the guide in sequence with probes and must-ask marks; the consent script and AI clause; the handling rules for notes and recordings; the memo template; the reporting plan with the methods-table skeleton; the version log.
- Summary block: categories and question counts; clues covered, and any assigned clue with no question; the rivals each module discriminates; the must-ask questions; whether the AI clause and `privacy.ai_processing` agree; the next skill.

## Anti-patterns

- **Color questions.** A question with no node behind it spends interview time and buys nothing.
- **Leading with the hypothesis.** Once the interviewee knows the answer you want, f rises for everything they say.
- **Motives instead of episodes.** "Why did you…" invites the tidy reason; "what happened, and who was there" yields evidence.
- **Only the favored path.** The rival's clues get the same specificity.
- **One guide for every position.** A junior official and a minister were placed to know different things.
- **Recordings in the project tree.** Originals live in `restricted/` and nowhere else.
- **Deep background as evidence.** It points the search; it never codes a node.
- **The memo next week.** Same day, or the record is already a reconstruction.
- **Saturation as the stopping rule.** Expected learning about the query ends interviewing.

## Next

`/qualstack:preregister` before the decisive interviews; in the field, `/qualstack:evidence-log` for each interview the day it happens and `/qualstack:deidentify` for transcripts and memos; then `/qualstack:source-critique` (s and f from each memo's assessment) and `/qualstack:code-evidence`.
