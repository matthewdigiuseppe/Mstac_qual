---
name: qualstack-init
description: Scaffolds a new QualStack project folder (paper/, evidence/, data/, code/, output/, restricted/, .qualstack/ memory) from the plugin template, LaTeX or Quarto. Use when the user wants to start a new qualitative, case-study, process-tracing, or mixed-method project — e.g. "set up a new project on X" — or asks to run qualstack-init.
argument-hint: "<short-name> [--quarto]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
---

# /qualstack:qualstack-init

**Stage:** setup · **Voice:** scaffolder

Once per project, in the directory where the project folder should live; every other skill assumes this layout. `$ARGUMENTS` is a short slug (`land-reform-chile`; lowercase, hyphens, no spaces) optionally followed by `--quarto` for a Quarto main file instead of LaTeX. Ask for the slug if missing.

## Procedure

1. **Refuse to nest.** If the current directory or an ancestor already contains `.qualstack/`, stop and tell the user to `cd` out; a project inside a project breaks every path convention and the guard hook's idea of where `restricted/` is.
2. **Run** `bash "${CLAUDE_PLUGIN_ROOT}/bin/qualstack-init" <short-name> [--quarto]`.
3. **Fallback** if the script is missing or there is no bash: copy `${CLAUDE_PLUGIN_ROOT}/templates/project-folder` to `./<short-name>` (hidden files included: `.qualstack/`, `.gitignore`, `.ignore`); stamp `short_name: "<short-name>"` into `.qualstack/config.yaml`; for `--quarto`, replace `paper/main.tex` with a `main.qmd` that `{{< include >}}`s the section files as `.qmd` and set `format: "quarto"` in config.
4. **Verify** `.qualstack/config.yaml`, `paper/`, `evidence/log.csv`, `evidence/raw/`, `data/`, `code/`, `restricted/`, `.gitignore`, and `.ignore` exist. Do not open `restricted/README.md`; the guard hook keeps that folder out of Claude's reach, and the README is for the researcher.
5. **Hand off,** in this order:
   - fill in `.qualstack/config.yaml`: title, authors, target journals, `voice.writing_style` if a style skill is installed;
   - if the project will involve interviews, observation, or any living participants: set `design.human_subjects: true` and **`privacy.ai_processing`** to what the ethics approval and consent forms allow (`none`, `pseudonymized`, or `full`) before any participant material enters the folder, and read the `restricted/README.md` that the scaffold put there;
   - if the folder will be a git repository, confirm `restricted/` is ignored (`git check-ignore restricted/` prints it) before the first commit;
   - then `/qualstack:research-question` or `/qualstack:idea-shotgun`.

## Outputs

- `./<short-name>/` — the full scaffold; summary: path, format (latex / quarto), the privacy setting still to make, next steps.

## Anti-patterns

- **Scaffolding over an existing folder.** If `./<short-name>` exists, stop; never merge into it.
- **Skipping the privacy setting** on a project with participants. It decides what may enter this folder at all.
- **Skipping config.** It works empty, but remind the user once: several skills read `target_journals`, `design.*`, and `voice.*`.

## Next

`/qualstack:research-question` or `/qualstack:idea-shotgun`; any time later, `/qualstack:paper-status`.
