#!/bin/bash
# Daily auto-backup for Clark's critical repos.
# Commits and pushes pending changes in each repo listed in the per-machine
# config file (~/.claude/backup-repos.conf). Installed by claurke-claude-kit
# bootstrap.sh; runs at 02:00 via the com.clarkhager.daily-backup launchd job.
#
# Config format (one repo per line):  name | path | pull_first
#   pull_first=true  -> repo has a remote/server writer (e.g. Helmut). Pull its
#                       commits ff-only before committing local edits; on real
#                       divergence, skip the repo rather than commit on top and
#                       make it worse.
#   pull_first=false -> normal repo: just commit + push local changes (default).

CONF="${BACKUP_REPOS_CONF:-$HOME/.claude/backup-repos.conf}"
LOG=~/.claude/logs/daily-backup-$(date +%Y%m%d).log
mkdir -p ~/.claude/logs

# Trim leading/trailing whitespace without collapsing internal spaces
# (repo paths contain spaces, e.g. "Under the Boardwalk").
trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

backup_repo() {
  local name="$1"
  local path="$2"
  local pull_first="$3"
  cd "$path" 2>/dev/null || { echo "$name: path not found at $path" >> "$LOG"; return; }
  # Single-writer repos (Helmut writes server-side): pull its commits before adding
  # local hand-edits, so laptop and origin never drift. ff-only: on real divergence,
  # skip the backup rather than commit on top and make it worse.
  if [[ "$pull_first" == "true" ]]; then
    if git pull --ff-only origin main >> "$LOG" 2>&1; then
      echo "$name: pulled (ff-only)" >> "$LOG"
    else
      echo "$name: pull --ff-only FAILED (divergence) — skipped to avoid drift" >> "$LOG"
      return
    fi
  fi
  if [[ -n $(git status --porcelain) ]]; then
    git add -A
    git commit -m "Daily auto-backup: $(date +%Y-%m-%d)" >> "$LOG" 2>&1
    git push origin main >> "$LOG" 2>&1 && echo "$name: pushed" >> "$LOG" || echo "$name: push FAILED" >> "$LOG"
  else
    echo "$name: no changes" >> "$LOG"
  fi
}

echo "=== Daily backup: $(date) ===" >> "$LOG"

if [[ ! -f "$CONF" ]]; then
  echo "config not found at $CONF — nothing backed up. Copy backup-repos.conf.example to $CONF and edit it." >> "$LOG"
  echo "=== Done: $(date) ===" >> "$LOG"
  exit 0
fi

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"                          # strip trailing comments
  [[ -z "${line//[[:space:]]/}" ]] && continue # skip blank lines
  IFS='|' read -r r_name r_path r_pull <<< "$line"
  r_name="$(trim "$r_name")"
  r_path="$(trim "$r_path")"
  r_pull="$(trim "$r_pull")"
  [[ -z "$r_name" || -z "$r_path" ]] && continue
  r_path="${r_path/#\~/$HOME}"                  # expand a leading ~
  backup_repo "$r_name" "$r_path" "$r_pull"
done < "$CONF"

echo "=== Done: $(date) ===" >> "$LOG"
