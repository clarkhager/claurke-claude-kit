---
name: linear-ops
description: |
  Linear board management for Linear/JAD-tracked development work - triggerable any time, not just at session close. Encodes the ticket conventions (team Jadyly Dev Studios, JAD prefix, project placement, blocks/blockedBy relations), a STATE-RECONCILE pass (find issues stuck "In Progress" that are actually done, blocked, or merged and haven't been moved), board-hygiene sweeps (stale states, missing project/assignee, orphaned blockers, priority sanity), and mapping shipped PRs/commits to Done with a receipt comment that cites the merge locator. Use whenever Clark says "linear-ops", "clean up the board", "board hygiene", "reconcile Linear", "what's stuck in progress", "which tickets are actually done", "mark the shipped tickets done", "sync Linear with git", "file a JAD ticket", "create a Linear issue for this", "set up the blockers", or otherwise wants Linear issues created, reconciled against real git/PR state, or swept for hygiene. Also invoked by session-close-wherehouse as its dev hygiene gate. Scoped to Linear-backed dev work; encodes JAD conventions but is not hardcoded to one project, so it works for any JAD-tracked build. Do NOT use for non-dev projects with no Linear board (Home Assistant, BizzaBrain) or for the generic memory-file close (session-close).
---

# Linear Ops - Board Management for Dev Work

Keep the Linear board telling the truth. The board is only useful if its state matches reality - an issue marked "In Progress" that actually shipped three days ago is worse than no board, because it hides the real next move. This skill does the reconciliation and hygiene that keeps the board honest, plus the ticket-creation conventions so new issues land in the right shape.

It's standalone and triggerable any time - mid-session when Clark wants to file tickets or clean up, or as the dev hygiene gate inside `session-close-wherehouse`. Nothing here is close-bound.

## Tools and conventions

**Tools:** the Linear MCP (list/get/save issues, save/list comments, list issue statuses, list projects, list teams) for the board; git and the GitHub CLI/MCP (`gh pr list`, `gh pr view`, commit logs, PR search) to observe real shipped state. The reconcile and PR-mapping passes are cross-referencing the two.

**Team:** `Jadyly Dev Studios`, issue prefix `JAD`. Default new issues here unless Clark names another team.

**Ticket conventions** (when creating issues):
- **Project placement is required.** Every issue belongs to a project (e.g. "Harness & long-running workflow", "Analysis Layer", "Calendar & coverage"). Ask which project if it's not obvious from context; don't leave issues projectless - a missing project is the #1 hygiene defect.
- **Description shape:** lead with the finding/goal in one bolded line, then why it matters, then the gate/validation (cost, canon-touch, how you'll know it's done). Match the voice of existing JAD tickets - terse, evidence-first.
- **Relations:** wire `blockedBy` / `blocks` when one issue composes or depends on another (e.g. a variant blocked by the base-layer upgrade). Getting the block order right is what makes the board a real work queue.
- **Priority:** set it (Urgent/High/Medium/Low). Unset priority is a hygiene defect the sweep flags.
- Linear auto-generates the git branch name; surface it when Clark's about to start the work.

**The board is visible to Clark and anyone he shares it with - every mutation is a final action.** Never bulk-move, bulk-comment, or reassign without showing Clark the itemized list first and getting explicit approval. Propose, then write. This is the review-gate; a batch of state changes is exactly what it guards.

## State reconcile

The core pass. Find issues whose Linear state lies about reality and propose corrections.

1. **Pull the candidates.** List issues in started/`In Progress` (and optionally `Todo` that's been touched). These are where drift hides - work finishes but the state never advances.
2. **Check each against real state.** For each candidate, look for evidence it's actually elsewhere:
   - **Done?** A merged PR referencing the issue (branch name matches the issue's `gitBranchName`, or the PR/commit mentions `JAD-NN`), a completed deploy, a STATUS/MEMORY note that the work shipped, or a checklist that's fully ticked. → propose **Done** (with the receipt comment, see below).
   - **Blocked?** Waiting on an external input, a decision, or another unfinished issue. → propose moving to **Blocked**/**Backlog** with a comment naming the blocker, and wire the `blockedBy` relation if the blocker is itself a JAD issue.
   - **Actually still in progress?** Real work in flight, PR open but not merged. → leave it, but note it for the loose-ends sweep (open PR).
3. **Classify, don't guess.** If the evidence is ambiguous (an issue looks done but you can't find the merge), say so and ask - don't silently flip it. A generic "looks finished" is not a merge locator.
4. **Present the reconcile table** - issue, current state, proposed state, the evidence - and get approval before any write.

## Map shipped PRs/commits → Done (with a receipt)

When a PR or commit that references a JAD issue has merged, the issue should be Done - and the move should leave a receipt so the board records *how* it shipped, not just that it did.

For each shipped issue:
1. **Add a receipt comment** citing the locator: the PR link/number, the merge commit SHA, and the merge date - e.g. `Shipped in clarkhager/claurke-claude-kit#42 (merged 2026-07-03, SHA a1b2c3d).` The comment is the audit trail; the state change alone loses the how.
2. **Move the issue to Done** only after the comment is written. No receipt, no move - a Done with no locator is the same empty claim the Receipts rule guards against.

Match PRs to issues by: the issue's `gitBranchName`, a `JAD-NN` mention in the PR title/body/commits, or Linear's own GitHub-linked attachments if present. If a PR references no issue, flag it - it may need one (or it's out-of-band work Clark should know landed unticketed).

## Board-hygiene sweep

A broader pass than reconcile - catch the slow rot:
- **Stale states:** `In Progress` with no activity for a while (covered by reconcile), `Todo` that's really backlog, `Done` that was reopened.
- **Missing project or assignee** on active issues.
- **Orphaned blockers:** issue A `blockedBy` B where B is already Done - the block should be cleared so A surfaces as workable.
- **Priority gaps:** active issues with no priority.
- **Duplicate/overlap:** two issues describing the same work.

Present findings grouped by defect type with a proposed fix each; apply only what Clark approves.

## What NOT to do

- Don't mutate the board (move state, comment, reassign, create, relate) without showing the itemized change set and getting explicit approval first - board writes are visible final actions.
- Don't mark an issue Done without a receipt comment carrying the merge locator - state-only Done loses the how and can't be audited.
- Don't flip a state on a guess - ambiguous evidence means ask, not assume.
- Don't invent a project for a new issue - ask which one; don't leave it projectless either.
- Don't run this against non-dev projects with no Linear board - that's a category error; use the generic close/ops skills there.

## Provenance

Built 2026-07-03 per JAD-27 to decouple Linear/git board management from the generic `session-close` (which stays project-agnostic). Standalone and reusable across any JAD-tracked build; also composed by `session-close-wherehouse` as its dev hygiene gate.
