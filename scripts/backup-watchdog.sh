#!/bin/bash
# Dead-man watchdog for daily-backup.sh.
# Installed by claurke-claude-kit bootstrap.sh; runs at 09:00 via the
# com.clarkhager.backup-watchdog launchd job.
#
# WHY THIS EXISTS: daily-backup.sh can notify you when a repo FAILS, but it
# cannot notify you when it never runs at all — a dead job sends nothing, and
# silence is indistinguishable from success. So the backup writes a heartbeat
# on completion and this job checks the heartbeat's age. No heartbeat, or a
# stale one, means the 02:00 run died or never fired.
#
# Threshold is 26h, not 24h: the laptop may be asleep at 02:00, in which case
# launchd fires the job on wake, and the heartbeat legitimately drifts a couple
# of hours later each day. 26h absorbs that drift without crying wolf.
#
# Turtles note: nothing watches the watchdog. That's the accepted floor — a
# machine so dead that neither launchd job fires is a machine you'll notice.

HEARTBEAT="$HOME/.claude/logs/.daily-backup-heartbeat"
LOG=~/.claude/logs/backup-watchdog-$(date +%Y%m%d).log
STALE_AFTER=$((26 * 60 * 60))
mkdir -p ~/.claude/logs

# shellcheck source=/dev/null
source "$HOME/.claude/scripts/notify.sh" 2>/dev/null || {
  echo "$(date): notify.sh missing — watchdog cannot alert" >> "$LOG"
  exit 1
}
export NOTIFY_LOG="$LOG"

now=$(date +%s)

if [[ ! -f "$HEARTBEAT" ]]; then
  echo "$(date): NO HEARTBEAT at $HEARTBEAT — backup has never completed" >> "$LOG"
  notify_send high "Daily backup: NO HEARTBEAT" rotating_light,skull \
"daily-backup.sh has never completed on this machine.
No heartbeat file at $HEARTBEAT.
Check: launchctl list | grep daily-backup"
  exit 0
fi

last=$(cut -d' ' -f1 < "$HEARTBEAT" 2>/dev/null | tr -d '[:space:]')
if ! [[ "$last" =~ ^[0-9]+$ ]]; then
  echo "$(date): heartbeat unreadable ('$last')" >> "$LOG"
  notify_send high "Daily backup: heartbeat corrupt" rotating_light \
"Heartbeat file exists but holds no valid timestamp. Backup state unknown."
  exit 0
fi

age=$(( now - last ))
hours=$(( age / 3600 ))

if (( age > STALE_AFTER )); then
  echo "$(date): STALE heartbeat — ${hours}h old" >> "$LOG"
  notify_send high "Daily backup DID NOT RUN" rotating_light,skull \
"Last successful backup completed ${hours}h ago ($(date -r "$last" '+%a %b %d %H:%M')).
The 02:00 job has not completed since.
Check: launchctl list | grep daily-backup
Then:  bash ~/.claude/scripts/daily-backup.sh"
else
  echo "$(date): OK — heartbeat ${hours}h old" >> "$LOG"
fi
