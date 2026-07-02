# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A repo hosting the **`okf-docs`** Claude Code skill — a gated procedure that converts a project's
documentation layer into the **OKF (Open Knowledge Format) bundle format** (one concept per file,
source-of-truth linked never duplicated) and generates missing docs from ground truth. Stack-agnostic;
pulled into other projects and shared with a team. See [README.md](README.md).

Spec reference (format only, no OKF tooling):
<https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md>

## The skills

Three verbs over one shared contract. Bodies are **telegraphic** (structured, deduplicated, zero
rhetoric); the frontmatter `description` stays natural-language and trigger-rich (the router reads it).

- [`skills/okf-docs`](skills/okf-docs/SKILL.md) — **bulk convert** a pile of docs into a bundle
  (gated migration; `preview` mode proposes the split without writing).
- [`skills/okf-add`](skills/okf-add/SKILL.md) — **incremental**: add/update ONE concept, create the
  bundle on first run. Non-destructive.
- [`skills/okf-check`](skills/okf-check/SKILL.md) — **read-only** bundle health / CI gate.
- **The contract is canonical at [`docs/okf-format.md`](docs/okf-format.md)** (format, links,
  verdict→disposition, VERIFY) and [`templates/okf-docs.rule.md`](templates/okf-docs.rule.md) (the
  emitted governance rule). Skills read *synced copies* under their own `references/` · `templates/`.
  **Edit the canonical repo-root file, then run `scripts/sync-skill-resources.sh`** — never edit a
  bundle copy directly (CI drift-checks it).
- **Keep the skills project-agnostic.** No local paths, product names, or stack commands baked in —
  everything project-specific is a named INPUT resolved at runtime (`LAYER`, `BUNDLE_ROOT`,
  `SOURCES_OF_TRUTH[]`, `FOUNDING_DOCS[]`, `TRACKER`).

## Working agreements

- **Commits: Conventional Commits only (semantic).** `feat:` / `fix:` / `docs:` / `chore:` /
  `refactor:` / `test:` / `style:` / `ci:`. A non-conforming subject is a defect — enforced by a
  husky `commit-msg` hook running commitlint. End commit messages with the `Co-Authored-By` trailer.
- **Never commit to `main`.** Work on a branch; land via a squashed PR to `main`.
- **Skills are self-contained.** A skill reads only inputs bundled in its own dir (`templates/` for
  files it emits, `references/` for files it reads) — never repo-root files at runtime (skills are
  symlinked/copied into other projects). Repo root is canonical; `scripts/sync-skill-resources.sh`
  fans the shared contract into each bundle, and CI drift-checks it (`sync:check`).
- **Versioning is release-managed.** `metadata.version` in `SKILL.md` carries an
  `# x-release-please-version` marker; release-please stamps it. Don't hand-bump it.

## Local checks

Requires **Node ≥ 22.12** (commitlint 21.x needs it; also matches CI).

```bash
npm install   # one-time: installs markdownlint + cspell + husky/commitlint hook
npm run check # markdown lint · spell · bundle drift · skill frontmatter
```

New domain terms flagged by the spell checker go in [`project-words.txt`](project-words.txt).

## Layout

```text
docs/okf-format.md   canonical format contract (synced into each skill's references/)
templates/           canonical governance-rule template (synced into okf-add / okf-docs)
skills/okf-*/        okf-docs · okf-add · okf-check (SKILL.md + synced references/ · templates/)
scripts/             sync + frontmatter guards
```
