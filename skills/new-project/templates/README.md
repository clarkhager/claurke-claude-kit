# Vendored templates (Cowork fallback only)

These are copies of claurke-memory-kit's `templates/` (CLAUDE.md, MEMORY.md, STATUS.md, PRIMER.md).

**Canonical source is the claurke-memory-kit repo** (`~/.claude/memory-kit/templates/` on an installed machine). The Claude Code path of the new-project skill never reads these — it runs `scripts/new-project.sh`, which uses the live memory-kit. Only the Cowork branch (no real-machine bash) scaffolds from these copies.

**Re-sync on any memory-kit template change:**

```bash
cp ~/.claude/memory-kit/templates/{CLAUDE,MEMORY,STATUS,PRIMER}.md ~/.claude/claurke-kit/skills/new-project/templates/
```
