# Contributing

Thanks for helping improve okf-docs. This repo is **mostly Markdown** — skills, references, and
docs — so "contributing" is mostly writing clear, machine-readable prose. A few rules keep it
consistent.

## Ground rules

- **Conventional Commits only** (`feat:` / `fix:` / `docs:` / `chore:` / `refactor:` / `test:` /
  `style:` / `ci:`). A non-conforming subject is a defect — enforced by a husky `commit-msg` hook
  running commitlint (`commitlint.config.cjs`); `npm install` wires it up via the `prepare` script.
- **Never commit to `main`.** Work on a branch; land via a squashed PR to `main`.

## Authoring skills

- Skill bodies are **telegraphic** — structured, deduplicated, zero rhetoric, every decision-bearing
  datum kept.
- Frontmatter `description` stays natural-language and trigger-rich (the router reads it).
- Required frontmatter: `name`, `description`, `license` (top-level), plus `metadata.author` and
  `metadata.version` (nested under `metadata:`). CI enforces all five
  (`scripts/check-skill-frontmatter.sh`). `metadata.version` is release-managed — carry the
  `# x-release-please-version` marker and let release-please bump it.

## Bundled resources (drift guard)

Skills are **self-contained**: a skill reads only inputs bundled in its own dir (`templates/`,
`references/`) — never repo-root files at runtime (skills are symlinked/copied into other projects).
Repo root is canonical; bundles are kept in sync by `scripts/sync-skill-resources.sh` (its MAP is
populated once the skill and its shared resources exist). **After editing a canonical file, run it:**

```bash
scripts/sync-skill-resources.sh        # copy canonical → bundles
scripts/sync-skill-resources.sh check  # CI mode: exit 1 on drift
```

## Versioning

Versioning follows [Semantic Versioning](https://semver.org/) and is **fully automated by
[release-please](https://github.com/googleapis/release-please)** — you never bump a version by hand.
Merge normal PRs to `main`; release-please maintains a standing **Release PR** that accumulates the
pending bump + changelog (patch for `fix:`, minor for `feat:`, major for a `!`/`BREAKING CHANGE:`).
Merging that Release PR cuts the release: it bumps `package.json`, regenerates
[`CHANGELOG.md`](CHANGELOG.md), tags, and creates a GitHub Release.

Config: [`release-please-config.json`](release-please-config.json) +
[`.release-please-manifest.json`](.release-please-manifest.json).

## Local checks

Requires **Node ≥ 22.12** (commitlint 21.x needs it; also matches CI). Check with `node -v`.

```bash
npm install      # one-time: installs markdownlint + cspell + husky/commitlint hook
npm run check    # markdown lint · spell · bundle drift · skill frontmatter
```

New domain terms flagged by the spell checker go in [`project-words.txt`](project-words.txt). CI
runs the same checks plus an offline internal-link check on every PR.
