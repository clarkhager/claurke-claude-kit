# claurke-claude-kit

**My Claude workflow, externalized.** I sync it across my machines and accounts. You can fork it as a starting point for your own.

This repo is the orchestrator. It bootstraps a complete personal Claude setup on a new machine in one command: behavioral rules ([claurke-rules-kit](https://github.com/clarkhager/claurke-rules-kit)), per-project memory templates ([claurke-memory-kit](https://github.com/clarkhager/claurke-memory-kit)), the humanizer skill, and a checklist for the manual steps that can't be scripted (Cowork's global instructions, MCP connections).

Designed for a hybrid Cowork + Claude Code workflow. Cowork for knowledge work, ideation, system management. Claude Code for development. Handoffs from Cowork to Claude Code when a thought becomes a build task.

> **Fork-first warning:** this is mine. The rules, the voice profile reference, the workflow assumptions, the MCP list - all calibrated to me. If you want to use it, fork it, review what's in here, replace what's mine with what's yours. Don't blindly run my setup on your machine.

---

## Operating manual

For the comprehensive guide to running this system - daily operations, verification, updates, troubleshooting, recovery scenarios, and the decision log - see **[docs/operating-manual.md](docs/operating-manual.md)**.

This is the operator's reference. Read it before changing anything you don't understand. The quick-start section below gets you installed; the operating manual gets you unstuck.

---

## Quick start

### On a fresh machine (mine or yours)

```bash
gh repo clone clarkhager/claurke-claude-kit ~/.claude/claurke-kit
bash ~/.claude/claurke-kit/bootstrap.sh
```

### As a colleague (skip personal identity)

```bash
gh repo clone clarkhager/claurke-claude-kit ~/.claude/claurke-kit
bash ~/.claude/claurke-kit/bootstrap.sh --starter
```

The bootstrap script:

1. Clones the rules-kit and memory-kit repos to `~/.claude/`
2. Runs rules-kit's deploy.sh --global to install behavioral rules at `~/.claude/`
3. Checks for the humanizer skill and prints install instructions if missing
4. Prints the Cowork-specific manual steps (paste rules into Settings > Global Instructions, connect MCPs)
5. Tells you how to use `scripts/new-project.sh` for per-project memory setup

In `--starter` mode, the script skips the personal identity overlay so a colleague gets the generic skeleton.

---

## What's in here

| File | Purpose |
|------|--------|
| `bootstrap.sh` | One-command install on a new machine |
| `scripts/install-humanizer.sh` | Detects or guides install of the humanizer skill |
| `scripts/setup-mcps.sh` | Walks through MCP connection setup |
| `scripts/new-project.sh` | Wraps memory-kit's per-project deploy for a new project |
| `personal/` | Identity overlay (voice profile, secrets, account-specific files) - gitignored |
| **`docs/operating-manual.md`** | **The comprehensive operator's reference. Read this when something feels off.** |
| `docs/how-i-actually-use-this.md` | Narrative walkthrough of the workflow |
| `docs/personal-overlay.md` | What goes in `personal/` and why |
| `docs/new-machine-setup.md` | Checklist for setting up a new machine end-to-end |
| `docs/cowork-vs-claude-code.md` | What works where, and how the kits behave in each |

---

## How I actually use this

Cowork is my partner for knowledge work, ideation, system management, and project organization. It never codes - when a conversation becomes a build task, I hand off to Claude Code with the project context already captured in memory-kit files.

For any new project (work or personal), I run `bash scripts/new-project.sh /path/to/folder`. That gives me a folder with CLAUDE.md, MEMORY.md, STATUS.md, and PRIMER.md from memory-kit. The global behavioral rules from rules-kit are already loaded; the project files add the context.

For every Cowork session, the rules-kit CLAUDE.md is in Cowork's Settings > Global Instructions (pasted manually, one-time). The behavioral rules apply across every session. Memory-kit's project CLAUDE.md loads automatically when I connect Cowork to a project folder.

For every Claude Code session, the same rules-kit CLAUDE.md is at `~/.claude/CLAUDE.md` (loaded automatically by Claude Code). Same project files as Cowork loads when I cd into a project directory.

See `docs/how-i-actually-use-this.md` for the longer narrative, and `docs/operating-manual.md` for the operator's reference.

---

## Make it yours

Three things to swap when you fork:

1. **The personal overlay.** Everything in `personal/` is mine. Replace the voice profile reference with yours. Replace the MCP list with your tools. Replace the account-specific settings.
2. **The rules in claurke-rules-kit.** The behavioral rules in that repo were tuned through iterative testing against my specific failure modes. They probably mostly apply to you, but you should at least re-read the sparring-partner framing and the anti-sycophancy rules and decide what's calibrated to you vs. what's just calibrated to me.
3. **The memory-kit templates.** The CLAUDE.md, MEMORY.md, STATUS.md, PRIMER.md templates have some of my conventions baked in. Adapt the standing rules and the source-of-truth hierarchy to your team's conventions.

See `docs/personal-overlay.md` for the specific overlay pattern.

---

## Sync across my machines

My own future-reference, since I'll forget:

On a new machine, `gh repo clone clarkhager/claurke-claude-kit ~/.claude/claurke-kit && bash ~/.claude/claurke-kit/bootstrap.sh`.

The personal overlay lives outside this repo (in a private gist or second private repo) and gets symlinked or cloned into `personal/` after bootstrap. Account-specific differences (work vs personal Claude account) live in the overlay, not the public repo.

When the rules-kit or memory-kit changes, run `bash ~/.claude/claurke-kit/bootstrap.sh --update`. The operating manual has the full update workflow including the Cowork re-paste rules.

---

## Credits and lineage

Built on top of:

- [HumanLayer's CLAUDE.md guidance](https://www.humanlayer.dev/blog/writing-a-good-claude-md) - the canonical methodology in this space.
- [Mathias Bynens's dotfiles](https://github.com/mathiasbynens/dotfiles) - the dual-purpose framing that lets one repo serve both personal sync and colleague onboarding.
- [Karpathy's distilled CLAUDE.md](https://github.com/multica-ai/andrej-karpathy-skills/blob/main/CLAUDE.md) - the four-principle pattern for behavioral rules.
- [Anthropic's knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins) - the structural reference for plugin-style layout.
- [Harper Reed's dotfiles](https://github.com/harperreed/dotfiles) - proof that the dotfiles-embedded `.claude/` pattern works for personal sync.

The two kits this repo orchestrates:

- [claurke-rules-kit](https://github.com/clarkhager/claurke-rules-kit) - universal behavioral rules
- [claurke-memory-kit](https://github.com/clarkhager/claurke-memory-kit) - per-project memory templates
