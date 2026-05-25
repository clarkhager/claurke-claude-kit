# New machine setup

Quick reference for setting up Claude on a new machine end-to-end.

## Prereqs

Install first:

- **git** - any recent version
- **gh CLI** - https://cli.github.com/ - for cloning the repos. Falls back to https clone if not installed.
- **Cowork app** - if you'll use it. Download from Anthropic.
- **Claude Code** - if you'll use it. `npm install -g @anthropic-ai/claude-code` or via the install script.

Sign in to your Claude account in both apps before continuing.

## One-command bootstrap

```bash
gh repo clone clarkhager/claurke-claude-kit ~/.claude/claurke-kit
bash ~/.claude/claurke-kit/bootstrap.sh
```

The bootstrap will:

1. Clone rules-kit and memory-kit to `~/.claude/`
2. Deploy rules-kit at the global level (lands at `~/.claude/CLAUDE.md`)
3. Check for the humanizer skill, print install instructions if missing
4. Print MCP setup notes
5. Tell you about the personal overlay (skipped in `--starter` mode)
6. Print Cowork-specific manual steps (paste rules into Settings, connect MCPs)

## Manual steps after bootstrap

### Cowork side (not scriptable)

1. Open Cowork > Settings > Global Instructions. Paste contents of `~/.claude/CLAUDE.md`. Save.
2. Open Cowork > Settings > Connectors. Connect the MCPs you use (Gmail, Slack, Notion, etc.). Each requires OAuth in your account.
3. Open Cowork > Settings > Plugins. Verify the Anthropic Skills bundle is installed (for humanizer). Install any other plugins you use.

### Personal overlay (for personal sync, not for --starter mode)

1. Clone your private personal-overlay repo (if you maintain one) into `~/.claude/claurke-kit/personal/`
2. Or manually populate `personal/` with your voice profile, MCP list, account notes

## Verify

In Cowork, in a fresh session, ask: *"What are the five required elements of the impasse-surfacing artifact?"*

Expected: position held, basis, what would change the position, three things you might be wrong about ordered by likelihood, an explicit ask.

If Claude can't answer or makes something up, the rules-kit CLAUDE.md isn't loaded into Cowork. Re-check step 1 of the Cowork manual steps above.

In Claude Code, cd into a project that has memory-kit installed, run `claude`, and ask the same question. Should produce the same answer.

## When you start a new project

```bash
bash ~/.claude/claurke-kit/scripts/new-project.sh /path/to/project
```

This wraps memory-kit's deploy.sh and gives you the per-project files (CLAUDE.md, MEMORY.md, STATUS.md, PRIMER.md).

## Updating later

When rules-kit or memory-kit changes:

```bash
bash ~/.claude/claurke-kit/bootstrap.sh --update
```

This runs check-updates.sh on both kits and offers to redeploy.
