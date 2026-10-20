---
name: lit-map
description: Systematic literature map for qualitative and multi-method work, run against the converted corpus (lit/index.md and lit/md/) — the conversation and where its consensus cracks; the claims restated as candidate causal relations (who argues X causes Y, through what, under what conditions) that become nodes, arrows, and restrictions for the theory; the rival explanations and whether they are really mutually exclusive; the historiography of each candidate case and which cases are over-studied; the evidence others used for which clues; the open question; and BibTeX staged into paper/refs.bib. Use once a research question is locked, when the user asks what to cite, who has written on a topic or studied a case, or what the rival explanations are, and before building the theory or drafting the introduction.
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

# /qualstack:lit-map

**Stage:** model · **Voice:** systematic-reviewer

After `/qualstack:research-question` returns green or yellow. Two questions: what conversation is this project joining, and where does its consensus crack; and what does that conversation already believe about the causal structure, the rivals, the cases, and the evidence? A map that yields no candidate arrows for `/qualstack:theory-build` and no candidate sources for `/qualstack:fieldwork-plan` is a bibliography.

## Procedure

1. **Load** `.qualstack/research-question.md` (the contribution sentence and the query are the seed; it names the candidate cases) and `.qualstack/config.yaml`. **Corpus first:** if `lit/pdf/` holds PDFs that `lit/index.md` does not list, run `/qualstack:pdf-ingest` before anything else; searching the web for abstracts of papers already on disk is backwards. Triage from `lit/index.md`; open one section of a converted paper in `lit/md/` (the front matter's `sections` list is the map: Grep the heading, Read that range), not the whole file. Read, from `${CLAUDE_PLUGIN_ROOT}/references/`, `causal-models.md` (how verbal arguments become types and restrictions), `bayesian-process-tracing.md` (rival explanations), and `evidence-and-sources.md` (secondary sources and historiography).
2. **Define the search** in one paragraph and get sign-off: 3–5 keyword combinations; the 2–3 most directly engaged authors; the window (about ten years plus the foundational work); venues, meaning field and area journals, university-press monographs (much qualitative work lives in books), dissertations, working papers, and APSA, MPSA, ISA, SSHA, and regional-association programs; and, per candidate case, the case name with the outcome, in the case's languages where the user reads them (say which historiographies go uncovered). The strings and dates go in the map, so the search can be rerun.
3. **Search.** Local corpus first, then WebSearch for keyword and author scans and WebFetch (or a scholarly-search connector, if one is available) for abstracts; snowball backward through the Foundation works' reference lists (`lit/md/<citekey>.refs.md`) and forward through "cited by" on the two or three works closest to the claim. Look specifically for earlier process tracing, multi-method studies, and reanalyses of the candidate cases, and for evidence already deposited (QDR projects, ATI-annotated articles). Aim for 20–40 candidates in the conversation, plus each case's historiography.
4. **Triage:** **Foundation** (3–5; the canonical works; must-cite), **Frontier** (5–10; recent, in active conversation with the claim; engage explicitly), **Adjacent** (5–10; a different question; cite once), **Historiography** (per case; the works that establish what happened), **Discard** (noted, not engaged). Every row names the work by citekey (its `lit/md/` file name or `paper/refs.bib` key), so later skills can open the section behind it. A work is literature when you engage its argument and evidence when you code a node from it, and only `/qualstack:evidence-log` makes it evidence, with its footnotes checked.
5. **Claims as candidate causal relations,** one row per Foundation or Frontier claim:

   | # | Work | X → Y | Through (mediators) | Under (moderators, scope) | Form | Query | Cases and evidence | Rules out |
   |---|---|---|---|---|---|---|---|---|

   - **Form** is necessary, sufficient, monotonic, or joint ("Y only if X and W" is type 0001); **Rules out** is the missing arrow or the restriction the claim implies ("X never lowers Y" removes type 10); **Query** is the family the work answers (case-level effect, attribution, path, average, actual cause), often never stated.
   - Read the claim in the argument section, not the abstract, or mark the row `abstract only`. A vague verb ("shapes", "matters for") is recorded as vague, or as each reading it admits; never sharpen it silently.
   - One label with two definitions is two candidate nodes; a common cause the literature names becomes a node or a `<->`; a scope condition is a moderator or a population boundary, and the row says which.
   - A restriction that rests on one author's assertion is a candidate prior, not a certainty.
   - End with a **candidate model**: the union of nodes (CamelCase; no underscores, dots, or hyphens) and arrows as a draft statement, each arrow and restriction keyed to claim rows, e.g. `Inequality -> Mobilization -> Democracy; Pressure -> Democracy; Inequality -> Democracy`. It is a menu for `/qualstack:theory-build`, not a commitment. Note quantitative findings and cross-case datasets that could set priors or train the model.
6. **Rival explanations.** List the rival accounts of the outcome and, for each pair, test exclusivity (Zaks 2017): can both be true at once, is one a mechanism of the other, do they answer different queries? Causes are not rivals: "inequality or international pressure?" is two difference-making questions. Restate each rival as a claim about the same model (an alternative cause of Y, another path, another functional form), and the set as mutually exclusive claims about a case (X a difference-maker and W not; W and not X; both; neither). Flag any rival that predicts the same value of every observable node as the main claim: no clue can discriminate it, and the paper must say so.
7. **Cases already studied, and by whom.** Per candidate case: the works, their school or thesis, the query each answered (usually a narrative, not a counterfactual), their verdict on each contested node, and the sources each rests on. Flag **over-studied cases**: a case the theory was built on cannot also test it, and its historiography has already selected the evidence. Flag cases nobody has traced. Where historians disagree, record who says what on which node: scholars cite the historians whose accounts fit (Lustick 1996), so the debate goes in the map, and contested values are later coded under each account, never settled by picking the convenient historian.
8. **Evidence others used for which clues,** one row per node × case × work: the evidence behind the claim (archive and series, interviews and how many, other secondaries, or none, meaning the author's inference), whether its footnote was checked, and its access now (open, archive-restricted, closed, newly released). Many works citing one source are one source. This table seeds the source map in `/qualstack:fieldwork-plan`: series already mined, series never consulted, claims resting on nothing.
9. **Consensus and cracks,** one paragraph: what the conversation believes; where it is contested; what the canonical work does not answer (the query never asked as a counterfactual, the rival never tested, the clue never sought, the case never traced).
10. **The open question,** one paragraph: which works the project engages most directly; what it adds that they lack (a sharper query, a model of a verbal argument, a clue that discriminates rivals they could not, an unopened series, a case outside the over-studied set); and the two or three likely referees, at least one an area specialist or historian of the case, with what each would insist on (`/qualstack:referee-mock` uses this). A recent work that already answers the query for the case sends the project back to `/qualstack:research-question`.
11. **Stage `paper/refs.bib`:** an entry per Foundation, Frontier, and Historiography work engaged, appended and deduped by key, never overwritten; unknown fields left blank with `% TODO`; prefer entries from `lit/refs-ingested.bib`, never one still marked `% TODO verify`.
12. **Save** `.qualstack/lit-map.md`, dated with `date +%Y-%m-%d`, and set `paper.status: "modeling"` in `.qualstack/config.yaml` if it still says `ideating`. When `lit/index.md` changes, the map is stale: add dated rows to the search record and the tables rather than rewriting them.

## Outputs

- `.qualstack/lit-map.md`: search record; triage; claims table and candidate model; rivals and how they relate; case historiography with over-studied cases flagged; evidence-used table; consensus and cracks; the open question; likely referees.
- `paper/refs.bib`: appended entries.
- Summary block: the 3–5 must-engage works, the candidate model statement, the rivals and whether they exclude each other, the over-studied cases, the open question, the next skill.

## Anti-patterns

- **A list instead of a synthesis.** Thirty papers is not a map; the claims table, the rivals, and the gap are.
- **Inventing citations or claims.** Not found by search means left out; a claim seen only in an abstract is marked so.
- **Arrows from adjectives.** "X shapes Y" is not an arrow until direction, path, and form are stated.
- **Rivals at face value.** Two accounts that can both be true are not a test between them.
- **One historian.** A case's history is a debate; map it.
- **The canonical case as a test.** A case the theory was built on cannot confirm it.
- **Too broad a frontier.** Five engaged works beat fifteen name-drops.
- **Hiding contradictions.** If the consensus contradicts the claim, say so now, not at R1.

## Next

`/qualstack:theory-build` reads the claims table and the candidate model. Later, `/qualstack:case-select` uses the case historiography and `/qualstack:fieldwork-plan` the evidence-used table. A recent work that already answers the query → `/qualstack:research-question`. The map is a prerequisite for drafting the intro or theory with `/qualstack:draft-section`.
