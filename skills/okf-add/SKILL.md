---
name: okf-add
description: Add or update ONE concept in an existing OKF documentation bundle — the incremental, as-you-write path (not a bulk migration). Use when asked to "document this", "add a doc", "write this up as a concept", "capture this decision", "add to the product/architecture bundle", or to record a single new fact in OKF format. Non-destructive: only creates or updates concept files and the index; never deletes. Creates the bundle (index + governance rule) on first run. For converting a pile of existing docs, use okf-docs instead.
license: MIT
metadata:
  author: acatl
  version: "0.0.0" # x-release-please-version
---

# okf-add — add or update one concept in an OKF bundle

The incremental companion to `okf-docs`. One concept per run. **Never deletes** — only creates or
updates. Applies the shared contract [`references/okf-format.md`](references/okf-format.md).

## When NOT this skill

- Migrating / reorganizing a pile of existing docs → `okf-docs` (bulk convert; has the safety gates).
- Just checking an existing bundle's health → `okf-check` (read-only).

## INPUTS (resolve before STAGE 0; ask operator if absent)

- `CONTENT` — the fact / note / decision to record (prose, or a pointer to where it currently sits).
- `BUNDLE_ROOT` — target bundle dir, e.g. `docs/product/`. If it doesn't exist yet, STAGE 0 creates it.
- `LAYER` — the doc domain (`product`, `architecture`, any) — only used to pick `SOURCES_OF_TRUTH`.
- `SOURCES_OF_TRUTH[]` — what the concept will LINK to (code, config, spec system). Never copied in.

## STAGE 0 — LOCATE OR INIT BUNDLE (gate G1)

- If `BUNDLE_ROOT/index.md` exists → this is the bundle; read `index.md` + list concept files.
- If it does NOT exist → **INIT:** create `BUNDLE_ROOT/`, write `index.md` (frontmatter ONLY
  `okf_version: "0.1"`), and emit the governance rule from
  [`templates/okf-docs.rule.md`](templates/okf-docs.rule.md) to the project's rule location (Claude
  Code: `.claude/rules/okf-docs.md`), filling its `paths:` with `BUNDLE_ROOT/**/*.md`. **GATE: do not
  author a concept until the bundle + index exist.**

## STAGE 1 — RESOLVE HOME (gate G2 — one home per fact)

- Search the bundle for a concept that already owns this fact
  (`grep -rl` on key terms across `BUNDLE_ROOT`).
- **Decision:**
  - existing owner → **UPDATE that file** in place (extend/correct the section). Do NOT create a second file.
  - no owner → **NEW concept.** Name it by `reader × change-cadence` (the same classification okf-docs
    uses), not by topic. Path = concept identity.
- **GATE: creating a second home for a fact that already has one is rejected.** When ambiguous which
  concept owns it, ask the operator.

## STAGE 2 — SOURCE THE CLAIMS

- Every claim links to its `SOURCES_OF_TRUTH`; it is never copied or reformatted in.
- **If a fact is not in ground truth, INTERVIEW the operator — never invent.** Label each claim
  `sourced` (cite the path/line) or `inferred`.

## STAGE 3 — AUTHOR (apply contract)

- Write/extend the concept per [`references/okf-format.md`](references/okf-format.md): `type:`
  frontmatter (no `title`, no `timestamp`), one H1, `##` sections, relative clickable links.
- If updating, fix any stale claims in the touched sections to current reality (leave-it-cleaner,
  in-file only).

## STAGE 4 — WIRE INDEX

- If a NEW concept: add a grouped **link** to it in `index.md` (link-only — no copied description).
- If an UPDATE: confirm the existing `index.md` link still resolves.

## STAGE 5 — VERIFY (gate G3)

Run VERIFY (from [`references/okf-format.md`](references/okf-format.md)) scoped to the **touched
files** (the concept + `index.md`): lint clean + links resolve. Fix and re-run until green.

## DONE

The concept exists/updated in `BUNDLE_ROOT`, `index.md` links it, touched files lint clean and links
resolve. On first run: bundle + `index.md` + governance rule created. Report: concept path (new or
updated), claims labeled `sourced`/`inferred`, index change, whether the bundle was initialized.
