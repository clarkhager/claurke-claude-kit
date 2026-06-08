#!/bin/bash
# sync-voice-profile.sh
# Syncs canonical voice-profile.md to per-project Cowork roots as generated copies.
#
# ONE-WAY: edit the canonical file in claurke-kit, NOT the generated copies.
# Canonical: ~/.claude/claurke-kit/personal-overlay-repo/voice-profile.md
#
# Discovery: direct children of ~/Documents/Claude/Projects that contain a CLAUDE.md,
# plus the EXTRAS array below for out-of-tree project roots.
#
# Called by:
#   bootstrap.sh --update          (catch-up on fresh/out-of-sync machines)
#   personal-overlay-repo git hooks (post-commit, post-merge — immediacy on canonical change)
#   Run directly: bash ~/.claude/claurke-kit/scripts/sync-voice-profile.sh

set -euo pipefail

CANONICAL="$HOME/.claude/claurke-kit/personal-overlay-repo/voice-profile.md"
PROJECTS_DIR="$HOME/Documents/Claude/Projects"

# Out-of-tree project roots to include alongside auto-discovered ones.
# Add new out-of-tree roots here; auto-discovery handles ~/Documents/Claude/Projects/*.
EXTRAS=(
  "$HOME/Desktop/jadyly-app"
)

BANNER="<!-- DO NOT EDIT — generated copy from ~/.claude/claurke-kit/personal-overlay-repo/voice-profile.md
     All edits go in the canonical claurke-kit file, not here.
     Regenerated on: bash ~/.claude/claurke-kit/bootstrap.sh --update
     Or automatically via post-commit/post-merge hook in personal-overlay-repo. -->

"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
print_ok()   { echo -e "${GREEN}✓${NC} $1"; }
print_warn() { echo -e "${YELLOW}!${NC} $1"; }
print_step() { echo -e "${BLUE}>${NC} $1"; }

if [ ! -f "$CANONICAL" ]; then
  print_warn "Canonical voice-profile not found at $CANONICAL — sync skipped."
  exit 0
fi

# Build list of target roots: auto-discovered + extras
ROOTS=()
if [ -d "$PROJECTS_DIR" ]; then
  for d in "$PROJECTS_DIR"/*/; do
    if [ -f "${d}CLAUDE.md" ]; then
      ROOTS+=("${d%/}")
    fi
  done
fi
for extra in "${EXTRAS[@]}"; do
  if [ -d "$extra" ]; then
    ROOTS+=("$extra")
  fi
done

if [ ${#ROOTS[@]} -eq 0 ]; then
  print_warn "No project roots found — sync wrote nothing."
  exit 0
fi

print_step "Syncing voice-profile.md to ${#ROOTS[@]} project root(s)..."

for root in "${ROOTS[@]}"; do
  dest="$root/voice-profile.md"

  # Write banner + canonical content (idempotent — overwrites each run)
  { printf '%s' "$BANNER"; cat "$CANONICAL"; } > "$dest"

  # Ensure .gitignore contains voice-profile.md so the copy is never committed
  gitignore="$root/.gitignore"
  if [ -f "$gitignore" ]; then
    if ! grep -qxF "voice-profile.md" "$gitignore"; then
      echo "voice-profile.md" >> "$gitignore"
    fi
  else
    echo "voice-profile.md" > "$gitignore"
  fi

  print_ok "$(basename "$root"): $dest"
done

echo ""
print_ok "Voice profile sync complete (${#ROOTS[@]} roots updated)."
