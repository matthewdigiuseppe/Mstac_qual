---
name: preregister
description: Drafts a preregistration for a process-tracing, comparative, or multi-method study that locks where qualitative inference forks — the query, the causal model with its restrictions and priors (code and hash), the clue plan with model-derived likelihoods, probative values, and expected learning, any two-step search, the case-selection rule and selection log, the coding-rules version, the updating code and what posterior counts as support, fieldwork stopping rules, how surprises become dated addenda, and the embargo — and refuses to mark it ready until every field is specific. Use before collecting or reading the decisive evidence, or when the user mentions preregistration, a pre-analysis plan, OSF, EGAP, registered reports, or results-free review.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(date *)
  - Bash(sha256sum *)
  - Bash(python3 *)
---

# /qualstack:preregister

**Stage:** design · **Voice:** preregistration-clerk

Before the decisive evidence is collected or read, or whenever confirmatory inference must be credibly separable from exploration. Expects `/qualstack:causal-model`, `/qualstack:query-design`, `/qualstack:model-review`, `/qualstack:case-select`, `/qualstack:clue-select`, and `/qualstack:coding-rules` to have run. The bar throughout: could two researchers, given only this document, the registered code, and the coded evidence, compute the same posterior on the primary query without talking; and could a reader see, for every clue, how far finding it and not finding it would move that query before anyone looked?

## Procedure

1. **Load** `.qualstack/queries.md`; `.qualstack/model.md` and `code/01-model.R`; the newest `.qualstack/model-review-*.md` (its verdict); `.qualstack/case-selection.md`; `.qualstack/clue-plan.md` and `output/tables/clue-diagnosis.csv`; `data/coding-rules.md`; `.qualstack/fieldwork-plan.md`; `.qualstack/theory.md` (rivals); `code/03-data.R` and `code/04-update.R` if drafted; `.qualstack/llm-usage.jsonl` if an LLM will code or assess evidence.
2. **Read** `${CLAUDE_PLUGIN_ROOT}/references/preregistration-guide.md` (the standard, vague-to-specific examples, registry checks, the addendum table) and the preregistration section of `${CLAUDE_PLUGIN_ROOT}/references/transparency-and-ethics.md`.
3. **Freshness.** `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-status` must not list `.qualstack/clue-plan.md` or `.qualstack/case-selection.md` as stale: probative values computed on an earlier model belong to that model. If stale, rerun `/qualstack:clue-select` or `/qualstack:case-select` first.
4. **Registry and evidence status.** Choose the registry by the guide's checks (time stamp and immutability, embargo, attachments, an anonymized view for reviewers), or the target journal's results-free or registered-report track if one exists. Record in the header, by category and without names, what has already been seen: scoping interviews, archive series read, secondary literature, cross-case data. A plan that hides prior looks is worse than none.
5. **Draft `prereg/prereg.md`** from `${CLAUDE_PLUGIN_ROOT}/skills/preregister/assets/prereg-template.md`. All ten sections are required:
   1. **Causal model**: the statement; each restriction, confounding arc, and prior with its label (R1, C1, P1) and its justification from `model.md`; `code/01-model.R` attached verbatim with its `sha256sum`; the model-review verdict and date.
   2. **Queries**: one primary, the rest secondary; each in words and in CausalQueries syntax with its `given`, case-level or population-level, with its prior from `output/tables/prior-queries.csv`.
   3. **Cases**: the population; the selection rule, using only recorded values or saying what else it conditions on; the cases and the values the rule used; the replacement rule if access fails; the selection log kept in `.qualstack/case-selection.md`.
   4. **Clue plan**: per clue, the node; where it will be sought (source categories, never names); φ1 and φ0, the probative value if found and if absent, the test type, the chance of finding it, the posterior either way, and the expected learning, all computed from the registered model; the search that must fail before a 0 is coded; the two-step plan if any (the first clue, what follows each result, expected cost and learning).
   5. **Coding rules**: per-node versions and the `sha256sum` of `data/coding-rules.md`; who codes; the blind second-coding plan; any LLM coder or assessor with its model version, brief, and validation plan.
   6. **Updating and reporting**: `code/03-data.R` and `code/04-update.R` (or the planned calls), `model.seed`, sampler settings; what is reported: prior beside posterior, intervals for population queries, case-level answers for traced cases.
   7. **Decision rules**: per query, numeric posterior thresholds for support, evidence against, and inconclusive, with reasons; the counterfactual table (the posterior under each pattern of clue results), so a reader sees what the evidence could have shown.
   8. **Robustness**, committed now: named alternative priors; each restriction relaxed; confounding allowed; clue measurement error; each case and each source dropped; values coded only from confidential items set to NA.
   9. **Stopping, surprises, deviations**: when each clue's search ends and when fieldwork ends (sources exhausted, a date, a budget, a saturation rule per interview category); surprises go in a dated addendum (`prereg/addendum-YYYY-MM-DD.md`) written before the new evidence is coded and framed results-free (what changed and why, not what it does to the answer); a closed source leaves its clue NA; new evidence on a modeled node takes its probative value from the registered model, a new node is a model revision, and both are reported with and without; every deviation appears in the paper beside the plan.
   10. **Data availability and embargo**: what will be shared (`/qualstack:archive`), what cannot be and why; the embargo chosen; how the public plan avoids naming participants, small sites, or confidential sources.

   With `model.formal: false`, sections 1, 4, and 6 lock instead the exhaustive, mutually exclusive hypotheses, the prior on each with its reason, Pr(K | H) for every planned clue under every hypothesis as a range, and the informal procedure in `bayesian-process-tracing.md`.
6. **Pre-flight.** Refuse to mark the plan ready until: the recorded hash matches the current `code/01-model.R`; every clue has model-derived values and an expected learning from that model (informally: likelihood ranges under every hypothesis); the primary query is in code syntax with its `given` (informally: an exhaustive, mutually exclusive set of hypotheses); every decision threshold is a number; every model node has a complete coding-rule block with a version; the selection rule says what it conditions on; every clue has a stated search and fieldwork a concrete end; the evidence already seen is disclosed; `python3 ${CLAUDE_PLUGIN_ROOT}/bin/qualstack-redact check prereg` exits 0 (or, with no identity key yet, fails only for that reason) and the plan names no participant.
7. **Config.** Set `design.prereg: true` in `.qualstack/config.yaml`, leave `design.prereg_url: ""` for the user, and append a dated line to `decisions:`.
8. **Hand-off.** Tell the user: file the plan as written, attaching `code/01-model.R` and `output/tables/clue-diagnosis.csv`; paste the registry URL into `design.prereg_url`; from then on the guard hook makes the files in `prereg/` read-only and every change is a new dated addendum. Collect or read the decisive evidence only after filing.

## Outputs

- `prereg/prereg.md`: the preregistration.
- `.qualstack/config.yaml`: `design.prereg: true`, `prereg_url` left for the user, a `decisions:` line.
- Summary block: registry and embargo, the evidence already seen, items still failing pre-flight if any; file before collecting, then paste the URL back.

## Anti-patterns

- **Hypotheses without probative values.** "We expect to find evidence of the mechanism" locks nothing; the clue, its likelihoods, and its expected learning do.
- **Likelihoods set after the clue is seen.** A specification chosen after the estimate.
- **Absence explained away in advance.** If finding a clue supports the claim, not finding it counts against; the plan states the posterior both ways.
- **No stopping rule.** "Until saturation" or "until the archive is exhausted" is not a rule; name the series, the categories, the date.
- **A plan written after reading the archive**, without saying so.
- **A plan that exposes people.** Sources by category; an embargo when the case itself is sensitive.
- **Editing the registered file.** Every change is a dated addendum.

## Next

Collect: `/qualstack:fieldwork-plan` if not yet written, then `/qualstack:evidence-log` and `/qualstack:code-evidence`. For confirmatory claims, do not run `/qualstack:analyze` before the plan is filed.
