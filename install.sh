#!/bin/bash
# install.sh - One-line installer for the claurke system
# Usage: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/clarkhager/claurke-claude-kit/main/install.sh)"
#
# This script handles everything needed to bring a new machine to the point
# where the Cowork-driven onboarding can take over:
# - Installs Homebrew (macOS) if missing
# - Installs git and gh CLI if missing
# - Authenticates gh with the user's GitHub account
# - Clones the claurke kit
# - Runs bootstrap.sh --starter to deploy rules + install skills
#
# After this finishes, the user opens Cowork and says "install claurke for me"
# and the claurke-onboarding skill drives the rest of the setup.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

print_step() { echo -e "${BLUE}>${NC} $1"; }
print_ok()   { echo -e "${GREEN}✓${NC} $1"; }
print_warn() { echo -e "${YELLOW}!${NC} $1"; }
print_err()  { echo -e "${RED}✗${NC} $1"; }

echo ""
echo "================================================="
echo -e "  ${BOLD}claurke - one-step installer${NC}"
echo "================================================="
echo ""
echo "This will install:"
echo "  - Homebrew (if not already on your Mac)"
echo "  - git and gh (GitHub CLI), if needed"
echo "  - The claurke kit to ~/.claude/claurke-kit"
echo "  - Two helper skills that work inside Cowork"
echo ""
echo -e "${BOLD}After this finishes${NC}, open Cowork and type:"
echo -e "  ${BOLD}install claurke for me${NC}"
echo ""
echo "The Cowork skill takes it from there - asks you a few"
echo "interview questions, sets up your personal voice profile,"
echo "and walks you through the final Cowork settings."
echo ""
read -p "Ready to proceed? [Y/n] " -r REPLY
echo ""
if [[ -n "${REPLY:-}" ]] && [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
  echo "Aborted. Re-run when you're ready."
  exit 0
fi

# --- Detect OS ---
OS=$(uname -s)
if [ "$OS" != "Darwin" ] && [ "$OS" != "Linux" ]; then
  print_err "This installer supports macOS and Linux only."
  echo "On Windows, use WSL or follow the manual install steps at:"
  echo "  https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/colleague-onboarding.md"
  exit 1
fi

# --- Step 1: Install Homebrew (macOS only) ---
if [ "$OS" = "Darwin" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    print_step "Installing Homebrew (the macOS package manager)..."
    echo "  Homebrew is what installs git and gh below. It's the standard"
    echo "  way to install developer tools on Mac."
    echo ""
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for this session
    if [ -x "/opt/homebrew/bin/brew" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    print_ok "Homebrew installed"
  else
    print_ok "Homebrew already installed"
  fi
fi

# --- Step 2: Install git ---
if ! command -v git >/dev/null 2>&1; then
  print_step "Installing git..."
  if [ "$OS" = "Darwin" ]; then
    brew install git
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y git
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y git
  else
    print_err "Cannot auto-install git on this system."
    echo "Please install git manually, then re-run this installer."
    exit 1
  fi
  print_ok "git installed"
else
  print_ok "git already installed"
fi

# --- Step 3: Install gh CLI ---
if ! command -v gh >/dev/null 2>&1; then
  print_step "Installing GitHub CLI (gh)..."
  if [ "$OS" = "Darwin" ]; then
    brew install gh
  elif command -v apt-get >/dev/null 2>&1; then
    type -p curl >/dev/null || sudo apt-get install -y curl
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update && sudo apt-get install -y gh
  else
    print_warn "Cannot auto-install gh CLI on this system."
    echo "Please install gh manually from https://cli.github.com/ then re-run this installer."
    exit 1
  fi
  print_ok "gh CLI installed"
else
  print_ok "gh CLI already installed"
fi

# --- Step 4: Authenticate gh ---
if ! gh auth status >/dev/null 2>&1; then
  echo ""
  print_step "Logging in to GitHub..."
  echo "This opens your browser so you can authorize gh. Follow the prompts."
  echo "If you don't have a GitHub account yet, go to https://github.com/signup first."
  echo ""
  gh auth login --web --git-protocol https
  print_ok "GitHub login complete"
else
  print_ok "gh CLI already authenticated"
fi

# --- Step 5: Clone the kit ---
KIT_DIR="$HOME/.claude/claurke-kit"
if [ -d "$KIT_DIR/.git" ]; then
  print_warn "claurke-kit already exists at $KIT_DIR"
  echo "  Updating to latest..."
  git -C "$KIT_DIR" pull --ff-only origin main || print_warn "git pull failed - kit may have local modifications. Continuing with existing version."
else
  print_step "Cloning the claurke kit to $KIT_DIR..."
  mkdir -p "$(dirname "$KIT_DIR")"
  gh repo clone clarkhager/claurke-claude-kit "$KIT_DIR"
  print_ok "claurke kit cloned"
fi

# --- Step 6: Run bootstrap in starter mode ---
echo ""
print_step "Running bootstrap (starter mode)..."
echo "  This deploys the behavioral rules, installs the helper skills,"
echo "  and prints the manual Cowork settings you'll do next."
echo ""
bash "$KIT_DIR/bootstrap.sh" --starter

# --- Done ---
echo ""
echo "================================================="
echo -e "  ${GREEN}${BOLD}Install complete!${NC}"
echo "================================================="
echo ""
echo -e "${BOLD}What just happened:${NC}"
echo "  - The behavioral rules are now at ~/.claude/CLAUDE.md"
echo "  - Two helper skills are installed: claurke-ops and claurke-onboarding"
echo "  - The full kit lives at $KIT_DIR"
echo ""
echo -e "${BOLD}Your next move:${NC}"
echo ""
echo "  1. Open Cowork"
echo "  2. Start a fresh session"
echo -e "  3. Type: ${BOLD}install claurke for me${NC}"
echo ""
echo "The Cowork skill takes it from there - asks you a few questions,"
echo "sets up your voice profile, and walks you through the last steps."
echo ""
echo "Want to read first?"
echo "  https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/colleague-onboarding.md"
echo ""
