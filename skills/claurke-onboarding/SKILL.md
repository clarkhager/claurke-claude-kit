---
name: claurke-onboarding
description: Walks new users through adopting the claurke system - Clark Hager's versioned multi-machine Claude workflow with anti-sycophancy rules, project memory templates, and voice profile. Use whenever someone says "install claurke", "set up claurke", "onboard me to claurke", "set up the claurke system", "I want to use Clark's Claude workflow", "help me get the claurke system running", "get me started with claurke", "set up Claude on my machine like Clark's", or similar. This skill runs an interactive interview using AskUserQuestion (adoption path, voice preferences, personal preferences) and outputs the generated voice-profile.md and personal-preferences.md content in chat for the user to save to their Mac. It assumes the user has already run the install.sh one-liner from their terminal, which installed Homebrew, gh CLI, and cloned the kit. The skill cannot run bash on the user's actual Mac - Cowork's bash runs in a sandboxed environment - so it surfaces terminal commands for the user to run themselves in their own Terminal app. Fire even when the user doesn't say "claurke" explicitly if they're asking to set up a behavioral-rules + memory + voice-profile Claude workflow.
---

# claurke-onboarding

You're walking a new user through adopting Clark Hager's claurke system. The system is five GitHub repos plus a personal overlay - read `docs/colleague-onboarding.md` from the kit if you need the full context: https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/colleague-onboarding.md

Your job is to make adoption feel guided. The user may be a beginner with Claude. Be patient, surface manual steps clearly, and use the interview tools to do the work where you can.

## Critical: how this skill actually works

You're running inside Cowork. Cowork's bash runs in a sandboxed Linux environment that **cannot see or modify the user's actual Mac**. Commands like `brew install`, `gh auth login`, `git clone`, or anything touching `~/.claude/` won't reach their machine.

What this means in practice:

- **Do not run bash to check prereqs.** It checks the sandbox, not their Mac. The sandbox doesn't have brew or gh installed.
- **Do not run bash to install anything on their Mac.** It can't. Installation already happened via the `install.sh` one-liner they ran in their own Terminal before getting here.
- **Do not run bash to clone repos or write files in `~/.claude/`.** It would write to the sandbox, not their Mac.
- **DO use bash** if you want to generate or transform text in scratch space, but anything the user needs on their machine has to be either (a) shown in chat for them to paste into TextEdit + save, or (b) handed to them as a terminal command for them to run themselves.

Your real job is the interview. Generate the right `voice-profile.md` and `personal-preferences.md` content based on their answers, then walk them through saving those files and pasting into Cowork settings.

## Tools at your disposal

- **AskUserQuestion** - use this for ALL multiple-choice prompts. Don't just type questions in chat; the structured UI is friendlier.
- **Read** - read this skill or the colleague onboarding doc if you need context mid-flow.

## The interview-driven flow

Walk through these steps in order. Use AskUserQuestion at each decision point.

### Step 0: Welcome and confirm intent

Greet the user. Confirm they want to install claurke. If they're unclear what claurke is, give a one-paragraph summary (versioned multi-machine Claude workflow with anti-sycophancy rules, project memory, voice profile, bootstrap script) and point at the full doc at https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/colleague-onboarding.md.

### Step 1: Confirm install.sh has been run

Use AskUserQuestion to ask:

> Have you already run the install.sh one-liner from your Terminal? (The one starting with `curl -fsSL https://raw.githubusercontent.com/clarkhager/claurke-claude-kit/main/install.sh...`)

Options:
- **Yes, I ran it and it completed successfully** (Recommended)
- **Yes, but I hit errors partway through**
- **No, I haven't run it yet**

Routing:
- **Yes, completed**: proceed to Step 2.
- **Errors partway**: ask what error they saw. Most common: smart-quote replacement when pasting (give them the alternate command), gh auth login interrupted (have them re-run `gh auth login` themselves and confirm), repo clone failure (verify the repo URL and their gh auth). Do not try to fix via Cowork's bash - give them the command to run in their own Terminal.
- **Haven't run it yet**: give them the one-liner to paste into Terminal:

```
curl -fsSL https://raw.githubusercontent.com/clarkhager/claurke-claude-kit/main/install.sh -o /tmp/claurke-install.sh && bash /tmp/claurke-install.sh
```

Pause until they confirm it finished.

### Step 2: Adoption path

Use AskUserQuestion to ask which path:

- **Full adoption** (Recommended) - kits + personal overlay for identity. Most common.
- **Rules only** - just behavioral rules deployed to `~/.claude/CLAUDE.md` and Cowork Global Instructions. No memory templates, no overlay. For users who already have their own project management approach.
- **Fork and customize** - they fork the public kits to their GitHub and customize before deploying. Most flexibility, most upfront work. Tell them this path is mostly out of scope for the interactive walkthrough - point them at the operating manual.

For **Rules only**: skip steps 5, 6, and the overlay parts of step 7. They still need step 4 (personal preferences) for Cowork Global Instructions paste.

### Step 3: GitHub username

Use AskUserQuestion to ask for their GitHub username (free-text). You'll use it later for the overlay repo command.

### Step 4: Voice profile interview

Skip this for Rules-only path.

Use AskUserQuestion (one question at a time) to ask:

- **Salutation style** - "Hey [Name] -" (Clark's pattern) / "Hi [Name]," (standard) / "Other (specify)"
- **Sign-off** - "Thank you," (Clark's pattern) / "Best," / "Cheers," / "Other (specify)"
- **Em dashes** - Banned (use space-hyphen-space) / Allowed / Allowed sparingly
- **Contractions** - Use naturally / Avoid / Mixed depending on register
- **Tone defaults** - Direct and honest / Warm and supportive / Concise / Formal

Save their answers internally. You'll use them in Step 6.

### Step 5: Personal preferences interview

Use AskUserQuestion to ask:

- **Their name** (free-text, will go in the identity section)
- **Their role** (free-text, 1 line)
- **Preferred AI assistant name** - default to "Jeeves" (Clark's), or their own pick (free-text)
- **Primary tools they use** (multi-select: Gmail, Google Calendar, Slack, Notion, Asana, Linear, GitHub, Other)
- **Response length preference** - Match the task / Short by default / Detailed by default

Save their answers. You'll use them in Step 7.

### Step 6: Generate and output voice-profile.md

Skip this for Rules-only path.

Build the voice-profile.md content based on their Step 4 answers. Use Clark's voice-profile.md as the structural template (salutation rule, sign-off rule, punctuation rule, contractions rule, tone rule, banned phrases list, enforcement note) but with their preferences filled in.

Output the full content in a code block in chat. Tell them clearly:

> Copy the content between the lines below. Open TextEdit on your Mac, create a new plain text document (Format > Make Plain Text), paste the content, save it as `voice-profile.md` (with `.md` extension, NOT `.txt`) anywhere you can find it - your Desktop works.
>
> Then in Terminal, run:
>
> ```
> mv ~/Desktop/voice-profile.md ~/.claude/claurke-kit/personal/voice-profile.md
> ```

Wait for them to confirm they saved + moved the file.

### Step 7: Generate and output personal-preferences.md

Build the personal-preferences.md content based on their Step 5 answers. Use Clark's personal-preferences-clean.md as the structural template, with their preferences filled in.

Output the full content in a code block in chat. Tell them:

> Copy the content between the lines below. Open TextEdit, create a new plain text document, paste, save as `personal-preferences.md` to your Desktop.
>
> Then in Terminal:
>
> ```
> mv ~/Desktop/personal-preferences.md ~/.claude/claurke-kit/personal/personal-preferences.md
> ```
>
> Also keep a copy handy - you'll paste this content into Cowork settings in Step 9.

For Rules-only path: skip the move command (no `~/.claude/claurke-kit/personal/` folder exists for them). They just need the content to paste into Cowork settings.

### Step 8: Set up the personal overlay repo (Full adoption only)

Skip this for Rules-only path.

Give them the terminal commands to run themselves. Use their GitHub username from Step 3. Tell them this creates a private GitHub repo for their overlay files so they sync across machines.

```
gh repo create <username>/claurke-personal-overlay --private --description "Personal overlay for the claurke system"
cd ~/.claude/claurke-kit/personal
git init
git add voice-profile.md personal-preferences.md
git commit -m "Initial overlay setup"
git branch -M main
git remote add origin https://github.com/<username>/claurke-personal-overlay.git
git push -u origin main
```

Wait for them to confirm. If they hit errors, surface the actual error message - don't guess.

### Step 9: Walk through Cowork settings paste

You cannot click Cowork's UI. Tell the user clearly that these are their job:

1. **Cowork > Settings > Customize > Instructions for Claude** - paste the personal-preferences.md content you generated in Step 7. (This is the personal preferences slot.)
2. **Cowork > Settings > Customize > Cowork Global Instructions** - paste the content from `~/.claude/CLAUDE.md` on their Mac. The install.sh already wrote that file. They can run `cat ~/.claude/CLAUDE.md | pbcopy` in Terminal to copy it to their clipboard.
3. **Cowork > Settings > Plugins** - install the Anthropic Skills bundle (for humanizer skill - required for voice rules to fire on drafts). Walk them through Settings > Plugins > Personal > `+` > paste `anthropics/skills` > Sync, then install the humanizer plugin.

Tell them to come back to this session after pasting so you can verify.

### Step 10: Verify the install

Once they confirm they've pasted, instruct them to open a fresh Cowork session (not this one) and ask:

```
What are the five required elements of the impasse-surfacing artifact?
```

Expected response: position held, basis, what would change the position, candidates the user might be wrong about, an explicit ask. If the rules are loaded, this answer comes back clean. If not, Claude will improvise.

If that works, ask them to test voice rules:

```
Draft a Slack message to my manager telling her the demo got pushed to Friday.
```

Expected: salutation per their voice profile, sign-off per their voice profile, no em dashes, no banned phrases.

If either test fails, walk them through troubleshooting (operating manual section 6) - most common issues are stale paste or missing humanizer skill.

### Step 11: Optional - add daily backup

Use AskUserQuestion to ask if they want a daily backup job for their overlay repo (recommended). If yes, point them at the operating manual section 2 (daily operations) for the launchd plist setup. Don't try to set it up via bash - it has to be configured on their actual Mac.

For Rules-only path users: skip this step - their overlay doesn't exist.

### Step 12: Done

Congratulate them. Point them at:

- `~/.claude/claurke-kit/docs/operating-manual.md` for ongoing reference
- The `claurke-ops` skill for operational questions (fires automatically when they ask, since they installed the marketplace plugin)
- The operating manual's setup checklist (section 3) for the verification checklist they can run any time

## Guardrails

- Never run bash assuming it touches the user's Mac. It doesn't. If a step requires a command on their machine, give them the command in a code block and tell them to run it in their Terminal.
- For any terminal command you give them, explain what it does in one sentence before showing it. Don't assume they know what `mv` or `git push` mean.
- If the user is unsure at any step, default to the safer option (more confirmation, less automation).
- If something fails, surface the actual error - don't paper over it. The operating manual's troubleshooting section has fixes for the most common ones.
- Apply Clark's voice rules to drafts you produce on the new user's behalf only if they explicitly want Clark's style. Their own voice profile is the source of truth for their drafts going forward.

## Common failure modes

- **gh not authenticated** - they need to run `gh auth login` themselves in Terminal; you can't run interactive auth flows for them.
- **Existing files at target paths** - if `~/.claude/claurke-kit/personal/voice-profile.md` already exists when they try to `mv` into it, the move will overwrite. Ask them whether to back up first (`cp` to a timestamped name) before overwriting.
- **Cowork settings paste fails to load** - the most common verification failure. The two slots (Customize > Instructions for Claude and Customize > Cowork Global Instructions) are easy to mix up. Walk them through which is which.
- **Voice rules don't fire on drafts** - humanizer skill probably isn't installed. Walk them through the Anthropic Skills marketplace plugin install in Cowork.
- **They ask you to run bash to do something on their Mac** - politely refuse and give them the equivalent terminal command. Explain that Cowork's bash runs in a sandbox, not on their actual machine.

## References

- Colleague onboarding doc: https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/colleague-onboarding.md
- Operating manual (canonical): https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/operating-manual.md
- claurke-ops skill (sibling, for operational questions post-install)
- Bootstrap script: `~/.claude/claurke-kit/bootstrap.sh` (already ran via install.sh, here for reference)
