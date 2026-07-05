# CLAUDE.md — {{PROJECT_NAME}}
**Read this before touching any file. Updated after every significant session.**
Last updated: {{DATE}} — Initial setup via claude-memory-kit.

---

## What This Is

{{WHAT_THIS_IS}}

Stack: {{STACK}}

---

## Current Build State ({{DATE}})

[What phase are you in? What shipped most recently? What's in flight? What's the immediate next move?]

`STATUS.md` is canonical for live state and next move. If this section and STATUS.md disagree, STATUS.md wins.

---

## File Map

- `MEMORY.md` — Canonical for decisions and institutional knowledge. Write on explicit trigger only.
- `STATUS.md` — Live next move and session state. Read this first every session.
- `PRIMER.md` — Narrative context, history, stakeholders, the WHY behind decisions.

### Source-of-truth hierarchy
1. `STATUS.md` — canonical for next move and live state
2. `CLAUDE.md` — canonical for build state, rules, architecture
3. `MEMORY.md` — canonical for decisions
4. `PRIMER.md` — narrative context, loses to all above on factual questions

---

## Compaction Safety

**What survives /compact (re-injected automatically):**
- This file (project-root `CLAUDE.md`) — re-read from disk and reinjected after every compaction

**What does NOT survive /compact (silent loss):**
- Path-scoped rules (`.claude/rules/*.md` with `paths:` frontmatter) — summarized away; only re-inject when Claude next reads a matching file path
- Subdirectory `CLAUDE.md` files — re-inject only when Claude reads a file in that directory
- Instructions given only in conversation, never written to a file

**Protocol:** Run `/compact` proactively at 60-70% context fill before auto-compact fires. Customize: `/compact Focus on [current task] and any architectural decisions made this session`. Non-negotiable rules belong in this file, not in scoped rules.

---

## Scoped Rules (technical projects only)

| File | Scope | What it covers |
|------|-------|----------------|
| `.claude/rules/server.md` | `server/**` | [e.g. API patterns, error handling] |
| `.claude/rules/migrations.md` | `migrations/**` | [e.g. naming conventions, schema rules] |

*Remove this section if not a technical project.*

---

## Standing Rules

1. **CLAUDE.md is the living document.** Update it after every significant session.
2. **MEMORY.md trigger rule.** Never write to MEMORY.md without an explicit trigger from the user. Surface candidate decisions at session close instead.
3. **Brief before build.** Every significant feature gets a written brief before implementation begins.
4. **No direct commits to production.** All changes go through review.
5. **Gotchas are permanent records.** When you discover something surprising, add it to Known Gotchas immediately.
6. **Equal stakeholder directive.** Shoot straight. No sycophancy, no hallucinations.

---

## Known Gotchas

[Empty until you discover them. Add immediately — don't wait.]

---

## Anti-Patterns

> **Note on enforcement:** CLAUDE.md is context, not enforced configuration. It's delivered as a user message and Claude can deprioritize rules in long sessions. For truly non-negotiable behavior, use hooks (see `~/.claude/hooks/`). The memory write rule below is the one most worth enforcing via hook if violations become a pattern.

- Never write to MEMORY.md without explicit user trigger
- [Add project-specific anti-patterns here]
