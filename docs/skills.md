# QualStack skill reference

Each skill is invoked as `/qualstack:<name>` once the plugin is installed. Stages follow the workflow in [philosophy.md](philosophy.md); `/qualstack:paper-status` tells you where a project is and what is stale.

## Stage 0 — Setup

| Skill | Voice | Use when |
|---|---|---|
| `/qualstack:qualstack-init <name>` | scaffolder | Starting a project. Creates the folder layout every other skill assumes, including the locked `restricted/` folder. |

## Stage 1 — Ideate

| Skill | Voice | Use when |
|---|---|---|
| `/qualstack:research-question` | advisor | Pitching or reconsidering a project. Six forcing questions: contribution, the query as a counterfactual, leverage, falsifiability, access and ethics, scoop and historiography risk; green/yellow/red. |
| `/qualstack:scope-challenge` | adversarial-advisor | The project sprawls across too many cases, periods, or questions. |
| `/qualstack:idea-shotgun` | generative | You have cases, an archive, or a puzzle and want alternative angles before committing. |

## Stage 2 — Model

| Skill | Voice | Use when |
|---|---|---|
| `/qualstack:pdf-ingest` | archivist | PDFs are on disk: the literature, or archival scans to be searched and quote-checked. |
| `/qualstack:lit-map` | systematic-reviewer | After a candidate question: the conversation, claims as candidate causal relations, rivals, the historiography of each case. |
| `/qualstack:theory-build` | theorist | Stating the argument: nodes with time stamps, possible arrows, functional claims, rivals restated as exclusive claims, clue positions. |
| `/qualstack:causal-model` | modeler | Formalizing the argument in CausalQueries: the DAG, restrictions and priors with grounds, nodal-type counts, implied priors, unintended structure. |
| `/qualstack:query-design` | methodologist | Turning "explain Y" into exact queries: family, given, level, which case-level question, identification, the decision each feeds. |
| `/qualstack:model-review` | design-critic | Before design depends on the model, and after any revision: prosecutes structure, grounds, informativeness, coherence; pass/conditional/fail. |

## Stage 3 — Design

| Skill | Voice | Use when |
|---|---|---|
| `/qualstack:design-research` | methodologist | Setting the data strategy: design type, population, wide vs. deep with costs, integration plan. |
| `/qualstack:case-select` | methodologist | Choosing which cases to trace: expected learning of each strategy under the model, the selection rule and log. |
| `/qualstack:clue-select` | methodologist | Choosing what to look for, in what order: probative value, test types, expected learning, two-step plans with costs, stopping rules. |
| `/qualstack:coding-rules` | measurement-clerk | Before coding: what counts as 1, 0, and NA for every node, versioned. |
| `/qualstack:fieldwork-plan` | field-director | Archives or interviews ahead: source map, access, ethics and consent, safety, data management, stopping rules. |
| `/qualstack:interview-guide` | interviewer | Interviews ahead: questions mapped to clues, consent and attribution tiers, same-day memos. |
| `/qualstack:preregister` | preregistration-clerk | Before evidence is seen: locks the query, model, clue likelihoods, case rule, coding rules, analysis code. |

## Stage 4 — Collect

| Skill | Voice | Use when |
|---|---|---|
| `/qualstack:evidence-log` | archivist | Any document, interview, field note, or search result enters the project. |
| `/qualstack:deidentify` | privacy-officer | Interview transcripts or field notes name people: pseudonymizes them from `restricted/` without Claude reading the originals. |
| `/qualstack:source-critique` | source-critic | Weighing sources: provenance, incentives, dependence; reliability as the chance a source reports a clue when true and when false. |
| `/qualstack:chronology` | historian | Building a case timeline from the evidence; checking the order the model assumes. |
| `/qualstack:code-evidence` | coder | Coding cases by the rules into the coding log and case data; blind second coding by an agent; agreement. |

## Stage 5 — Analyze

| Skill | Voice | Use when |
|---|---|---|
| `/qualstack:process-trace <case>` | analyst | Weighing the evidence in a case: evidence path, counterfactual table, informal likelihoods, blind assessment, dependence. |
| `/qualstack:analyze` | analyst | Coding complete: one model, one update; population, subgroup, and named-case answers; what the data taught; clue labels. |
| `/qualstack:robustness` | skeptical-analyst | After analysis: implied independencies, predictive checks, LOO against rivals, sensitivity, influence of cases, sources, and confidential evidence. |
| `/qualstack:viz` | figure-designer | Figures: DAGs, prior/posterior plots, evidence paths, design frontiers, sensitivity, timelines. |
| `/qualstack:evidence-audit` | staff-methodologist | Before writing and before submission: citations, quotations, coded values, numbers, inference claims, privacy; pass/fix-then-pass/fail. |

## Stage 6 — Write

| Skill | Voice | Use when |
|---|---|---|
| `/qualstack:draft-section <name>` | writer | Drafting a section in your voice (`voice.writing_style`); cases written around the clues; every claim cited to evidence. |
| `/qualstack:abstract-shotgun` | writer | After a complete draft: abstract variants. |
| `/qualstack:title-shotgun` | writer | Late stage: title options screened for overclaiming and identifiability. |
| `/qualstack:coauthor-review` | coauthor | On a complete draft: holes, distractions, opportunities, line edits. |
| `/qualstack:referee-mock` | referee | Before submission: historian, process-tracing methodologist, quantitative skeptic, or editor (`voice.reviewer_style`). |

## Stage 7 — Submit

| Skill | Voice | Use when |
|---|---|---|
| `/qualstack:journal-fit` | editor | Choosing journals: fit for qualitative and multi-method work, scored; policies checked at the source. |
| `/qualstack:submission-pack` | production-editor | Journal chosen: anonymization, redaction and quote checks, transparency appendix, format, upload bundle. |
| `/qualstack:cover-letter` | the author addressing the editor | After submission-pack. |
| `/qualstack:r-and-r` | the author addressing editor and reviewers | Revise and resubmit: response with changes routed through the model and the evidence log. |

## Stage 8 — Reflect

| Skill | Voice | Use when |
|---|---|---|
| `/qualstack:retro` | coach | After acceptance or rejection: plan against record. |
| `/qualstack:archive` | replicator | At acceptance: the transparency package, checksums, clean-room rebuild, deposit plan, dependence on confidential evidence. |

## Power tools

| Skill | Use when |
|---|---|
| `/qualstack:paper-status` | Opening a session or asking "what's next?": runs `bin/qualstack-status` (artifacts, stale memos, evidence-trail integrity, derived stage) and recommends the next skill. |
| `/qualstack:careful` | Near a deadline: destructive commands need confirmation, enforced by the hook. |
| `/qualstack:freeze` | Lock edits to one directory. |
| `/qualstack:guard` | `careful` plus `freeze`. |
| `/qualstack:unfreeze` | Remove the lock. |
| `/qualstack:llm-checklist` | An LLM is part of the instrument (blind coding, blind assessment, extraction, translation): logs each use and compiles the GUIDE-LLM checklist. |
| `/qualstack:learn` | Per-project conventions Claude should remember. |
| `/qualstack:qualstack-upgrade` | Update QualStack. |

## Agents

| Agent | Spawned by | Does |
|---|---|---|
| `qualstack:coder` | `/qualstack:code-evidence` | Codes evidence from written rules alone, blind to the first coder, the outcome, and the hypothesis. |
| `qualstack:assessor` | `/qualstack:process-trace` | States how likely an evidence item is under neutrally labeled explanations, blind to the one the author favors. |

## Reference library

| Reference | What it holds | Loaded by |
|---|---|---|
| `causal-models.md` | Nodes, nodal and causal types, DAG rules, d-separation, theory to model, queries, counterfactual discipline | theory-build, causal-model, query-design, model-review, process-trace |
| `bayesian-process-tracing.md` | Bayes for clues, probative value vs. expected learning, Van Evera's tests as regions, where probative value comes from, many clues, elicitation | process-trace, clue-select, model-review, evidence-audit, referee-mock |
| `mixed-methods.md` | One model, one update; data format; selection; the three kinds of answer; π̂ vs. φ̂; data-derived probative value; identification | design-research, case-select, analyze, robustness |
| `design-diagnosis.md` | Expected posterior variance; clue selection; case selection and the literature mapped onto it; wide vs. deep | design-research, case-select, clue-select, fieldwork-plan, r-and-r |
| `model-justification.md` | Where a model can come from; "nothing from nothing"; unintended structure; the four checks | causal-model, model-review, robustness, analyze, evidence-audit |
| `causalqueries-cookbook.md` | CausalQueries 1.4.6 syntax, idioms, and gotchas, verified | every formal skill |
| `evidence-and-sources.md` | The evidentiary chain, logging, source criticism as likelihoods, absence of evidence, archives, interviews, field notes, secondary sources, chronology | evidence-log, source-critique, chronology, interview-guide, fieldwork-plan, process-trace |
| `concepts-and-coding.md` | Concept to node, dichotomizing, coding rules, 0 vs. NA, the coding log, reliability, measurement error, case data | coding-rules, code-evidence, analyze |
| `transparency-and-ethics.md` | Transparency vs. protection, human subjects, confidentiality, AI processing, preregistration, the transparency package, anonymous review | deidentify, fieldwork-plan, interview-guide, preregister, submission-pack, archive |
| `preregistration-guide.md` | What to lock in a qualitative or model-based preregistration, deviations, addenda | preregister |
| `audit-catalog.md` | The checks the evidence audit runs, their severity, how each is verified | evidence-audit |
| `writing-conventions.md` | Structure of a case-based paper, writing cases around clues, reporting models and posteriors, hedging, quotations | draft-section, coauthor-review, abstract-shotgun |
| `referee-report-conventions.md` | Report structure and tone for qualitative and multi-method work (fallback for `voice.reviewer_style`) | referee-mock |
| `figure-conventions.md` | DAGs, posterior and evidence-path plots, frontiers, timelines | viz |
| `r-conventions.md` | The R pipeline, seeds, CausalQueries habits, Stan diagnostics | analyze, robustness, viz |
| `journals.md` | Candidate journals for qualitative and multi-method work and the fit signals to score | journal-fit, referee-mock (editor) |
| `pdf-extraction.md` | PDF backends and the quality gate | pdf-ingest |

## R tools and templates

| File | Used by | Holds |
|---|---|---|
| `skills/causal-model/assets/01-model-template.R` | causal-model | The model script: statement, restrictions, priors, queries, outputs |
| `skills/clue-select/assets/clue-diagnosis.R` | clue-select, model-review | `qs_clue_screen`, `qs_clue_table`, `qs_strategy_table`, `qs_two_step` |
| `skills/case-select/assets/case-diagnosis.R` | case-select, design-research | `qs_case_strategies`, `qs_wide_deep` |
| `skills/process-trace/assets/trace-case.R` | process-trace, robustness | `qs_trace_case`, `qs_informal_trace` |
| `skills/analyze/assets/03-data-template.R`, `04-update-template.R` | analyze | Data assembly with checks; the update and every output table |
| `skills/robustness/assets/model-checks.R` | robustness, model-review | `qs_implied_independencies`, `qs_ci_tests`, `qs_ppc`, `qs_loo`, `qs_sensitivity` |

`tests/r/verify-book.R` checks the R tools against numbers published in *Integrated Inferences*.

## File output conventions

| Skill | Writes to |
|---|---|
| `/qualstack:research-question` | `.qualstack/research-question.md` |
| `/qualstack:lit-map`, `/qualstack:theory-build` | `.qualstack/lit-map.md`, `.qualstack/theory.md` |
| `/qualstack:causal-model` | `code/01-model.R`, `.qualstack/model.md`, `output/models/model.rds` |
| `/qualstack:query-design` | `.qualstack/queries.md` |
| `/qualstack:model-review` | `.qualstack/model-review-<date>.md` |
| `/qualstack:design-research` | `.qualstack/design.md`, `paper/sections/design.tex` (stub) |
| `/qualstack:case-select`, `/qualstack:clue-select` | `.qualstack/case-selection.md`, `.qualstack/clue-plan.md`, `code/02-design.R` |
| `/qualstack:coding-rules` | `data/coding-rules.md` |
| `/qualstack:fieldwork-plan`, `/qualstack:interview-guide` | `.qualstack/fieldwork-plan.md`, `.qualstack/interview-guide.md` |
| `/qualstack:preregister` | `prereg/prereg.md` |
| `/qualstack:evidence-log`, `/qualstack:deidentify` | `evidence/log.csv`, `evidence/raw/`, `evidence/md/` |
| `/qualstack:source-critique`, `/qualstack:chronology` | `.qualstack/source-critique-<date>.md`, `.qualstack/chronology-<case>.md` |
| `/qualstack:code-evidence` | `data/coding-log.csv`, `data/case-data.csv` |
| `/qualstack:process-trace` | `.qualstack/process-trace-<case>.md`, `evidence/memos/` |
| `/qualstack:analyze` | `code/03-data.R`, `code/04-update.R`, `output/tables/queries.csv` and companions |
| `/qualstack:robustness` | `code/05-robustness.R`, `.qualstack/robustness-<date>.md` |
| `/qualstack:viz` | `code/06-figures.R`, `output/figures/` |
| `/qualstack:evidence-audit` | `.qualstack/evidence-audit-<date>.md` |
| `/qualstack:draft-section` | `paper/sections/<name>.tex` |
| `/qualstack:coauthor-review`, `/qualstack:referee-mock` | `.qualstack/review-cache/` |
| `/qualstack:journal-fit` | `.qualstack/journal-fit-<date>.md` |
| `/qualstack:submission-pack`, `/qualstack:cover-letter`, `/qualstack:r-and-r` | `submission/` |
| `/qualstack:retro`, `/qualstack:archive` | `.qualstack/retro.md`, `transparency-manifest.txt`, `transparency/` |

Stage-completing skills advance `paper.status` in `.qualstack/config.yaml` (`lit-map` → modeling, `design-research` → designing, `evidence-log` → collecting, `analyze` and `process-trace` → analyzing, `draft-section` → writing, submission → submitted, `r-and-r` → r-and-r, `archive` → archived); `/qualstack:paper-status` reconciles that field with the artifacts on disk.
