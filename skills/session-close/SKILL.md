---
name: session-close
description: |
  Universal session-close protocol for any claurke project without a dedicated close skill. Updates STATUS.md with a session summary and next move, applies the three-category memory write protocol to MEMORY.md, proposes gotcha candidates for approval, refreshes PRIMER.md only when load-bearing facts changed. Project-agnostic: reads the project's CLAUDE.md for overrides. Trigger whenever Clark says "session close", "close it out", "I'm done for now", "let's call it", "goodnight", "that's it for today", "save context", "save everything", or signals leaving, tired, or switching - in ANY project without its own session-close skill (Home Assistant, BizzaBrain, claurke, new projects). Do NOT trigger for Wayfinder/Bizzabo Academy (session-close-wayfinder) or Actually/jadyly-app (session-close-actually). Do NOT trigger on "wrap up", "daily wrap", "session log" (daily-wrap). Err toward triggering in uncovered projects - better to run and capture nothing than skip and lose context.
---

# Session Close - Universal Protocol

You're closing a Cowork or Claude Code session in a claurke project. The goal: the next session starts with everything this session knew. This is the generic base protocol - it works in any project with claurke memory files (CLAUDE.md, MEMORY.md, STATUS.md, optionally PRIMER.md).

This is not a ceremony. It's a checklist. Run it fast and get Clark out the door.

**Routing note:** If you're in a Wayfinder / Bizzabo Academy session, stop and use `session-close-wayfinder` instead. If you're in an Actually / jadyly-app session, use `session-close-actually`. Those skills carry project-specific gates this one intentionally omits. This skill is for every other project.

## Step 0: Orient on the project

Read, in this order:

1. **The project's CLAUDE.md** - this is where project-specific overrides live. Look for: a file map (where gotchas, lessons, ideas, and session logs belong in this project), memory write rules beyond the universal ones, line ceilings or format rules on specific files, write-path restrictions, and any source-of-truth hierarchy. Where the project's CLAUDE.md conflicts with this skill, the project's CLAUDE.md wins - it's more specific.
2. **STATUS.md** - the next-move file. You'll rewrite parts of it in Step 2.
3. **MEMORY.md** - so you know what's already captured and don't propose duplicates.

If the project has no memory files at all, don't invent a structure mid-close. Tell Clark the project isn't scaffolded and offer to run the new-project skill first, then come back to the close.

## Step 1: Conversation scan

Review the full session for anything that should survive. Don't ask Clark to enumerate - scan it yourself, then present what you found and let him correct. You're looking for:

- **Decisions** - "we agreed to X", "let's go with Y", "don't do X anymore", anything that locks an approach for future sessions
- **Gotchas** - error patterns, API quirks, silent failure modes, workarounds, "turns out...", "the real cause was..."
- **Action items** - things Clark said he'd do, things to monitor, blocked items waiting on external input
- **Open threads** - half-finished work, questions raised but not answered, ideas worth keeping
- **Verifiable events** - PR merges, migrations applied, files moved, renames completed (these matter for memory category sorting in Step 2)

## Step 2: Memory write protocol (three categories)

MEMORY.md writes follow the universal memory write discipline from the rules-kit. Sort every candidate write into one of three categories. When the category is uncertain, default to Category 1 - the strictest.

**Category 1 - new entries (strict trigger).** Adding a new decision, claim, or fact requires an explicit trigger phrase from Clark this session: "remember this", "make a note", "save this", "log this", "add to memory", "don't forget", or a near-equivalent. No trigger means no write. Instead, surface each candidate in the confirmation output (Step 6) with: the claim, where in the session it came from, and an approve/reject ask. Next session can also pick up unapproved candidates from the STATUS.md session summary.

**Category 2 - edits to existing entries (trigger OR verifiable event).** Changing an existing entry requires either an explicit trigger from Clark ("update the note about X") or a verifiable in-session event that made the entry stale: a tool call result, a file change with a citable diff, or a decision Clark stated this session. The hard guard: you must be able to point at the specific session action that made the old entry stale. Staleness inferred from external sources (Clark mentioned something happened elsewhere, a notification said so) doesn't qualify - that's Category 1, surface it as a candidate. When editing, preserve the rest of the file byte-for-byte; never rewrite MEMORY.md wholesale.

**Category 3 - mechanical maintenance (inline with report).** Bookkeeping with deterministic rules runs inline without a trigger, under two conditions: the trigger is a specific verifiable event (a PR merge you saw via tool call, a successful operation you performed, a file-system change you made), and you report the edit in the confirmation output. Examples: refreshing a status table after a merge you observed, syncing a count after an operation you ran. If the event is inferred rather than observed, it's not Category 3.

The failure mode this protocol prevents: silent memory drift. Quiet writes accumulate across sessions and corrupt the project's source of truth; missed captures mean decisions decay. The categories balance both risks.

## Step 3: STATUS.md update

STATUS.md is the next-move file - the first thing the next session reads. Update it with:

1. **Session summary** - dated, 3-6 lines: what happened, what shipped, what changed
2. **Next move** - the single most important thing the next session should do first
3. **Pending items** - the action items and open threads from Step 1, specific enough to act on ("check PR #99 CI status", not "follow up on PR")
4. **Unapproved memory candidates** - Category 1 candidates Clark didn't rule on, so they aren't lost if he closes without answering

Follow the project's existing STATUS.md structure. Update sections in place; don't duplicate or append a second copy of the file's structure.

## Step 4: Gotcha candidates (propose, then write)

From the Step 1 scan, draft each gotcha as a candidate: one or two lines, naming the failure mode and the fix or rule. Present the full list to Clark for approval BEFORE writing any of them.

Where approved gotchas go depends on the project - check the CLAUDE.md file map from Step 0. Common homes: a Known Gotchas section in the project CLAUDE.md, a GOTCHAS.md, or a LESSONS.md. If the project defines none, propose adding a Known Gotchas section to the project CLAUDE.md and let Clark confirm the location along with the content.

Respect any line ceiling the project enforces on the target file. If adding gotchas would breach it, flag the oldest entries as archive candidates rather than silently growing the file.

## Step 5: PRIMER.md refresh (conditional)

Only if the project has a PRIMER.md. PRIMER is for narrative arc, not changelog. The test: would the next session miss something load-bearing without this edit? If yes, edit. If no, skip - sprint-tactical work belongs in STATUS.md, which Step 3 already handled.

Refresh triggers: a new architectural pattern, a new operating rule, a scope or phase shift, a relationship or stakeholder change. After editing, update the "Last updated" line at the top with the date and a one-line summary.

## Step 5.5: Build-log capture (The Wherehouse only)

**Gate:** run this step ONLY when Step 0's CLAUDE.md is The Wherehouse meta-project (or another project whose CLAUDE.md declares a `build-log/` knowledge root and points at the `helmut-buildlog` tool). Skip silently in every other project. This is the self-documenting development memory: a synthesized, bounded build-log entry per dev session plus a secret-scrubbed cold archive.

The product is the SYNTHESIZED entry, not the transcript. Capture *why it changed*, never *what happened when*. No chronology, no tool-by-tool replay, no conversational back-and-forth.

**1. Synthesize the entry (in-context — identical in Cowork and Claude Code).** From the Step 1 conversation scan, write the bounded fields as a JSON spec (this is model-authored from what you know at close; it does NOT parse a transcript): `session_id`, `date`, `title`, `surface` (`cowork`|`claude-code`), `repos`, `areas`, `decisions` (each `{decision, rationale, memory_ref?}`), `rejected_alternatives` (`{option, why}`), `reversals` (`{from, to, evidence}` — the high-value narrative, always include the *triggering evidence*), `gotchas` (`{gotcha, ref?}`), `commits`/`briefs`/`files` (links, not prose), `open_threads`. Then write it:

```
echo '<json-spec>' | uv run --project ~/Documents/Claude/Projects/helmut-retrieval \
  helmut-buildlog synthesize --repo "~/Documents/Claude/Projects/The Wherehouse" --spec -
```

The writer scrubs secrets, runs the fail-on-leak gate, and is idempotent on `session_id` (re-running overwrites that session's one entry — no duplicates).

**2. Archive the scrubbed raw transcript (surface-specific — this is the only part that differs by surface).**
- **In Cowork:** pull this session's transcript with the `session_info` tool (`list_sessions` to find the active session, then `read_transcript`), and pipe its text in:
  ```
  helmut-buildlog archive --archive-repo ~/Documents/Claude/Projects/wherehouse-buildlog-archive \
    --surface cowork --session-id <id> --date <iso> --transcript -
  ```
- **In Claude Code:** pass this session's JSONL path (`~/.claude/projects/<slug>/<session-id>.jsonl`):
  ```
  helmut-buildlog archive --archive-repo ~/Documents/Claude/Projects/wherehouse-buildlog-archive \
    --surface code --session-id <id> --date <iso> --transcript <path-to-jsonl>
  ```
The archiver scrubs + leak-gates before writing and commits to the dedicated archive repo (unindexed cold backstop, never a knowledge root). If the `gh` remote exists, it stays local-only unless Clark has approved a push.

Report both outputs (entry path + archive path) in Step 6.

## Step 6: Confirmation output

After all writes and proposals, output a compact summary:

```
Session close complete ([project name]).

Files updated:
- STATUS.md - [brief description]
- MEMORY.md - [Cat 1 written: N (explicit trigger) | Cat 2 edits: N | Cat 3 maintenance: N | or "not touched"]
- PRIMER.md - [refreshed: reason | skipped: no narrative trigger | n/a]
- [gotcha target file] - [N added | none]
- Build log - [entry path + archive path written | n/a: not The Wherehouse]

Memory candidates needing your call:
- [claim] (from: [where in session]) - write it? Y/N
- ...

Pending for next session:
- [action items, priority order]
```

Keep it short. Clark is trying to leave. If he answers the candidate asks, write the approved ones before the session ends. If he doesn't, they're already preserved in STATUS.md.

## Voice

Any prose drafted during this close (session summaries, gotcha text, PRIMER narrative) is content drafted on Clark's behalf. Load the voice profile before drafting, from the first accessible path: `voice-profile.md` in auto-memory, `~/Documents/Claude/Projects/voice-profile.md`, or `~/.claude/claurke-kit/personal/voice-profile.md`. If none is accessible, apply the fallback voice rules from Clark's personal preferences. Run the humanizer skill as a final pass on drafted prose. File-format scaffolding (headers, table syntax, dates) is exempt; the sentences inside aren't.

## What NOT to do

- Don't create HTML artifacts or session logs - that's daily-wrap, a different skill
- Don't ask Clark 10 questions - scan the conversation yourself, present findings, let him correct
- Don't update files that weren't touched by this session's work - Steps 4 and 5 are conditional, not mandatory
- Don't rewrite MEMORY.md wholesale - append or edit specific entries only
- Don't write to MEMORY.md without sorting the write into a category first - uncertain means Category 1
- Don't block Clark from leaving - if something is unclear, write what you know, flag the uncertainty in STATUS.md, and let next session pick it up
- Don't run this in Wayfinder or Actually sessions - their dedicated skills carry gates this one doesn't have
- Don't invent project structure - no memory files means offer new-project first, not freelance scaffolding

## Provenance

This skill is the extracted universal layer of `session-close-wayfinder` and `session-close-actually` (built 2026-06-05). It encodes the rules-kit Memory Write Discipline section (the project-agnostic form of RFD-004's three-category model, post-rollout - no staging ceremony). The project skills remain independent; a future refactor may slim them to reference this protocol plus their project gates. Canonical home for the memory rules: claurke-rules-kit `rules/CLAUDE.md`.
