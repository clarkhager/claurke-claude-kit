#!/bin/bash
# install-humanizer.sh - Detect the humanizer skill, or guide installation
# Checks Claude Code install paths AND Cowork plugin paths (which are
# session-scoped under local-agent-mode-sessions/skills-plugin/).

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Static paths to check first
HUMANIZER_PATHS=(
  "$HOME/.claude/skills/humanizer"
  "$HOME/.claude/plugins/anthropic-skills/skills/humanizer"
  "$HOME/.claude/plugins/cache/anthropic-skills"
  "$HOME/Library/Application Support/Claude/skills/humanizer"
)

FOUND=false
FOUND_AT=""

for p in "${HUMANIZER_PATHS[@]}"; do
  if [ -e "$p" ]; then
    FOUND=true
    FOUND_AT="$p"
    break
  fi
done

# If not found yet, check Cowork's session-scoped plugin paths via glob expansion.
# Path pattern: ~/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin/<account_uuid>/<session_uuid>/skills/humanizer
if [ "$FOUND" = false ]; then
  COWORK_BASE="$HOME/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin"
  if [ -d "$COWORK_BASE" ]; then
    # Use shell glob expansion; nullglob protects against the literal pattern if no match
    shopt -s nullglob 2>/dev/null || true
    for p in "$COWORK_BASE"/*/*/skills/humanizer; do
      if [ -d "$p" ]; then
        FOUND=true
        FOUND_AT="$p"
        break
      fi
    done
    shopt -u nullglob 2>/dev/null || true
  fi
fi

if [ "$FOUND" = true ]; then
  echo -e "${GREEN}✓${NC} humanizer skill detected at $FOUND_AT"
  exit 0
fi

echo -e "${YELLOW}!${NC} humanizer skill not detected at standard paths."
echo ""
echo "The Voice rule in CLAUDE.md requires the humanizer skill as a final pass on drafted content."
echo "Without it installed, the voice-rule pass silently won't run."
echo ""
echo "To install:"
echo "  Cowork:      Settings > Plugins > install the Anthropic Skills bundle"
echo "  Claude Code: claude plugin install anthropic-skills"
echo "               (or place skill at ~/.claude/skills/humanizer/)"
echo "  Direct:      npx skills add anthropics/skills --skill humanizer"
echo ""
echo "Paths checked:"
for p in "${HUMANIZER_PATHS[@]}"; do
  echo "  - $p"
done
echo "  - \$HOME/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin/*/*/skills/humanizer (Cowork glob)"
echo ""
