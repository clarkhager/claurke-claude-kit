# Operating manual

The canonical reference for running this system day-to-day. Read this before changing anything you don't understand. Nine sections: layering model, daily operations, recommended setup checklist, verification, update workflows, troubleshooting, recovery scenarios, decision log, implementation gotchas.

---

## 1. Layering model

Five places hold rules and context. Knowing which layer owns what prevents duplication and silent overrides. Read this section first; the rest of the manual assumes it.

### Layer 1: Personal Preferences

Path: Settings > General > Instructions for Claude (the slot that applies across your whole Claude account, not just Cowork).

Scope: All Claude interactions on the account (claude.ai web, Cowork, mobile app, anywhere personal preferences load).

Owns: who you are (name, role, situation), preferred tools, assistant naming, high-level working preferences (response length, draft-first orientation), pointers to where voice rules and behavioral rules live, a thin fallback baseline of voice rules and behavioral rules for environments where the full overlay or rules-kit isn't loaded.

Does not own: the canonical voice rules (those live in voice-profile.md overlay), the full behavioral spine (that lives in rules-kit), project-specific rules (those live in the project's CLAUDE.md). Personal Preferences should stay short - they're loaded into every system prompt, including quick claude.ai web sessions.

### Layer 2: Cowork Global Instructions

Path: Cowork > Settings > Cowork > Global Instructions.

Scope: All Cowork sessions on the account.

Owns: the full rules-kit CLAUDE.md content, pasted in verbatim. This is the behavioral spine (anti-sycophancy, response shape, tool-use discipline, voice loading rule, coding behavior, skill management, diagnostic mode, self-checkpoints, success criteria, system reference).

Does not own: identity content (lives in Personal Preferences), the voice rules themselves (live in voice-profile.md overlay; rules-kit only contains the loading instruction).

### Layer 3: ~/.claude/CLAUDE.md (Claude Code's global file)

Path: `~/.claude/CLAUDE.md` on each machine.

Scope: All Claude Code sessions.

Owns: identical to Layer 2 - the full rules-kit CLAUDE.md content. Auto-deployed by `bootstrap.sh`.

Does not own: anything Layer 2 doesn't own.

### Layer 4: Project-level files (CLAUDE.md, MEMORY.md, STATUS.md, PRIMER.md)

Path: At the root of each project folder.

Scope: When the project folder is open in Cowork or you're in it in Claude Code.

Owns: project-specific context, decisions, rules, memory, status. Examples: the MEMORY.md write rule for Wayfinder (RFD-004), per-project decision logs, project-specific tool preferences, project-specific drafting overrides.

Does not own: anything that applies across all your work. Universal rules belong in rules-kit so every project benefits.

### Layer 5 (overlay): voice-profile.md and other personal files

Path: `~/.claude/claurke-kit/personal/voice-profile.md` (gitignored from the public claurke-claude-kit repo). Also `mcp-list.md`, `skills-list.md`, `account-notes.md` in the same directory.

Scope: voice-profile.md is loaded by reference whenever Claude drafts content on your behalf. The reference itself lives in rules-kit's Voice section.

Owns: salutation, sign-off, banned phrases, em-dash rule, contractions, tone notes, voice examples. Anything that's specific to how you sound in your own writing.

Does not own: behavioral rules (rules-kit), identity (Personal Preferences), project-specific drafting rules (project CLAUDE.md).

### Dedup rules

- Identity (who you are) lives in Personal Preferences only.
- Canonical voice rules live in voice-profile.md only. Personal Preferences has a one-line fallback baseline for environments where the overlay isn't accessible; that's intentional, not duplication.
- Behavioral rules live in rules-kit CLAUDE.md only (deployed to Cowork Global Instructions and `~/.claude/CLAUDE.md`).
- Project-specific rules live in the project's CLAUDE.md only.

### Conflict resolution (what wins when two layers disagree)

The dedup rules above are designed to prevent conflicts. When a conflict does arise (usually because the dedup rules were violated):

1. More specific wins over less specific. Project CLAUDE.md overrides global rules-kit. voice-profile.md overrides the Personal Preferences voice baseline.
2. When two layers at the same specificity conflict, follow the more restrictive rule.
3. Surface the conflict explicitly rather than resolving silently (per rules-kit's "surface contradictions" rule).

The one acceptable mechanical duplication: rules-kit CLAUDE.md is deployed to both Cowork Global Instructions and `~/.claude/CLAUDE.md` because Cowork and Claude Code each have their own global slot. Both paste from the same source file, so the duplication is mechanical, not conceptual.

### Why this matters

Without the dedup rules, the same rule lives in two or three places. Updating in one place leaves the others stale; you end up debugging behavior that looks contradictory because two slightly-different versions of the same rule are both loading. The single-source rule for each category prevents that. The fallback baseline in Personal Preferences is the one explicit exception - it exists for environments outside the kit's reach, and it's intentionally thinner than the canonical rules to make the source-of-truth obvious.

---

## 2. Daily operations

### Cowork (knowledge work, ideation, project management)

Open Cowork. The rules-kit CLAUDE.md is already in Settings > Cowork > Global Instructions (you pasted it during bootstrap). Behavioral rules apply automatically.

When you connect Cowork to a project folder, memory-kit's CLAUDE.md, MEMORY.md, STATUS.md, and PRIMER.md auto-load from that folder. Project context applies in addition to the global rules.

### Starting a new project (interview-driven flow)

```bash
bash ~/.claude/claurke-kit/scripts/new-project.sh
```

The script walks you through an interview to capture project framing at creation time. Four supported project types:

| Type | When to use | Extras the script sets up |
|---|---|---|
| **code** | Tech projects (Python, Node, Rust, Go, etc.) | `.gitignore` per language + `.claude/rules/` folder for scoped rules + keeps Scoped Rules section in CLAUDE.md |
| **knowledge** | Notes / vault / non-code workspaces | Removes Scoped Rules section (irrelevant for non-code) |
| **meta** | Cross-repo coordination (tracks decisions across multiple repos) | Adds Tracked Repos section to CLAUDE.md listing the repos it follows |
| **subworkspace** | Auto-detected when parent dir is already a project | Adds Parent Workspace section + skips git-init guidance (parent's repo handles it) + suggests no separate daily-backup entry |

The interview asks:

1. Project directory (can supply as arg: `bash new-project.sh ~/Documents/Claude/Projects/my-project`)
2. Project type (auto-detects sub-workspace if parent has CLAUDE.md/MEMORY.md)
3. Type-specific questions (language for code, tracked repos for meta)
4. "What is this project?" - 1-2 sentences, pre-populated into CLAUDE.md's "What This Is" section
5. "Immediate next move?" - pre-populated into STATUS.md's Next Move section
6. Expected duration > 4 weeks? Y/N - controls whether PRIMER.md is included
7. Origin / why - 1 line for PRIMER.md (skippable, fill in later)

Output: CLAUDE.md, MEMORY.md, STATUS.md, (optionally PRIMER.md) in the project root, all pre-populated from your answers. Plus type-specific scaffolding.

The script also prints type-aware next steps at the end (e.g., for code: how to git init + push to a private GitHub repo + add to daily backup; for sub-workspace: confirms no separate git/backup needed).

### After the script runs

1. Review CLAUDE.md - the script populated "What This Is" from your answer; check Standing Rules, Known Gotchas, Anti-Patterns sections and add project-specific entries
2. Connect the folder as a Cowork workspace (for top-level projects) or open the parent and navigate in (for sub-workspaces)
3. Start your first session with the kickoff prompt the script printed: `New session in <project>. Read CLAUDE.md, MEMORY.md, and STATUS.md. Tell me what you know and what the next move is.`

### Non-interactive mode (advanced)

If you want to skip the interview and just deploy templates with default values, call memory-kit's deploy.sh directly:

```bash
bash ~/.claude/memory-kit/deploy.sh ~/Documents/Claude/Projects/my-project
```

This is the underlying script that the orchestrator calls. It prompts for name + stack + primer Y/N only, and leaves the new interview-driven fields as bracketed placeholders. Useful for scripted deploys or when you'll fill in the templates manually.

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

## 3. Recommended setup checklist (new machine, new account, new colleague)

On a fresh install, beyond running bootstrap.sh, populate your personal overlay using the templates in `personal/templates/`:

### Step 1: Voice profile (recommended)

Copy `personal/templates/voice-profile-template.md` into your personal overlay as `voice-profile.md` and fill in your sections (salutation, sign-off, banned phrases, voice examples).

This is the canonical source for the voice rules Claude follows when drafting on your behalf. Personal preferences hold only a thin fallback baseline; the richer rules live here. Skip only if you genuinely don't want Claude to draft on your behalf.

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

1. Cowork > Settings > Cowork > Global Instructions: paste contents of `~/.claude/CLAUDE.md`
2. Cowork > Settings > Connectors: connect MCPs per your list
3. Cowork > Settings > Plugins: install skills per your list (verify Anthropic Skills bundle for humanizer; verify claurke-ops is recognized)

### Step 5: Personal preferences

If this is a fresh Claude account or you're cleaning up an existing one, paste the personal preferences template into Settings > General > Instructions for Claude. The template lives at `personal/templates/personal-preferences-template.md` (or you can copy your existing personal preferences from another machine). Per section 1's dedup rules, personal preferences should hold identity + working style + pointers + fallback baselines only - not duplicate the rules-kit content.

### Step 6: Verify

Run Test 1 from the Verification section below in a fresh Cowork session to confirm the rules are loaded and the system is responding correctly.

---

## 4. Verification

Use these prompts to confirm the system is loaded correctly. Run periodically (especially after fresh installs or kit updates) to catch silent failures.

### Test 1: rules file is loaded

Ask in a fresh session: *"What are the five required elements of the impasse-surfacing artifact?"*

Expected: position held, basis, what would change the position, three things you might be wrong about ordered by likelihood, an explicit ask.

If Claude can't answer, makes something up, or says "I don't see that in your CLAUDE.md," the rules file isn't loaded. In Cowork: check Settings > Cowork > Global Instructions has the latest paste. In Claude Code: check `~/.claude/CLAUDE.md` exists and has expected content.

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

Expected: skill triggers, fetches the operating manual (or reads from local), responds with the section 3 setup checklist and section 7 lost-state recovery steps, cites the sections.

If the skill doesn't fire, verify it's installed at `~/.claude/skills/claurke-ops/SKILL.md`. For Cowork, also check Settings > Plugins shows claurke-ops as installed.

### Test 6: voice profile loads on draft

Ask: *"Draft a Slack message to my manager telling her the demo got pushed to Friday."*

Expected: salutation `Hey [Name] -` (or your equivalent), sign-off `Thank you,` on its own line, no em dashes, no banned AI-tell phrases. If the draft uses generic openings ("Hi [Name],"), formal sign-offs ("Best,"), or any banned phrases, voice-profile.md isn't loading or the humanizer skill isn't running. Check the overlay path and verify humanizer is installed.

### Signs the rules aren't firing

Flag these in any session:

- Claude opens with validation ("great question," "you're absolutely right") without citing a specific claim
- Claude buries flaws after agreement rather than leading with them
- Claude commits to a diagnosis without three labeled hypotheses (in diagnostic mode)
- Claude claims to have read a file or run a command without an actual tool call
- Generic response patterns that ignore the response-shape rules
- Drafted content uses em dashes, banned phrases, or generic salutations

Any of these mean the rules aren't loaded. Re-run Test 1 and check the deployment.

---

## 5. Update workflows

### When a kit changes

You pushed a change to claurke-rules-kit, claurke-memory-kit, or claurke-claude-kit. To propagate:

```bash
bash ~/.claude/claurke-kit/bootstrap.sh --update
```

This pulls the latest of both kits and offers to redeploy. Run on each machine.

### When rules-kit's CLAUDE.md changes (Cowork-specific extra step)

Claude Code picks up `~/.claude/CLAUDE.md` automatically after `--update`. Cowork doesn't. Cowork reads from Settings > Cowork > Global Instructions, which you pasted manually during bootstrap.

If the change affects the main CLAUDE.md content (rules, primer, structural pieces), re-paste into Cowork:

1. Open `~/.claude/CLAUDE.md` (the freshly updated version)
2. Copy the entire contents
3. Cowork > Settings > Cowork > Global Instructions > paste, save

If the change only affects side docs (claude_voice_rules.md, claude_anti_sycophancy.md, claude_coding_rules.md, claude_diagnostic_mode.md), no Cowork re-paste needed. Side docs are lazy-loaded by reference in the main file.

### When voice-profile.md changes

Voice profile is in the personal overlay (gitignored), so updates don't propagate via `bootstrap.sh --update`. Sync manually across your machines via the private overlay repo or gist. No Cowork re-paste needed because rules-kit loads the file by reference at draft time, not at session start.

### When personal preferences change

Personal preferences live in your Claude account (Settings > General > Instructions for Claude). They sync across machines within the same account automatically. Switching accounts (personal -> work) requires pasting the appropriate version into each account separately.

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

## 6. Troubleshooting

### Rules aren't firing in Cowork

Most likely: Settings > Cowork > Global Instructions has stale content, or never had the rules pasted.

Fix:

1. Open `~/.claude/CLAUDE.md` on disk
2. Verify it has the current rules-kit content (compare to GitHub if unsure)
3. Copy entire contents
4. Cowork > Settings > Cowork > Global Instructions > paste fresh, save
5. Open a new Cowork session and run Test 1

### Rules aren't firing in Claude Code

Most likely: `~/.claude/CLAUDE.md` doesn't exist, has stale content, or has wrong permissions.

Fix:

1. Check the file exists: `ls -la ~/.claude/CLAUDE.md`
2. Verify content matches rules-kit's latest
3. Re-run `bash ~/.claude/claurke-kit/bootstrap.sh --update` if stale
4. Run Test 1 in a fresh `claude` session

### Drafted content sounds wrong (voice rules not firing)

Most likely one of: voice-profile.md isn't in the overlay path, humanizer skill isn't installed, or the draft was produced in an environment where the overlay can't be loaded.

Fix:

1. Verify voice-profile.md exists: `ls -la ~/.claude/claurke-kit/personal/voice-profile.md`
2. If missing, restore from your private overlay backup (or copy `personal/templates/voice-profile-template.md` and fill in)
3. Verify humanizer is installed: ask Claude "is the humanizer skill available?" or check Cowork > Settings > Plugins
4. If both are present, run Test 6 in a fresh session to confirm
5. If you're in a sandbox or claude.ai web where the overlay can't load, the fallback baseline in personal preferences applies - check it's up to date

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

This is also covered as a Recovery scenario (see section 7, "Renamed or moved a project folder that other tools reference") because the root cause is usually a folder rename earlier in the session.

### Claude isn't using the project memory files

Most likely: project files aren't in the folder Claude is loading from.

Fix:

1. Verify CLAUDE.md, MEMORY.md, STATUS.md exist at the project root
2. In Cowork: verify the folder is connected as a workspace (Settings > Workspaces)
3. In Claude Code: verify you're running `claude` from inside the project folder (not a parent)

### Personal preferences and rules-kit are duplicating rules

This is a layering violation. Personal preferences should hold identity + working style + pointers + thin fallback baselines only. Behavioral rules belong in rules-kit (Layer 2/3). Voice rules belong in voice-profile.md (Layer 5).

Fix:

1. Read section 1 (Layering model) to confirm which layer owns which content
2. Remove duplicated content from the wrong layer
3. Keep only the fallback baseline in personal preferences for environments outside the kit's reach
4. Re-paste both Layer 1 (Personal Preferences) and Layer 2 (Cowork Global Instructions) after cleanup

---

## 7. Recovery scenarios

### Accidentally deleted personal/ overlay

The personal overlay is gitignored, so git won't help you recover. If you keep a private repo or gist as backup (the recommended pattern), re-clone it into `~/.claude/claurke-kit/personal/`.

If you have no backup, the public skeleton still works without the overlay. You lose identity files (voice profile, MCP list, account notes) but the rules and templates are intact. Drafted content falls back to the personal-preferences voice baseline until you restore voice-profile.md.

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
3. Re-paste into Cowork's Settings > Cowork > Global Instructions if the rolled-back change affected the main CLAUDE.md

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

## 8. Decision log

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

### Why voice rules live in voice-profile.md, not personal preferences

For a while, voice rules lived in personal preferences as a single growing block. Two problems emerged:

1. Personal preferences are loaded into every system prompt, including quick claude.ai web sessions where the voice rules don't even apply (no drafting happens). Sending a ~80-line voice spec into every chat wastes tokens for no benefit.
2. Voice rules co-existed with behavior rules and identity in the same slot, making it unclear what was authoritative when something conflicted.

Moving voice rules to voice-profile.md in the personal overlay solves both: the file loads only when rules-kit's Voice section references it (at draft time), and the slot has exactly one responsibility. Personal preferences keep a thin fallback baseline for environments where the overlay can't load (claude.ai web), but the canonical source is the overlay file.

### Why the layering model became a top-of-manual concept

The rules-kit CLAUDE.md, voice-profile.md, personal preferences, and project files all overlap if you're not careful about which slot owns what. After observing actual drift (the same rule landing in three places, then updates only being applied to one), the layering model was elevated to section 1 of the operating manual so it's encountered before any operational guidance. Most troubleshooting traces back to a layering violation; the model is the diagnostic frame.

### Why new-project.sh became interview-driven with project types

The original new-project.sh was a thin wrapper around memory-kit/deploy.sh - it just dumped the four templates with `{{PROJECT_NAME}}`, `{{STACK}}`, `{{DATE}}` substituted and left the user to fill in everything else. Two problems with that pattern emerged in practice:

1. **Project framing was deferred indefinitely.** The "What This Is" section, "Next Move" section, and origin story all stayed bracketed placeholders, and users (Clark included) often shipped projects where those sections were never filled in. Claude in fresh sessions couldn't load real project context because there wasn't any.
2. **Sub-workspaces needed a different tool.** When creating ai-squad inside BizzaBrain, the standard new-project.sh didn't know it was a sub-workspace and tried to scaffold it like a top-level project (suggesting separate git repo, separate daily backup, etc.). The cowork-os:subfolders skill existed for this but was a third-party plugin Clark wanted to retire.
3. **One-size-fits-all scaffolding produced friction.** Code projects need `.gitignore` and a `.claude/rules/` folder; knowledge projects don't need either; meta-projects need a tracked-repos pointer; sub-workspaces need a parent-workspace reference. The single template tried to cover all cases by keeping a "Scoped Rules (technical projects only) - Remove this section if not a technical project" comment, which most users never actually remove.

The interview-driven flow solves all three: an interview captures the framing at creation time so CLAUDE.md and STATUS.md are populated when the project starts; type detection (sub-workspace auto-detected when parent has CLAUDE.md/MEMORY.md) handles the cowork-os:subfolders use case natively; type-aware scaffolding produces appropriate defaults per project type. The standalone non-interactive path (`memory-kit/deploy.sh` directly) is preserved for advanced users and scripted deploys.

---

## 9. Implementation gotchas (for kit maintainers)

When modifying the kit scripts (deploy.sh, new-project.sh, bootstrap.sh, install-humanizer.sh, etc.), watch for these patterns that have bitten the kit's own development before. Each entry: the pattern, why it fails, how to write it safely.

### Apostrophes inside `${VAR:-default}` bash expansions

Single quotes inside `${VAR:-default}` patterns open a string that bash never sees closed, even when the whole expression is wrapped in double quotes. The error surfaces much later in the script - usually as `syntax error near unexpected token "("` on a line that has nothing apparent wrong with it.

**Example that breaks:**

```bash
WHAT_THIS_IS="${WHAT_THIS_IS:-What's the core approach?}"
```

**Example that works** (rephrase without contractions):

```bash
WHAT_THIS_IS="${WHAT_THIS_IS:-What is the core approach?}"
```

**If you must include an apostrophe**, build the string in a separate line first:

```bash
DEFAULT_TEXT="What's the core approach?"
WHAT_THIS_IS="${WHAT_THIS_IS:-$DEFAULT_TEXT}"
```

The string is assigned in a fully-double-quoted context first, so the apostrophe is just a literal character. Then the `${VAR:-$DEFAULT_TEXT}` expansion uses the already-built variable.

**Caught:** May 2026, when the rewrite of new-project.sh shipped with `What's the core approach?` in the WHAT_THIS_IS default. Script crashed at line 207 (an `echo` with markdown link parens in `append_tracked_repos_section`) - 90+ lines after the actual offender. Took diagnosis via incremental `bash -n` to find that the real failure was line 120.

**Other characters to avoid inside `${VAR:-default}`:** backticks (command substitution), unescaped `$` (variable expansion), unbalanced parens, double quotes. Build the string in a separate variable first when you need any of these.

### Heredoc delimiter must be at column 0

When using `cat << EOF` heredocs, the closing `EOF` must be at column 0 (no leading whitespace) unless you use `<<- EOF` (which strips leading tabs only, not spaces). If the EOF is indented inside a function or conditional, bash keeps reading lines until end of file looking for a column-0 match. The error you see is usually `unexpected end of file` on the last line of the script, which is misleading.

**Example that breaks:**

```bash
my_function() {
  cat << EOF
some content
  EOF                # <- indented; bash doesn't recognize this as the terminator
}
```

**Example that works:**

```bash
my_function() {
  cat << EOF
some content
EOF                  # <- at column 0
}
```

IDEs that auto-indent shell scripts can sneak this bug in. Watch for it especially when copy-pasting heredocs into a function body.

### Unquoted vs quoted heredoc delimiter

`cat << EOF` (unquoted delimiter) expands variables (`$VAR`), command substitution (`` `cmd` `` or `$(cmd)`), and arithmetic (`$((expr))`) inside the heredoc content. To suppress all expansion and pass the content through literally, use `cat << 'EOF'` (single-quoted delimiter).

**Use unquoted when you WANT expansion:**

```bash
cat << EOF
Project is at $PROJECT_DIR.
Today is $(date).
EOF
```

**Use quoted when you DON'T want expansion** (e.g., embedded python code, raw markdown, anything with `$` that should be literal):

```bash
python3 << 'PYEOF'
import json, os
print(os.environ.get('HOME'))
PYEOF
```

The python heredocs in `deploy.sh` and `new-project.sh` use `'PYEOF'` for exactly this reason - python code references variables and shouldn't be subject to bash expansion.

### Test scripts with `bash -n` before pushing

For any non-trivial script change, run `bash -n script.sh` locally to catch syntax errors without executing. Doesn't catch runtime errors but catches the apostrophe/heredoc/quote bugs above before they ship.

For scripts that are too complex to syntax-check cleanly, write a smoke test that runs the script in a temp directory with default inputs and asserts on the output files. Worth the 15 minutes when the script is going to run on a half-dozen machines.

---

## When in doubt

Three places to check first when something feels off:

1. **This file** for operational questions ("how do I X," "why is Y broken")
2. **`docs/cowork-vs-claude-code.md`** for product-specific behavior
3. **The kit READMEs on GitHub** for kit-specific concerns

If the answer isn't in any of those, the system has evolved beyond what's documented. Update this manual.
