#!/bin/bash
# Sync ~/.agents_skills/ → ~/.hermes/skills/
# Hermes uses Path.rglob() which doesn't follow symlinks, so it needs a real copy.
set -e

SOURCE="$HOME/.agents_skills/"
TARGET="$HOME/.hermes/skills/"

echo "Syncing skills to Hermes..."
rsync -av --delete \
  --exclude='.*' \
  --exclude='sync-to-hermes.sh' \
  "$SOURCE" "$TARGET"
echo "Done. Hermes now has $(ls "$TARGET" | grep -v '^\.' | wc -l) skills."