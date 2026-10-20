---
name: llm-checklist
description: Logs LLM-as-research-instrument use (model version, access mode, config, prompts) to a ledger as it happens and compiles the 14-item GUIDE-LLM reporting checklist (Feuerriegel et al. 2026) for the methods appendix. Use whenever an LLM is integral to the design — blind second coding of evidence, blind likelihood assessment in process tracing, extracting or translating passages from documents and transcripts, transcription, classification — even if the user only mentions having used ChatGPT, Claude, Gemini, or an open model on their evidence; not for editorial drafting. Run before submission to flag missing items.
argument-hint: "[log <details>|status|report|latex]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(date *)
---

# /qualstack:llm-checklist

**Stage:** cross-cutting (collect → submit) · **Voice:** reporting-clerk

Implements **GUIDE-LLM**, the consensus reporting checklist for large language models in behavioural and social science (Feuerriegel, S. et al., *Nature Human Behaviour*, 2026, https://doi.org/10.1038/s41562-026-02492-7). Two jobs: **log** LLM use as it happens, and **compile** the filled checklist for the paper.

Log the first time an LLM touches the research and every time the model, version, prompt, or configuration changes, not at write-up: the checklist wants the exact version (often dated, like `gpt-4o-2024-11-20`), access mode, and configuration, and these change or are discontinued without notice, so the only reliable record is the one captured when the calls were run.

## Integral vs. editorial

GUIDE-LLM covers LLM use that is **integral to the research design**, not minor editorial help.

- **Log:** blind second coding of clue nodes (`/qualstack:code-evidence` with the `qualstack:coder` agent); blind likelihood elicitation (`/qualstack:process-trace` with the `qualstack:assessor` agent); extracting passages, dates, or events from archival documents or transcripts that enter the evidence log, chronology, or case data; machine transcription or translation of interviews or documents that are then quoted or coded; classification or annotation of any text that enters the analysis. Claude via QualStack doing any of these counts.
- **Do not log here** (disclose per the journal's AI-use policy instead): drafting prose, formatting tables, debugging code, brainstorming, including Claude / QualStack as a writing aid. Drafting the discussion section is not an instrument.
- In doubt, log it: over-disclosure costs a table row, under-disclosure costs reproducibility.

## Subcommands (`$ARGUMENTS`)

- `log [free text or details]` — append or update one LLM task; free-form is fine, the skill normalizes it and asks for missing checklist-critical fields.
- `status` — per-task coverage of the 14 required items, plus a scan of the codebase for LLM calls no task references.
- `report` (default) — compile the checklist from the ledger to `.qualstack/llm-checklist.md`.
- `latex` — also emit a Supplementary-Information block to `paper/sections/llm-checklist.tex`.

## The ledger

`.qualstack/llm-usage.jsonl`: append-only, one JSON object per line, **one LLM task per line** (a distinct model used for a distinct purpose; the paper reports each separately, so one task = one line = one checklist block). Line 1 is a `_meta` header (competing interests, GUIDE-LLM citation). Lines tagged `"_example": true` are illustrative and ignored by `status` / `report`. Fields map 1:1 to checklist items:

```json
{
  "id": "short-stable-handle", "date_logged": "YYYY-MM-DD",
  "purpose": "",                                    // A.1
  "automation": "",                                 // A.2  human-in-the-loop | fully-automated (+ audit rate)
  "model": {"name": "", "provider": "", "size": "", // B.1
            "version_or_id": "", "access_date": "", "source_url": ""},
  "access_mode": "", "context_mode": "",            // B.2  API | web | local;  chat | separate-calls
  "config": {"temperature": null, "max_tokens": null, "seed": null, "n_runs": null, "other": ""},  // B.3
  "customization": "",                              // B.4  none | fine-tuned | RAG | tools/function-calling | ...
  "persistent_memory": false,                       // B.5
  "prompt_user_ref": "", "prompt_system_ref": "",   // C.1, C.2  paths to verbatim prompt files
  "data_sensitivity": "",                           // D.1
  "human_validation": "", "post_processing": "",    // E.1, E.2
  "code_ref": "",                                   // F.1  path to the script / notebook making the calls
  "opt": {"llm_choice_justification": "", "prompt_design_rationale": "", "cross_model_comparison": "",
          "training_data_leakage": "", "bias_assessment": "", "transcripts_ref": "",
          "ethical_implications": "", "compute_use": ""},
  "notes": ""
}
```

Prompts live in files (e.g. `code/llm/prompts/*.txt`) referenced by path; never paraphrase a prompt into the ledger or inline it as a giant JSON string. For an agentic system with no single verbatim prompt, point `prompt_user_ref` at the source or config that defines the interaction logic and say so in `notes` (the paper permits "the most complete documentation feasible").

## Procedure

**`log`**

1. Create the ledger with a `_meta` header if absent (competing interests from `.qualstack/config.yaml` authors / funding if available; otherwise blank and flagged).
2. Get today's date (`date +%Y-%m-%d`); parse the user's text into the schema. An `id` that already exists means update that task in place (re-read and rewrite the file); otherwise mint a short `id` from purpose + date.
3. Fill what you can, then ask only for the checklist-critical fields still empty: exact `model.version_or_id` (refuse a bare brand like "ChatGPT" or "GPT-4"); `access_mode` + `context_mode`; `config.temperature` and `n_runs` (temperature drives reproducibility; if the model exposes none, record that); `prompt_user_ref` as a path, not a paraphrase; `human_validation` plan or result. Never block on `opt.*`.
4. **Check the privacy setting.** `data_sensitivity` must say what the model saw (pseudonymized transcripts, open archival documents, published sources) and that it matches `privacy.ai_processing` in `.qualstack/config.yaml`. If the task fed the model material the setting does not allow, stop and tell the user: that is a protocol deviation to report to their ethics board, not a ledger entry to tidy.
5. Write the normalized object as one line; echo it back.
6. If `prompt_user_ref` / `code_ref` point at files that do not exist yet, remind the user to save the verbatim prompt and the call script there: C.1 and F.1 need them and `/qualstack:archive` collects them. For subagent runs, the brief each agent received is the user prompt and the agent definition (`agents/coder.md`, `agents/assessor.md` at the plugin version used) is the system prompt; save the briefs under `.qualstack/review-cache/briefs/` (a subfolder, so that a brief never displaces a review's verdict, which `/qualstack:paper-status` reads from the newest top-level file).

**`status`**

1. For each non-`_meta`, non-`_example` task print a 14-row check (✅ filled / ⚠️ missing, item code + name), grouped by `id`.
2. Grep the project (`code/`, `*.py`, `*.R`, `*.ipynb`, `*.qmd`; never `restricted/`) for call sites (`openai`, `anthropic`, `chat.completions`, `client.messages.create`, `litellm`, `ollama`, `transformers`, `huggingface`, `gemini`, `vertexai`, `together`, `groq`); list any file that calls an LLM but is not referenced by some task's `code_ref` and warn it may need a ledger entry.
3. One-line verdict: `N tasks, M required items missing across them` plus the exact list to fix.

**`report`** (and `latex`)

1. Read the ledger and `.qualstack/config.yaml`; skip `_meta` / `_example` lines.
2. Read `references/guide-llm-items.md` in this skill's folder for the verbatim 14 items and the LaTeX skeleton.
3. One block per task: the full GUIDE-LLM table filled from the task fields, with every empty required field rendered as `⚠️ MISSING — <what to capture>` so the gap is visible in the draft; a separate "Optional (GUIDE-LLM online)" subsection from `opt.*`, omitting blanks (no ⚠️ there).
4. G.1 (competing interests / funding) once, from `_meta.competing_interests` cross-checked against config; flag if blank, it is required.
5. Citation footer with the template link (https://osf.io/mv63j/). Write `.qualstack/llm-checklist.md` and print the missing-item summary.
6. For `latex` (or on offer), also write `paper/sections/llm-checklist.tex` (a `description` / `longtable` block from the skeleton) and tell the user to `\input` it.

## Outputs

- `.qualstack/llm-usage.jsonl` — the ledger, created on first `log`.
- `.qualstack/llm-checklist.md` — the compiled checklist, one block per task, missing items flagged.
- `paper/sections/llm-checklist.tex` — on request, an SI-ready block.

## Anti-patterns

- **Bare model names.** "We used ChatGPT / GPT-4" hides version, configuration, and access mode that change results; demand the identifier (B.1).
- **Paraphrased prompts.** C.1 means verbatim, as a file.
- **"Default settings."** Capture `temperature`, `seed`, `n_runs`, or state explicitly that the model exposes none.
- **No human validation.** E.1 is what licenses reading outputs as the construct; for a second coder it is the agreement statistic before adjudication, for an assessor the comparison with the author's own likelihoods. An unvalidated pipeline is a finding waiting to be retracted.
- **Logging at write-up.** Reconstructing versions months later is exactly the failure GUIDE-LLM exists to prevent.
- **Padding with editorial use.** "Claude helped write the intro" is an AI-use disclosure, not an instrument.

## Next

`/qualstack:evidence-log` when LLM outputs (a transcription, a translation, an extracted passage) become evidence items (log provenance there too, cross-referencing `code_ref`); `/qualstack:preregister` when LLM use is part of the planned procedure (pre-commit the coding brief, model version, validation plan; the ledger then documents adherence); `/qualstack:draft-section appendix` to paste or `\input` the block; `/qualstack:archive` collects the ledger, briefs, and agreement reports; `/qualstack:learn` for conventions that generalize.
