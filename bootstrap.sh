#!/bin/bash
# bootstrap.sh - Install Clark Hager's full Claude workflow on a new machine
# Usage: bash bootstrap.sh [--starter | --update]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
RULES_KIT_DIR="$CLAUDE_DIR/rules-kit"
MEMORY_KIT_DIR="$CLAUDE_DIR/memory-kit"
SKILLS_DIR="$CLAUDE_DIR/skills"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() { echo -e "${BLUE}>${NC} $1"; }
print_ok()   { echo -e "${GREEN}✓${NC} $1"; }
print_warn() { echo -e "${YELLOW}!${NC} $1"; }

usage() {
  cat <<EOF
Usage: bash bootstrap.sh [--starter | --update | --help]

Modes:
  (no flag)     Full personal sync. Installs both kits, sets up personal overlay.
  --starter     Skeleton install for colleagues. Skips personal identity overlay.
  --update      Run check-updates on both kits, redeploy if needed.
  --help        This message.
EOF
}

MODE="personal"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --starter) MODE="starter"; shift ;;
    --update)  MODE="update";  shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1"; usage; exit 1 ;;
  esac
done

echo ""
echo "claurke-claude-kit bootstrap"
echo "============================="
echo "Mode: $MODE"
echo ""

# --- Prereq check ---
print_step "Checking prerequisites..."
command -v git >/dev/null || { echo "git not found. Install git first."; exit 1; }
command -v gh >/dev/null || print_warn "gh CLI not found. Clones will use https. Install gh for SSH cloning."
print_ok "Prereqs OK"

# --- Update mode: pull latest and exit ---
if [ "$MODE" = "update" ]; then
  echo ""
  print_step "Updating rules-kit..."
  if [ -d "$RULES_KIT_DIR/.git" ]; then
    bash "$RULES_KIT_DIR/check-updates.sh" || print_warn "rules-kit update returned non-zero"
  else
    print_warn "rules-kit not installed. Run without --update first."
  fi

  echo ""
  print_step "Updating memory-kit..."
  if [ -d "$MEMORY_KIT_DIR/.git" ]; then
    bash "$MEMORY_KIT_DIR/check-updates.sh" || print_warn "memory-kit update returned non-zero"
  else
    print_warn "memory-kit not installed. Run without --update first."
  fi

  echo ""
  print_step "Updating claurke-claude-kit (this repo)..."
  git -C "$SCRIPT_DIR" pull --ff-only origin main || print_warn "claurke-claude-kit update failed"

  # Refresh claurke-ops skill from the updated kit
  if [ -d "$SCRIPT_DIR/skills/claurke-ops" ]; then
    mkdir -p "$SKILLS_DIR"
    rm -rf "$SKILLS_DIR/claurke-ops"
    cp -r "$SCRIPT_DIR/skills/claurke-ops" "$SKILLS_DIR/"
    print_ok "claurke-ops skill refreshed"
  fi

  echo ""
  print_ok "Updates done."
  exit 0
fi

# --- Clone the two kits if not present ---
mkdir -p "$CLAUDE_DIR"

clone_kit() {
  local repo="$1"
  local dest="$2"
  local name="$3"

  if [ -d "$dest/.git" ]; then
    print_ok "$name already cloned at $dest"
  else
    print_step "Cloning $name to $dest..."
    if command -v gh >/dev/null; then
      gh repo clone "clarkhager/$repo" "$dest"
    else
      git clone "https://github.com/clarkhager/$repo.git" "$dest"
    fi
    print_ok "$name cloned"
  fi
}

clone_kit "claurke-rules-kit"  "$RULES_KIT_DIR"  "rules-kit"
clone_kit "claurke-memory-kit" "$MEMORY_KIT_DIR" "memory-kit"

# --- Deploy rules-kit globally ---
echo ""
print_step "Deploying rules-kit at the global level..."
bash "$RULES_KIT_DIR/deploy.sh" --global

# --- Install claurke-ops skill (shipped with this kit) ---
echo ""
print_step "Installing claurke-ops skill..."
if [ -d "$SCRIPT_DIR/skills/claurke-ops" ]; then
  mkdir -p "$SKILLS_DIR"
  rm -rf "$SKILLS_DIR/claurke-ops"
  cp -r "$SCRIPT_DIR/skills/claurke-ops" "$SKILLS_DIR/"
  print_ok "claurke-ops installed to $SKILLS_DIR/claurke-ops"
  print_warn "For Cowork: claurke-ops may also need manual install via Settings > Plugins. The skill files are at $SKILLS_DIR/claurke-ops/"
else
  print_warn "claurke-ops source not found at $SCRIPT_DIR/skills/claurke-ops (kit may be outdated; run git pull)"
fi

# --- Skill check ---
echo ""
print_step "Checking humanizer skill..."
bash "$SCRIPT_DIR/scripts/install-humanizer.sh" || true

# --- MCP setup notes ---
echo ""
print_step "MCP setup notes..."
bash "$SCRIPT_DIR/scripts/setup-mcps.sh" || true

# --- Personal overlay (skip in starter mode) ---
echo ""
if [ "$MODE" = "personal" ]; then
  print_step "Personal overlay setup..."
  if [ -d "$SCRIPT_DIR/personal" ] && [ "$(ls -A "$SCRIPT_DIR/personal" 2>/dev/null | grep -v README.md)" ]; then
    print_ok "Personal overlay already populated at $SCRIPT_DIR/personal"
  else
    cat <<EOF
Personal overlay is empty. To populate:
  1. Copy templates into the overlay:
       cp personal/templates/voice-profile-template.md         personal/voice-profile.md
       cp personal/templates/personal-preferences-template.md  personal/personal-preferences.md
       cp personal/templates/mcp-list-template.md              personal/mcp-list.md
       cp personal/templates/skills-list-template.md           personal/skills-list.md
  2. Edit each file with your specific content.
  3. voice-profile.md is canonical: rules-kit's Voice section loads it by reference at draft time.
  4. personal-preferences.md is the source you paste into Settings > General > Instructions for Claude.
  5. The personal/ directory is gitignored. For multi-machine sync, keep it in a separate private repo or gist.
  6. See docs/personal-overlay.md and docs/operating-manual.md section 1 (Layering model) for the full pattern.
EOF
  fi
else
  print_step "Starter mode: skipping personal overlay"
  cat <<EOF
To make this kit yours:
  1. Fork the three repos: claurke-rules-kit, claurke-memory-kit, claurke-claude-kit
  2. Update bootstrap.sh and scripts to reference your forks instead of clarkhager/*
  3. Customize the rules in your fork of rules-kit if needed
  4. Create your own personal/ overlay with your voice profile, personal preferences, and identity files
  5. See docs/personal-overlay.md, docs/operating-manual.md section 1, and docs/how-i-actually-use-this.md for guidance
EOF
fi

# --- Cowork-specific manual steps ---
echo ""
echo "============================================"
echo "Cowork-specific manual steps (not scriptable):"
echo "============================================"
cat <<EOF

1. Open Cowork app > Settings > Cowork > Global Instructions
   Paste the contents of $CLAUDE_DIR/CLAUDE.md
   Save.

2. Open Cowork app > Settings > General > Instructions for Claude
   Paste the contents of $SCRIPT_DIR/personal/personal-preferences.md
   (Or copy from personal/templates/personal-preferences-template.md and fill in)
   Save.

3. Open Cowork app > Settings > Connectors
   Connect the MCPs you use per your personal mcp-list.md.
   Always-install for any user: Gmail, Slack, Notion, GitHub, Atlassian/Jira,
   Postman, Claude in Chrome, PDF Viewer, Context7.
   These connections are account-bound and can't be scripted.

4. Open Cowork app > Settings > Plugins
   Verify the Anthropic Skills bundle is installed (for humanizer skill).
   Verify claurke-ops appears in your installed skills (manual install may be
   needed; the skill files are at $SKILLS_DIR/claurke-ops/).
   Install any additional plugins you want active in Cowork.

============================================
For per-project memory setup, when you start a new project:
  bash $SCRIPT_DIR/scripts/new-project.sh /path/to/project
============================================
EOF

echo ""
print_ok "Bootstrap complete."
echo ""
