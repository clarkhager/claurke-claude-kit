---
name: session-close-wherehouse
description: |
  Dev session-close variant for The Wherehouse and any Linear/JAD-tracked development work. Mirrors session-close-wayfinder: it delegates the entire UNIVERSAL close layer (STATUS update + prune, three-category MEMORY writes, gotcha approval, PRIMER refresh, AskUserQuestion interview, copy-paste kickoff prompt) to the generic `session-close` skill, then adds the DEV gates that generic intentionally omits - a `linear-ops` board reconcile (move shipped tickets to Done with receipts, catch drift) and a git LOOSE-ENDS sweep (open PRs, unmerged branches, merged-but-undeployed repos, so nothing like PR #37 slips through) - plus the Wherehouse build-log capture. Trigger whenever Clark signals closing a session ("session close", "close it out", "I'm done for now", "let's call it", "goodnight", "that's it for today", "save context", "save everything", or signals leaving/tired/switching) AND the session is in The Wherehouse project OR is Linear/JAD-tracked dev work (helmut-retrieval, the kit repos, any repo with a JAD board and open PRs). This is the close skill for dev work: when it applies, the generic session-close does NOT fire (same routing as the other variants). Do NOT trigger for non-dev projects (Home Assistant, BizzaBrain - those use generic session-close), or Wayfinder (session-close-wayfinder). Do NOT trigger on "wrap up"/"daily wrap" (daily-wrap).
---

# Session Close - Wherehouse / Dev Variant

You're closing a dev session - The Wherehouse or other Linear/JAD-tracked work. This variant is thin on purpose: the universal close logic lives in the generic `session-close` skill and is identical across all Clark's projects, so this skill **delegates that layer** and only adds what's specific to dev work: Linear board hygiene, git loose-ends, and the Wherehouse build-log.

The same decoupling as `session-close-wayfinder`: generic stays generic, project gates live here.

**Intentionally Cowork-only:** kept off Claude Code auto-install by the bootstrap `COWORK_ONLY` guard (JAD-24) - a phrase-triggered close must not fire mid-task in a worker session. Not a missing install.

## Step 1: Run the universal close layer

Execute the generic `session-close` protocol in full - every step *except* its final confirmation-and-kickoff output. That includes its JAD-93 layer as written there: supersession-at-write, the mandatory gotcha supersession question, the UNCONDITIONAL Step 6 prune + tripwire report, the monthly-compaction ride, and the `MEMORY-WARNINGS.md` prune-first contract - all apply in full here; The Wherehouse is the primary instance.

Read `~/.claude/claurke-kit/skills/session-close/SKILL.md` (or the installed `session-close` skill) and follow it - do not re-implement or duplicate that logic here; when it changes, this variant inherits the change for free.

**One ordering change:** hold the generic **confirmation summary + kickoff prompt** (its final step) until the end of *this* skill. Run everything else in generic first, then do the dev gates below, then emit the confirmation + kickoff - so the loose-ends and reconcile findings land in the pending list of the paste-ready prompt.

## Step 2: Linear board reconcile (dev gate A)

Run the `linear-ops` skill's reconcile + PR-mapping passes, scoped to this session's work:

- **State reconcile:** find JAD issues stuck `In Progress` that this session actually finished, blocked, or merged, and propose the corrected states.
- **Map shipped PRs/commits → Done with a receipt:** for work this session shipped (a merged PR referencing a JAD issue), add the receipt comment (PR link + merge SHA + date) and move the issue to Done - only after the comment is written.
- Present the itemized change set and get Clark's approval before any board write. Board mutations are visible final actions.

Read `~/.claude/claurke-kit/skills/linear-ops/SKILL.md` for the conventions and the approval gate. If this dev work has no Linear board, skip this gate.

## Step 3: Git loose-ends sweep (dev gate B)

The gate that exists so nothing ships into a black hole - the PR #37 lesson: work merged or opened and then forgotten because nothing surfaced it at close. Sweep the repos this session touched (and the project's known repos) for:

- **Open PRs** - not yet merged. `gh pr list --state open` per repo. Each one is a pending item: what's blocking the merge?
- **Unmerged local branches with commits** - work in flight that isn't on `main` and has no PR. `git branch --no-merged main` / check for ahead-of-main branches. Flag anything with unpushed or un-PR'd commits.
- **Merged-but-undeployed repos** - a repo where `main` has moved past the last deploy. This is the highest-value catch: helmut-retrieval especially has **no auto-deploy** (merging to main does NOT ship it; `fly deploy` is manual, and new roles/endpoints need their own Fly secret). A merge that never deployed is a silent regression waiting to surface. Check each dev repo: is `main` ahead of what's live? Does a merged endpoint still need `fly deploy` + `fly secrets set`?

Surface every loose end as a **pending item in STATUS and in the kickoff prompt**, specific enough to act on ("PR #37 open on helmut-retrieval - needs review then merge", "helmut-retrieval main merged JAD-25 but not deployed - `cd` in, `fly deploy`, set the DSN secret"). Getting these into the next-session prompt is the whole point: the sweep is worthless if the finding doesn't reach the next session.

Don't deploy or merge anything as part of the close - the sweep observes and records; Clark decides when to act. (Follow the project's infra rules: observe before prescribing, deploy from a clean worktree off origin/main, never `git checkout main` in a dirty tree.)

**Orca worktree sweep (part of gate B).** If any Orca lane ran this session - or if `orca worktree ps` shows worktrees at all - sweep them the same way. A worktree whose branch is already merged to `origin/main` is dead weight, and dead lanes accumulate until the projects window hides the live ones (~22 had to be cleared at once on 2026-07-13; five more were still open the same day the archive-at-merge practice landed - a practice with no trigger does not fire).

```bash
orca worktree ps --limit 50
# per worktree: git -C <repo> branch -r --merged origin/main | grep <branch>  -> merged = candidate
# archive:      orca worktree rm --worktree path:<path> --force
```

**Itemize the candidates and get Clark's approval before removing any** - `--force` destroys uncommitted work that never became a PR, so this is a final action under the global review gate. The sweep proposes; Clark disposes. See `orca-ops` > "Closing a lane (archive at merge)".

## Step 3b: Skill retro gate (dev gate C)

**Run this whenever an Orca lane ran, or whenever a documented skill was used and found wanting.** Skills rot silently: the failure mode is a skill that names the wrong tool, ships a wrong CLI flag, or states a practice with nothing to trigger it - and nobody notices for weeks because nothing ever asks.

Ask three questions, cheap to answer, and answer them honestly:

1. **Was anything the skill documents actually WRONG?** A command, a flag, a path, a tool name, a claim about what a tool can do. Corrections outrank additions - a wrong instruction is worse than a missing one, because it gets followed.
2. **Did we derive a rule that isn't written down?** Something a future session would have to re-derive from scratch.
3. **Did a documented practice fail to fire because nothing triggered it?** If so the fix is a gate, not better wording. Rewriting an aspiration more emphatically does not make it fire.

**Surface amendments as CANDIDATES for Clark's approval - never a silent overwrite.** Same shape as the memory write protocol: state the claim, state where in the session it came from, ask. This is the mechanism that makes "living skill" true instead of aspirational.

Approved candidates become a **PR to `claurke-claude-kit`** (the canonical home for kit skills). An edit to Cowork's skill cache is invisible and dies with the session - the cache is read-only and reloads at session start. After merge: `bash ~/.claude/claurke-kit/bootstrap.sh --update`, plus a plugin **Update** in Cowork for bundled kit skills to refresh.

Record each accepted amendment in that skill's own **Amendment log** section, dated, naming the defect it fixes. The log is what lets a future session see whether the skill has been earning its keep or quietly rotting.

## Step 4: Build-log capture (Wherehouse only)

**Gate:** run this step ONLY when Step 1's CLAUDE.md is The Wherehouse meta-project (or another project whose CLAUDE.md declares a `build-log/` knowledge root and points at the `helmut-buildlog` tool). Skip silently in every other dev project. This is the self-documenting development memory: a synthesized, bounded build-log entry per dev session plus a secret-scrubbed cold archive.

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
  uv run --project ~/Documents/Claude/Projects/helmut-retrieval \
    helmut-buildlog archive --archive-repo ~/Documents/Claude/Projects/wherehouse-buildlog-archive \
    --surface cowork --session-id <id> --date <iso> --transcript -
  ```
- **In Claude Code:** pass this session's JSONL path (`~/.claude/projects/<slug>/<session-id>.jsonl`):
  ```
  uv run --project ~/Documents/Claude/Projects/helmut-retrieval \
    helmut-buildlog archive --archive-repo ~/Documents/Claude/Projects/wherehouse-buildlog-archive \
    --surface code --session-id <id> --date <iso> --transcript <path-to-jsonl>
  ```
The archiver scrubs + leak-gates before writing and commits to the dedicated archive repo (unindexed cold backstop, never a knowledge root). If the `gh` remote exists, it stays local-only unless Clark has approved a push.

Report both outputs (entry path + archive path) in the confirmation.

## Step 5: Confirmation output + kickoff prompt

Emit the generic confirmation summary and the copy-paste kickoff prompt now (held from Step 1), extended with the dev-gate results so the next session inherits them:

```
Session close complete (The Wherehouse).

Files updated:            [from generic confirmation]
- STATUS.md / MEMORY.md / PRIMER.md / gotchas - ...

Linear:                   [dev gate A]
- [N issues reconciled: JAD-NN -> Done (receipt) | none]

Loose ends (in STATUS + kickoff):   [dev gate B]
- [open PRs / unmerged branches / undeployed merges, or "clean"]

Build log:                [Wherehouse only]
- [entry path + archive path | n/a]
```

Then the paste-ready kickoff prompt (generic template), with the loose ends and reconcile follow-ups included in "Pending, in priority order" - so PR #37 and any undeployed merge are the first thing the next session sees.

## What NOT to do

- Don't re-implement the universal close - delegate to `session-close`; this skill only adds dev gates.
- Don't skip the Step-1 prune or tripwire report - the universal Step 6 is unconditional at every close (JAD-93), dev sessions included.
- Wherehouse-specific: the weekly memory-audit files its corrective JAD tickets at audit time (actuator mechanism 3) - never park an audit finding in the close report instead of Linear.
- Don't deploy or merge during the close - the loose-ends sweep observes and records; Clark acts.
- Don't mutate the Linear board without Clark's approval of the itemized change set.
- Don't skip surfacing a loose end into the kickoff prompt - an unrecorded open PR is the exact failure this variant exists to prevent.
- Don't run the build-log step outside The Wherehouse (or a project that declares the build-log root).

## Provenance

Built 2026-07-03 per JAD-27, blocked-by the JAD-26 generic `session-close` upgrade it composes. Mirrors `session-close-wayfinder`: generic stays project-agnostic, dev gates (Linear reconcile via `linear-ops`, git loose-ends, Wherehouse build-log) live here. The build-log capture relocated verbatim from the generic skill's former Step 5.5 (it was Wherehouse-specific and became dead code once routing sends Wherehouse here); it wraps the JAD-11 `helmut-buildlog` tooling unchanged.
