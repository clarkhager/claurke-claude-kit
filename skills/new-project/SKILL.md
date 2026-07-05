---
name: new-project
description: Scaffold a new claurke project OR a nested sub-workspace inside an existing project - the interview-driven setup that creates CLAUDE.md, MEMORY.md, STATUS.md (and optionally PRIMER.md) with type-aware structure (code / knowledge / meta / subworkspace). Use whenever Clark wants to start, set up, scaffold, or spin up a new project or workspace, AND whenever he wants a subfolder, sub-workspace, nested space, or "a space for X inside <project>" - sub-workspace creation is this skill's job, even when the word "project" never appears ("make a subfolder for the kitchen reno in Home", "carve out a space for taxes inside Finances"). Also fires on "run new-project", "new-project script", or "set up the memory files for this folder". Works in both Claude Code (runs scripts/new-project.sh headlessly) and Cowork (scaffolds via file tools). NOT for first-time claurke installation on a new machine (claurke-onboarding) and NOT for debugging/updating the kits themselves (claurke-ops).
---

# New Project / Sub-Workspace Setup

Interview-driven scaffolding for claurke projects. One engine, two execution paths: in Claude Code the bundled script does the work; in Cowork (sandboxed bash — it cannot create directories on Clark's real machine, so running the script would silently no-op) you scaffold the same structure with file tools inside the mounted workspace.

## Step 1 — Interview (both environments)

Use AskUserQuestion. Gather, in as few rounds as possible:

1. **Location + name.** Where should it live? Default root: `~/Documents/Claude/Projects/<name>`. A path inside an existing project (parent dir has CLAUDE.md or MEMORY.md) means **sub-workspace mode** — detect this and CONFIRM it with Clark rather than assuming (a stray CLAUDE.md in a random checkout shouldn't silently demote his new project to a sub-workspace).
2. **Type** — `code` (tech stack, .gitignore, .claude/rules/), `knowledge` (notes/vault, default for top-level), `meta` (cross-repo coordination, tracked-repos section), `subworkspace` (inherits parent context, no separate git repo; default when parent is a project).
3. **Type-specific:** code → language (python/node/rust/go/other) + stack string; meta → space-separated `owner/repo` list to track.
4. **What this is** (1-2 sentences for CLAUDE.md), **immediate next move** (1 sentence for STATUS.md).
5. **PRIMER.md?** (default Y top-level, N sub-workspace) + one-line origin story if yes.
6. **Configure ~/.claude/settings.json?** (hooks, auto-memory off, compaction; default Y top-level, N sub-workspace). This mutates global settings — never assume yes.

## Step 2 — Branch on environment

Decide which world you're in: if Bash can see the real machine (`ls ~/.claude/memory-kit` succeeds), you're in Claude Code — use the script. If not (Cowork's sandbox), scaffold with file tools.

### Claude Code path — run the engine headlessly

Export the interview answers as env vars and run the script (never interactively — it would block on `read`):

```bash
NEW_PROJECT_TYPE=<type> \
NEW_PROJECT_LANGUAGE=<lang-if-code> \
NEW_PROJECT_STACK="<stack-if-code>" \
NEW_PROJECT_TRACKED_REPOS="<repos-if-meta>" \
NEW_PROJECT_WHAT_THIS_IS="<answer>" \
NEW_PROJECT_NEXT_MOVE="<answer>" \
NEW_PROJECT_ADD_PRIMER=<Y|N> \
NEW_PROJECT_ORIGIN_STORY="<answer-if-primer>" \
NEW_PROJECT_CONFIG_SETTINGS=<Y|N> \
bash ~/.claude/claurke-kit/scripts/new-project.sh "<project_dir>" < /dev/null
```

The script handles everything: memory-kit deploy, type-specific CLAUDE.md edits, .gitignore, and prints the next-steps block. Relay that output to Clark (it contains the git/backup/Cowork-connect steps and the first-session kickoff prompt). Unset/omit any var that doesn't apply; the header of the script documents each one.

### Cowork path — scaffold with file tools

The target must be inside the mounted workspace (creating a sub-workspace inside the current project is the common case; a brand-new top-level project outside the workspace is impossible from Cowork — say so and hand Clark the one-line terminal command: `bash ~/.claude/claurke-kit/scripts/new-project.sh "<path>"`).

1. Read the templates in this skill's `templates/` dir (CLAUDE.md, MEMORY.md, STATUS.md, PRIMER.md if wanted).
2. Create the files in the target folder, filling the placeholders the same way the script does: project name, stack, the what-this-is text into CLAUDE.md's "What This Is", the next move into STATUS.md, the origin story into PRIMER.md. Today's date on "Last updated" lines.
3. Type-specific edits, mirroring the script exactly:
   - **code**: keep the "## Scoped Rules" section.
   - **knowledge / meta / subworkspace**: remove the "## Scoped Rules (technical projects only)" section INCLUDING its leading `---` divider (the template has dividers on both sides — removing only the section leaves an orphaned double divider).
   - **meta**: append a "## Tracked Repos" section listing each `owner/repo` as a GitHub link, with the closing line "When changes land in any of these repos, capture the decision in MEMORY.md and update STATUS.md if it affects the next move."
   - **subworkspace**: append this section verbatim (substituting the parent's name/path):

     ```markdown
     ---

     ## Parent Workspace

     This is a sub-workspace of **<PARENT_NAME>** (`<PARENT_PATH>`).

     - Parent context (parent's CLAUDE.md, MEMORY.md, voice rules) applies in addition to this file.
     - Memory in this MEMORY.md is project-scoped. Universal decisions still go in the parent's MEMORY.md.
     - Git is handled by the parent repo; do not run `git init` in this folder.
     - Daily backup is handled by the parent repo's line in `~/.claude/backup-repos.conf`.
     ```

4. Hand Clark whatever the sandbox couldn't do, complete and copy-pasteable: for a top-level project, the `git init … && gh repo create clarkhager/<slug> --private --source=. --remote=origin --push` block (slug = name lowercased, spaces→`-`) and the backup line to append to `~/.claude/backup-repos.conf` (`<name> | <path> | false`). Sub-workspaces need neither (parent repo covers both).
5. Close with the first-session kickoff prompt: "New session in <name>. Read CLAUDE.md, MEMORY.md, and STATUS.md. Tell me what you know and what the next move is."

## Sub-workspace semantics (why this shape)

A sub-workspace gives a distinct workstream its own identity and memory isolation — its MEMORY.md is project-scoped, so decisions there don't pollute the parent's memory — while the parent's context, voice rules, git repo, and daily backup still apply. That's why it gets no `git init`, no separate backup entry, and (usually) no PRIMER. Universal decisions still belong in the parent's MEMORY.md.

## Templates note

`templates/` in this skill dir is a Cowork-only fallback copy of claurke-memory-kit's templates (see `templates/README.md` for the re-sync command). The Claude Code path always uses the live memory-kit via the script.
