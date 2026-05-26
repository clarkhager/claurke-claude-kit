# Operating manual

The canonical reference for running this system day-to-day. Read this before changing anything you don't understand. Seven sections: daily operations, recommended setup checklist, verification, update workflows, troubleshooting, recovery scenarios, decision log.

---

## 1. Daily operations

### Cowork (knowledge work, ideation, project management)

Open Cowork. The rules-kit CLAUDE.md is already in Settings > Global Instructions (you pasted it during bootstrap). Behavioral rules apply automatically.

When you connect Cowork to a project folder, memory-kit's CLAUDE.md, MEMORY.md, STATUS.md, and PRIMER.md auto-load from that folder. Project context applies in addition to the global rules.

New project: `bash ~/.claude/claurke-kit/scripts/new-project.sh /path/to/project`

### Claude Code (development)

Run `claude` in any terminal. The rules-kit CLAUDE.md loads automatically from `~/.claude/CLAUDE.md`. When you `cd` into a project folder, memory-kit's files load from the project root.

Hooks fire here. The pre-compact hook saves a structured transcript backup to `~/.claude/backups/` before context compaction. The memory-check hook warns at session close if memory files weren't updated during significant work.

### Cross-product handoff (Cowork to Claude Code)

When a Cowork conversation produces a build task:

1. In Cowork, capture the task in the project's MEMORY.md or STATUS.md (use explicit trigger phrase per memory-kit's write rule: "remember this," "log this," "make a note")
2. Open Claude Code, `cd` into the project folder
3. Claude Code reads the same memory files; the context is preserved
4. Build with hooks active (transcript backups, end-of-session warnings)
5. Updates to memory files in Claude Code are visible to Cowork next time you open the project

---

## 2. Recommended setup checklist (new machine, new account, new colleague)

On a fresh install, beyond running bootstrap.sh, populate your personal overlay using the templates in `personal/templates/`:

### Step 1: Voice profile (optional)

Copy `personal/templates/voice-profile-template.md` into your personal overlay as `voice-profile.md` and fill in your sections (salutation, sign-off, banned phrases, voice examples).

Skip this step if your Claude account's personal preferences already cover voice rules adequately. The voice profile is for richer detail beyond preferences, not a replacement.

### Step 2: MCP list

Copy `personal/templates/mcp-list-template.md` into your personal overlay as `mcp-list.md`. The template is organized by:

- **Always install**: Gmail, Slack, Notion, GitHub, Atlassian/Jira, Postman, Claude in Chrome, PDF Viewer, Context7
- **Development projects**: Railway, Supabase, Vercel, Clerk, Sentry, Apify, Jam, Desktop Commander
- **Design projects**: Figma, Canva, Replicate, Higgsfield, Gemini Image
- **Personal additions**: your space for niche or company-specific MCPs (e.g., Spotify, Home Assistant, Amie)

Connect each MCP in your Claude account: Cowork > Settings > Connectors, or Claude Code via `.mcp.json` / settings.json. MCPs are account-bound, so installing on one machine syncs to all your machines on that account.

### Step 3: Skills list

Copy `personal/templates/skills-list-template.md` into your personal overlay as `skills-list.md`. The template lists:

- **Required**: humanizer (voice rule dependency), skill-creator (skill management rule dependency), claurke-ops (operational knowledge skill, shipped with claurke-claude-kit and auto-installed by bootstrap.sh)
- **Always install**: docx, xlsx, pptx, pdf, doc-coauthoring, typography, ui-ux-pro-max
- **Development projects**: mcp-builder, webapp-testing
- **Design projects**: theme-factory, web-artifacts-builder
- **Domain-specific**: bizzabo-api-toolkit (relevant when working with Bizzabo)
- **Personal additions**: skills you've built via /skill-creator for your specific workflow (e.g., home-assistant-best-practices for HA users)

Install existing third-party skills via the marketplace UI (Cowork) or `claude plugin install` (Claude Code). Create new skills via the /skill-creator skill, per the Skill management rule in rules-kit CLAUDE.md.

**Note on claurke-ops:** unlike third-party skills, claurke-ops ships with claurke-claude-kit (at `skills/claurke-ops/`). The bootstrap script copies it to `~/.claude/skills/claurke-ops/` automatically. For Cowork specifically, manual install via Settings > Plugins may also be needed - the skill files are at the bootstrap-installed path.

### Step 4: Manual Cowork steps

The bootstrap script prints these but they're worth listing here too:

1. Cowork > Settings > Global Instructions: paste contents of `~/.claude/CLAUDE.md`
2. Cowork > Settings > Connectors: connect MCPs per your list
3. Cowork > Settings > Plugins: install skills per your list (verify Anthropic Skills bundle for humanizer; verify claurke-ops is recognized)

### Step 5: Verify

Run Test 1 from the Verification section below in a fresh Cowork session to confirm the rules are loaded and the system is responding correctly.

---

## 3. Verification

Use these prompts to confirm the system is loaded correctly. Run periodically (especially after fresh installs or kit updates) to catch silent failures.

### Test 1: rules file is loaded

Ask in a fresh session: *"What are the five required elements of the impasse-surfacing artifact?"*

Expected: position held, basis, what would change the position, three things you might be wrong about ordered by likelihood, an explicit ask.

If Claude can't answer, makes something up, or says "I don't see that in your CLAUDE.md," the rules file isn't loaded. In Cowork: check Settings > Global Instructions has the latest paste. In Claude Code: check `~/.claude/CLAUDE.md` exists and has expected content.

### Test 2: behavioral rules fire

Ask: *"I have a plan to refactor my email triage workflow by deleting all messages older than 30 days, no exceptions. Review it."*

Expected: first sentence names a specific weakness with a stated consequence (likely loss of important threads, lack of search backup, compliance/retention concerns). Generic hedges ("this might be aggressive") or opening with validation means the response-shape rule isn't firing.

### Test 3: diagnostic-mode side doc loads when triggered

Ask: *"Show your work: my Gmail integration stopped pulling new messages this morning. Diagnose it."*

Expected: Claude announces "Switching to diagnostic mode" and produces three labeled hypotheses with falsification tests. If you see the announcement and the structured artifacts, the diagnostic-mode side doc is being read on demand.

### Test 4: hooks fire (Claude Code only)

After a session in Claude Code with file edits, check `~/.claude/backups/` for a timestamped backup file. If the file exists with the expected structure (User Requests, Files Modified, Tools Used, Errors), the pre-compact hook fired. If missing, check `~/.claude/settings.json` has `PreCompact` hook registration and `~/.claude/hooks/pre-compact.sh` is executable.

### Test 5: claurke-ops skill fires

Ask: *"set up Claude on this new MacBook"*

Expected: skill triggers, fetches the operating manual (or reads from local), responds with the section 2 setup checklist and section 6 lost-state recovery steps, cites the sections.

If the skill doesn't fire, verify it's installed at `~/.claude/skills/claurke-ops/SKILL.md`. For Cowork, also check Settings > Plugins shows claurke-ops as installed.

### Signs the rules aren't firing

Flag these in any session:

- Claude opens with validation ("great question," "you're absolutely right") without citing a specific claim
- Claude buries flaws after agreement rather than leading with them
- Claude commits to a diagnosis without three labeled hypotheses (in diagnostic mode)
- Claude claims to have read a file or run a command without an actual tool call
- Generic response patterns that ignore the response-shape rules

Any of these mean the rules aren't loaded. Re-run Test 1 and check the deployment.

---

## 4. Update workflows

### When a kit changes

You pushed a change to claurke-rules-kit, claurke-memory-kit, or claurke-claude-kit. To propagate:

```bash
bash ~/.claude/claurke-kit/bootstrap.sh --update
```

This pulls the latest of both kits and offers to redeploy. Run on each machine.

### When rules-kit's CLAUDE.md changes (Cowork-specific extra step)

Claude Code picks up `~/.claude/CLAUDE.md` automatically after `--update`. Cowork doesn't. Cowork reads from Settings > Global Instructions, which you pasted manually during bootstrap.

If the change affects the main CLAUDE.md content (rules, primer, structural pieces), re-paste into Cowork:

1. Open `~/.claude/CLAUDE.md` (the freshly updated version)
2. Copy the entire contents
3. Cowork > Settings > Global Instructions > paste, save

If the change only affects side docs (claude_voice_rules.md, claude_anti_sycophancy.md, claude_coding_rules.md, claude_diagnostic_mode.md), no Cowork re-paste needed. Side docs are lazy-loaded by reference in the main file.

### When claurke-ops changes

The skill source lives at `skills/claurke-ops/` in claurke-claude-kit. When you push a change, run `bootstrap.sh --update` on each machine. Bootstrap refreshes the local `~/.claude/skills/claurke-ops/` from the kit's source. For Cowork, you may need to reinstall the skill via Plugins panel to pick up the new version.

### When the system primer changes (rare)

The "System reference" section in rules-kit's CLAUDE.md should be stable. The repo names, the update commands, the architecture - none of that changes often. When it does, the re-paste workflow above applies.

### When a new skill or MCP is added

Skills and MCPs are account-level, not in the kits. Install in each Claude account you use (personal, work):

- Skills: Cowork > Settings > Plugins, or `claude plugin install` in Claude Code
- MCPs: Cowork > Settings > Connectors, or `.mcp.json` in Claude Code

Update your personal overlay's `mcp-list.md` or `skills-list.md` to record the addition. This keeps your overlay current as your stack evolves.

### When memory-kit's templates change

The template changes apply to new projects via `scripts/new-project.sh`. Existing projects keep their original template content; the deploy script skips existing files. If you want template changes propagated to existing projects, manually merge them (memory-kit's check-updates.sh shows you the diff).

---

## 5. Troubleshooting

### Rules aren't firing in Cowork

Most likely: Settings > Global Instructions has stale content, or never had the rules pasted.

Fix:

1. Open `~/.claude/CLAUDE.md` on disk
2. Verify it has the current rules-kit content (compare to GitHub if unsure)
3. Copy entire contents
4. Cowork > Settings > Global Instructions > paste fresh, save
5. Open a new Cowork session and run Test 1

### Rules aren't firing in Claude Code

Most likely: `~/.claude/CLAUDE.md` doesn't exist, has stale content, or has wrong permissions.

Fix:

1. Check the file exists: `ls -la ~/.claude/CLAUDE.md`
2. Verify content matches rules-kit's latest
3. Re-run `bash ~/.claude/claurke-kit/bootstrap.sh --update` if stale
4. Run Test 1 in a fresh `claude` session

### claurke-ops skill not firing

Most likely: skill isn't installed in this account, or the description isn't triggering.

Fix:

1. Verify install: `ls -la ~/.claude/skills/claurke-ops/SKILL.md`
2. If missing, run `bash ~/.claude/claurke-kit/bootstrap.sh --update` to reinstall
3. For Cowork: check Settings > Plugins shows claurke-ops; may need manual install
4. Re-run Test 5 in a fresh session
5. If still not firing, the description may need optimization. Run `python -m scripts.run_loop` from the skill-creator skill against `~/.claude/claurke-kit/skills/claurke-ops/evals/trigger-eval.json`

### Hooks not firing in Claude Code

Check:

1. `~/.claude/hooks/pre-compact.sh` and `memory-check.sh` exist and are executable (`ls -la ~/.claude/hooks/`)
2. `~/.claude/settings.json` contains hook registrations under `hooks.PreCompact` and `hooks.Stop`
3. If either missing, re-run memory-kit's deploy: `bash ~/.claude/memory-kit/deploy.sh`

### Hooks not firing in Cowork

This is expected behavior, not a bug. Cowork doesn't fire user hooks reliably per anthropics/claude-code issues #27398 and #40495. The hook scripts are installed but never run.

For Cowork sessions where you'd want hook-based safety (compaction backup, memory-update warnings), do those manually:

- Note important state to MEMORY.md or STATUS.md before ending the session
- Don't rely on the kit for automated backup in Cowork

### Side doc not loading (lazy-load fails)

Lazy loading via filename reference is unreliable in Cowork. If a side doc's content isn't loading when you expect it to:

1. Verify the side doc exists at the expected path (`~/.claude/claude_voice_rules.md`, etc.)
2. Try invoking with a more explicit trigger (e.g., "diagnostic mode" instead of an implicit query)
3. If still failing, the load-bearing content should probably be inlined into the main CLAUDE.md instead of lazy-loaded. Apply the same pattern as the previous inline fixes.

### Humanizer skill not running on drafts

Most likely: skill isn't installed in this account.

Fix:

1. Run `bash ~/.claude/claurke-kit/scripts/install-humanizer.sh` to detect
2. If not detected, install via Cowork > Settings > Plugins (Anthropic Skills bundle), or Claude Code `claude plugin install anthropic-skills`
3. Verify by asking Claude to draft something and observe whether humanizer is invoked

### MCPs not available

Most likely: MCP isn't connected in this account.

Fix:

- Cowork: Settings > Connectors > connect the MCP
- Claude Code: configure `.mcp.json` or settings.json
- Each MCP requires OAuth or API key per account; not portable across accounts without re-auth

### MCP "server disconnected" errors after restart

Most likely: an MCP server script's path has changed (folder rename, move, delete) and `claude_desktop_config.json` still points at the old location.

Fix:

1. Open `~/Library/Application Support/Claude/claude_desktop_config.json`
2. Find the `mcpServers` section and inspect the `command` and `args` paths for each disconnected MCP
3. Verify each referenced script exists at the path listed: `ls -la /path/from/config`
4. If a path is broken, update it to the new location (back up the config first: `cp claude_desktop_config.json claude_desktop_config.json.bak-$(date +%Y%m%d-%H%M%S)`)
5. Full quit Claude desktop (Cmd+Q) and reopen so MCP server processes spawn at corrected paths

This is also covered as a Recovery scenario (see section 6, "Renamed or moved a project folder that other tools reference") because the root cause is usually a folder rename earlier in the session.

### Claude isn't using the project memory files

Most likely: project files aren't in the folder Claude is loading from.

Fix:

1. Verify CLAUDE.md, MEMORY.md, STATUS.md exist at the project root
2. In Cowork: verify the folder is connected as a workspace (Settings > Workspaces)
3. In Claude Code: verify you're running `claude` from inside the project folder (not a parent)

---

## 6. Recovery scenarios

### Accidentally deleted personal/ overlay

The personal overlay is gitignored, so git won't help you recover. If you keep a private repo or gist as backup (the recommended pattern), re-clone it into `~/.claude/claurke-kit/personal/`.

If you have no backup, the public skeleton still works without the overlay. You lose identity files (voice profile, MCP list, account notes) but the rules and templates are intact.

Going forward: set up the private backup before relying on the overlay for anything important.

### Corrupted CLAUDE.md in ~/.claude/

Re-deploy from rules-kit: `bash ~/.claude/rules-kit/deploy.sh --global`

The deploy script backs up the existing file before overwriting, so you'll have a `.bak-<timestamp>` copy if you need to diff.

### Bootstrap fails

Most common causes:

- `git` or `gh` not installed (prereq check at start of bootstrap will catch this)
- No network access to GitHub
- Permission issues writing to `~/.claude/`

Fix:

1. Install prereqs (`brew install gh git` on macOS)
2. Verify network: `gh repo view clarkhager/claurke-claude-kit`
3. Verify permissions: `ls -la ~/.claude`; should be owned by you
4. Re-run bootstrap

### Kits drift across machines

You pushed an update on machine A but forgot to run `--update` on machine B. The two machines now have different versions.

Fix: on the drifted machine, run `bash ~/.claude/claurke-kit/bootstrap.sh --update`. This pulls the latest of both kits and offers to redeploy.

Prevention: when you push a kit update, mentally note to run `--update` on other machines next time you're on them. (Future option: a scheduled task that runs `--update` automatically.)

### Lost all local state on a machine

Fresh machine setup. Run the full bootstrap from scratch:

```bash
gh repo clone clarkhager/claurke-claude-kit ~/.claude/claurke-kit
bash ~/.claude/claurke-kit/bootstrap.sh
```

This pulls everything down and walks you through the Cowork-specific manual steps. Restore the personal overlay from your backup repo if you have one.

### Pushed a broken kit update

The broken push will propagate to any machine that runs `--update`. Roll back:

1. Revert the bad commit: `git -C ~/.claude/rules-kit revert HEAD` (or whichever kit), push the revert
2. Run `--update` on each machine to pick up the fix
3. Re-paste into Cowork's Settings > Global Instructions if the rolled-back change affected the main CLAUDE.md

### Renamed or moved a project folder that other tools reference

Folder renames break hardcoded path references in config files outside the folder itself. The most common offenders:

- `~/Library/Application Support/Claude/claude_desktop_config.json` - MCP server scripts launched by Claude desktop (custom MCPs you've built that live inside the renamed folder)
- `~/.claude/memory-kit.conf` - project registry for memory-kit; stale paths produce warnings on check-updates.sh
- Cowork workspace registrations at `~/.claude/projects/-Users-...` - orphaned pointers; harmless but appear in the project list
- Shell aliases, scripts, or `.zshrc` / `.bashrc` entries that hardcoded the path
- Git remotes if the renamed folder was a git repo with path-relative remotes (rare)

**Symptom:** after the rename, processes that depended on the old path fail silently or report "server disconnected" / "file not found" errors. Claude desktop MCPs are the most visible case because their failures show as banner notifications on app start.

**Recovery steps:**

1. Identify the old path (the name you renamed from).
2. Grep the common config locations for the old path:
   ```bash
   grep -rn "OldFolderName" ~/Library/Application\ Support/Claude/ ~/.claude/ 2>/dev/null
   ```
3. For each reference, back up the file first then edit:
   ```bash
   cp file file.bak-$(date +%Y%m%d-%H%M%S)
   sed -i '' 's|OldPath|NewPath|g' file
   ```
   (The `sed -i ''` form is the macOS in-place edit syntax. Use `sed -i` without the empty string on Linux.)
4. Restart affected processes. Claude desktop MCPs require full quit (Cmd+Q, not just close window) and reopen so spawn paths refresh.
5. Verify functionality - the affected MCPs or tools should reconnect.

**Specific failure mode captured here:** May 2026 session - renamed `BizzaBrain 🧠/` to `BizzaBrain/` for personal GitHub migration. Did not check `claude_desktop_config.json`, which had three MCP server scripts (gmail, google-workspace, amie) pointing inside the old folder. After app restart, all three MCPs showed "server disconnected" because their spawn paths were broken. Fix was updating three paths in the config via sed.

**Prevention:** before renaming any project folder that has been around for a while, grep for the old path in common config locations. The cheap one-line check:

```bash
grep -rn "OldFolderName" ~/Library/Application\ Support/Claude/ ~/.claude/ 2>/dev/null
```

If grep returns nothing, the rename is safe. If it returns hits, update those references before or alongside the rename. Add this check to any project-migration checklist.

---

## 7. Decision log

Why the system is the way it is. Read this before second-guessing a structural choice.

### Why three repos instead of one monorepo

The research surfaced HumanLayer's three-tier pattern as the most-imitated scaling pattern: short CLAUDE.md for behavior, .claude/commands/ for skills, separate companion repo for long-form methodology. Our three repos map onto that. Lets each kit evolve at its own cadence.

### Why chezmoi was deferred

Research (Agent 2 of the meta-repo audit) recommended chezmoi as the right tool for multi-machine + multi-account config sync with templating. We deferred because:

- Current scale is small (~10 files, 2 accounts, 2 machines, no tracked secrets)
- chezmoi adds operational overhead (learning curve, migration burden if you change tools later)
- Bash + git is sufficient for the current pattern
- Adopt chezmoi if specific templating pain materializes (e.g., personal vs. work account configs need to genuinely diverge in file content)

### Why the overlay pattern instead of fork-per-machine

Research (Agent 4) showed Mathias Bynens's dotfiles pattern as the proven dual-purpose model. One public repo with a gitignored personal overlay handles both personal sync (you populate the overlay on your machines) and colleague onboarding (the overlay is empty for them, so they get the generic skeleton).

Fork-per-machine creates merge hell. The overlay pattern keeps one source of truth and isolates identity to a separate gitignored layer.

### Why the overlay pattern instead of a fully private repo

A fully private repo would solve multi-machine sync but lose the dual-purpose property. The public skeleton plus gitignored overlay lets the same repo serve both your personal sync use case and any colleague you onboard, without maintaining two parallel codebases (one public for sharing, one private for personal). The overlay collapses both needs into one repo with a clean boundary between generic skeleton and personal identity.

The private-repo idea does show up in the system, but only as the backup mechanism for the overlay layer specifically (see Recovery scenarios). The kit itself stays public so colleagues can fork; identity stays in the overlay backed up to a private repo so it syncs across your own machines without leaking.

### Why hooks aren't reliable enforcement

Research (the Cowork hooks investigation) confirmed: Anthropic's own knowledge-work-plugins ship zero hooks, and GitHub issues #27398 and #40495 document that Cowork's spawn flags silently exclude both plugin-scope and user-scope hooks. Hooks work in Claude Code but not Cowork.

Implication: CLAUDE.md is soft enforcement (best-effort). For destructive actions specifically, rely on Cowork's built-in deletion permission prompt and Ask-before-acting permission mode, which are host-enforced.

### Why @-imports were abandoned

Empirical testing in Cowork (during the rules-kit deployment) showed @-imports don't load reliably. We tested with `@claude_voice_rules.md` and `@claude_anti_sycophancy.md` and Claude couldn't access the contents.

Fix: load-bearing content is inlined into the main CLAUDE.md instead of lazy-loaded via @-imports. The diagnostic-mode side doc is the one exception that worked under lazy loading (with strong explicit triggers).

### Why constraint format over imperative format

Research (the original anti-sycophancy investigation) found that declarative "X requires Y" rules survive multi-turn pressure better than imperative "do X" rules. Anthropic's own guidance reinforces this: "Tell Claude what to do instead of what not to do."

It's not a silver bullet, but it's measurably better. The rules-kit CLAUDE.md uses constraint format throughout.

### Why behavioral rules are bundled with prerequisites detection (humanizer)

Silent failures of dependencies are the worst kind. If the Voice rule references a humanizer skill that isn't installed, the voice-rule pass silently doesn't run; you only find out by noticing draft quality drops. The deploy script's auto-detection at install time surfaces missing dependencies before they cause silent failures.

### Why the skill management rule (use /skill-creator for skills)

Claude (especially in Cowork) has historically created skills ad-hoc - placing files in arbitrary directories, freelancing the SKILL.md structure, bypassing account-level placement. The skill-creator skill enforces best practice and ensures skills are stored at the account level so they sync across machines. Without this rule, Claude's ad-hoc behavior recreates the same fragility we're trying to avoid with the kit system itself.

A paired rule covers installing existing third-party skills: those go through the Cowork plugin marketplace or `claude plugin install`, never manual file placement, for the same account-level sync reason.

### Why the claurke-ops skill exists

Created to give Claude on-demand access to this operating manual without requiring the user to remember to reference it by name. The CLAUDE.md primer gives baseline awareness; the skill gives depth on operational queries ("how do I update," "why aren't the rules firing," "set up Claude on a new machine"). Both layers needed for the completeness goal.

### Why claurke-ops is shipped in the kit repo and auto-installed by bootstrap

Third-party skills go through the marketplace install path. claurke-ops is ours, lives in the kit, and should never drift from the operating manual it surfaces. Shipping it in `skills/claurke-ops/` in claurke-claude-kit means it versions with the kit; bootstrap.sh copies it to `~/.claude/skills/claurke-ops/` so Claude Code picks it up automatically. For Cowork, a manual Plugins-panel install may also be needed because Cowork's plugin system is account-level and doesn't observe filesystem changes directly.

---

## When in doubt

Three places to check first when something feels off:

1. **This file** for operational questions ("how do I X," "why is Y broken")
2. **`docs/cowork-vs-claude-code.md`** for product-specific behavior
3. **The kit READMEs on GitHub** for kit-specific concerns

If the answer isn't in any of those, the system has evolved beyond what's documented. Update this manual.
