# claurke - colleague onboarding

**What this is:** a versioned, multi-machine Claude workflow with anti-sycophancy rules, project memory templates, and a personal voice profile. Originally built by Clark Hager for his own use; the public repos are designed to be forkable so anyone can adopt the same patterns.

**What this doc is:** a beginner-friendly walkthrough of how to adopt the system on your own machine. If you have Cowork installed and a GitHub account, you can be running with the full kit in 30-60 minutes.

---

## Why use this

Claude is powerful but ships with a default personality that's too agreeable, doesn't have strong opinions, and loses context between sessions. The claurke system fixes those things by layering:

- **Anti-sycophancy rules** - Claude operates as a sparring partner, not an assistant. Disagreement is a feature. Position changes require new evidence, not pressure.
- **Project memory templates** - every project gets CLAUDE.md (rules), MEMORY.md (decisions), STATUS.md (next move), PRIMER.md (origin story) so context survives across sessions.
- **Voice profile** - drafts Claude produces on your behalf sound like you, not like an AI, with a humanizer pass that catches the obvious tells.
- **Multi-machine sync** - the same rules work on every machine you sign into your Claude account from.
- **Bootstrap that just works** - one script sets up new machines or new accounts; another sets up new projects.

If you're constantly fighting Claude on "you're being too agreeable" or "this doesn't sound like me" or "I told you that yesterday, why don't you remember," this addresses all three.

---

## What you get when you adopt

- The full behavioral spine (~190 lines of rules covering anti-sycophancy, response shape, tool-use discipline, voice, coding behavior, skill management, diagnostic mode, memory write discipline)
- Memory-kit templates for new projects with type-aware scaffolding (code / knowledge / meta / sub-workspace)
- An operating manual (9 sections) you can reference when something breaks
- The `claurke-ops` skill that fires when you ask Claude about your setup
- The `claurke-onboarding` skill (this skill's sibling) that walks new machines through setup
- A bootstrap script that handles multi-machine sync
- Templates for your personal overlay (voice profile, MCP list, skills list, personal preferences)

---

## What you'll need

- **Claude Cowork** (https://www.anthropic.com/cowork) **or Claude Code** (https://docs.claude.com/en/docs/claude-code/overview) installed. Cowork is the friendlier path.
- **A GitHub account** (https://github.com/signup). You'll need one to fork the public kit repos and to create your own private overlay repo for identity files.
- **macOS or Linux.** The bootstrap and daily-backup scripts assume Unix; Windows would need WSL or manual adaptation.
- **30-60 minutes** for the initial setup. Less if you use the interview-driven flow.

---

## The recommended path: let Cowork drive the setup

Open Cowork. Start a fresh session. Type:

```
Install the claurke system for me.
```

The `claurke-onboarding` skill kicks in, interviews you about your adoption preferences and identity (multiple-choice questions where applicable), runs the install commands on your behalf, and surfaces the manual steps you have to do yourself (paste into Cowork settings, etc.). This is the friendliest path if you don't want to think about the architecture.

If you want to know what the skill is actually doing under the hood, read on. Otherwise just open Cowork and ask it to install.

---

## The three adoption paths

The interview asks which path fits. Pick before starting if you want to know what you're committing to.

### Path A: I want the whole thing

Fork the three public kits and adopt as-is. Use Clark's rules, his memory templates, his orchestrator. Adapt only your identity layer (voice profile, personal preferences). Time: 30 min if you have everything ready.

### Path B: I want just the behavioral rules

Clone the rules-kit, deploy it to your `~/.claude/CLAUDE.md`, paste into Cowork Global Instructions. Skip the project memory templates and the orchestrator. Time: 10 min. Good if you're already using your own project management approach and just want the anti-sycophancy spine.

### Path C: I want to customize before adopting

Fork the public kits. Edit the rules-kit CLAUDE.md to match your style (which rules to keep, which to soften, which to add). Then bootstrap from your fork instead of Clark's. Time: an hour or two depending on how much you customize.

---

## Manual install (if you don't want to use the interview)

These are the commands the `claurke-onboarding` skill runs on your behalf. You can do them yourself if you prefer.

### Step 1: Install prereqs

```bash
brew install gh git uv
brew install --cask obsidian  # only if you want Obsidian for knowledge work
gh auth login
```

### Step 2: Clone the kit and run bootstrap

```bash
gh repo clone clarkhager/claurke-claude-kit ~/.claude/claurke-kit
bash ~/.claude/claurke-kit/bootstrap.sh --starter
```

The `--starter` flag means "public skeleton only - skip the personal overlay" - which is what you want as a new adopter. (Without `--starter`, the bootstrap assumes Clark's personal overlay is being deployed.)

The bootstrap will:
- Clone the rules-kit and memory-kit
- Deploy the rules to `~/.claude/CLAUDE.md`
- Install the `claurke-ops` and `claurke-onboarding` skills to `~/.claude/skills/`
- Print the manual Cowork UI steps you have to do

### Step 3: Set up your own private overlay (for identity)

The public kits don't include your voice profile, MCP list, or personal preferences - those are your identity layer and should live in a private repo. Create one:

```bash
gh repo create <your-username>/claurke-personal-overlay --private --description "My personal overlay for the claurke system"
gh repo clone <your-username>/claurke-personal-overlay ~/.claude/claurke-kit/personal-overlay-repo
mkdir -p ~/.claude/claurke-kit/personal
```

Copy the templates and edit them:

```bash
cp ~/.claude/claurke-kit/personal/templates/voice-profile-template.md ~/.claude/claurke-kit/personal-overlay-repo/voice-profile.md
cp ~/.claude/claurke-kit/personal/templates/personal-preferences-template.md ~/.claude/claurke-kit/personal-overlay-repo/personal-preferences.md
# Edit both files with your name, voice rules, preferred tools, etc.
```

Symlink them into the overlay slot:

```bash
ln -sfn ~/.claude/claurke-kit/personal-overlay-repo/voice-profile.md         ~/.claude/claurke-kit/personal/voice-profile.md
ln -sfn ~/.claude/claurke-kit/personal-overlay-repo/personal-preferences.md  ~/.claude/claurke-kit/personal/personal-preferences.md
```

Commit and push the overlay:

```bash
cd ~/.claude/claurke-kit/personal-overlay-repo
git add -A && git commit -m "Initial overlay setup" && git push
```

### Step 4: Manual Cowork UI steps

The bootstrap can't automate Cowork's UI. Do these by hand:

1. **Cowork > Settings > General > Instructions for Claude** - paste the contents of `~/.claude/claurke-kit/personal-overlay-repo/personal-preferences.md`
2. **Cowork > Settings > Cowork > Global Instructions** - paste the contents of `~/.claude/CLAUDE.md`
3. **Cowork > Settings > Plugins** - install the Anthropic Skills bundle if you want the humanizer skill (required for voice rules to fire on drafts)

### Step 5: Verify

Open a fresh Cowork session and ask:

```
What are the five required elements of the impasse-surfacing artifact?
```

Expected: Claude responds with the five elements (position held, basis, what would change the position, three candidates you might be wrong about, an explicit ask).

If Claude can't answer, the rules aren't loading. Check that you pasted the rules-kit content into Cowork Global Instructions.

Next:

```
Draft a Slack message to my manager telling her the demo got pushed to Friday.
```

Expected: salutation per your voice profile, sign-off per your voice profile, no em dashes, no banned phrases.

If the draft looks wrong, your voice profile isn't loading. Re-check the symlink at `~/.claude/claurke-kit/personal/voice-profile.md`.

---

## The five-layer architecture (in case you want to understand)

The system is built around the idea that **each rule has exactly one home**. No duplication, no drift.

| Layer | Lives at | What it owns |
|---|---|---|
| 1. Personal Preferences | Cowork Settings > General > Instructions for Claude | Your identity (name, role, preferred tools), high-level working style, thin fallback baselines |
| 2. Cowork Global Instructions | Cowork Settings > Cowork > Global Instructions | The full rules-kit CLAUDE.md (behavioral spine) |
| 3. ~/.claude/CLAUDE.md | Your machine | Same as Layer 2, for Claude Code |
| 4. Project files | At each project root | Project-specific context (CLAUDE.md, MEMORY.md, STATUS.md, PRIMER.md) |
| 5. Personal overlay | ~/.claude/claurke-kit/personal/ | Voice profile, MCP list, skills list (loaded by reference at draft time) |

When two layers disagree: more specific wins (project > global), or follow the more restrictive rule.

Full details in `docs/operating-manual.md` section 1.

---

## Starting a new project

Once the kit is set up, creating a new project with the memory system is one command:

```bash
bash ~/.claude/claurke-kit/scripts/new-project.sh
```

The script interviews you (project type, language for code projects, what the project is, immediate next move) and produces a project folder with CLAUDE.md / MEMORY.md / STATUS.md / PRIMER.md all pre-populated. Four project types supported:

- **code** - tech projects, gets a `.gitignore` and `.claude/rules/` folder
- **knowledge** - notes / vault / non-code workspaces
- **meta** - cross-repo coordination projects
- **subworkspace** - auto-detected when the parent dir is already a project, inherits parent context

Full details in `docs/operating-manual.md` section 2.

---

## FAQ

**Q: Do I have to fork the public repos, or can I just clone?**
A: Cloning works. Fork only if you plan to customize the rules or templates and want your own version-controlled history.

**Q: What if I don't have Obsidian? Do I need it?**
A: No. Obsidian is for knowledge-work projects (BizzaBrain-style). If you're only doing code or notes-in-Cowork projects, skip the Obsidian install entirely.

**Q: Can I use this with claude.ai web (no Cowork)?**
A: Partially. Personal Preferences are the only layer that applies in claude.ai web. The personal preferences template has a thin fallback baseline of voice rules and behavioral rules for this case. The full behavioral spine and voice profile only load in Cowork or Claude Code.

**Q: I work at a company with strict policies. Can I use this?**
A: The public repos contain no sensitive data and no company-specific configuration. Your private overlay repo is where your identity lives - that stays under your control. Check with your company's security/IT before pushing to GitHub if you're unsure.

**Q: I want to add my own rules. Where do they go?**
A: Depends what kind. Behavioral rules go in your fork of rules-kit. Project-specific rules go in that project's CLAUDE.md. Voice rules go in voice-profile.md. Read `docs/operating-manual.md` section 1 (layering model) to know which slot to use.

**Q: What's the difference between `claurke-ops` and `claurke-onboarding`?**
A: `claurke-ops` is for operational questions about the system once you have it installed ("how do I update," "why aren't the rules firing," "set up a new project"). `claurke-onboarding` is specifically for the initial install flow on a new machine or for a new user.

**Q: How do I update later when the kits change?**
A: `bash ~/.claude/claurke-kit/bootstrap.sh --update`. This pulls the latest of both kits and offers to redeploy. Run on each machine.

**Q: What if something breaks?**
A: `docs/operating-manual.md` section 6 (troubleshooting) has the most common issues. Section 7 has recovery scenarios for nastier problems. The `claurke-ops` skill can also surface answers if you ask Claude directly.

---

## Where to get help

- **The operating manual:** `~/.claude/claurke-kit/docs/operating-manual.md` after install, or https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/operating-manual.md before. Nine sections, comprehensive.
- **The claurke-ops skill:** ask Claude directly about anything in the manual. The skill fires automatically when you ask operational questions.
- **GitHub issues:** https://github.com/clarkhager/claurke-claude-kit/issues. File bugs or improvement requests on the public kit.
- **Original author:** Clark Hager (https://github.com/clarkhager). He doesn't promise support but is reachable.

---

## A note on customization vs adoption

If you adopt the rules-kit as-is, you get Clark's specific voice and personality preferences baked into the behavioral rules. That's fine for many people - the rules are mostly universal (anti-sycophancy, response shape, tool-use discipline). The Clark-specific bits are mostly in the voice profile, which lives in your own overlay anyway.

If you want to customize:

1. Fork the rules-kit
2. Edit `rules/CLAUDE.md` to match your style
3. Point your bootstrap at your fork instead of Clark's (`gh repo clone <yourusername>/claurke-rules-kit ...`)
4. Pull updates from upstream when you want them: `git fetch upstream && git merge upstream/main`

The operating manual's section 8 (decision log) documents why each rule is the way it is - useful reading before you decide what to change.
