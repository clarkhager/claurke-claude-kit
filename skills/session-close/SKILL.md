---
name: session-close
description: |
  Universal session-close protocol for any claurke project without a dedicated close skill. Updates STATUS.md with a session summary and next move, applies the three-category memory write protocol to MEMORY.md, proposes gotcha candidates for approval, prunes the STATUS session chain into STATUS-archive.md, refreshes PRIMER.md only when load-bearing facts changed, and ends by emitting a copy-paste kickoff prompt for the next session. Runs the close as an AskUserQuestion interview (candidate approval, next-session ordering, open decisions - recommendations baked into every option). Project-agnostic: reads the project's CLAUDE.md for overrides, makes zero Linear/git/deploy assumptions. Trigger whenever Clark says "session close", "close it out", "I'm done for now", "let's call it", "goodnight", "that's it for today", "save context", "save everything", or signals leaving, tired, or switching - in ANY project without its own session-close skill (Home Assistant, BizzaBrain, claurke, new projects). Do NOT trigger for Wayfinder/Bizzabo Academy (session-close-wayfinder), or The Wherehouse/Linear-tracked dev work (session-close-wherehouse). Do NOT trigger on "wrap up", "daily wrap", "session log" (daily-wrap). Err toward triggering in uncovered projects - better to run and capture nothing than skip and lose context.
---

# Session Close - Universal Protocol

You're closing a Cowork or Claude Code session in a claurke project. The goal: the next session starts with everything this session knew. This is the generic base protocol - it works in any project with claurke memory files (CLAUDE.md, MEMORY.md, STATUS.md, optionally PRIMER.md).

This is not a ceremony. It's a checklist. Run it fast and get Clark out the door.

**This skill is 100% project-agnostic.** It makes no assumptions about Linear, git, PRs, branches, or deploys - a Home Assistant close and a code close run the exact same steps. Dev-specific gates (board reconcile, git loose-ends) live in the dev variant `session-close-wherehouse`, which delegates the universal layer back here.

**Routing note:** If you're in a Wayfinder / Bizzabo Academy session, use `session-close-wayfinder`. The Wherehouse or any Linear/JAD-tracked dev work, use `session-close-wherehouse`. Those skills carry project-specific gates this one intentionally omits. This skill is for every other project.

**Intentionally Cowork-only:** kept off Claude Code auto-install by the bootstrap `COWORK_ONLY` guard (JAD-24) - a phrase-triggered close must not fire mid-task in a worker session. Not a missing install.

## Step 0: Orient on the project

Read, in this order:

1. **The project's CLAUDE.md** - where project-specific overrides live. Look for: a file map (where gotchas, lessons, ideas, and session logs belong in this project), memory write rules beyond the universal ones, line ceilings or format rules on specific files, write-path restrictions, and any source-of-truth hierarchy. Where the project's CLAUDE.md conflicts with this skill, the project's CLAUDE.md wins - it's more specific.
2. **STATUS.md** - the next-move file. You'll rewrite parts of it in Step 5 and prune it in Step 6.
3. **MEMORY.md** - so you know what's already captured and don't propose duplicates.

If the project has no memory files at all, don't invent a structure mid-close. Tell Clark the project isn't scaffolded and offer to run the new-project skill first, then come back to the close.

## Step 1: Conversation scan

Review the full session for anything that should survive. Don't ask Clark to enumerate - scan it yourself, then present what you found and let him correct. You're looking for:

- **Decisions** - "we agreed to X", "let's go with Y", "don't do X anymore", anything that locks an approach for future sessions
- **Gotchas** - error patterns, API quirks, silent failure modes, workarounds, "turns out...", "the real cause was..."
- **Action items** - things Clark said he'd do, things to monitor, blocked items waiting on external input
- **Open threads** - half-finished work, questions raised but not answered, ideas worth keeping
- **Verifiable events** - file moves, renames, operations you performed this session (these matter for memory category sorting in Step 3)

Hold the results. You'll turn them into interview options in Step 2 and writes in Steps 3-5.

## Step 2: The close interview (AskUserQuestion)

The close is an interview, not a wall of prose. Use `AskUserQuestion` to get every decision Clark needs to make - and **bake your recommendation into each option** so he's ratifying a judgment, not doing the analysis himself. This is the point: he's trying to leave, so each option should carry the call and the one-line reason.

Ask only what's actually open this session. A read-only session with nothing to save may need no questions at all - go straight to Step 5 (STATUS update). Assemble the questions that apply from the four kinds below (AskUserQuestion takes up to 4 questions per call; batch them):

**A. Memory candidates (multiSelect).** Every Category-1 candidate from Step 1 (see Step 3 for the categories) becomes one option; selecting it approves the write. Put the claim in the option **label**, and the recommendation + provenance in the **description** - e.g. label `MA sync cleanup gap`, description `Recommended - durable architectural fact, no trigger given this session. From the Echo Show diagnosis.` or label `Prefer 6" pots for braids`, description `I'd skip - already covered by the STATUS summary; not a reusable rule.` Selected options get written under the Step 3 protocol; unselected ones are surfaced in STATUS (Step 5) so they aren't lost.

**B. Gotcha candidates (multiSelect).** Same shape for the Step 1 gotchas: one option per gotcha, label names the failure mode, description carries the fix + your recommendation (`Recommended - silent failure, will bite again` vs `I'd skip - one-off, not a pattern`). Approved ones are written in Step 4 (Gotcha writes).

**C. Next-session ordering (single-select).** What should the next session do first? Offer the 2-4 plausible first moves, **recommended one first**, each description saying why. This answer drives the kickoff prompt in Step 8.

**D. Open decisions (single-select each).** Any decision this session raised but didn't settle that shapes the next session. Recommended option first, reason in each description.

Practical constraints: AskUserQuestion needs 2-4 options per question. If a candidate group has 5+ items, split it across additional questions (or a second call). If a group has exactly 1 candidate, present it as a two-option single-select (`Write it (Recommended - ...)` / `Skip (STATUS covers it)`) rather than a one-option multiSelect. Keep `header` labels short (≤12 chars). Clark can always pick "Other" to redirect you.

If Clark closes without answering, don't block - treat unanswered candidates as "not approved," preserve them in STATUS (Step 5), and finish the close.

## Step 3: Memory write protocol (three categories)

MEMORY.md writes follow the universal memory write discipline from the rules-kit. Sort every candidate into one of three categories. When the category is uncertain, default to Category 1 - the strictest.

**Category 1 - new entries (strict trigger OR interview approval).** Adding a new decision, claim, or fact requires either an explicit trigger phrase from Clark this session ("remember this", "make a note", "save this", "log this", "add to memory", "don't forget", or a near-equivalent) OR his approval of that candidate in the Step 2 interview. No trigger and no approval means no write - the candidate stays surfaced in STATUS (Step 5) and next session can pick it up.

**Category 2 - edits to existing entries (trigger OR verifiable event).** Changing an existing entry requires either an explicit trigger from Clark ("update the note about X") or a verifiable in-session event that made the entry stale: a tool call result, a file change with a citable diff, or a decision Clark stated this session. The hard guard: you must point at the specific session action that made the old entry stale. Staleness inferred from outside the session (Clark mentioned something happened elsewhere) doesn't qualify - that's Category 1, surface it as a candidate. When editing, preserve the rest of the file byte-for-byte; never rewrite MEMORY.md wholesale.

**Category 3 - mechanical maintenance (inline with report).** Bookkeeping with deterministic rules runs inline without a trigger, under two conditions: the trigger is a specific verifiable event (an operation you performed, a file-system change you made), and you report the edit in the confirmation output. If the event is inferred rather than observed, it's not Category 3.

The failure mode this protocol prevents: silent memory drift. Quiet writes accumulate across sessions and corrupt the source of truth; missed captures mean decisions decay. The categories balance both risks.

## Step 4: Write approved gotchas

Write only the gotchas Clark approved in Step 2B. Where they go depends on the project - check the CLAUDE.md file map from Step 0. Common homes: a Known Gotchas section in the project CLAUDE.md, a `GOTCHAS.md`, or a `LESSONS.md`. If the project defines none, propose adding a Known Gotchas section to the project CLAUDE.md and confirm the location with Clark before writing.

Draft each as one or two lines - the failure mode and the fix or rule - and date it. Respect any line ceiling the project enforces on the target file; if adding gotchas would breach it, flag the oldest entries as archive candidates rather than silently growing the file. Watch for duplication: if an approved fact was also written to MEMORY.md as a Category-1 entry (because Clark gave a trigger phrase), don't write the same rule to two files - keep it in the one its content fits best and note the call.

## Step 5: STATUS.md update

STATUS.md is the next-move file - the first thing the next session reads. Update it with:

1. **Session summary** - dated, 3-6 lines: what happened, what shipped, what changed. Follow the project's existing session-entry format (many projects head each with `Session N (date) - ...`).
2. **Next move** - the single most important thing the next session should do first. This should match the Step 2C answer.
3. **Pending items** - the action items and open threads from Step 1, specific enough to act on ("check the freezer sensor battery after 30 days", not "follow up on sensor").
4. **Unapproved memory candidates** - Category 1 candidates Clark didn't approve in Step 2, so they aren't lost if he closes without ruling.

Update sections in place; don't duplicate or append a second copy of the file's structure.

## Step 6: Prune the STATUS session chain

Every claurke STATUS.md bloats - the dated session summaries pile up until the file is mostly history and the next-move gets buried. Keep STATUS lean so the top of the file is always the live state.

**Rule:** after adding this session's entry (Step 5), keep the **most recent 3-5 session entries** in STATUS.md. Spill everything older into `STATUS-archive.md` in the same directory.

- Move the oldest entries verbatim - cut from STATUS, paste into the archive under the same heading style, newest-archived first. Don't summarize or drop content; the archive is the full record.
- If `STATUS-archive.md` doesn't exist, create it with a one-line header (`# STATUS Archive - [project] (older session entries, newest first)`) and a pointer back: note in STATUS that older sessions live in `STATUS-archive.md`.
- Update the `Last updated:` line at the top of STATUS to this session's date.
- Only prune the session-history chain. Leave standing sections (next move, current state, pending, reference tables) in place - they're not history.
- If the project's CLAUDE.md sets a different STATUS retention rule or a different archive filename, follow it - project overrides win.

This is mechanical maintenance (Category 3): report the prune in the confirmation output (how many entries moved, to where).

## Step 7: PRIMER.md refresh (conditional)

Only if the project has a PRIMER.md. PRIMER is for narrative arc, not changelog. The test: would the next session miss something load-bearing without this edit? If yes, edit. If no, skip - sprint-tactical work belongs in STATUS.md, which Step 5 handled.

Refresh triggers: a new architectural pattern, a new operating rule, a scope or phase shift, a relationship or stakeholder change. After editing, update the "Last updated" line at the top with the date and a one-line summary.

## Step 8: Confirmation output + next-session kickoff prompt

First, a compact summary of what you did:

```
Session close complete ([project name]).

Files updated:
- STATUS.md - [brief description]; pruned [N] session entries to STATUS-archive.md
- MEMORY.md - [Cat 1 written: N (trigger/approved) | Cat 2 edits: N | Cat 3 maintenance: N | or "not touched"]
- PRIMER.md - [refreshed: reason | skipped: no narrative trigger | n/a]
- [gotcha target file] - [N added | none]

Still open (surfaced in STATUS):
- [unapproved candidates, if any]
```

Then **always** emit a copy-paste kickoff prompt for the next session - paste-ready, tailored to the interview answers, so Clark can drop it into a fresh session and land running. This is the highest-leverage artifact of the close: it turns "where was I?" into one paste.

```
--- Next-session kickoff (copy-paste) ---
New session on [project name]. Continuing from [date] (Session N).

Reacclimate: read STATUS.md (next move + live state), then CLAUDE.md and MEMORY.md[, PRIMER.md]. In one line: [where we are].

First move: [the Step 2C answer - the agreed first focus].

Pending, in priority order:
- [item]
- [item]

Keep in mind: [open threads / decisions still in the air, if any].
```

Fill every bracket from this session - don't emit the template with placeholders. Keep the summary short; Clark is trying to leave. If he answered the candidate asks, write the approved ones before the session ends. If he didn't, they're already preserved in STATUS.

## Voice

Any prose drafted during this close (session summaries, gotcha text, PRIMER narrative, the kickoff prompt) is content drafted on Clark's behalf. Load the voice profile before drafting, from the first accessible path: `voice-profile.md` in auto-memory, `~/Documents/Claude/Projects/voice-profile.md`, or `~/.claude/claurke-kit/personal/voice-profile.md`. If none is accessible, apply the fallback voice rules from Clark's personal preferences. Run the humanizer skill as a final pass on drafted prose. File-format scaffolding (headers, table syntax, dates) is exempt; the sentences inside aren't.

## What NOT to do

- Don't create HTML artifacts or session logs - that's daily-wrap, a different skill
- Don't interrogate Clark in prose - scan the conversation yourself, then put the decisions in an AskUserQuestion interview with your recommendation in every option
- Don't emit the kickoff prompt with unfilled placeholders - fill every bracket from this session, or omit the line
- Don't update files that weren't touched by this session's work - Steps 5 and 6 are conditional, not mandatory
- Don't rewrite MEMORY.md wholesale - append or edit specific entries only
- Don't write to MEMORY.md without sorting the write into a category first - uncertain means Category 1
- Don't add Linear, git, PR, or deploy steps here - this skill is generic; those live in `session-close-wherehouse`
- Don't run this in Wayfinder or Wherehouse/dev sessions - their dedicated skills carry gates this one doesn't have
- Don't invent project structure - no memory files means offer new-project first, not freelance scaffolding
- Don't block Clark from leaving - if something is unclear, write what you know, flag it in STATUS, and let the next session pick it up

## Provenance

This skill is the extracted universal layer of `session-close-wayfinder` and `session-close-wherehouse` (base built 2026-06-05; upgraded 2026-07-03 per JAD-26 with the AskUserQuestion interview, the copy-paste kickoff prompt, and the STATUS prune). It encodes the rules-kit Memory Write Discipline section (the project-agnostic three-category model). The Wherehouse build-log capture that briefly lived here moved to `session-close-wherehouse` (JAD-27), keeping this layer 100% generic. Canonical home for the memory rules: claurke-rules-kit `rules/CLAUDE.md`.
