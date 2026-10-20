# Referee-report conventions for qualitative and multi-method work

Built-in fallback for `/qualstack:referee-mock`. If the user has a
reviewer-style skill installed (named in `.qualstack/config.yaml` →
`voice.reviewer_style`), that skill wins on voice, tone, and structure; this
file keeps the mock report credible without it, and says what a report on a
case-based, process-tracing, or multi-method paper has to check whoever
writes it. A mock report is only useful if it is the report the author
fears: the one a historian of the case, a process-tracing methodologist,
and a quantitative skeptic would each write.

## Structure

1. **Summary** (one paragraph). A neutral restatement of the query, the
   cases, the evidence base, the design, and the headline claim with its
   posterior, in the reviewer's words, not the abstract's: "the paper argues
   that the army's split caused the regime to negotiate, tracing one case
   through 200 archival documents and 30 interviews, and reports a posterior
   of 0.81." Its job is to show the editor the paper was read and to expose,
   implicitly, any gap between what is claimed and what is shown.
2. **Major comments** (numbered, 3–6). Issues that change the headline or
   the publishability if unaddressed. Each: what the problem is, why it
   matters for the inference or the contribution, and what would resolve it
   (a resolvable ask, below). A major comment without one reads as a veto.
3. **Minor comments** (numbered, 5–15). Clarity, presentation, missing
   citations, table and figure mechanics, a date or a name to verify.
   Terse is fine.
4. **Recommendation**: Reject, Major revisions, Minor revisions, or Accept,
   consistent with the majors (calibration below).
5. **Confidential note to the editor** (optional, a few lines): fit, an
   ethics concern, what the reviewer could not judge. Never a harsher
   verdict than the report gives the authors.

## Tone

- Professional and direct. Critique the manuscript, never the authors; no
  sarcasm, no rhetorical questions, no praise-padding before each criticism.
- One sentence of genuine positioning ("the archival base is unusually
  deep", "the model makes the inference unusually explicit") calibrates the
  editor; a paragraph of compliments is noise.
- No condescension toward either tradition: not "anecdotal" or "just a
  story" for case evidence, not "false precision" for a formal model. Say
  what is wrong with this paper's version.
- Confidence proportional to expertise: flag, do not adjudicate, issues
  outside the persona's lane (table below).

## Specificity

- Every substantive comment cites its target: section, paragraph, table,
  figure, clue, or evidence ID. "More archival work is needed" is not a
  comment; "the claim that the junta had decided by May rests on E031, an
  interview fifteen years later; the junta's own minutes for April and May,
  if they survive, would settle it, and the fiscal-crisis rival predicts
  they will show the decision after the budget cut" is.
- A request for new evidence says what it would show under each hypothesis;
  otherwise it is a fishing license.
- Quote the paper when disputing its wording; mark each point must-fix or
  suggestion so the authors can triage.
- Facts the reviewer cannot point to in the paper or its sources (a
  historian's view, an archive's holdings, a date) are phrased as questions
  to verify, not asserted from memory.

## What a report on qualitative work checks

| Layer | The reviewer asks | Typical resolvable ask |
|---|---|---|
| Query | Is the question a counterfactual about a named cause in named cases? Effect, attribution, path, or average? Is it the one the conclusion answers? | State the query; separate the case-level claim from the population claim |
| Model | Is the DAG the knowledge base or only the favored path? Which restrictions and priors carry the answer? (Humphreys & Jacobs 2023) | Add the omitted route or `<->`; report the answer without restriction R2; vary the priors |
| Case selection | By what rule were the cases chosen, and on the outcome? Can they speak to the population claimed? (Geddes 1990; Collier & Mahoney 1996; Seawright & Gerring 2008) | The selection log; untraced cases kept with clues missing; a narrower population claim |
| Clues and likelihoods | Where do Pr(K \| H) and Pr(K \| not H) come from? Fixed before the evidence was seen? Test labels with numbers? (Van Evera 1997; Collier 2011; Bennett 2015) | Likelihoods from the model or the dated clue plan; the likelihood and counterfactual tables |
| Sources | Who produced each decisive item, when, for whom, with what incentives? Contemporaneous or retrospective? Independent of each other? (Lustick 1996; Trachtenberg 2006) | A second source with independent error; the node coded under the rival historiography; the decisive clue set to NA |
| Narrative and rivals | Could any observation in the narrative have counted against the argument? Is each rival met with evidence that separates it? (Zaks 2017) | For each rival, the clue that discriminates and what it showed |
| Measurement | 0 versus NA; one coding bar for every case; agreement before adjudication | The coding log; agreement statistics; flips in the robustness runs |
| Sizing | Is the language within the posterior? Is the prior beside it? Which question does a case-level number answer? | Recalibrate the claims; the posterior table with priors |
| Generalization | A case of what? How does the answer travel: model, scope conditions, cross-case data? (Gerring 2017) | Stated scope conditions; the population query from a joint update |
| Transparency and ethics | Can a stranger trace `\ev{}` to a log row? How much rests on confidential evidence? Could an insider identify a participant? (Moravcsik 2010; APSA 2020) | Evidence and interview methods tables (Bleich & Pekkanen 2013); confidential-only values set to NA; coarser attributions |

## Personas and their lanes

| Persona | Reads first | Owns | Flags, does not adjudicate |
|---|---|---|---|
| Historian or area specialist | The case narratives, the sources section, the evidence table | Provenance, dating, anachronism, historiography and whose account is used, archives not consulted, translation, context and facts | Bayesian arithmetic, model structure |
| Process-tracing methodologist | Theory, cases, results, the model code | The query, the DAG and restrictions, priors, likelihoods and when they were set, test labels, dependence among sources, which question a case-level number answers | Archival facts, translation |
| Quantitative skeptic | Design, results, robustness | Case selection, selection on the outcome, generalizing from one case, external validity, prior sensitivity, coding reliability, omitted confounders | Source criticism, historiography |
| Editor | Abstract, introduction, conclusion, length, appendix | Contribution per page, fit with the journal's recent articles, register, headline against evidence, transparency norms, anonymization | Every technical point, which it delegates to the referees |

- **The historian** asks of each decisive item what Trachtenberg (2006)
  and Thies (2002) ask: who wrote it, when, knowing what; is a later memoir
  or interview standing in for a motive at the time; is one historian's
  account doing the work (Lustick 1996); would the other side's archive
  record what the actors told outsiders.
- **The methodologist** asks whether each probative value is derived or
  asserted (Fairfield & Charman 2017; 2022): a hoop or smoking-gun label
  without its two likelihoods and a prior is a claim, not a result;
  likelihoods dated after the evidence was seen are a forking path; five
  reports of one leak are one source.
- **The quantitative skeptic** asks the large-N questions in the paper's own
  terms: not where the standard errors are, but how far the priors drive a
  non-identified answer, what the answer is leaving each case out, and what
  the untraced cases would have shown (Humphreys & Jacobs 2023).
- **The editor** reads the target journal's register: a political science
  journal wants the theoretical payoff on page one, a historians' journal
  wants the historiographic intervention; the same research needs two
  framings.

## Asks a qualitative referee can and cannot make

Resolvable asks (each names what it would show):

- Seek clue K in case j, in a named series or from a named category of
  informant, with the likelihood of finding it under each hypothesis.
- Code node N under the rival historiography and rerun; report the shift.
- Set every value coded only from `confidential` items to NA, one at a time
  and together; report how far the posterior moves.
- Report the counterfactual table; give informal likelihoods as ranges and
  the posterior at both ends.
- Show the answer without restriction R, under flat priors, and leaving
  each case out.
- Provide originals of translated quotations; the interview methods table;
  the surrounding passage, an active citation, or an ATI annotation for a
  contested quotation (Moravcsik 2010).
- Narrow the claim to the population the cases can speak for.

Asks a referee must not make, or must route to the editor:

- A participant's identity, a transcript beyond what consent covers, the
  name of a village the paper keeps anonymous; ask instead for the access
  route and the reliance number, how far the posterior moves when
  confidential-only values are set to NA (Jacobs, Büthe et al. 2021; APSA
  2020).
- A different study (a large-N design, another country, a new field
  season): the editor decides whether that is a revision or a new paper.
- Significance tests or standard errors for a case-level probability, or
  "n = 1" as a verdict.
- Unspecified "more interviews" or "more archives".
- Conversion to the reviewer's tradition: a coherent informal Bayesian
  analysis owes its priors and likelihoods, not a CausalQueries model; a
  test-label analysis owes its likelihoods, not a new method.

## Calibrating the recommendation

| The majors say | Recommendation |
|---|---|
| No evidence the authors have or could get can answer the query (no clue could discriminate; selection leaves no defensible population claim and the case claim does not matter in itself) | Reject |
| Fixable with materials the authors hold or can reach: likelihoods argued, nodes recoded, robustness run, an archive series consulted, selection modeled, claims resized | Major revisions |
| Presentation, sizing of language, missing tables or originals, citations | Minor revisions |
| None that change the headline | Accept (rare in a first round) |

- Three unresolved inferential problems and "minor revisions" cannot
  coexist; a major comment that the reviewer would not hold up acceptance
  for is a minor one.
- When a fix needs a new archive trip or interview round, say so explicitly,
  so the editor can judge whether the journal's revision timeline allows it.

## Discipline norms

- Review the paper the authors wrote, not the one the reviewer would have
  written; asking for a different paper is an editor's decision.
- Ask for explicit inference in the paper's own form: Bayesian process
  tracing (Fairfield & Charman 2017; 2022) and causal models (Humphreys &
  Jacobs 2023) both make priors and likelihoods inspectable, and neither is
  owed by a paper that states them another way.
- Transparency is calibrated to the setting (Jacobs, Büthe et al. 2021):
  protection of participants outranks openness, and openness takes forms
  other than posting transcripts.
- Length: one to two pages single-spaced for a first-round report; a
  historian's list of factual corrections can go in an attachment.

## Failure modes of a mock report

| Failure | Symptom | Fix |
|---|---|---|
| Sycophancy | No major comment | Run the layer table row by row |
| The generic | "More theory", "more sources" | Cite the target; name the clue or source and what it would show |
| The quantitative template | p-values, standard errors, "n = 1" | Ask the question in the paper's framework |
| Persona drift | The historian redoes the Bayes; the editor redesigns the study | Stay in the lane; flag the rest |
| Invented expertise | A historian, archive, or date asserted that appears nowhere in the paper or its sources | Phrase it as a question to verify |
| Awe at the archive | Depth of fieldwork taken for inference | Ask what the documents discriminate between |
| Asking past consent | A request for names or transcripts | Ask for the access route and the reliance number |
