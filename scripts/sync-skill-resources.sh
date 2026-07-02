#!/usr/bin/env bash
# Sync canonical templates/docs into the skill bundles that ship them.
#
# WHY: skills travel as standalone dirs (symlinked into consuming projects, or
# copied/plugin-packaged later), so each skill must carry the inputs it reads at
# runtime — it cannot reach repo-root templates/ or docs/. The repo root stays the
# single source of truth; this script copies it into the bundles and (in check
# mode) fails if a bundle has drifted.
#
#   sync   (default) copy canonical -> bundle
#   check            diff only; exit 1 on any drift (use in pre-push / CI)
#
# Manifest format: "<canonical path>::<bundle path>", both repo-relative.

set -euo pipefail
cd "$(dirname "$0")/.."

# Canonical shared resources -> the skill bundles that ship them. Skills travel
# as standalone dirs, so each must carry the inputs it reads at runtime; repo root
# stays the single source of truth and this fans it out (check mode = drift guard).
MAP=(
  "docs/okf-format.md::skills/okf-docs/references/okf-format.md"
  "docs/okf-format.md::skills/okf-add/references/okf-format.md"
  "docs/okf-format.md::skills/okf-check/references/okf-format.md"
  "templates/okf-docs.rule.md::skills/okf-docs/templates/okf-docs.rule.md"
  "templates/okf-docs.rule.md::skills/okf-add/templates/okf-docs.rule.md"
)

mode="${1:-sync}"
drift=0

for pair in ${MAP[@]+"${MAP[@]}"}; do
  src="${pair%%::*}"
  dst="${pair##*::}"
  [ -f "$src" ] || { echo "⛔ canonical missing: $src" >&2; exit 2; }
  case "$mode" in
    sync)
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      ;;
    check)
      if [ ! -f "$dst" ] || ! cmp -s "$src" "$dst"; then
        echo "⛔ drift: $dst out of sync with $src" >&2
        drift=1
      fi
      ;;
    *)
      echo "usage: $0 [sync|check]" >&2; exit 2;;
  esac
done

if [ "$mode" = check ]; then
  if [ "$drift" -eq 0 ]; then
    echo "✅ skill resource bundles in sync"
  else
    echo "Run: scripts/sync-skill-resources.sh" >&2
    exit 1
  fi
else
  echo "✅ synced ${#MAP[@]} skill resources"
fi
