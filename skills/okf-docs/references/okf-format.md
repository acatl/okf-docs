# OKF format — the shared contract

The single source of truth for what an OKF bundle *is*. Every `okf-*` skill reads this (bundled as
`references/okf-format.md`); the governance rule template restates its user-facing half. Canonical at
repo root — edit here, then `scripts/sync-skill-resources.sh` fans it into the skill bundles.

## Bundle

- Bundle = a directory; **one concept per `.md`**; file path = concept identity.
- **One home per fact.** A fact lives in exactly one concept; everything else links to it.
- Bundle **links into** its `SOURCES_OF_TRUTH`; it never copies or reformats them.

## Frontmatter (YAML)

- `type:` REQUIRED — short noun (`Charter|Principles|Domain Model|Requirements|Surfaces|Decision Ledger|Non-Goals|Open Questions|Reference|Strategy|Contract|Feature|…`).
- `description:` one line. `tags: [..]`. `status: active|deferred`. `resource:` optional path/url.
- **NO `title`** (the body H1 is the title; a frontmatter `title` trips markdownlint MD025).
- **NO `timestamp`** (git owns history; it rots).

## Body

- Exactly one H1 = title, then `##` sections; prefer tables/lists over prose.

## Links

- **RELATIVE + clickable** (`[text](../x.md)`), never OKF's `/`-rooted form (there is no resolver).
- Code/cross-layer refs are real links too — not code-spans. Keep globs (`apps/*`), commands, and
  code identifiers as code-spans.

## index.md

- Bundle entry; frontmatter is ONLY `okf_version: "0.1"`.
- Grouped **links** to concepts (link-only — no copied descriptions → no drift). No backlinks.

## Knowledge vs. enforcement (load-bearing)

- `SOURCES_OF_TRUTH` are *knowledge / ground truth* any agent or human reads directly: code, config,
  a spec system (e.g. `openspec/specs/`), the bundle itself.
- Tool-specific *enforcement* — ESLint, CI, git hooks, Claude Code `.claude/rules/*`, `.cursorrules` —
  is NOT a source of truth. It *implements* the bundle and is vendor-locked. Never list it in
  `SOURCES_OF_TRUTH`; never make a concept link it as canonical. Enforcement points **up** at the
  bundle, not the reverse.

## VERDICT → DISPOSITION (audit → migration)

| verdict | disposition |
| --- | --- |
| canonical-unique | move into bundle as a concept |
| superseded-by-source | remove + redirect to the source (banner-keep only if rationale has standalone value) |
| historical | redirect banner; founding doc → redirect-map/frozen |
| diverged-misleading | fix to reality; if the design never shipped → redirect stub to what did |
| dead | capture unique content to `TRACKER`, then remove |

## VERIFY (commands)

Replace `<BUNDLE_ROOT>` with the bundle dir. Append any other changed `.md` paths to `EXTRA`.

```bash
# 1. lint (lockfile-pinned binary via the repo script) — add other changed .md after the glob
npm run lint:md -- "<BUNDLE_ROOT>/**/*.md"
# 2. links resolve (run from repo root)
python3 - <<'PY'
import re, os, glob
EXTRA = []  # add other changed .md paths here, e.g. ["docs/index.md"]
for f in glob.glob("<BUNDLE_ROOT>/**/*.md", recursive=True) + EXTRA:
    d = os.path.dirname(f)
    for m in re.finditer(r'\]\(([^)]+)\)', open(f, encoding="utf-8").read()):
        t = m.group(1).split('#')[0].split(' ')[0]
        if not t or t.startswith(('http', 'mailto:', '~')):
            continue
        assert os.path.exists(os.path.normpath(os.path.join(d, t))), f"BROKEN {f} -> {t}"
print("links OK")
PY
# 3. no dangling refs to removed files (ALL file types — configs/CI/source too, not just *.md)
grep -rn "<removed-basename>" . --exclude-dir={node_modules,dist,.nx,.git} | grep -v worktrees | grep -v changes/archive || echo "clean"
```
