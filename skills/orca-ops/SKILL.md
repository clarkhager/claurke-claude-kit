---
name: orca-ops
description: The operating and coaching guide for how Clark uses Orca (stablyai/orca) for parallel agent coding - worktree-per-lane, the Fable-scopes / sol-prep-builds / Codex-reviews division of labor, our settings decisions, per-repo setup scripts, and the pilot/marathon patterns. Use this skill whenever Clark asks anything about Orca, wants to set up or fire a lane or a worktree, asks "how do I do X in Orca", is starting or planning a marathon or multi-agent run, needs to onboard a repo into Orca, or asks about Orca settings, orchestration, agents, or maintenance - even if he doesn't say the word "Orca" but is clearly talking about running parallel coding agents in his setup. This is the analog of linear-ops, the operating manual so any session can run Orca correctly and coach Clark from it without re-deriving it. Living skill - harden after each pilot and marathon.
---

# orca-ops - operating + coaching guide for Orca

This is how *we* use Orca, layered on top of the product. For raw Orca mechanics that aren't our convention, point to `onorca.dev/docs` rather than duplicating them here. This is a living doc: after each pilot and marathon, fold in what actually worked and broke (tracked as JAD-94; hardening gated on the JAD-93 pilot and the first marathon).

## The model - how we work in Orca

- **One worktree per lane.** Each agent runs in its own isolated git worktree off the repo, so parallel lanes cannot collide on files. Worktrees live under `~/orca/workspaces`, nested by repo name.
- **Division of labor.** Fable/Claude scopes a layer into a build-ready plan; sol-prep splits a plan into conflict-free build lanes and runs them; Codex reviews BLOCKING on each; Cowork holds the meta-plan and the canon-write gates. sol-prep is a conflict-splitter and executor, never the designer - scoping is Fable/Opus work.
- **Pilot before marathon.** Validate the tool on one contained lane before betting a multi-lane run on it. Discovering an Orca quirk on a $0 single lane beats finding it mid-marathon.

## Starting a lane (the core flow)

Create a lane from a Linear issue so the branch names itself and the issue attaches (and, with status-sync on, the issue flips to In Progress).

**GUI (preferred for one-offs and first-time flows):** open the Tasks/Linear drawer, find the issue, create a worktree from it, pick the repo. Then the default Claude terminal opens - paste the lane brief; open a second terminal, switch it to Codex, as the BLOCKING reviewer.

**CLI (for scripting marathons):** `orca` is at `/usr/local/bin/orca`.
- Get repo IDs: `orca worktree ps --json` (also lists connected repos).
- Create: `orca worktree create --repo id:<repoId> --name <name> --issue <JAD-XX> --json`.
- Drive terminals: `orca terminal create --worktree ... --command "..."`, collect with `orca terminal read --json` / `orca terminal wait --for tui-idle --json`.

## Orchestration - the marathon fan-out

The Orchestration skill is installed on all three agents. A coordinator agent can hand off context to another agent or worktree, run **phased** child agents (each depends on the last) or **parallel** child agents (independent work), and split a large change into per-worktree PRs. For a marathon with many lanes, use the coordinator to fan out rather than hand-creating every worktree. This is the native version of what sol-prep formalizes.

## Closing a lane (archive at merge)

A lane's job ends when its PR merges (or its work otherwise lands) - archive the worktree as the last step of that merge: `orca worktree rm --worktree path:<worktree-path> --force` (works in any repo; `--force` handles live terminals and a not-fully-merged local branch, which is safe once the PR is on main). Skip it and merged lanes pile up until the projects window is dozens of dead worktrees hiding the few live ones - a real prune had to clear ~22 at once on 2026-07-13. Treat archive-at-merge like deleting a merged branch: automatic, part of finishing, not a separate cleanup you'll do "later."

## Our settings (decided 2026-07-09, with the why)

- **Agents:** default agent = Claude; Codex enabled as the reviewer; Claude Agent Teams available. **Keep-computer-awake ON** - a sleeping Mac or a closed lid kills long or unattended lanes mid-run. **Auto-generate tab titles ON** - readable per-lane names when staring at many tabs.
- **Agent Permissions:** **Manual** for watched/pilot work so you see every move; **Yolo** for unattended marathons (the `--dangerously-skip-permissions` / `--dangerously-bypass-approvals-and-sandbox` flags), because you cannot approve prompts across N parallel lanes and the git worktree isolation is what keeps the blast radius contained.
- **Git & Source Control:** **Keep-Local-Main-Up-to-Date ON** so each new worktree starts from fresh main, not a stale local copy. Auto-Rename Branch ON. Orca Attribution OFF (keeps commits clean; our commit convention has its own co-author lines).
- **Integrations:** GitHub connected via the `gh` CLI; Linear connected and verified on **Jadyly Dev Studios** (clarkhager@gmail.com). Task picker decluttered to GitHub + Linear only (GitLab/Jira/Bitbucket hidden - unused).
- **Stats & Usage:** enable Claude + Codex token tracking so we get a combined spend ledger across lanes (supports Rule 22, especially once metered runs start after the Fable window).

## Per-repo setup scripts

A setup script runs automatically when Orca creates a worktree, to make the lane build-ready.
- **Docs/memory repos (The Wherehouse):** leave blank - nothing to install, a script would be a no-op.
- **Code repos:** `uv sync` (helmut-retrieval), `npm install` (helmut-review), `swift build` (actually-companion). On these, also turn ON **"Wait for setup to complete before starting agent"** so the agent does not start before deps are ready.

## Browser and Computer Use

- **Browser Use skill** is installed - agents can drive Orca's built-in browser to navigate and verify pages (relevant to the page-agent work, JAD-92, and any web-verification lane). **Cookie import is a security decision:** it hands agents your authenticated logins, so only do it when a lane genuinely needs authenticated pages.
- **Computer Use** is ready (Accessibility + Screenshots granted) - Orca's own agents can inspect and operate desktop apps when asked.

## Shortcuts cheat-sheet

`⌘N` create worktree · `⌘J` switch worktree · `⌘⇧↓` / `⌘⇧↑` next/prev worktree · `⌘1-9` select workspace · `⌘P` go to file · `⌘E` dictation (Parakeet TDT v3, hold to talk). Orca intercepts terminal shortcuts first ("Orca first"). Full keymap: `~/.orca/keybindings.json`.

## Provider accounts

Claude and Codex are authed on clarkhager@gmail.com under Settings → AI Provider Accounts. When GPT-5.6 Sol launches, add or hot-swap its account here - this is the seam for the provider-independence work (JAD-38) and sol-prep's dual-model config swap.

## Coaching Clark

- Clark ran his first Orca pilot on 2026-07-09; treat him as capable but new to Orca specifically. Teach the *why* behind each setting, recommend a call, and let him decide - do not silently flip settings. Prefer the GUI for first-time flows, the CLI once a flow is proven.
- When driving his machine via computer-use, the control grant is session-scoped and can drop between turns; re-request when it does, and know that a Cowork bridge drop does not kill lanes already running inside Orca.

## Maintenance

Keep this skill current. After each pilot and marathon: fold in what worked and broke, update the settings decisions if we changed any, and add new gotchas. Do not let it grow into a mirror of onorca.dev - keep it to our conventions plus pointers.

## Mechanics beyond our conventions

For anything not covered here, see `onorca.dev/docs`: "Your first 3-agent session", the CLI reference, Orchestration, the Linear items drawer, and the Settings reference.
