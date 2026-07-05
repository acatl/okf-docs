---
paths:
  # One glob per OKF bundle root in this project. Examples:
  # - "docs/product/**/*.md"
  # - "docs/architecture/**/*.md"
  - "<BUNDLE_ROOT>/**/*.md"
---

# OKF documentation bundles

## Rule

Durable project knowledge lives in OKF bundles — one concept per markdown file, minimal YAML
frontmatter, relative clickable links. These bundles are the canonical, **vendor-neutral**
knowledge. They are *enforced* (not defined) by linters, CI, git hooks, and these `.claude/rules/*` —
never the reverse.

## Source of truth

- **Current feature/capability behavior** → the project's spec system, if it has one (e.g.
  `openspec/specs/`). Bundles link into it; **never reformat it into OKF**.
- **How the system is built** → the architecture bundle (start at its `index.md`).
- **What the product is / why** → the product bundle (start at its `index.md`).
- **Database schema** → the ORM entities / migrations (wherever schema is actually defined).
- **Knowledge is portable** (plain markdown under the bundle root, any agent reads it).
  **Enforcement is tool-specific** (linters, CI, `.claude/rules/*`) and is NOT a documentation
  source of truth.

## Concept file format

- One concept per `.md`; the file path is the concept's identity.
- Frontmatter: `type:` REQUIRED; plus `description`, `tags`, `status: active|deferred`, optional
  `resource`. **No `title`** (the body H1 is the title; a frontmatter `title` trips markdownlint
  MD025). **No `timestamp`** (git owns history).
- Body: exactly one H1, then `##` sections; prefer tables/lists over prose.
- Links: **relative + clickable**. A bundle concept links to code/config, the spec system, ADRs, and
  other concepts (its own bundle or a sibling bundle). It does **not** link the frozen/redirect
  founding docs.
- `index.md`: the bundle entry; frontmatter is only `okf_version: "0.1"`; grouped **links** to
  concepts (link-only — no copied descriptions, which drift). No backlinks.

## Don't

- **Don't author current behavior** in a catch-all `docs/*` file or a new top-level doc — behavior
  lives in the spec system; durable knowledge lives in the bundles.
- **Don't reformat the spec system** into OKF — link into it.
- **Don't add a frontmatter `title` or `timestamp`** to a concept.
- **Don't link a bundle concept to a frozen/redirect founding doc** — point at the canonical source
  or the owning concept.
- **Don't treat `.claude/rules/*` (or any tool config) as a knowledge source of truth** — they
  enforce the bundles; vendor-neutral knowledge does not depend on them.

## Building / maintaining a bundle

- **Bulk convert** a pile of docs into a bundle → the `okf-docs` skill (gated migration).
- **Add or update one concept** as you go → the `okf-add` skill (incremental, non-destructive).
- **Check a bundle's health** (format, links, source-of-truth drift) → the `okf-check` skill
  (read-only).
