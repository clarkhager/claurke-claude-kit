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

# Installs post-commit/post-merge hooks in personal-overlay-repo that call
# sync-voice-profile.sh whenever canonical voice-profile.md changes.
install_voice_hooks() {
  local kit_dir="$1"
  local overlay_repo="$kit_dir/personal-overlay-repo"
  local hooks_dir="$overlay_repo/.git/hooks"
  local sync_script="$kit_dir/scripts/sync-voice-profile.sh"

  if [ ! -d "$overlay_repo/.git" ]; then
    print_warn "personal-overlay-repo is not a git repo — voice-profile hooks not installed"
    return
  fi

  mkdir -p "$hooks_dir"

  for hook in post-commit post-merge; do
    cat > "$hooks_dir/$hook" <<HOOK
#!/bin/bash
# Auto-installed by bootstrap.sh — regenerates Cowork voice-profile copies on commit/merge
bash "$sync_script" || true
HOOK
    chmod +x "$hooks_dir/$hook"
    print_ok "Hook installed: $hooks_dir/$hook"
  done
}

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

# --- Install a kit-shipped skill helper ---
install_kit_skill() {
  local skill_name="$1"
  local src="$SCRIPT_DIR/skills/$skill_name"
  local dest="$SKILLS_DIR/$skill_name"
  if [ -d "$src" ]; then
    mkdir -p "$SKILLS_DIR"
    rm -rf "$dest"
    cp -r "$src" "$dest"
    print_ok "$skill_name installed to $dest"
  else
    print_warn "$skill_name source not found at $src (kit may be outdated; run git pull)"
  fi
}

# Skills that ship in the plugin manifest but must NOT auto-install on Claude Code.
#
# COWORK_ONLY = any phrase-triggered close-class skill (session-close, session-close-*,
# session-close-wherehouse). These must NOT auto-install on Claude Code — a "goodnight" /
# "session close" phrase would auto-close a worker session mid-task (JAD-24 invariant).
# Standalone tools like linear-ops install everywhere.
#
# The exclusion lives HERE, in the installer — not as a shape change to marketplace.json's
# skills array — because both the Cowork and the Claude Code plugin loaders consume that
# array, so it must stay a plain string array. Add a close-class skill name here to keep it
# Cowork-only.
COWORK_ONLY=("session-close" "session-close-wherehouse")

# --- Install every kit skill listed in the plugin manifest (except COWORK_ONLY) ---
# Reads .claude-plugin/marketplace.json's per-plugin skills arrays and installs each skill,
# so bundled non-namesake skills (spec-shard-with-contracts, ...) are no longer silently
# skipped. Replaces the old hardcoded install_kit_skill "claurke-ops"/"claurke-onboarding"
# pair. python3 is used because it is already a kit dependency (scripts/new-project.sh uses
# the same idiom); jq is not stock macOS and not installed by install.sh.
install_manifest_skills() {
  local manifest="$SCRIPT_DIR/.claude-plugin/marketplace.json"
  if ! command -v python3 >/dev/null; then
    print_warn "python3 not found — no kit skills installed (install python3 and re-run)"
    return
  fi
  if [ ! -f "$manifest" ]; then
    print_warn "marketplace.json not found at $manifest — no kit skills installed (broken kit; run git pull)"
    return
  fi

  # Emit the basename of every skill path across all plugins. Command substitution guarded by
  # `if !` so a parse failure warns loudly instead of silently installing nothing (the exact
  # silent-green bug this fixes); a bare x=$(...) would abort under `set -e` before any check.
  local skills_out
  if ! skills_out=$(python3 - "$manifest" <<'PYEOF'
import sys, json, os
with open(sys.argv[1]) as f:
    data = json.load(f)
for plugin in data.get("plugins", []):
    for skill in plugin.get("skills", []):
        print(os.path.basename(skill.rstrip("/")))
PYEOF
  ); then
    print_warn "marketplace.json parse failed — no kit skills installed (check the manifest)"
    return
  fi

  local skill cowork skip
  while IFS= read -r skill; do
    [ -z "$skill" ] && continue
    skip=0
    # ${arr[@]+"${arr[@]}"} so an emptied COWORK_ONLY doesn't trip `set -u` on bash 3.2.
    for cowork in ${COWORK_ONLY[@]+"${COWORK_ONLY[@]}"}; do
      [ "$skill" = "$cowork" ] && { skip=1; break; }
    done
    if [ "$skip" -eq 1 ]; then
      print_warn "$skill skipped (Cowork-only; not auto-installed on Claude Code)"
      continue
    fi
    install_kit_skill "$skill"
  done <<< "$skills_out"
}

# --- Install the daily backup script + launchd job (personal machines only) ---
# Ships the pull-first daily-backup.sh to ~/.claude/scripts, installs the 02:00
# launchd job, and seeds a per-machine repo list if one isn't already present.
# The repo list (~/.claude/backup-repos.conf) is per-machine and NEVER clobbered,
# so a fresh machine backs up nothing until the list is filled in. That ordering
# matters: the pull-first script lands BEFORE any repo is listed, so a machine
# can never become a divergent second writer on a single-writer repo.
install_daily_backup() {
  local src="$SCRIPT_DIR/scripts/daily-backup.sh"
  local conf_example="$SCRIPT_DIR/scripts/backup-repos.conf.example"
  local scripts_dir="$CLAUDE_DIR/scripts"
  local dest="$scripts_dir/daily-backup.sh"
  local conf="$CLAUDE_DIR/backup-repos.conf"
  local plist="$HOME/Library/LaunchAgents/com.clarkhager.daily-backup.plist"
  local label="com.clarkhager.daily-backup"
  local ntfy_conf="$CLAUDE_DIR/ntfy.conf"
  local watchdog_dest="$scripts_dir/backup-watchdog.sh"
  local watchdog_plist="$HOME/Library/LaunchAgents/com.clarkhager.backup-watchdog.plist"
  local watchdog_label="com.clarkhager.backup-watchdog"

  if [ ! -f "$src" ]; then
    print_warn "daily-backup.sh not found at $src (kit may be outdated; run git pull)"
    return
  fi

  mkdir -p "$scripts_dir" "$CLAUDE_DIR/logs" "$HOME/Library/LaunchAgents"
  cp "$src" "$dest"
  chmod +x "$dest"
  print_ok "daily-backup.sh installed to $dest"

  # Seed the per-machine repo list only if absent — never clobber a real list.
  if [ -f "$conf" ]; then
    print_ok "backup repo list already present at $conf (left untouched)"
  elif [ -f "$conf_example" ]; then
    cp "$conf_example" "$conf"
    print_warn "Seeded placeholder backup list at $conf — EDIT IT, or nothing is backed up."
  else
    print_warn "backup-repos.conf.example missing from kit; no backup list seeded."
  fi

  # --- Push notifications (ntfy) ---
  # notify.sh is the shared helper; any scheduled job can source it. The topic lives
  # in ~/.claude/ntfy.conf, which is per-machine and, like backup-repos.conf, seeded
  # once and never clobbered — re-running bootstrap must not silently repoint your
  # alerts at a placeholder topic and leave you thinking you're covered.
  if [ -f "$SCRIPT_DIR/scripts/notify.sh" ]; then
    cp "$SCRIPT_DIR/scripts/notify.sh" "$scripts_dir/notify.sh"
    chmod +x "$scripts_dir/notify.sh"
    print_ok "notify.sh installed to $scripts_dir/notify.sh"
  else
    print_warn "notify.sh missing from kit — scheduled jobs will run without alerts."
  fi

  if [ -f "$ntfy_conf" ]; then
    print_ok "ntfy config already present at $ntfy_conf (left untouched)"
  elif [ -f "$SCRIPT_DIR/scripts/ntfy.conf.example" ]; then
    cp "$SCRIPT_DIR/scripts/ntfy.conf.example" "$ntfy_conf"
    print_warn "Seeded placeholder ntfy config at $ntfy_conf — SET NTFY_TOPIC, or alerts go nowhere."
  fi

  # --- Dead-man watchdog ---
  # The backup can shout when a repo fails; it cannot shout when it never runs. The
  # watchdog checks the heartbeat at 09:00 and covers exactly that hole.
  if [ -f "$SCRIPT_DIR/scripts/backup-watchdog.sh" ]; then
    cp "$SCRIPT_DIR/scripts/backup-watchdog.sh" "$watchdog_dest"
    chmod +x "$watchdog_dest"
    cat > "$watchdog_plist" <<WPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$watchdog_label</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$watchdog_dest</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>9</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>$CLAUDE_DIR/logs/launchd-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>$CLAUDE_DIR/logs/launchd-stderr.log</string>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
WPLIST
    launchctl unload "$watchdog_plist" 2>/dev/null || true
    if launchctl load "$watchdog_plist" 2>/dev/null; then
      print_ok "launchd job '$watchdog_label' loaded (checks the backup heartbeat at 09:00)"
    else
      print_warn "Could not load watchdog job. Load it with: launchctl load $watchdog_plist"
    fi
  fi

  # Write the launchd plist (generated so paths match this machine's \$HOME).
  cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$label</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$dest</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>$CLAUDE_DIR/logs/launchd-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>$CLAUDE_DIR/logs/launchd-stderr.log</string>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
PLIST
  print_ok "launchd plist written to $plist"

  # Reload the job so the latest plist/script is registered (idempotent).
  launchctl unload "$plist" 2>/dev/null || true
  if launchctl load "$plist" 2>/dev/null; then
    print_ok "launchd job '$label' loaded (runs daily at 02:00)"
  else
    print_warn "Could not load launchd job automatically. Load it with: launchctl load $plist"
  fi
}

# True on a personal machine (populated overlay or an existing backup list).
# Guards personal-only install steps during --update so colleagues running
# --starter never get Clark's launchd job.
is_personal_machine() {
  [ -f "$SCRIPT_DIR/personal/voice-profile.md" ] || [ -f "$CLAUDE_DIR/backup-repos.conf" ]
}

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

  # Refresh kit-shipped skills from the updated kit
  install_manifest_skills

  # Refresh the daily backup script + launchd job (personal machines only)
  if is_personal_machine; then
    echo ""
    print_step "Refreshing daily backup script + launchd job..."
    install_daily_backup
  fi

  # Sync voice-profile copies to Cowork project roots
  echo ""
  print_step "Syncing voice-profile to project roots..."
  bash "$SCRIPT_DIR/scripts/sync-voice-profile.sh" || print_warn "voice-profile sync returned non-zero"

  # Install/refresh git hooks in personal-overlay-repo (so canonical changes auto-sync)
  echo ""
  print_step "Installing voice-profile git hooks in personal-overlay-repo..."
  install_voice_hooks "$SCRIPT_DIR"

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

# --- Install kit-shipped skills ---
echo ""
print_step "Installing kit-shipped skills..."
install_manifest_skills
print_warn "For Cowork: kit-shipped skills may also need manual install via Settings > Plugins. The skill files are at $SKILLS_DIR/"

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
You're in starter mode - the colleague-onboarding path. Recommended next move:

  1. Open Cowork and start a fresh session
  2. Type: "install claurke for me"
     The claurke-onboarding skill will walk you through the interview-driven
     setup (creates your private overlay repo, populates voice profile and
     personal preferences via multi-choice questions, surfaces the manual
     Cowork UI steps).

Or if you'd rather do it manually, see docs/colleague-onboarding.md for the
full command list.
EOF
fi

# --- Daily backup script + launchd job (personal mode only) ---
if [ "$MODE" = "personal" ]; then
  echo ""
  print_step "Installing daily backup script + launchd job..."
  install_daily_backup
fi

# --- Voice profile sync + git hooks ---
echo ""
print_step "Syncing voice-profile to Cowork project roots..."
bash "$SCRIPT_DIR/scripts/sync-voice-profile.sh" || print_warn "voice-profile sync returned non-zero"

echo ""
print_step "Installing voice-profile git hooks in personal-overlay-repo..."
install_voice_hooks "$SCRIPT_DIR"

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
   Verify claurke-ops and claurke-onboarding appear in your installed skills
   (manual install may be needed; the skill files are at $SKILLS_DIR/).
   Install any additional plugins you want active in Cowork.

============================================
For per-project memory setup, when you start a new project:
  bash $SCRIPT_DIR/scripts/new-project.sh
============================================
EOF

echo ""
print_ok "Bootstrap complete."
echo ""
