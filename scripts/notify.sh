#!/bin/bash
# Shared push-notification helper for claurke scheduled jobs (ntfy).
# Installed to ~/.claude/scripts/notify.sh by claurke-claude-kit bootstrap.sh.
#
# Usage:  source "$HOME/.claude/scripts/notify.sh"
#         notify_send <priority> <title> <tags> <message>
#   priority: min|low|default|high|urgent   (ntfy Priority header)
#   tags:     comma-separated ntfy tags, e.g. rotating_light,floppy_disk
#
# Config lives in ~/.claude/ntfy.conf — per-machine, NEVER committed, NEVER
# clobbered by bootstrap (same contract as backup-repos.conf):
#   NTFY_SERVER=https://ntfy.sh
#   NTFY_TOPIC=your-topic-here
#   NTFY_TOKEN=            # optional; only for reserved/private topics
#
# CONTRACT: notify_send NEVER fails the caller. No config, no network, ntfy down,
# DNS dead — it logs what happened and returns 0. A broken notification channel
# must never take down the job it was built to report on. That inverts the whole
# point: you'd lose the backup AND the alert about losing the backup.
#
# Optional: set NOTIFY_LOG=/path/to/log before calling to record send outcomes.

NOTIFY_CONF="${NOTIFY_CONF:-$HOME/.claude/ntfy.conf}"

notify_send() {
  local priority="${1:-default}"
  local title="${2:-claurke}"
  local tags="${3:-bell}"
  local message="${4:-}"
  local log="${NOTIFY_LOG:-/dev/null}"

  if [[ ! -f "$NOTIFY_CONF" ]]; then
    echo "notify: no config at $NOTIFY_CONF — notification skipped" >> "$log"
    return 0
  fi

  local NTFY_SERVER="" NTFY_TOPIC="" NTFY_TOKEN=""
  # shellcheck disable=SC1090
  source "$NOTIFY_CONF" 2>/dev/null

  if [[ -z "$NTFY_TOPIC" ]]; then
    echo "notify: NTFY_TOPIC unset in $NOTIFY_CONF — notification skipped" >> "$log"
    return 0
  fi
  NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"

  local auth=()
  [[ -n "$NTFY_TOKEN" ]] && auth=(-H "Authorization: Bearer $NTFY_TOKEN")

  # --max-time caps the whole call: a hung ntfy can't wedge a launchd job.
  if curl -fsS --max-time 10 --retry 2 --retry-delay 3 \
      -H "Title: $title" \
      -H "Priority: $priority" \
      -H "Tags: $tags" \
      "${auth[@]}" \
      -d "$message" \
      "${NTFY_SERVER%/}/$NTFY_TOPIC" > /dev/null 2>&1; then
    echo "notify: sent [$priority] $title" >> "$log"
  else
    echo "notify: SEND FAILED [$priority] $title (ntfy unreachable) — job continues" >> "$log"
  fi
  return 0
}
