# QualStack

**A Claude Code plugin for qualitative and mixed-method political science.** The sibling of [MStack](https://github.com/matthewdigiuseppe/MStack) (quantitative papers), built on Macartan Humphreys and Alan Jacobs's *Integrated Inferences: Causal Models for Qualitative and Mixed-Method Research* (Cambridge, 2023) and its R package [CausalQueries](https://cran.r-project.org/package=CausalQueries).

MStack's wager is that role-based slash commands beat free-form prompting because they force the right questions at the right stage. QualStack makes the same wager for case-based research, and adds the book's central one: **within-case evidence has probative value only through background beliefs about how the world works, so write those beliefs down as a causal model, derive what each clue can teach from it, and update one model on all the evidence, qualitative and quantitative alike.** The 46 skills walk a project from the question through the model, case and clue selection, fieldwork, evidence handling, process tracing, robustness, writing, submission, and the transparency package.

## Install

QualStack works in every flavor of Claude Code: the terminal CLI, the desktop apps, Claude Code on the web (claude.ai/code), and the IDE extensions.

### Step 1 — Add QualStack to Claude Code

```
/plugin marketplace add matthewdigiuseppe/Mstac_qual
/plugin install qualstack@qualstack
```

All 46 commands (`/qualstack:research-question`, `/qualstack:causal-model`, `/qualstack:process-trace`, …) are then available. `/plugin` lists what is installed.

### Step 2 — Install R and CausalQueries (for the formal skills)

The model-based skills write and run R code. In R:

```r
install.packages(c("CausalQueries", "here", "ggplot2"))   # CausalQueries brings rstan
```

QualStack's R tools are tested against CausalQueries 1.4.6. Projects that set `model.formal: false` in their config use informal Bayesian process tracing and need no R.

### Step 3 — Start a project

```
/qualstack:qualstack-init wartime-taxation
```

Open `.qualstack/config.yaml` in the new folder and fill in the title, your name, the design type, and, if you will interview or observe people, `privacy.ai_processing` (what your ethics protocol and consent forms allow an AI service to process: `none`, `pseudonymized`, or `full`). Then start with `/qualstack:research-question`. At any point `/qualstack:paper-status` says where the project stands and which skill comes next.

### Optional: the command-line tools

`bin/` holds standard-library Python scripts that also work outside Claude Code: `qualstack-init`, `qualstack-status`, `qualstack-pdf2md`, `qualstack-redact`, `qualstack-quotecheck`. Clone the repository and run `./setup` to put them on your PATH. This does not register the skills; the `/plugin install` above does that.

## Workflow

| Stage | Skill | What it does |
|---|---|---|
| **Setup** | `/qualstack:qualstack-init <name>` | Scaffolds the project folder every skill assumes |
| **Ideate** | `/qualstack:research-question` | Six forcing questions: contribution, the query as a counterfactual, leverage, falsifiability, access and ethics, scoop risk |
| | `/qualstack:scope-challenge` | Adversarial advisor: is this a paper, a book, or a footnote? |
| | `/qualstack:idea-shotgun` | Alternative angles on the same cases or sources |
| **Model** | `/qualstack:pdf-ingest` | PDFs (literature and archival scans) to token-cheap, searchable Markdown |
| | `/qualstack:lit-map` | The conversation, claims as candidate causal relations, rivals, the historiography of each case |
| | `/qualstack:theory-build` | The argument as nodes, possible arrows, functional claims, rivals, and clue positions |
| | `/qualstack:causal-model` | The model in CausalQueries: DAG, restrictions and priors with stated grounds, nodal-type counts, implied priors |
| | `/qualstack:query-design` | Every question as an exact query: attribution, effect, path; case or population; which case-level question |
| | `/qualstack:model-review` | Prosecutes the model: missing arrows, ungrounded restrictions, "nothing from nothing", testable implications |
| **Design** | `/qualstack:design-research` | Design type, wide vs. deep with costs, the integration plan |
| | `/qualstack:case-select` | Expected learning of each case-selection strategy under the model; the selection rule and log |
| | `/qualstack:clue-select` | What to look for and in what order: probative value, test type, expected learning, two-step plans with costs |
| | `/qualstack:coding-rules` | What counts as 1, 0, and not observed for every node, versioned |
| | `/qualstack:fieldwork-plan` | Source map, archives, interviewees, ethics, safety, data management, stopping rules |
| | `/qualstack:interview-guide` | Questions mapped to clues, consent and attribution tiers, same-day memos |
| | `/qualstack:preregister` | Locks the query, the model, the clue likelihoods, the case rule, and the coding rules |
| **Collect** | `/qualstack:evidence-log` | Registers every document, interview, and field note with an ID and access tier |
| | `/qualstack:deidentify` | Pseudonymizes transcripts from the locked `restricted/` folder without Claude ever reading them |
| | `/qualstack:source-critique` | Provenance, incentives, dependence; source reliability as likelihoods |
| | `/qualstack:chronology` | Dated, sourced timelines; checks the order the model assumes |
| | `/qualstack:code-evidence` | Codes evidence by the rules into the coding log and case data; blind second coding by an agent |
| **Analyze** | `/qualstack:process-trace <case>` | The evidence path and counterfactual table for a case; informal likelihoods; blind assessment |
| | `/qualstack:analyze` | One model, one update: population, subgroup, and named-case answers; what the data taught |
| | `/qualstack:robustness` | Implied independencies, predictive checks, LOO against rival models, sensitivity, influence |
| | `/qualstack:viz` | DAGs, prior/posterior plots, evidence paths, frontiers, timelines |
| | `/qualstack:evidence-audit` | Every citation, quotation, coded value, and number traced to its source before anyone else looks |
| **Write** | `/qualstack:draft-section <name>` | Sections in your voice, cases written around the clues, every claim cited to evidence |
| | `/qualstack:abstract-shotgun` | Abstract variants |
| | `/qualstack:title-shotgun` | Title options |
| | `/qualstack:coauthor-review` | Simulated coauthor critique |
| | `/qualstack:referee-mock` | Mock referee reports: historian, process-tracing methodologist, quantitative skeptic, editor |
| **Submit** | `/qualstack:journal-fit` | Target journals scored for qualitative and multi-method work |
| | `/qualstack:submission-pack` | Anonymization, quote and pseudonym checks, transparency appendix, format |
| | `/qualstack:cover-letter` | Cover letter |
| | `/qualstack:r-and-r` | Response to reviewers, with new evidence and reanalysis routed through the model |
| **Reflect** | `/qualstack:retro` | Plan against record: which clues delivered, where the model was wrong |
| | `/qualstack:archive` | Transparency package: model code, coded data, evidence log with access tiers, annotations, checksums |
| **Power** | `/qualstack:paper-status` | Where the project stands, what is stale, the next skill |
| | `/qualstack:careful`, `/qualstack:freeze`, `/qualstack:guard`, `/qualstack:unfreeze` | Edit-safety modes, enforced by a hook |
| | `/qualstack:llm-checklist` | Logs LLM-as-instrument use (blind coding, assessment) for the GUIDE-LLM checklist |
| | `/qualstack:learn` | Per-project conventions Claude should remember |
| | `/qualstack:qualstack-upgrade` | Self-update |

Full table with voices and triggers: [docs/skills.md](docs/skills.md). Why it is built this way: [docs/philosophy.md](docs/philosophy.md). What the formal skills produce on a real problem: [docs/example.md](docs/example.md).

## Project scaffold

```
my-project/
  .qualstack/       config.yaml, memos, review-cache/, learnings.jsonl, llm-usage.jsonl
  paper/            main.tex (\ev{E014} cites evidence), sections/, refs.bib
  lit/              pdf/, md/, index.md
  evidence/         log.csv, raw/ (read-only), md/, memos/
  data/             raw/ (read-only), coding-rules.md, case-data.csv, coding-log.csv, clean/
  code/             01-model.R … 06-figures.R (CausalQueries)
  output/           models/, tables/, figures/
  restricted/       identity key, consent forms, originals: never read by Claude, never committed
  prereg/  submission/  transparency/
```

## What is enforced, not just suggested

A `PreToolUse` hook (`hooks/qualstack-guard.py`) blocks the tool call itself:

- **`restricted/` never enters Claude's context.** File tools and shell commands that name it, glob into it, or scan the project without excluding it are denied. Only `bin/qualstack-redact` crosses the wall, finding the key through the config and printing counts and pseudonyms, never names. (The hook reads command lines, not what a script opens, so no project code may read `restricted/`.)
- **Sources are read-only once they exist**: `evidence/raw/`, `data/raw/`, `lit/pdf/`. Corrections are new files.
- **A registered preregistration is locked** once `design.prereg_url` is set; amendments are dated addenda.
- **Safety modes**: `/qualstack:careful` confirms destructive commands; `/qualstack:freeze` locks edits outside one directory.

## The R tools

The design and analysis skills ship small, tested R functions on top of CausalQueries:

| File | Functions | Reproduces |
|---|---|---|
| `skills/causal-model/assets/01-model-template.R` | the model script | — |
| `skills/clue-select/assets/clue-diagnosis.R` | `qs_clue_screen`, `qs_clue_table`, `qs_strategy_table`, `qs_two_step` | II Figs. 12.2, 12.4, 12.6–12.7 |
| `skills/case-select/assets/case-diagnosis.R` | `qs_case_strategies` (posterior reweighting, no extra Stan runs), `qs_wide_deep` | II Tables 13.6–13.7 |
| `skills/process-trace/assets/trace-case.R` | `qs_trace_case`, `qs_informal_trace` | II Fig. 16.10 |
| `skills/analyze/assets/03-data-template.R`, `04-update-template.R` | the data and update scripts | II ch. 10 democratization results |
| `skills/robustness/assets/model-checks.R` | `qs_implied_independencies`, `qs_ci_tests`, `qs_ppc`, `qs_loo`, `qs_sensitivity` | II Tables 16.1–16.2, Figs. 16.1, 16.3, 16.9, LOO |
| `skills/viz/assets/theme_qualstack.R` | grayscale-safe theme; `qs_plot_dag`, `qs_plot_prior_posterior`, `qs_plot_evidence_path`, `qs_plot_frontier`, `qs_plot_sensitivity`, `qs_plot_timeline`, `qs_save` | — |

`tests/r/verify-book.R` checks them against the published numbers; `python3 tests/run_tests.py` runs it when R and CausalQueries are installed.

## Design principles

1. **The model is the theory, written down.** Probative value, case selection, and clue selection are computed from it, not asserted.
2. **Role over prompt.** Every skill speaks in a defined voice: advisor, modeler, methodologist, archivist, privacy officer, analyst, referee, replicator.
3. **Forcing questions before generation.** Early skills interrogate; design skills compute before they recommend.
4. **One model, one update.** Cross-case data and traced cases enter one likelihood; untraced cases stay in with their clues missing.
5. **The evidence trail is the paper's spine.** Every claim cites an evidence ID; every coded value names its evidence; every quotation is checked against its source.
6. **Participants first.** Identifiable material stays in `restricted/`; what an AI may process is set by the protocol, not by convenience.
7. **Enforcement over convention**, as in MStack: the hook blocks the call.
8. **Per-project memory.** `.qualstack/` carries decisions, memos, and verdicts across sessions; `/qualstack:paper-status` reports what is stale.

## Defaults

- **Formal stack:** R with CausalQueries (binary nodes; Stan for updating). `model.formal: false` switches to informal Bayesian process tracing.
- **Manuscript:** LaTeX (`qualstack-init --quarto` for Quarto).
- **Voice:** `voice.writing_style` and `voice.reviewer_style` in the config name your own style skills; QualStack ships fallbacks.

## License

MIT.
