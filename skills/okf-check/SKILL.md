---
name: okf-check
description: Read-only health check for an OKF documentation bundle — reports format violations, broken or dangling links, missing/orphaned index entries, and source-of-truth divergence. Use when asked to "check the docs bundle", "is the bundle in sync", "audit the OKF docs", "lint the bundle", "find stale docs", or as a CI gate on a docs bundle. Never writes — reports findings and points at okf-add / okf-docs to fix. For converting or adding docs, use those skills instead.
license: MIT
metadata:
  author: acatl
  version: "0.1.0" # x-release-please-version
---

# okf-check — read-only OKF bundle health

Verifies one or more bundles against the shared contract
[`references/okf-format.md`](references/okf-format.md). **Never writes** — reports only. To fix a
finding, hand it to `okf-add` (single concept) or `okf-docs` (bulk).

## INPUTS

- `BUNDLE_ROOT[]` — one or more bundle dirs to check (e.g. `docs/product/`, `docs/architecture/`).
- `SOURCES_OF_TRUTH[]` — needed only for CHECK 4 (divergence). Skip that check if not provided.

## CHECKS (report each finding with file + line + severity)

1. **Format** — per the contract: every concept has `type:` frontmatter; **no `title`**, **no
   `timestamp`**; exactly one H1; `index.md` frontmatter is ONLY `okf_version`. (`error`)
2. **Links resolve** — run the VERIFY link-checker (contract §VERIFY) over each `BUNDLE_ROOT`. Any
   relative link that doesn't resolve is a finding. (`error`)
3. **Index coverage** — every concept file is linked from `index.md` (no orphans), and every
   `index.md` link points at an existing file (no dead entries). (`warn` orphan · `error` dead link)
4. **Source-of-truth divergence** — spot-check concrete claims (routes, columns, components, tool
   names) against `SOURCES_OF_TRUTH`. A claim contradicted by code/spec is `diverged`; cite the
   proving path/line. (`warn`; skipped if no `SOURCES_OF_TRUTH`)
5. **One home per fact** — heuristic: flag concepts whose titles/`type` strongly overlap as possible
   duplicate homes for the same fact. (`warn`)

## DANGLING (repo-wide)

If asked to verify after a removal: run the contract's dangling-ref grep (ALL file types, not just
`*.md` — configs/CI/source too) for the removed basename. Any live hit is a finding. (`error`)

## DONE

Report only — no writes. Group findings by severity (`error` blocks, `warn` advises), each with
file · line · what's wrong · which skill fixes it (`okf-add` / `okf-docs`). Exit summary: clean, or N
errors / M warnings. Suitable as a CI gate (non-zero on any `error`).
