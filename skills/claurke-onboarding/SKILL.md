---
name: claurke-onboarding
description: Walks new users through adopting the claurke system - Clark Hager's versioned multi-machine Claude workflow with anti-sycophancy rules, project memory templates, and voice profile. Use whenever someone says "install claurke", "set up claurke", "onboard me to claurke", "set up the claurke system", "I want to use Clark's Claude workflow", "help me get the claurke system running", "get me started with claurke", "set up Claude on my machine like Clark's", or similar. Drive the install with AskUserQuestion for multiple-choice prompts (adoption path, prereq install, voice preferences) and bash for actual install commands (gh repo clone, bootstrap.sh, gh repo create for overlay). Surface manual Cowork UI steps clearly when reached - Claude cannot click those for the user, only describe them. Fire even when the user doesn't say "claurke" explicitly if they're asking to set up a behavioral-rules + memory + voice-profile Claude workflow.
---

# claurke-onboarding

You're walking a new user through adopting Clark Hager's claurke system. The system is five GitHub repos plus a personal overlay - read `docs/colleague-onboarding.md` from the kit if you need the full context: https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/colleague-onboarding.md

Your job is to make adoption feel guided. The user may be a beginner with Claude. Be patient, surface manual steps clearly, use the available tools to do the work where you can.

## Tools at your disposal

- **AskUserQuestion** - use this for ALL multiple-choice prompts. Don't just type questions in chat; the structured UI is friendlier.
- **bash** - use this to run install commands. Always show what you're about to run before running it.
- **Read** - read the operating manual, the colleague onboarding doc, or any other file if you need context mid-flow.

## The interview-driven flow

Walk through these steps in order. Use AskUserQuestion at each decision point.

### Step 0: Welcome and confirm intent

Greet the user. Confirm they want to install claurke. If they're unclear what claurke is, give a one-paragraph summary (versioned multi-machine Claude workflow with anti-sycophancy rules, project memory, voice profile, bootstrap script) and point at the full doc at https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/colleague-onboarding.md.

### Step 1: Check prerequisites

Run bash to check what they have:

```bash
for tool in gh git brew; do
  if command -v $tool >/dev/null 2>&1; then
    echo "✓ $tool installed at $(which $tool)"
  else
    echo "✗ $tool MISSING"
  fi
done
```

If anything is missing, use AskUserQuestion to ask if they want you to install it. If they say yes, run `brew install <tool>` for them. If brew itself is missing, give them the install command (https://brew.sh/) and pause until they confirm it's installed.

Then check gh auth:

```bash
gh auth status 2>&1 | head -5
```

If they're not logged in, instruct them to run `gh auth login` and confirm when they're done. You can't run interactive auth flows on their behalf.

### Step 2: Adoption path interview

Use AskUserQuestion to ask which adoption path they want. Three options:

- **Full adoption** - clone the public kits as-is, set up their own private overlay for identity. Most common path.
- **Rules only** - just the behavioral rules (rules-kit) deployed to `~/.claude/CLAUDE.md` and Cowork Global Instructions. No memory templates, no overlay. Good for users who already have their own project management approach.
- **Fork and customize** - fork the public kits to their GitHub, customize before deploying. Most work upfront but most flexibility.

Based on their answer, skip steps that don't apply.

### Step 3: GitHub username

Use AskUserQuestion or bash (`gh api user --jq .login`) to determine their GitHub username. Need this for two things: cloning the kit and creating their private overlay repo.

### Step 4: Run bootstrap (Full or Fork paths)

Clone the kit and run bootstrap:

```bash
gh repo clone clarkhager/claurke-claude-kit ~/.claude/claurke-kit
bash ~/.claude/claurke-kit/bootstrap.sh --starter
```

The `--starter` flag tells bootstrap to skip the personal overlay step (which is Clark-specific). Bootstrap will:
- Clone rules-kit and memory-kit
- Deploy the rules to `~/.claude/CLAUDE.md`
- Install the `claurke-ops` and `claurke-onboarding` skills to `~/.claude/skills/`
- Print manual Cowork UI steps for later

For the Rules-only path, skip the memory-kit deploy. Modify the command:

```bash
gh repo clone clarkhager/claurke-rules-kit ~/.claude/rules-kit
bash ~/.claude/rules-kit/deploy.sh --global
```

### Step 5: Create their private overlay (Full or Fork paths)

Ask them what to call their overlay repo (default: `claurke-personal-overlay`). Then:

```bash
gh repo create <username>/<overlay-repo-name> --private --description "Personal overlay for the claurke system"
gh repo clone <username>/<overlay-repo-name> ~/.claude/claurke-kit/personal-overlay-repo
mkdir -p ~/.claude/claurke-kit/personal
```

Copy the templates into the overlay:

```bash
cp ~/.claude/claurke-kit/personal/templates/voice-profile-template.md ~/.claude/claurke-kit/personal-overlay-repo/voice-profile.md
cp ~/.claude/claurke-kit/personal/templates/personal-preferences-template.md ~/.claude/claurke-kit/personal-overlay-repo/personal-preferences.md
```

### Step 6: Voice profile interview

Use AskUserQuestion (multi-select for some) to ask:

- **Salutation style** - "Hey [Name] -" (Clark's pattern) / "Hi [Name]," (standard) / "Other (specify)"
- **Sign-off** - "Thank you," (Clark's pattern) / "Best," / "Cheers," / "Other (specify)"
- **Em dashes** - Banned (use space-hyphen-space) / Allowed / Allowed sparingly
- **Contractions** - Use naturally / Avoid / Mixed depending on register
- **Tone defaults** - Direct and honest / Warm and supportive / Concise / Formal

For each answer, write into voice-profile.md via Edit or by running sed. Tell them they can fill in voice examples (real messages they've sent) later when they have 20 min.

### Step 7: Personal preferences interview

Use AskUserQuestion to ask:

- **Their name** (will go in the identity section)
- **Their role** (1 line)
- **Preferred AI assistant name** - default to their actual name or pick one ("Jeeves" is Clark's; anything works)
- **Primary tools they use** (comma-separated: Gmail, Slack, Notion, etc.)
- **Response length preference** - Match the task / Short by default / Detailed by default

Write into personal-preferences.md.

### Step 8: Symlink the overlay into the kit slot

```bash
ln -sfn ~/.claude/claurke-kit/personal-overlay-repo/voice-profile.md         ~/.claude/claurke-kit/personal/voice-profile.md
ln -sfn ~/.claude/claurke-kit/personal-overlay-repo/personal-preferences.md  ~/.claude/claurke-kit/personal/personal-preferences.md
```

### Step 9: Commit and push the overlay

```bash
cd ~/.claude/claurke-kit/personal-overlay-repo
git add -A
git commit -m "Initial overlay setup"
git push
```

### Step 10: Surface the manual Cowork UI steps

You cannot click Cowork's UI. Tell the user clearly that these are their job:

1. **Cowork > Settings > General > Instructions for Claude** - paste contents of `~/.claude/claurke-kit/personal-overlay-repo/personal-preferences.md`
2. **Cowork > Settings > Cowork > Global Instructions** - paste contents of `~/.claude/CLAUDE.md`
3. **Cowork > Settings > Plugins** - install the Anthropic Skills bundle (for humanizer skill - required for voice rules to fire on drafts)

Print the file paths and offer to `cat` each file so they can copy the contents quickly. Tell them to come back to this session after pasting so you can verify.

### Step 11: Verify the install

Once they confirm they've pasted, instruct them to open a fresh Cowork session (not this one) and ask:

```
What are the five required elements of the impasse-surfacing artifact?
```

Expected response: position held, basis, what would change the position, three candidates you might be wrong about, an explicit ask.

If that works, ask them to test voice rules:

```
Draft a Slack message to my manager telling her the demo got pushed to Friday.
```

Expected: salutation per their voice profile, sign-off per their voice profile, no em dashes, no banned phrases.

If either test fails, walk them through troubleshooting (operating manual section 6) - most common issues are stale paste or missing humanizer skill.

### Step 12: Optional - add daily backup

Use AskUserQuestion to ask if they want a daily backup job for their overlay repo (recommended). If yes, walk them through the script + launchd plist setup from operating-manual.md section 2 (daily operations) or section 9 (implementation gotchas) of the operating manual.

For users on the Rules-only path, daily backup may be unnecessary - their overlay doesn't exist.

### Step 13: Done

Congratulate them. Point them at:

- `~/.claude/claurke-kit/docs/operating-manual.md` for ongoing reference
- The `claurke-ops` skill for operational questions (fires automatically when they ask)
- `bash ~/.claude/claurke-kit/scripts/new-project.sh` to start their first project with the memory system

## Guardrails

- Always show the command you're about to run before running it. Let them see what's happening.
- For destructive commands (`rm`, `gh repo delete`, `mv`), pause and ask before executing.
- If the user is unsure at any step, default to the safer option (more confirmation, less automation).
- If something fails, surface the actual error - don't paper over it. The operating manual's troubleshooting section has fixes for the most common ones.
- Apply Clark's voice rules to drafts you produce on the new user's behalf only if they explicitly want Clark's style. Their voice profile (in their own overlay) is the source of truth for their drafts.

## Common failure modes

- **gh not authenticated** - they need to run `gh auth login` themselves; can't be automated.
- **brew not installed on macOS** - point them at https://brew.sh; pause until they confirm install.
- **Existing files at target paths** - bootstrap and overlay scripts are non-destructive (skip existing files). If they have a prior install attempt, surface the existing files and ask whether to keep, overwrite, or back up.
- **Cowork settings paste fails to load** - the most common verification failure. Re-instruct them on which slot is which (General vs Cowork tab); the two are easy to mix up.
- **Voice rules don't fire on drafts** - humanizer skill probably isn't installed. Walk them through Cowork > Settings > Plugins > Anthropic Skills bundle.

## References

- Colleague onboarding doc: https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/colleague-onboarding.md
- Operating manual (canonical): https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/operating-manual.md
- claurke-ops skill (sibling, for operational questions post-install)
- Bootstrap script: ~/.claude/claurke-kit/bootstrap.sh
