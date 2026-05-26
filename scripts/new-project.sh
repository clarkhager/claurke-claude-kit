#!/bin/bash
# new-project.sh - Interview-driven project setup with type-aware scaffolding
# Usage: bash new-project.sh [project_dir]
#
# Subsumes cowork-os:subfolders for sub-workspace creation.
# Detects existing parent projects (sub-workspace mode) and adjusts behavior accordingly.
#
# Project types:
#   code         - tech stack, .gitignore, .claude/rules/ folder
#   knowledge    - notes/vault style, no scoped rules section
#   meta         - cross-repo coordination, tracked-repos section in CLAUDE.md
#   subworkspace - inherits parent context, no separate git repo

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MEMORY_KIT_DIR="$HOME/.claude/memory-kit"
GITIGNORE_DIR="$KIT_DIR/templates/gitignores"

if [ ! -d "$MEMORY_KIT_DIR" ]; then
  echo "memory-kit not found at $MEMORY_KIT_DIR"
  echo "Run bootstrap.sh first to install both kits."
  exit 1
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() { echo -e "${BLUE}>${NC} $1"; }
print_ok()   { echo -e "${GREEN}✓${NC} $1"; }
print_warn() { echo -e "${YELLOW}!${NC} $1"; }

echo ""
echo "claurke new project setup"
echo "========================="
echo ""

# --- Step 1: Project directory ---
DEFAULT_PROJECTS_ROOT="$HOME/Documents/Claude/Projects"
if [ -n "${1:-}" ]; then
  PROJECT_DIR="$1"
else
  echo "Where should the project live?"
  echo "  Top-level example:  $DEFAULT_PROJECTS_ROOT/<name>"
  echo "  Sub-workspace ex:   $DEFAULT_PROJECTS_ROOT/<existing-project>/<name>"
  echo ""
  read -rp "Project directory: " PROJECT_DIR
fi

# Expand ~ if present
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

PARENT_DIR="$(dirname "$PROJECT_DIR")"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

# --- Step 2: Detect sub-workspace ---
IS_SUBWORKSPACE=false
PARENT_WORKSPACE_NAME=""
if [ -f "$PARENT_DIR/CLAUDE.md" ] || [ -f "$PARENT_DIR/MEMORY.md" ]; then
  IS_SUBWORKSPACE=true
  PARENT_WORKSPACE_NAME="$(basename "$PARENT_DIR")"
  echo ""
  print_step "Detected: parent at $PARENT_DIR is an existing project"
  print_step "$PROJECT_NAME will be a sub-workspace of $PARENT_WORKSPACE_NAME"
fi

# --- Step 3: Project type ---
if [ "$IS_SUBWORKSPACE" = true ]; then
  DEFAULT_TYPE="subworkspace"
else
  DEFAULT_TYPE="knowledge"
fi
echo ""
echo "Project types:"
echo "  code         - tech stack, .gitignore, .claude/rules/ folder"
echo "  knowledge    - notes/vault style (default for top-level)"
echo "  meta         - cross-repo coordination (tracks other repos)"
echo "  subworkspace - inherits parent context (default when parent is a project)"
read -rp "Project type [$DEFAULT_TYPE]: " PROJECT_TYPE
PROJECT_TYPE="${PROJECT_TYPE:-$DEFAULT_TYPE}"

# Validate
case "$PROJECT_TYPE" in
  code|knowledge|meta|subworkspace) ;;
  *)
    echo "Unknown type: $PROJECT_TYPE. Must be one of: code, knowledge, meta, subworkspace."
    exit 1
    ;;
esac

# --- Step 4: Type-specific prompts ---
LANGUAGE=""
TRACKED_REPOS=""
case "$PROJECT_TYPE" in
  code)
    echo ""
    read -rp "Language (python/node/rust/go/other): " LANGUAGE
    LANGUAGE="${LANGUAGE:-other}"
    read -rp "Tech stack (e.g. 'FastAPI + PostgreSQL'): " STACK
    STACK="${STACK:-$LANGUAGE}"
    ;;
  knowledge)
    STACK="knowledge work / notes"
    ;;
  meta)
    echo ""
    read -rp "Repos this project tracks (space-separated, e.g. 'clarkhager/repo1 clarkhager/repo2'): " TRACKED_REPOS
    STACK="meta-project / cross-repo coordination"
    ;;
  subworkspace)
    STACK="sub-workspace of $PARENT_WORKSPACE_NAME"
    ;;
esac

# --- Step 5: Universal interview ---
echo ""
read -rp "What is $PROJECT_NAME? (1-2 sentences for CLAUDE.md): " WHAT_THIS_IS
WHAT_THIS_IS="${WHAT_THIS_IS:-[2-3 sentences. What is this project? What's the core approach? What is it NOT?]}"

read -rp "Immediate next move? (1 sentence for STATUS.md): " NEXT_MOVE
NEXT_MOVE="${NEXT_MOVE:-[Single most important next action. Be specific.]}"

if [ "$IS_SUBWORKSPACE" = true ]; then
  DEFAULT_PRIMER="n"
else
  DEFAULT_PRIMER="Y"
fi
read -rp "Expected duration > 4 weeks? Adds PRIMER.md [Y/n] (default: $DEFAULT_PRIMER): " ADD_PRIMER
ADD_PRIMER="${ADD_PRIMER:-$DEFAULT_PRIMER}"

ORIGIN_STORY=""
if [[ "${ADD_PRIMER}" =~ ^[Yy]$ ]]; then
  read -rp "Origin / why (1 line, or blank to fill in PRIMER.md later): " ORIGIN_STORY
  ORIGIN_STORY="${ORIGIN_STORY:-[How did this project start? What was the first conversation? What was originally proposed that you rejected?]}"
fi

# --- Step 6: Create directory if missing ---
if [ ! -d "$PROJECT_DIR" ]; then
  mkdir -p "$PROJECT_DIR"
  print_ok "Created $PROJECT_DIR"
fi

# --- Step 7: Call memory-kit/deploy.sh with env vars (skips its prompts) ---
export MEMORY_KIT_PROJECT_NAME="$PROJECT_NAME"
export MEMORY_KIT_STACK="$STACK"
export MEMORY_KIT_ADD_PRIMER="$ADD_PRIMER"
export MEMORY_KIT_CONFIG_SETTINGS="Y"
export MEMORY_KIT_AUTO_CREATE_DIR="Y"
export MEMORY_KIT_WHAT_THIS_IS="$WHAT_THIS_IS"
export MEMORY_KIT_NEXT_MOVE="$NEXT_MOVE"
export MEMORY_KIT_ORIGIN_STORY="$ORIGIN_STORY"
export MEMORY_KIT_PROJECT_TYPE="$PROJECT_TYPE"
if [ "$IS_SUBWORKSPACE" = true ]; then
  export MEMORY_KIT_PARENT_WORKSPACE="$PARENT_WORKSPACE_NAME"
  export MEMORY_KIT_PARENT_PATH="$PARENT_DIR"
fi

bash "$MEMORY_KIT_DIR/deploy.sh" "$PROJECT_DIR"

# --- Step 8: Post-deploy type-specific modifications to CLAUDE.md ---
CLAUDE_FILE="$PROJECT_DIR/CLAUDE.md"

remove_scoped_rules_section() {
  # Remove the "## Scoped Rules (technical projects only)" block (the heading through to the next ---)
  python3 - "$CLAUDE_FILE" << 'PYEOF'
import sys, re
path = sys.argv[1]
with open(path) as f:
    text = f.read()
# Match the section starting at "## Scoped Rules" through the next "\n---\n" (or end)
pattern = re.compile(r'## Scoped Rules.*?(?=\n---\n)', re.DOTALL)
new_text = pattern.sub('', text)
with open(path, 'w') as f:
    f.write(new_text)
PYEOF
}

append_parent_workspace_section() {
  cat >> "$CLAUDE_FILE" << EOF

---

## Parent Workspace

This is a sub-workspace of **$PARENT_WORKSPACE_NAME** (\`$PARENT_DIR\`).

- Parent context (parent's CLAUDE.md, MEMORY.md, voice rules) applies in addition to this file.
- Memory in this MEMORY.md is project-scoped. Universal decisions still go in the parent's MEMORY.md.
- Git is handled by the parent repo; do not run \`git init\` in this folder.
- Daily backup is handled by the parent repo's entry in \`~/.claude/scripts/daily-backup.sh\`.
EOF
}

append_tracked_repos_section() {
  cat >> "$CLAUDE_FILE" << EOF

---

## Tracked Repos

This meta-project tracks decisions across these repos:

EOF
  for repo in $TRACKED_REPOS; do
    echo "- [$repo](https://github.com/$repo)" >> "$CLAUDE_FILE"
  done
  cat >> "$CLAUDE_FILE" << 'EOF'

When changes land in any of these repos, capture the decision in MEMORY.md and update STATUS.md if it affects the next move.
EOF
}

case "$PROJECT_TYPE" in
  code)
    # Keep the Scoped Rules section. Copy .gitignore + create .claude/rules/ folder.
    GITIGNORE_SRC="$GITIGNORE_DIR/${LANGUAGE}.gitignore"
    if [ ! -f "$GITIGNORE_SRC" ]; then
      GITIGNORE_SRC="$GITIGNORE_DIR/other.gitignore"
    fi
    if [ -f "$GITIGNORE_SRC" ] && [ ! -f "$PROJECT_DIR/.gitignore" ]; then
      cp "$GITIGNORE_SRC" "$PROJECT_DIR/.gitignore"
      print_ok ".gitignore ($LANGUAGE)"
    fi
    mkdir -p "$PROJECT_DIR/.claude/rules"
    print_ok ".claude/rules/ folder created"
    ;;
  knowledge)
    remove_scoped_rules_section
    print_ok "Removed Scoped Rules section (not a code project)"
    ;;
  meta)
    remove_scoped_rules_section
    append_tracked_repos_section
    print_ok "Removed Scoped Rules section, added Tracked Repos section"
    ;;
  subworkspace)
    remove_scoped_rules_section
    append_parent_workspace_section
    print_ok "Removed Scoped Rules section, added Parent Workspace section"
    ;;
esac

# --- Step 9: Print type-aware next steps ---
echo ""
echo "========================="
echo -e "${GREEN}Setup complete${NC}"
echo ""
echo "Project: $PROJECT_NAME ($PROJECT_TYPE)"
echo "Path: $PROJECT_DIR"
if [ "$IS_SUBWORKSPACE" = true ]; then
  echo "Parent: $PARENT_WORKSPACE_NAME ($PARENT_DIR)"
fi
echo ""
echo "Next steps:"
echo "  1. Review the generated CLAUDE.md, MEMORY.md, STATUS.md"

case "$PROJECT_TYPE" in
  code)
    echo "  2. Add scoped rules to .claude/rules/ as patterns emerge"
    echo "  3. Initialize git and push to a private GitHub repo:"
    echo "       cd $PROJECT_DIR"
    echo "       git init && git add -A && git commit -m 'Initial project'"
    echo "       gh repo create clarkhager/$PROJECT_NAME --private --source=. --remote=origin --push"
    echo "  4. Add to daily backup (edit ~/.claude/scripts/daily-backup.sh):"
    echo "       backup_repo \"$PROJECT_NAME\" \"\$HOME/Documents/Claude/Projects/$PROJECT_NAME\""
    echo "  5. Connect as Cowork workspace"
    ;;
  knowledge)
    echo "  2. Initialize git and push to a private GitHub repo:"
    echo "       cd $PROJECT_DIR"
    echo "       git init && git add -A && git commit -m 'Initial project'"
    echo "       gh repo create clarkhager/$PROJECT_NAME --private --source=. --remote=origin --push"
    echo "  3. Add to daily backup (edit ~/.claude/scripts/daily-backup.sh):"
    echo "       backup_repo \"$PROJECT_NAME\" \"\$HOME/Documents/Claude/Projects/$PROJECT_NAME\""
    echo "  4. Connect as Cowork workspace"
    if [[ "${ADD_PRIMER}" =~ ^[Yy]$ ]]; then
      echo "  5. Fill in PRIMER.md with deeper origin context when you have 20 min"
    fi
    ;;
  meta)
    echo "  2. Verify the Tracked Repos section reflects the right repos"
    echo "  3. Initialize git and push to a private GitHub repo:"
    echo "       cd $PROJECT_DIR"
    echo "       git init && git add -A && git commit -m 'Initial project'"
    echo "       gh repo create clarkhager/$PROJECT_NAME --private --source=. --remote=origin --push"
    echo "  4. Add to daily backup (edit ~/.claude/scripts/daily-backup.sh):"
    echo "       backup_repo \"$PROJECT_NAME\" \"\$HOME/Documents/Claude/Projects/$PROJECT_NAME\""
    echo "  5. Connect as Cowork workspace"
    ;;
  subworkspace)
    echo "  2. Parent ($PARENT_WORKSPACE_NAME) handles git + daily backup automatically; no separate repo needed"
    echo "  3. Connect as Cowork sub-workspace (or open the parent and navigate in)"
    if [[ "${ADD_PRIMER}" =~ ^[Yy]$ ]]; then
      echo "  4. Fill in PRIMER.md when you have 20 min (often optional for sub-workspaces - parent's context covers a lot)"
    fi
    ;;
esac

echo ""
echo "First-session kickoff prompt:"
echo "  New session in $PROJECT_NAME. Read CLAUDE.md, MEMORY.md, and STATUS.md."
echo "  Tell me what you know and what the next move is."
echo ""
