---
name: okf-docs
description: Convert a project's documentation layer into the OKF (Open Knowledge Format) bundle format, and generate missing docs from ground truth. Use when asked to "convert docs to OKF", "OKF the <product|architecture> docs", "build the docs bundle", "reorganize docs into one-concept-per-file", "migrate docs to the bundle format", or to document an under-documented layer. Parameterized by layer — the same skill runs on product, architecture, or any doc domain, under docs/ or any other folder. Machine-executable procedure with blocking safety gates; not a writing guide.
license: MIT
metadata:
  author: acatl
  version: "0.0.0" # x-release-please-version
---

# okf-docs — generate + convert a doc layer into the OKF bundle

Operates on ONE doc layer per run. Non-destructive by gate. Source-of-truth is
linked, never duplicated or reformatted. The OKF format itself is the shared
contract — [`references/okf-format.md`](references/okf-format.md) (frontmatter, links, verdict→disposition, VERIFY).

**MODES** (resolve with operator):

- `preview` — run STAGE 1–4 only, emit the proposed concept list + disposition, **write nothing**, stop. The on-ramp: see how a blob would split before committing.
- `convert` (default) — full run through STAGE 8.

## Companions

- Adding ONE concept as you write (not migrating a pile) → use `okf-add` instead.
- Checking an existing bundle's health (read-only) → use `okf-check`.

## INPUTS (resolve before STAGE 0; ask operator if absent)

- `LAYER` — the doc domain this run operates on, e.g. `product`, `architecture`, or any other.
- `BUNDLE_ROOT` — target dir for the bundle, e.g. `docs/product/`. Any folder — under `docs/` or elsewhere.
- `SOURCES_OF_TRUTH[]` — where ground truth for this layer lives. Typically some of: the codebase, config files, a spec system if the project uses one (e.g. `openspec/specs/`), and the bundle itself. Pick the ones that actually hold ground truth for `LAYER`; ask the operator when unclear.
- `FOUNDING_DOCS[]` — large multi-job docs to decompose (e.g. a single top-level `docs/<name>.md` that serves many readers/cadences at once).
- `TRACKER` — where captured content lands when a doc is removed (the project's issue/task tracker — GitHub Issues, Jira, Linear, a Kanban MCP, etc.).

## STAGE 0 — SOURCE OF TRUTH (gate G1)

Name `SOURCES_OF_TRUTH[]` explicitly. **GATE: do not proceed until named.** Rule for the whole run: every concept LINKS to its source of truth; it never copies it, and the source is never reformatted by this skill.

**Knowledge vs. enforcement (load-bearing).** `SOURCES_OF_TRUTH` are *knowledge / ground truth* any agent or human can read directly: code, config, a spec system, the bundle itself. Tool-specific *enforcement* mechanisms — ESLint, CI, git hooks, Claude Code `.claude/rules/*`, `.cursorrules`, etc. — are NOT sources of truth: they *implement* the bundle and are vendor-locked by discovery. Never list them in `SOURCES_OF_TRUTH`, and never make a concept link them as canonical. The bundle stays vendor-neutral; enforcement points up at the bundle, not the reverse.

## STAGE 1 — INVENTORY + CLASSIFY

- List every existing doc in scope (`ls`, `grep -rl`).
- Classify each by `reader × change-cadence`, NOT topic: `charter|principles|domain|requirements|surfaces|decision-log|reference|strategy|historical`.
- Flag "N-docs-in-a-trenchcoat": one file serving multiple readers/cadences → split target.

## STAGE 2 — MODE per concept

- `convert` — content exists in a doc.
- `generate` — concept missing; derive in STAGE 5 from `SOURCES_OF_TRUTH` + code + scattered docs. **If a fact is not in ground truth, INTERVIEW the operator — never invent.** Label each generated claim `sourced` or `inferred`.

## STAGE 3 — AUDIT (convert docs; parallelizable via subagents, one per doc group)

FOR each existing doc:

- `cite` = a specific line/path in `SOURCES_OF_TRUTH` (code/spec) proving the claim's status.
- `verdict ∈ {canonical-unique | superseded-by-source | historical | diverged-misleading | dead}` (the contract's VERDICT → DISPOSITION keys).
- **GATE: a verdict without a `cite` is rejected.** Spot-check concrete claims (routes, columns, components, tools) against code.

## STAGE 4 — DESIGN BUNDLE

- Target concept list = classify (STAGE 1) collapsed by `reader × cadence`. **Do NOT over-atomize** (split by distinct reader/cadence, not per paragraph).
- `index.md` = entry. Each concept = one file. One home per fact.
- **PREVIEW gate:** if `MODE == preview`, emit the proposed concept list (each with mode `convert`/`generate`, source doc(s), verdict/disposition) and **STOP here — no writes.**

## STAGE 5 — AUTHOR / DECOMPOSE (apply FORMAT)

Write each concept per the FORMAT block. `convert` = move+reshape existing prose. `generate` = derive from ground truth (STAGE 2 rules). Fix stale claims to current reality as you move them (leave-it-cleaner, in-file only).

## STAGE 6 — MIGRATE (apply DISPOSITION; gates G2–G4)

Per non-canonical doc, apply DISPOSITION. **Blocking preconditions before any delete/rename:**

- G2 (live refs — ALL file types, not just Markdown): `grep -rFn -- "<basename>" . --exclude-dir={node_modules,dist,.nx,.git} | grep -v worktrees | grep -v changes/archive` (fixed-string, from repo root `.`; `worktrees`/`changes/archive` are example immutable/generated paths — use the project's own) → repoint EVERY live ref. Do NOT restrict to `--include=*.md`: live references live in configs, CI workflows, and source comments too (e.g. a governance doc cited from a lint config, a CI workflow, or an ESLint config file).
- G2 (archive provenance — do NOT blanket-filter): run the SAME grep WITHOUT the `changes/archive` filter. `changes/archive/**` is immutable (never edit it), but an archived design that cites the doc is a real inbound link. Do NOT delete the doc blind: leave a redirect **stub** at the old path so the archived provenance link still resolves. Surface archive matches and decide stub-vs-leave per match; never skip them.
- G2: any unique content not in ground truth → CAPTURE to `TRACKER` first (create/update a task), verify it landed, then delete.
- G3: a ref inside a workflow-gated file (e.g. `openspec/specs/**`) → **DO NOT edit directly**; leave as provenance or route through that system's change workflow.
- G4: a `FOUNDING_DOC` with inbound refs above a handful → gut to a `§N → concept` **redirect map** (keep the file) or **freeze** it; do not delete.

## STAGE 7 — VERIFY (gate G5)

Run VERIFY. **GATE: links resolve + zero dangling refs** (the self-contained checks) — plus markdown lint clean *if the target project lints Markdown*. Fix and re-run until green.

## STAGE 8 — GOVERNANCE

Emit the governance rule from the bundled template [`templates/okf-docs.rule.md`](templates/okf-docs.rule.md) to the project's rule location (for Claude Code: `.claude/rules/okf-docs.md`). Fill its `paths:` frontmatter with a YAML list of `<BUNDLE_ROOT>/**/*.md` globs — one per bundle in the project. (`paths:` is the key Claude Code `.claude/rules/*` auto-load on — NOT `globs:`.) The template already encodes the FORMAT block + "source of truth = `SOURCES_OF_TRUTH`, never reformatted by docs work" + "superseded/historical docs carry a redirect banner or are removed, never authored as current behavior." Update it, don't hand-rewrite it.

---

## CONTRACT

FORMAT (frontmatter, body, links, `index.md`), the VERDICT → DISPOSITION table (STAGE 3 → STAGE 6), and the VERIFY commands (STAGE 7) all live in the shared contract: [`references/okf-format.md`](references/okf-format.md). Apply it verbatim; do not restate or diverge.

## DONE

`BUNDLE_ROOT/index.md` + concepts exist and lint clean; every live ref repointed; unique content from deleted docs captured in `TRACKER`; workflow-gated files untouched; founding docs frozen/mapped; the governance rule emitted from `templates/okf-docs.rule.md`. Report: concepts created, docs removed/redirected, refs repointed, captures, deferred (workflow-gated) items.
