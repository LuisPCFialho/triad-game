#!/usr/bin/env bash
# Build web export and publish to GitHub Pages (gh-pages branch).
# Run from project root.

set -euo pipefail

GODOT="${GODOT:-C:/Apps/Godot/Godot.exe}"
PROJ="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Re-importing assets"
"$GODOT" --headless --path "$PROJ" --import

echo "==> Exporting Web build"
mkdir -p "$PROJ/export/web"
"$GODOT" --headless --path "$PROJ" --export-release "Web" "$PROJ/export/web/index.html"

echo "==> Publishing to gh-pages"
cd "$PROJ"
WORK=$(mktemp -d)
cp -r export/web/* "$WORK/"
touch "$WORK/.nojekyll"

git worktree add --force -B gh-pages .gh-pages-wt
rm -rf .gh-pages-wt/*
cp -r "$WORK"/* .gh-pages-wt/
cp "$WORK/.nojekyll" .gh-pages-wt/.nojekyll
cd .gh-pages-wt
git add -A
git commit -m "deploy: $(date -Iseconds)" || echo "No changes"
git push -u origin gh-pages
cd "$PROJ"
git worktree remove --force .gh-pages-wt
rm -rf "$WORK"

echo "==> Done. Visit https://luispcfialho.github.io/triad-game/"
