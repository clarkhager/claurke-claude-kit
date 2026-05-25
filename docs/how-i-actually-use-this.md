# How I actually use this

The narrative walkthrough of the workflow this kit supports.

## The two products

**Cowork** is my partner for knowledge work, ideation, system management, and project organization. It never codes. When a conversation in Cowork becomes a build task, I hand off to Claude Code with the project context already captured in memory-kit files (CLAUDE.md, MEMORY.md, STATUS.md, PRIMER.md). The handoff works because both products read the same files.

**Claude Code** is for development. Everything that involves writing or modifying code. Claude Code respects hooks (memory-kit's pre-compact and memory-check fire normally), runs the rules-kit behavioral rules from `~/.claude/CLAUDE.md`, and loads project memory from the project's CLAUDE.md when I cd into a project folder.

## A typical day

Morning: Cowork session for inbox triage, calendar review, ideation around something I'm working on. Rules-kit's anti-sycophancy spine is active (it's pasted into Cowork's Global Instructions). If I'm in a specific project folder that Cowork is connected to, memory-kit's project CLAUDE.md is also loaded.

Midday: a project conversation in Cowork - planning, brainstorming, system design. Diagnostic mode triggers automatically when I push back on a stated diagnosis or when the same problem has been worked across more than two turns. The reasoning artifacts (three hypotheses, falsification tests, elimination chain) keep the model honest.

When a discussion becomes a build task, I switch to Claude Code. The same rules-kit CLAUDE.md is loaded (from `~/.claude/CLAUDE.md`). I cd into the project folder and memory-kit's project files load. The conversation continues from where Cowork left off, with the context preserved in the memory files.

Evening or end of session: in Claude Code, memory-kit's hooks fire automatically - the pre-compact hook saves a structured transcript backup before context compaction; the memory-check hook warns me at session close if no memory files were updated during significant work.

## What's where

- **Universal behavioral rules** (anti-sycophancy, sparring-partner framing, response shape, diagnostic mode): rules-kit, deployed globally to `~/.claude/CLAUDE.md`. Loaded by Claude Code automatically. Pasted into Cowork's Global Instructions once.
- **Per-project memory** (project context, decisions, live state, narrative): memory-kit, deployed to each project's root. Loaded by both Cowork and Claude Code when I'm in that project.
- **Voice rules** (salutation, sign-off, banned AI-tells, em-dash prohibition, contractions, length matching): my Claude account's personal preferences. Loads with every session in both products. Independent of these kits.
- **Skills** (humanizer, daily-wrap, inbox-triage, weekly-review, etc.): installed at the account level via Cowork's plugin system or Claude Code's `claude plugin install`. Independent of these kits.
- **MCPs** (Gmail, Slack, Notion, etc.): connected at the account level via each product's Settings > Connectors. Manually configured per account.
- **Personal identity overlay** (voice profile if I create one, account-specific MCP list, secrets references): `personal/` in this repo, gitignored, synced separately.

## Handoff flow (Cowork to Claude Code)

The handoff works because the kits standardize what context lives where:

1. In Cowork, the project's MEMORY.md captures decisions, the STATUS.md captures the live next move, and the conversation produces candidate notes for either file.
2. At a handoff point, I either explicitly write to MEMORY.md (using a trigger phrase per memory-kit's write rule) or let session-close ritual surface candidate notes.
3. I open the project in Claude Code. It reads the same CLAUDE.md, MEMORY.md, STATUS.md, PRIMER.md. The context is preserved.
4. Claude Code does the actual code work. When done, the memory-kit hooks fire, capturing the transcript backup and warning if memory files weren't updated.
5. Back in Cowork later, the updated MEMORY.md and STATUS.md reflect what Claude Code did.

## What I get from each layer

- **rules-kit**: every Claude session, regardless of project or product, gets the same anti-sycophancy and reasoning rules. Consistent behavior across contexts.
- **memory-kit**: each project has the same structure (CLAUDE.md, MEMORY.md, STATUS.md, PRIMER.md) so context isn't lost when I switch projects or when a session compacts. Consistent context across sessions.
- **claurke-claude-kit (this repo)**: a new machine takes one command to set up. A colleague can fork and adapt without me explaining every piece.
