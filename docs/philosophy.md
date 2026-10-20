# QualStack philosophy

## Why this exists

Case-based research is a long sequence of stage-specific decisions: what exactly is being asked, which cases to study, what to look for in them, how to treat a source, how much a piece of evidence should move belief, how to write it so a reader can check it. A "help me with my case study" prompt collapses all of them into one, and the stage Claude defaults to is the narrative: fluent prose about what the evidence "suggests", with the inferential work left implicit. That is exactly the part referees attack.

MStack showed that role-based slash commands, each with its stage, voice, and forcing questions, make a better collaborator than one free-form assistant. QualStack carries that design to qualitative and mixed-method political science, and grounds the methodological core in one book: Humphreys and Jacobs, *Integrated Inferences* (2023).

## The wager

Four claims, the last three from the book:

1. **Research has stages, and the questions do not transfer.** "Which case?" is a design question; "how strong is this memo?" is an analysis question; asking either at the wrong time wastes the fieldwork or the evidence.
2. **Within-case evidence has no probative value on its own.** How much a document or an interview should move belief about a case depends on beliefs from outside the case: about mechanisms, conditions, alternatives, and sources. Those beliefs can be stated as a causal model, and then the likelihoods (and the familiar test types, hoop, smoking gun, doubly decisive, straw in the wind) are derived from it rather than asserted. A test label is an output, never an input.
3. **Design is a calculation inside the model.** Which clue to seek, which case to trace, and whether to add cases or dig deeper all depend jointly on the model, the query, and what has been observed. There are no general rules ("select on X", "trace the deviant case", "follow the mediator"), but there is a general procedure: list what each option could find, how likely each finding is, and how much each would teach; choose with costs in view.
4. **Qualitative and quantitative evidence are values of the same nodes.** Cross-case data on many cases and clues gathered in a few enter one likelihood; cases teach about the population and the population about cases through the same posterior. There is no separate qualitative verdict to reconcile with a quantitative estimate.

## What QualStack is not

- **Not a narrative generator.** Drafting is one stage; most of the skills are upstream of it, and the drafting skill writes cases around the clues and the evidence trail, not around a story.
- **Not a substitute for the archive or the field.** It plans, records, checks, and reasons about evidence the researcher gathers. It never invents a source, a date, or a quotation, and the evidence audit exists to catch any that slip in.
- **Not neutral about the model.** It makes the model explicit so that it can be disputed: every restriction carries a stated ground, the model review prosecutes it, and the robustness skill shows which conclusions hang on which assumptions.
- **Not careless with people.** Identifiable material lives in a folder Claude cannot read, enforced by a hook; what an AI service may process is set by the ethics protocol and consent, recorded in the config, and checked before participant material is opened.

## How to read the skill set

Every skill carries a **stage** and a **voice**.

- **Advisor / adversarial-advisor** (ideate): talk the researcher out of projects whose evidence could not discriminate between the claim and its rivals.
- **Theorist, modeler, methodologist, design-critic** (model, design): turn the argument into a model, the question into a query, and the design into computed comparisons.
- **Archivist, privacy-officer, source-critic, historian, coder** (collect): keep the evidentiary chain intact from the claim to the box and folder, and turn evidence into coded values a stranger could re-derive.
- **Analyst, skeptical-analyst, staff-methodologist** (analyze): update, trace, stress-test, and audit.
- **Writer, coauthor, referee, editor** (write, submit): draft in the user's voice and front-run the historian, the process-tracing methodologist, and the quantitative skeptic who will review it.
- **Replicator** (reflect): would a stranger reach the same coded data and the same answers from the shared evidence, and know exactly what they could not see?

## Failure modes QualStack is built to prevent

| Failure | Skill that catches it |
|---|---|
| A project whose possible evidence could not tell the claim from its rival | `/qualstack:research-question` |
| "Explain Y in case j" with no stated counterfactual | `/qualstack:query-design` |
| A DAG with only the favored path, or monotonicity assumed silently | `/qualstack:causal-model`, `/qualstack:model-review` |
| Clues that cannot be informative under the model, discovered after fieldwork | `/qualstack:model-review`, `/qualstack:clue-select` |
| Cases justified by a label ("most likely") and generalized from one case | `/qualstack:case-select` |
| Mediators sought by habit while the alternative-cause clue is ignored | `/qualstack:clue-select` |
| Likelihoods chosen after reading the evidence | `/qualstack:clue-select`, `/qualstack:preregister`, `/qualstack:process-trace` (blind assessor) |
| Five reports of one leak counted as five pieces of evidence | `/qualstack:source-critique`, `/qualstack:process-trace` |
| A failed search coded as absence, or absence coded as missing | `/qualstack:coding-rules`, `/qualstack:code-evidence` |
| Untraced cases dropped from the multi-method analysis | `/qualstack:analyze` |
| A case updated on and then asked about as if new (double counting) | `/qualstack:query-design`, `/qualstack:analyze` |
| Conclusions that hold only under a restriction, reported as findings | `/qualstack:analyze`, `/qualstack:robustness` |
| A drifted quotation or a misattributed document | `/qualstack:evidence-audit` (`qualstack-quotecheck`) |
| A participant's name in a draft, a file, or an AI prompt | `/qualstack:deidentify`, the guard hook, `qualstack-redact check` |
| A desk reject for fieldwork narration that unblinds the author | `/qualstack:submission-pack` |
| A transparency appendix that cannot be checked | `/qualstack:archive` |
| Losing track of what is stale after the model changed | `/qualstack:paper-status` |
