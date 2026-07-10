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

# JAD-93 §6.2 actuator mechanism 1: the nightly job refuses green on blown memory
# budgets. Scans the repo's claurke memory files (T0/T1/T2) against the JAD-93 §4.3
# tripwires; prints one "file<TAB>words<TAB>budget" line per blown file. Runs in the
# repo's cwd; files that don't exist are skipped, so non-claurke repos are untouched.
# ponytail: CLAUDE.md sits at the Stage-A tripwire (5000w) until JAD-93 M7 lands
# Stage B — drop it to 2500 then. Per-repo overrides only if a project ever diverges.
scan_budgets() {
  local f budget words
  while read -r f budget; do
    [[ -f "$f" ]] || continue
    words=$(wc -w < "$f" | tr -d '[:space:]')
    if [[ "$words" -gt "$budget" ]]; then
      printf '%s\t%s\t%s\n' "$f" "$words" "$budget"
    fi
  done <<'BUDGETS'
CLAUDE.md 5000
STATUS.md 2500
MEMORY.md 4500
PRIMER.md 1500
connectors.md 600
BUDGETS
}

backup_repo() {
  local name="$1"
  local path="$2"
  local pull_first="$3"
  cd "$path" 2>/dev/null || { echo "$name: path not found at $path" >> "$LOG"; return; }
  # This script commits on the current branch and pushes main; anything else checked
  # out means a backup would land on (or push from) the wrong ref. Skip, don't guess.
  local branch
  branch="$(git symbolic-ref --short HEAD 2>/dev/null)"
  if [[ "$branch" != "main" ]]; then
    echo "$name: on '${branch:-detached HEAD}', not main — skipped" >> "$LOG"
    return
  fi
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
  # Budget check (JAD-93 §6.2): write/update the tracked warning file and flag the
  # commit subject on any blown budget; delete the warning file once budgets pass
  # (deletion is the receipt — File Map v2's prune-first rule keys off its existence).
  local subject="Daily auto-backup: $(date +%Y-%m-%d)"
  local blown_lines
  blown_lines="$(scan_budgets)"
  if [[ -n "$blown_lines" ]]; then
    local summary="" bf bw bb
    while IFS=$'\t' read -r bf bw bb; do
      summary="${summary:+$summary, }$bf ${bw}w/${bb}w"
    done <<< "$blown_lines"
    {
      echo "# MEMORY-WARNINGS — memory-file budgets blown"
      echo ""
      echo "Written by daily-backup.sh on $(date +%Y-%m-%d) (JAD-93 §6.2 actuator; tracked on purpose)."
      echo "Prune-first rule (File Map v2): while this file exists, the prune runs BEFORE any other"
      echo "work in the next session, on any surface. This file is deleted by the same script once"
      echo "all budgets pass — deletion is the receipt."
      echo ""
      while IFS=$'\t' read -r bf bw bb; do
        echo "- $bf: ${bw} words (budget ${bb})"
      done <<< "$blown_lines"
    } > MEMORY-WARNINGS.md
    subject="Daily auto-backup: $(date +%Y-%m-%d) [BUDGET BLOWN: $summary]"
    echo "$name: BUDGET BLOWN — $summary" >> "$LOG"
  elif [[ -f MEMORY-WARNINGS.md ]]; then
    rm -f MEMORY-WARNINGS.md
    echo "$name: budgets pass — MEMORY-WARNINGS.md cleared" >> "$LOG"
  fi
  if [[ -n $(git status --porcelain) ]]; then
    if ! git add -A >> "$LOG" 2>&1; then
      echo "$name: git add FAILED — not pushed" >> "$LOG"
      return
    fi
    if ! git commit -m "$subject" >> "$LOG" 2>&1; then
      echo "$name: git commit FAILED — not pushed" >> "$LOG"
      return
    fi
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
