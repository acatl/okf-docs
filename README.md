# okf-docs

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A Claude Code skill that converts a project's documentation layer into the **OKF (Open Knowledge
Format) bundle format** — one concept per file, minimal frontmatter, source-of-truth linked and never
duplicated — and generates missing docs from ground truth. Stack-agnostic; built to be pulled into
any project and shared with a team.

## Spec reference

Adapts the format (format only, no OKF tooling) from the OKF spec:
<https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md>

## Install

Pull the skill into a project with [vercel-labs/skills](https://github.com/vercel-labs/skills):

```bash
npx skills add acatl/okf-docs
```

It discovers the `skills/<name>/SKILL.md` layout automatically. Or wire it by hand — symlink (live
edits) or copy the skill dir into the consuming project's `.claude/skills/`:

```bash
ln -s /path/to/okf-docs/skills/okf-docs .claude/skills/okf-docs
```

Then invoke it: **"convert the product docs to OKF"**, **"build the docs bundle"**, **"reorganize
docs into one-concept-per-file"**, or point it at any under-documented layer.

## The skills

Three verbs over one shared format contract ([`docs/okf-format.md`](docs/okf-format.md)):

| Skill | Role | Weight |
|-------|------|--------|
| `okf-docs` | **Bulk convert** — turn a pile of existing docs into a bundle. Gated, non-destructive: source-of-truth is linked never reformatted; docs are removed only after live refs are repointed and unique content is captured to the tracker. Has a `preview` mode that proposes the split without writing. | heavy |
| `okf-add` | **Incremental** — add or update ONE concept as you write. Non-destructive (never deletes); creates the bundle + `index.md` + governance rule on first run. The as-you-go path. | light |
| `okf-check` | **Read-only health** — reports format violations, broken/dangling links, orphaned index entries, and source-of-truth drift. Writes nothing; suitable as a CI gate. | read-only |

Parameterized by layer — each runs on `product`, `architecture`, or any doc domain, under `docs/` or
any folder. Continuous enforcement is passive: the emitted `.claude/rules/okf-docs.md` (from
[`templates/okf-docs.rule.md`](templates/okf-docs.rule.md)) keeps new docs in-format without any
invocation.

## Layout

```text
README.md
docs/okf-format.md        canonical OKF format contract (synced into each skill bundle)
templates/                canonical governance-rule template (okf-add / okf-docs emit it)
skills/okf-*/             the three skills (SKILL.md + synced references/ · templates/)
scripts/                  sync-skill-resources.sh (bundle drift guard) + skill-frontmatter check
```

## Contributing & license

See [CONTRIBUTING.md](CONTRIBUTING.md) for commit conventions, skill-authoring rules, and local
checks (`npm run check`). Licensed under [MIT](LICENSE).
