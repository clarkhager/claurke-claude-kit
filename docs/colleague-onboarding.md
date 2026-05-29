# claurke - colleague onboarding

**What this is:** a versioned, multi-machine Claude workflow with anti-sycophancy rules, project memory templates, and a personal voice profile. Originally built by Clark Hager for his own use; the public repos are designed to be forkable so anyone can adopt the same patterns.

**Who this is for:** anyone who uses Claude Cowork or Claude Code and wants a more opinionated, less agreeable, more memory-aware setup than the defaults. You don't need to be a developer. The recommended install path uses one terminal command, then a few clicks in Cowork.

---

## The recommended install (one terminal command + a few clicks in Cowork)

### Step 1: Open Terminal

On your Mac, press **Cmd + Space**, type `Terminal`, and press Enter. A black window will open. That's Terminal. It looks intimidating but you're only going to paste one thing.

### Step 2: Paste this exact command into Terminal, then press Enter

```bash
curl -fsSL https://raw.githubusercontent.com/clarkhager/claurke-claude-kit/main/install.sh -o /tmp/claurke-install.sh && bash /tmp/claurke-install.sh
```

**What this does** (so you're not pasting blindly):

- Installs Homebrew if you don't have it (Homebrew is the standard Mac package manager - it's what lets you install developer tools)
- Installs `git` (version control) and `gh` (GitHub command-line tool) if you don't already have them
- Opens your browser so you can log in to GitHub (create an account at https://github.com/signup if you don't have one)
- Downloads the claurke kit to a hidden folder in your home directory (`~/.claude/claurke-kit`)
- Runs the bootstrap script which installs two helper skills at the filesystem level

When it finishes (5-15 minutes depending on what was already installed), it prints "Terminal install complete!" and tells you what to do next in Cowork.

### Step 3: Add the claurke marketplace in Cowork (one-time setup)

Open Cowork. Go to **Settings > Plugins > Personal tab** and click the **+** button to add a new marketplace.

In the URL field, paste:

```
clarkhager/claurke-claude-kit
```

Click **Sync**. A new marketplace tab named `claurke` (or similar) appears.

### Step 4: Install the claurke-onboarding plugin

Click into the new `claurke` marketplace tab. You will see two plugins:

- **claurke-onboarding** - this is the install skill
- **claurke-ops** - operational helper for after install

Click the **+** button next to `claurke-onboarding` to install it. (You can install `claurke-ops` later or now; it does not affect onboarding.)

### Step 5: Start a fresh Cowork session and ask Claude to install

Start a fresh Cowork session. Type:

```
install claurke for me
```

That triggers the `claurke-onboarding` skill you just installed. The skill asks you a few interview questions (multiple choice where possible):

- Which adoption path - full / rules-only / customize
- Your GitHub username
- Voice preferences - your salutation style, sign-off, whether you want em dashes banned, etc.
- Personal preferences - your name, role, preferred tools, AI assistant name

Then it creates your own private GitHub repo for your identity files, populates your voice profile and personal preferences from your answers, and surfaces the last three manual steps (which are paste-into-Cowork-settings operations that Claude can't click for you).

### Step 6: The three manual paste steps

The skill will tell you when to do these. They're three settings in Cowork that you have to paste into yourself:

1. **Cowork > Settings > General > Instructions for Claude** - paste your personal preferences file
2. **Cowork > Settings > Cowork > Global Instructions** - paste the behavioral rules file
3. **Cowork > Settings > Plugins** - install the Anthropic Skills bundle (for humanizer skill, which makes voice rules fire on drafts)

The skill prints the file paths and offers to display the contents so you can copy them quickly.

### Step 7: Verify

Open a fresh Cowork session and ask Claude:

```
What are the five required elements of the impasse-surfacing artifact?
```

If Claude responds with five elements (position held, basis, what would change the position, three candidates you might be wrong about, an explicit ask), the rules are loaded.

Then test voice rules:

```
Draft a Slack message to my manager telling her the demo got pushed to Friday.
```

If the draft uses your salutation style, your sign-off, no em dashes, and no AI-tell phrases ("I'd be happy to," "straightforward," etc.), your voice profile is loaded.

Done.

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
- The `claurke-onboarding` skill (used in Step 4 above) that walks new machines through setup
- A bootstrap script that handles multi-machine sync
- Templates for your personal overlay (voice profile, MCP list, skills list, personal preferences)

---

## What you'll need

- **Claude Cowork** (https://www.anthropic.com/cowork) **or Claude Code** (https://docs.claude.com/en/docs/claude-code/overview) installed. Cowork is the friendlier path.
- **A GitHub account** (https://github.com/signup). You'll create one in Step 2 if you don't have one - the installer opens your browser to log in.
- **macOS or Linux.** The bootstrap and daily-backup scripts assume Unix. Windows users need WSL or the manual path.
- **15-30 minutes** for the initial setup using the one-liner. Faster if everything's already installed.

---

## The three adoption paths (the skill asks which you want)

### Path A: I want the whole thing

Fork the three public kits and adopt as-is. Use Clark's rules, his memory templates, his orchestrator. Adapt only your identity layer (voice profile, personal preferences). Time: 30 min if you have everything ready. **Recommended for first-time adopters.**

### Path B: I want just the behavioral rules

Clone the rules-kit, deploy it to your `~/.claude/CLAUDE.md`, paste into Cowork Global Instructions. Skip the project memory templates and the orchestrator. Time: 10 min. Good if you're already using your own project management approach and just want the anti-sycophancy spine.

### Path C: I want to customize before adopting

Fork the public kits. Edit the rules-kit CLAUDE.md to match your style (which rules to keep, which to soften, which to add). Then bootstrap from your fork instead of Clark's. Time: an hour or two depending on how much you customize.

---

## Manual install (if you don't want to use the one-liner)

The one-liner runs these commands for you. You can run them yourself if you'd rather see each step.

### Step 1: Install prereqs

```bash
brew install gh git
gh auth login
```

### Step 2: Clone the kit and run bootstrap

```bash
gh repo clone clarkhager/claurke-claude-kit ~/.claude/claurke-kit
bash ~/.claude/claurke-kit/bootstrap.sh --starter
```

### Step 3: Add the claurke marketplace in Cowork

Same as the recommended path - Cowork > Settings > Plugins > Personal > click `+` > paste `clarkhager/claurke-claude-kit` > Sync. Then install the `claurke-onboarding` plugin from the new marketplace tab.

### Step 4: Open Cowork and run the onboarding skill

Start a fresh Cowork session. Type:

```
install claurke for me
```

The skill picks up from there.

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

**Q: Why curl-pipe-to-bash? Isn't that a security risk?**
A: It's the same pattern Homebrew uses. You're trusting that this repo's install.sh isn't malicious. You can read the script first at https://github.com/clarkhager/claurke-claude-kit/blob/main/install.sh if you want to verify.

**Q: I added the marketplace but Cowork shows 'Repository not accessible'. What now?**
A: Click the "Install the Claude GitHub App" link in the modal that appears, grant access to the `clarkhager/claurke-claude-kit` repo (or all repos in your account if you trust the Claude GitHub App), then come back and click Sync again.

**Q: The marketplace add doesn't work even after granting the GitHub App. What's the fallback?**
A: The skill files are already on your disk from Step 2. You can paste this prompt into a fresh Cowork session instead of "install claurke for me": `Walk me through installing Clark Hager's claurke system on my Mac. The kit is already installed at ~/.claude/claurke-kit. Read the file ~/.claude/skills/claurke-onboarding/SKILL.md for the full interview flow, then guide me through it step by step using multiple-choice questions where applicable.` This tells Cowork explicitly to read the skill file from disk and run the interview. Same result, just one extra prompt.

**Q: Do I have to fork the public repos, or can I just clone?**
A: Cloning works. Fork only if you plan to customize the rules or templates and want your own version-controlled history.

**Q: What if I don't have Obsidian? Do I need it?**
A: No. Obsidian is for knowledge-work projects. If you're only doing code or notes-in-Cowork projects, skip the Obsidian install entirely.

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
- **The claurke-ops skill:** ask Claude directly about anything in the manual. The skill fires automatically when you ask operational questions (once it's installed).
- **The claurke-onboarding skill:** the install skill. Asking "install claurke" or "set up claurke" in any fresh Cowork session triggers it (once it's installed via the marketplace).
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
