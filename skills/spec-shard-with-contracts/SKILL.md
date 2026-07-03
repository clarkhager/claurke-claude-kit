---
name: spec-shard-with-contracts
description: |
  Shard a LOCKED implementation plan into small, resumable spec documents, each carrying an explicit contract - what it assumes is already done, what it guarantees for the next shard, and how it validates before handing off - plus a per-shard validation gate. Use whenever a build is too big for one context window or will span multiple sessions, handoffs, or crashes: multi-day builds, multi-phase migrations, schema-then-consumer arcs, anything you'd otherwise hand-relay between sessions. Trigger when Clark says "shard this plan", "break this into specs", "this build is too big for one session", "spec-shard", "contracts between specs", "spec-shard-with-contracts", or when a gated master plan needs decomposing into Linear tickets / queue units for a long-running-coding run. This is the decomposition step AFTER grill-me-codex has locked intent and the plan is gated - it does NOT run the grill, the research, or the Codex plan-review itself; it consumes their locked output. Err toward triggering when a plan is clearly multi-step and about to be built over more than one sitting - un-sharded long builds are the exact pain this skill exists to remove.
---

# Spec-shard-with-contracts

You're turning a **locked** master plan into a series of spec documents small enough that each one fits a single fresh agent context, and connected by explicit contracts so the series can be built across many sessions, crashes, and handoffs without losing the thread.

This is Layer 2 of the long-running-coding workflow (`The Wherehouse/briefs/long-running-coding-workflow.md`). It composes with the rest of the kit - it does not replace any of it:

- **grill-me-codex** already produced the locked intent and the gated A-Z plan. You start where it stops.
- **Linear** (team Jadyly Dev Studios, key `JAD`) is the durable queue (Layer 1). Each shard maps to one ticket.
- **The Codex gate, worktrees, receipts, fresh-context subagent verification** are the per-shard validation tools you'll cite in each contract, not something you reinvent.

The one thing this skill owns is the **decomposition + the contracts between shards**. Get those right and a multi-day build becomes a clean series of resumable units instead of a hand-managed relay.

## Why contracts, and what one is

A long build fails at the *seams*, not in the middle of a shard. A fresh agent picking up shard N has none of the context that built shards 1..N-1. If shard N only implicitly assumes "the schema exists" or "the role can read corrections," and that assumption is wrong or half-true, the agent builds on sand and the failure surfaces late and expensively. The contract makes every seam explicit so a cold-start agent can verify its footing before writing a line.

Every shard carries three contract fields:

- **Assumes-done** - what must already be true when this shard starts. Two kinds: (a) *prior-shard outputs* (something an earlier shard in this plan guaranteed) and (b) *pre-existing canon* (something already true in the repo/system before this plan began). A cold agent reads this first and can check each item is real before proceeding.
- **Guarantees-for-next** - what this shard leaves true and done for later shards to build on. This is the shard's product stated as a *durable postcondition*, not a task list. If shard N's guarantee is vague, shard N+1's assumes-done can't be verified.
- **Validation** - how you prove the guarantee actually holds before the next shard starts. The per-shard gate: the tests, the acceptance check, the Codex review, the live-drive - whatever makes regression visible *now* instead of three shards later. A guarantee with no validation is a hope.

The load-bearing invariant: **every assumes-done item must resolve to either an earlier shard's guarantees-for-next or to pre-existing canon.** An assumes-done that matches neither is a gap in the plan - surface it (see Step 4). This closure check is what makes the series safe to build out of order or across a context reset.

## Step 0: Confirm the plan is locked

Do not shard a plan that's still in flux. Sharding freezes the decomposition; if the plan changes after, every downstream contract can drift. The plan is lockable when: intent is grilled (grill-me-codex done), the approach is gated (Codex plan-review or Clark's explicit go), and the open decisions are either closed or explicitly deferred with a named owner.

If the plan still has open load-bearing decisions, say so and stop - the fix is to close them (or hand back to grill-me-codex), not to shard around them. Sharding an unlocked plan is the failure mode this step prevents.

## Step 1: Find the shard boundaries

A shard is sized by **one fresh agent context** - small enough that a cold agent can hold the whole shard plus its assumes-done without drowning. That's the ceiling. The floor is a **coherent, independently-validatable unit** - a shard has to leave *something* a later shard can build on and that you can prove is done.

Cut on the natural seams, which are almost always where a real contract already exists:

- **Producer before consumer.** The thing that writes a table/route/artifact ships and is proven before the thing that reads it. (Schema+role before extractor; extractor+routes before the panel that calls them.)
- **Canon/precondition splits.** A cross-cutting prerequisite that several later shards need - a grant, a migration, a shared type - is its own small shard so it's proven once, up front. (This is why a one-migration prerequisite legitimately becomes its own shard.)
- **Gate boundaries.** Where the validation discipline changes - a schema/role shard needs the full canon gate (plan + Codex + fresh-context subagent + least-privilege-proven-as-the-role); a frontend shard needs the design-pipeline + live-drive gate. Different gates want different shards.
- **Human-in-the-loop boundaries.** Where the build must stop for a human decision - a migration go, a named dollar figure (Rule 22), a design sign-off. That HITL flag belongs in the assumes-done of the shard it blocks.
- **Dependency arrivals.** Where a shard needs something a *different* arc must land first (a sibling feature, an external merge). That external dependency is an assumes-done item even though no shard in *this* plan guarantees it.

Aim for the fewest shards that keep each one inside a single context and honestly validatable. More shards means more seams to get right; fewer means a shard that won't fit a cold context. When unsure, cut at the seam where a real contract already lives - those are cheap to write and safe to build against.

## Step 2: Write each shard's contract

For each shard, in build order, fill the template (below). Write **assumes-done** and **guarantees-for-next** as durable state ("the four analysis tables exist and `helmut_analysis` is proven least-privilege AS the role"), not as tasks ("create the tables"). Write **validation** as the specific gate that fires for this shard, naming the concrete check - not "test it" but "acceptance test seeds one poisoned fixture with a fabricated segment id and asserts the gate rejects it."

Mark human-in-the-loop items explicitly in assumes-done (prefix `HITL:`) - a cold agent must know to *stop* there, not guess. Mark external-arc dependencies too (prefix `EXTERNAL:`) - they don't resolve to a shard in this plan, so the closure check in Step 4 knows to accept them as leaf preconditions.

## Step 3: Order and map to the queue

Put the shards in a build order consistent with the contracts: a shard can't come before a shard it assumes-done from. Where two shards don't depend on each other, note they're parallelizable (useful for worktrees).

Each shard maps to exactly one Linear ticket (Layer 1). The spec doc is the ticket body; assumes-done becomes the ticket's blockers/deps, HITL items become the ticket's human-gate flags. (This skill produces the specs; creating the tickets is the Layer-1 handoff - don't create live tickets unless asked.)

## Step 4: Close the contract chain (the check that catches the real bugs)

Walk the whole set once, in order, and verify:

1. **Every assumes-done resolves.** For each shard, each assumes-done item matches an earlier shard's guarantees-for-next, OR is tagged pre-existing canon, OR is tagged `EXTERNAL:`/`HITL:`. Any item matching none is a **gap** - either a shard is missing, or the plan itself has a hole. Surface it; don't paper over it with an implicit assumption.
2. **Every guarantee is consumed or terminal.** A guarantees-for-next that no later shard assumes and that isn't the plan's final deliverable is a smell - either dead work (cut it) or a missing consumer shard (the plan under-delivers on its own goal). Flag both.
3. **Every shard has a real validation.** A shard whose validation is "n/a" or "it's obvious" can't gate a handoff - the next shard has no way to know it's safe to start.

Contracts are **living**, not frozen at authoring. Later work legitimately surfaces new preconditions - a review of a shipped shard finds a bug that must be fixed before a *later* shard is safe. When that happens, the new dependency is added to the later shard's assumes-done (and usually becomes its own small prerequisite shard/ticket). The closure check re-runs. This is expected; a plan whose contracts never change after authoring probably wasn't decomposed against reality.

If Step 4 surfaces gaps, report them before declaring the shard set done - a spec-shard whose chain doesn't close is worse than no shard, because it reads as safe when it isn't.

## The spec-doc template

Emit one of these per shard. Keep it tight - a spec doc is a contract plus a pointer back to the plan, not a re-statement of the whole plan.

```markdown
# Shard <N> - <short name>   (ticket: JAD-<n>)

**Plan:** <path to the locked master plan> § <section this shard covers>
**Build gate:** <the one-line gate class - e.g. "full canon gate" / "frontend gate" / "$0, no gate">
**Parallelizable with:** <other shard numbers, or "none - strictly after shard N-1">

## Assumes-done (preconditions)
- <prior-shard output — cite which shard guarantees it>
- <pre-existing canon — cite where it already lives>
- HITL: <human decision that must land first, e.g. "Clark's go on the migration">
- EXTERNAL: <dependency from another arc, e.g. "Node C merged + live">

## Scope (what this shard builds)
<2-5 lines. The what, pointing at the plan section for the how. Not a re-plan.>

## Guarantees-for-next (postconditions)
- <durable state this shard leaves true — the thing a later shard's assumes-done will cite>

## Validation (the per-shard gate)
- <the concrete check that proves the guarantee before the next shard starts —
  named test / acceptance / Codex review / live-drive, with the specific assertion>
```

## Worked shape (from the analysis-layer build)

The analysis-layer arc (`briefs/analysis-layer.md` §11) is the canonical worked example - five build phases (A-E) that became shards JAD-6..10, plus a one-migration prerequisite (JAD-5) split out ahead of Phase B. The contract shape maps directly onto that brief's phase table: the `Blocked on` column is **assumes-done** (with the Rule-22 dollar figure and the migration-go as `HITL:` items, and Node B/C as `EXTERNAL:`), the `What` column is the **guarantees-for-next**, and the `Gate` column is the **validation**. The chain closes cleanly: Phase D assumes-done ("Phase C API contract") is exactly Phase C's guarantee; Phase E's `EXTERNAL: Node B + Node C` are leaf preconditions no shard in the arc guarantees. And it demonstrates *living* contracts - a later review of the Node C surface surfaced two bugs (JAD-11 correlation miss, JAD-12 1:1 duplicates) that were added to Phase E's (JAD-10's) assumes-done after the arc was first sharded.

## What NOT to do

- **Don't shard an unlocked plan** (Step 0). Freezing a decomposition over shifting decisions guarantees contract drift.
- **Don't write guarantees as task lists.** "Create the routes" is a task; "the `POST /analyze` + `GET /analysis` + `PATCH /analysis/items/{id}` routes exist behind the bearer, single-flight-gated" is a postcondition a later shard can verify. Only postconditions make safe seams.
- **Don't leave an assumes-done unresolved.** An implicit "the schema is probably there" is the exact assumption that fails cold-start. Every precondition resolves to a guarantee, canon, `HITL:`, or `EXTERNAL:` - or it's a gap you must surface.
- **Don't inflate the shard count.** Every extra shard is another seam to get right. Cut on real contracts, not on cosmetic phase names.
- **Don't re-run the grill or the research.** Those are grill-me-codex's job and are already done when you're invoked. Re-doing them wastes the fresh context this skill exists to conserve.
- **Don't create live Linear tickets unless asked.** The skill emits specs; ticket creation is the Layer-1 handoff and touches a live service.

## Provenance

Built via skill-creator as a claurke-owned, kit-shippable skill (per the skill-management rule - no ad-hoc placement). It's the one net-new, adoptable piece of the long-running-coding workflow (brief §4 Layer 2); grill → plan → gate already existed. Canonical home: `claurke-claude-kit/skills/spec-shard-with-contracts/`.
