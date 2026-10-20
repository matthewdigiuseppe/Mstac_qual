---
name: idea-shotgun
description: Generates 4-6 genuinely different angles on the same cases, archive, fieldwork access, or topic — varying the causal query, the cases, the design (single-case tracing, comparison, multi-method), and the audience — carded by claim, query, leverage, cost, and risk, then ranked. Use when the user has access, sources, or a topic but no committed question, wants alternatives before investing in fieldwork, or a red-light verdict sent them back to ideation.
allowed-tools:
  - Bash(date *)
  - Read
  - Write
---

# /qualstack:idea-shotgun

**Stage:** ideate · **Voice:** generative

Produces variants so the user picks from a set instead of a hunch. Qualitative projects are often seeded by access (an archive just opened, a network of interviewees, a field site) rather than by a question; this is where access becomes a question.

## Procedure

1. **Load** `.qualstack/research-question.md` (if a prior attempt exists) and any notes on the sources or access the user has.
2. **Get the seed.** One paragraph from the user: what they have (cases, archives, interviewees, a cross-case dataset, a theoretical interest), what the question might be, the audience they imagine. If the conversation or `.qualstack/research-question.md` already supplies these, do not re-ask.
3. **Generate 4–6 angles**, each varying along one axis:
   - **same case, different query** — from "did X cause Y here?" (attribution) to "through which path?" (mechanism) to "was X necessary here?" (a different counterfactual);
   - **same query, different cases** — a deviant case, a most-likely or least-likely case, a paired comparison, a subnational scale-down (Snyder 2001);
   - **same evidence, different design** — single-case tracing → a multi-method design that pairs these cases with cross-case data and lets each inform the other (Humphreys & Jacobs 2023);
   - **same headline, different audience** — comparative, IR, American political development, historical political economy, methods.
   At least one angle reframes the question entirely.
4. **Card each angle:**

   ```
   ANGLE N: <one-sentence claim>
   Query:        <the causal question, case-level or population-level, as a counterfactual>
   Contribution: <the new sentence this adds to the literature>
   Leverage:     <the evidence that could discriminate between this claim and its main rival, and where it would come from>
   Cost:         <fieldwork / archive / coding weeks | total months | access risk>
   Risk:         <highest single risk: access, an uninformative model, scoop, historiography, ethics, fit>
   ```

5. **Rank** qualitatively on `(contribution × leverage) / (cost × risk)`; surface the top 2.
6. **Save** every angle, including the unsurfaced ones (next year's project), to `.qualstack/idea-shotgun-<YYYY-MM-DD>.md`.

## Outputs

- `.qualstack/idea-shotgun-<date>.md` — full angle set with cards.
- Summary block: top 2 with a one-line case each, and which to take to `/qualstack:research-question`.

## Anti-patterns

- **Variations on a theme.** Five angles that swap one case are not divergence.
- **Access as a question.** "I can interview ministers" is a resource; every angle states a query.
- **Defaulting to the seed.** At least one angle should reframe the question entirely.

## Next

`/qualstack:research-question` on the chosen angle.
