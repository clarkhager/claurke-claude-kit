# Cowork vs. Claude Code: what works where

This kit targets a hybrid workflow. Some pieces fire differently in each product. Quick reference.

## What works the same in both

- **rules-kit CLAUDE.md content** - the behavioral rules apply in both products. Anti-sycophancy spine, sparring-partner framing, response-shape rules, plan-before-coding, diagnostic mode triggers - all of these are content-level, and content loads the same way in both.
- **memory-kit templates** - CLAUDE.md, MEMORY.md, STATUS.md, PRIMER.md as content files. Both products read them the same way.
- **Voice rules from personal preferences** - load with every session in both products.

## What differs

### Loading mechanics

- **Claude Code**: `~/.claude/CLAUDE.md` auto-loads on every session. Project-root `CLAUDE.md` loads when you cd into the project.
- **Cowork**: `~/.claude/CLAUDE.md` does NOT auto-load. You paste the contents into Settings > Global Instructions once, and they apply across every Cowork session in that account. Project CLAUDE.md auto-loads when you connect Cowork to a folder.

### Hooks

- **Claude Code**: hooks fire reliably. memory-kit's `pre-compact.sh` saves a structured transcript backup before context compaction. `memory-check.sh` warns at session close if memory files weren't updated.
- **Cowork**: hooks DO NOT fire reliably as of February 2026 (see anthropics/claude-code issues #27398 and #40495). The hook scripts are installed but never run. You won't get automated transcript backups or end-of-session warnings.

### Skills

- **Both products** support skills installed at the account level. Install via Cowork's Plugins UI or Claude Code's `claude plugin install`. Once installed, the skill is available in both products in that account.

### MCPs

- **Cowork**: connect via Settings > Connectors. Each MCP requires OAuth or API key per account. Account-bound.
- **Claude Code**: configure via `.mcp.json` in project root or globally via settings.json. Some MCPs require additional account-level config too.
- **Cross-tool sync** (apc-cli, mcp-config-manager) can keep MCP configs aligned if you don't want to set up each tool separately.

## Failure modes specific to each

### Cowork-specific failure modes

- **Hooks dead**: any feature in memory-kit that relies on hooks (backup-on-compact, end-of-session warning) doesn't work. Plan to manually note important state to MEMORY.md or STATUS.md before ending Cowork sessions.
- **Manual paste step**: the rules-kit CLAUDE.md has to be pasted into Settings > Global Instructions once per account. If you change rules-kit and pull updates, you have to re-paste. The bootstrap script reminds you.
- **Persona drift in long sessions**: documented to degrade self-consistency by 30%+ after 8-12 turns. The sparring-partner framing weakens over time regardless of how well written the rules are.

### Claude Code-specific failure modes

- **CLAUDE.md compliance is still best-effort**. Research shows ~60-79% rule compliance on hard tasks. Hooks and tests are the deterministic enforcement layer; CLAUDE.md is the soft layer.
- **Per-project CLAUDE.md compaction loss**: path-scoped rules in subdirectory CLAUDE.md files don't survive `/compact` reliably. memory-kit's Compaction Safety section in the project CLAUDE.md template addresses this.

## When to use which product

My own pattern (adapt as needed):

- **Cowork**: knowledge work (inbox, calendar, meeting prep), ideation, brainstorming, system management, project planning, anything that doesn't directly involve writing or modifying code. Never codes.
- **Claude Code**: development. Writing code, modifying code, debugging, running tests, deploying. The pre-compact and memory-check hooks add safety here.
- **Handoff**: Cowork ideates and plans; when the conversation produces a build task, switch to Claude Code with the project memory files already populated.
