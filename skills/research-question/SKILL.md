---
name: research-question
description: Interrogates a qualitative or mixed-method project with six forcing questions — contribution, the causal query stated as a counterfactual (would X matter here, did X cause Y here, how often, through which path), where the leverage will come from, what evidence would cut against the claim, access and ethics feasibility, and scoop or historiography risk — and issues a green/yellow/red verdict. Use when the user pitches a case study, a process-tracing or comparative project, or a multi-method design, asks whether a project is worth pursuing, or wants a question pressure-tested before fieldwork.
allowed-tools:
  - Read
  - Write
  - Bash(date *)
---

# /qualstack:research-question

**Stage:** ideate · **Voice:** advisor

An interrogation, not a brainstorm: these are the questions that, asked after the field trip, become reasons the trip was wasted. Do not encourage before the answers are in.

## Procedure

Ask the six questions and wait for answers. In a live session ask one at a time, offering the option to answer all six in one message; in an asynchronous context (web/mobile, or a user who is clearly batching) present all six together rather than forcing six round-trips.

1. **Contribution in one sentence.** "If this project succeeds, what one sentence does it add, and for which readers?" Reject "sheds light on", "explores the role of", "provides a rich account of"; push for a claim someone could disagree with. A case study's contribution is either an inference about the case that matters in itself, or leverage on a general claim; say which.
2. **The query, as a counterfactual.** "What exactly do you want to know?" Make the user pick a family and say it in counterfactual terms (Humphreys & Jacobs 2023, ch. 4):
   - **case-level effect**: *would* changing X have changed Y in this case?
   - **attribution**: given the X and Y we observe, *did* X cause Y here? (Establishing that poison would make you sick is not establishing that you are sick because of poison.)
   - **average or conditional effect** in a stated population;
   - **path**: did X's effect run through M, which is a claim about how M would respond to X and Y to M, not that M happened;
   - **actual cause**: in a sequence where something else would have produced the outcome anyway (overdetermination, preemption), which condition did the producing.
   "Explain the outcome in case j" is not yet a query. Causes are not rivals: X can be *a* cause without being *the* cause. One project, one primary query.
3. **Leverage.** "What could you observe that would be more likely if your answer is right than if the strongest rival answer is right, and what knowledge from outside the case makes that so?" Within-case evidence has no probative value on its own; it gets it from background beliefs about how the world works, which the project must be able to state and defend (`/qualstack:causal-model` will formalize them). Ask for two concrete clues and the rival each discriminates against. "I'll read the archive and see what's there" means the design is not ready.
4. **Falsifiability.** "What would you have to find to lower your belief in the claim, and is it possible to find it?" Name a clue whose presence or absence would hurt. A project in which every possible observation fits the story is confirmation by construction, and referees will say so.
5. **Feasibility, access, and ethics.** "What is the longest pole — archive access and declassification, reaching interviewees, language, travel, security, ethics approval — how long, and what is plan B if it fails?" If living people will be interviewed or observed: what will consent cover, and what does the protocol allow an AI service to process (this becomes `privacy.ai_processing` in `.qualstack/config.yaml`; with `none`, Claude can work only from non-identifying material). Ask for a concrete timeline.
6. **Scoop and historiography risk.** "Has anyone answered this in the last few years, and has a historian or area specialist already settled the case?" Evidence, not "I haven't seen it": recent volumes of the target journals; working papers and APSA, MPSA, ISA, SSHA, and regional-association programs; dissertations; the historiography of the case. An over-studied case is fine only if the contribution is the inference (a formal answer to a sharp query, new evidence that discriminates), not another narrative.

**Verdict**, written with the answers and date to `.qualstack/research-question.md`:

- **Green** — all six substantive. Proceed to `/qualstack:lit-map`.
- **Yellow** — the query or the leverage is weak, or access is uncertain. Address the weak link explicitly, then proceed.
- **Red** — two or more answers vague or unsubstantiated, or no evidence could discriminate between the claim and its rival. Defer until the gaps close, or run `/qualstack:idea-shotgun` for a different angle on the same cases or sources.

Do not soften the verdict; if the answers do not justify the fieldwork, say so.

## Outputs

- `.qualstack/research-question.md` — the line `Verdict: green | yellow | red` comes first, right under the title, because `/qualstack:paper-status` reads the first line that mentions a verdict; the words "verdict" and "recommendation" appear on no other line; then questions, answers, the primary query in words, the date.
- Summary block: verdict, the query in one counterfactual sentence, next step.

## Anti-patterns

- **Encouragement before interrogation.**
- **Answering for the user.** If they cannot name the query or a discriminating clue, that is the signal.
- **Accepting "how" and "why" questions unconverted.** Every "why did Y happen" becomes a stated counterfactual about a named X.
- **Treating access as a contribution.** Being first into an archive is a resource; the question still has to be one.

## Next

Green → `/qualstack:lit-map`. Yellow → fix the weak link, re-run. Red → `/qualstack:idea-shotgun`, or `/qualstack:scope-challenge` if the project may simply be too big.
