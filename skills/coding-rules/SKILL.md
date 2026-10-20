---
name: coding-rules
description: Writes data/coding-rules.md, the versioned measurement contract for every node in the causal model — the concept, the indicators, what counts as 1, what counts as 0, what leaves the value NA, the time window and the dated event that anchors it, the unit, anchor cases, the sources expected to reveal it, and a change log — after forcing three questions per node (is the dichotomization honest, can a 0 be told from an NA, does the node's time stamp respect the order of the DAG). Use when the model is settled and coding is next, when the user asks how to code, measure, operationalize, or dichotomize a node, where to put a threshold, what counts as present or absent, or wants to change a rule after coding has begun.
argument-hint: "[node ...|revise <node>]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(date *)
---

# /qualstack:coding-rules

**Stage:** design · **Voice:** measurement-clerk

A rule is written before the evidence it judges and binds every case alike. The clerk refuses a node whose 0 cannot be told from its NA, a cut placed where the sample splits rather than where the theory says the effect switches on, a bar that moves with a case's outcome, and any change to a rule that is not versioned and followed by a full recode.

## Procedure

1. **Inputs.** The model statement (`STATEMENT` in `code/01-model.R`; `model.statement` in `.qualstack/config.yaml` when `model.formal: false`), the node definitions in `.qualstack/model.md`, `.qualstack/queries.md`, the clue plan (`.qualstack/clue-plan.md`: where each clue will be sought), and the cases (`.qualstack/case-selection.md`). No statement: stop and run `/qualstack:causal-model` first. `Read ${CLAUDE_PLUGIN_ROOT}/references/concepts-and-coding.md` in full: its block format is the format, field for field. `$ARGUMENTS` names the nodes to write; `revise <node>` goes to step 8; the default is every node without a complete block. Today: `date +%Y-%m-%d`.
2. **Header**, once: the model statement exactly as in the code; the unit (the case bounded in space and time, the episode and not the country-year) with case IDs as in `data/case-data.csv`; the 0 standard; the source precedence order (contemporaneous internal records over retrospective accounts, participants over observers, documents without an audience over public statements, unless the user argues another order) and the default value for a tie.
3. **One block per node**, in the model's node order (roots first), named exactly as in the statement (letters and digits only). Every field filled; `TBD` is not a value. Where the format leaves room:
   - **Period** carries the time window and the time stamp: a window relative to a dated event type ("the 24 months before the founding election"); each case's date for that event comes from `/qualstack:chronology`.
   - **Systematized definition** states the aggregation when the property belongs to sub-units (regions, factions): any, all, or a majority.
   - **Evidence types** carries the sources expected to reveal the node: the log types, the specific archives, series, or interviewee categories from the clue plan, and the minimum that settles a value (one contemporaneous document; two independent origins).
4. **Forcing question 1: is the dichotomization honest?** "Where is the cut, and why there?" Theory places it where the effect switches on, on substantive anchors, never at a median or a sample split, which moves as cases are added (Schneider & Wagemann 2012). Record one or two alternative cuts for `/qualstack:robustness`, and that the raw level goes in each coding-log `note`. Ask whether the 0 pools unlike cases (imposed transitions, collapses, no transition at all) that act differently on the node's children: if so, split the node, and remember that nested nodes need a restriction, an ordinal concept becomes cumulative nodes, and every split multiplies nodal types (back to `/qualstack:causal-model`). Every attribute is checked before any 1, so the label cannot stretch to cases that lack one (Sartori 1970); the indicators cover the systematized concept and nothing else (Adcock & Collier 2001).
5. **Forcing question 2: can a 0 be told from an NA?** "What positive evidence of absence would code 0, and what search would have found the property had it been there?" Name the source, the series, the period, and why it would record the property: P(found | present) = P(written down) × P(survived and released) × P(search reached it) × P(recognized). Silence is not a 0. If no source could establish absence, write `0 if: none attainable`, so the node is NA wherever it is not seen, and raise a measurement node (true K → coded K) with `/qualstack:causal-model` if the clue carries the query. The search is the same in every case: a clue sought only where it is expected makes NA depend on the value.
6. **Forcing question 3: does the time stamp respect the DAG?** For every arrow A → B, A's window closes before B's opens, or the block says why overlap is harmless (A a standing condition fixed before B could respond). An indicator dated in the outcome's period measures the outcome: drop it. A cause coded from evidence written after the outcome counts only for what it reports about its own period. An order that cannot be kept is a model question for `/qualstack:causal-model`, not a re-dating.
7. **Anchors and the partition test.** A clear 1, a clear 0, and a hard case per node, from pilot or out-of-scope cases where possible; an anchor drawn from a case still to be coded is marked `(in sample)` so that `/qualstack:code-evidence` can strip it from a blind coder's copy. Run each anchor and hard case through the block: every evidentiary situation must land in exactly one of `1 if`, `0 if`, `NA if`; a gap or an overlap is a clause to fix, and each resolved hard case becomes a clause. Record which case evidence had already been read when the rule was written; the bar never depends on a case's outcome or its fit with the hypothesis.
8. **Versions.** Before any value of a node is coded, edit the block and redate it. Once `data/coding-log.csv` has a row for the node (Grep it), any change to a clause that decides a value (definition, indicators, period, `1 if`, `0 if`, `NA if`, threshold, evidence types) is a new version: bump `vN` in the heading, add the change-log line (what changed, why, the date), and send the node to `/qualstack:code-evidence recode <node>`: every case recoded under the new version, old rows kept, case data rebuilt (`/qualstack:paper-status` shows `data/case-data.csv` stale until then). A change made after seeing a posterior is reported under both versions; with `design.prereg_url` set it is also a deviation, written in a new `prereg/addendum-YYYY-MM-DD.md`. Never recode only the cases that hurt. A node dropped from the model keeps its block, moved under a final `# Retired nodes` heading with a change-log line.
9. **Decisions.** Append one dated line per cut and per version change to `decisions:` in `.qualstack/config.yaml`.
10. **Check before hand-off.** Every statement node has exactly one complete block and no block names a node outside the statement (`/qualstack:code-evidence` refuses to build case data otherwise); the header's statement matches the code; every `0 if` names positive evidence, a search, or `none attainable`.

## Outputs

- `data/coding-rules.md`: the header and one block per node; changed blocks versioned, with their change logs.
- Dated `decisions:` lines in `.qualstack/config.yaml`.
- Summary block: nodes with complete blocks out of nodes in the model; per node the version, the cut and its alternatives, the 0 standard (positive evidence, a named search, or none attainable), and the time stamp; arrows whose order cannot be kept; nodes awaiting a recode.

## Anti-patterns

- **Sample-statistic cuts.** A median split is a property of the sample, not of the concept.
- **"Not mentioned" coded 0.** That is NA unless a named search meets the 0 standard.
- **Indicators from the outcome period.** They measure the outcome.
- **Rules written around cases.** A clause that names a case, outside the anchors, is a list of codes.
- **Silent edits.** A changed clause with no new version, no change-log line, and no full recode.
- **Case-dependent bars.** What a 1 needs never depends on whether the case fits.

## Next

`/qualstack:preregister` when `design.prereg` is true (the plan cites the rules' version); `/qualstack:evidence-log` as evidence arrives, then `/qualstack:code-evidence`. An arrow whose order cannot be kept, or a node with no attainable 0 that carries the query → `/qualstack:causal-model`. After a version change → `/qualstack:code-evidence recode <node>`.
