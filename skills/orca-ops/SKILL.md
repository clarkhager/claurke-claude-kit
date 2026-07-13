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
- **Lanes are split by FILE, not by ticket.** Two Linear issues that touch the same file are ONE lane, however cleanly they divide as tickets. Worktree isolation prevents lanes from corrupting each other; it does not merge their edits for you - two lanes editing `release.yml` produce two branches that conflict at PR time and silently drop half the work. Before firing N lanes, list the files each will touch and check for overlap. Overlap -> collapse into one lane, sequence the work inside it. (Learned 2026-07-13: JAD-97 and JAD-98's macOS half both edited `release.yml`; firing them in parallel would have been a conflict.)

## Who drives Orca (the three cockpits)

Orca runs on **M1 - the Burner** (`Clarks-Burner-Laptop.local`), which is always on and never sleeps. It is the ops host, not just a laptop. Three things can drive it:

| driver | bridge | when |
|---|---|---|
| **Cowork (this agent)** | **Desktop Commander MCP** (`start_process` -> real zsh on M1) | **The default.** Clark asks for lanes; Cowork fires and monitors them itself. |
| **Claude Code** | native shell, already on M1 | When Clark is at the keyboard driving a single deep lane himself. |
| **GUI** | Orca.app | First-time flows and one-offs, where seeing the drawer beats scripting it. |

**Cowork's bash is sandboxed Linux and CANNOT reach M1.** Desktop Commander is the *only* bridge from Cowork to the real machine - it is not computer-use, and computer-use is the wrong tool here (Terminal is granted at tier "click", so typing into it is blocked anyway).

**Do not hand Clark a Claude Code kickoff prompt for work you can fire yourself.** Global rule "Do, don't delegate" applies: if the lane can be created and monitored over Desktop Commander, create and monitor it. Hand back only what needs his hands or his judgment. (Learned 2026-07-13: a kickoff block was handed over for two lanes that Cowork then fired itself thirty seconds later. The Wherehouse Rule 18 kickoff format is written for a *Code* session and does not apply when Cowork is the driver - see "Orca-lane kickoff" below.)

### Orca-lane kickoff (the Rule 18 variant for Cowork-driven lanes)

Rule 18's (a)-(g) kickoff block assumes Clark launches Claude Code. When **Cowork** drives the lane, the classification work is identical but the artifact is different - state, before firing:

- **(a) Plan-only or build?** Canon/tripwire surfaces -> plan-only first, always.
- **(b) Codex?** yes/no + one-line why. BLOCKING on canon/security rows.
- **(c) Model + effort** for the lane agent.
- **(d) Lane map:** repo -> worktree name -> Linear issue, **plus the files each lane will touch** (the conflict check above).
- **(e) Gates:** the artifact-keyed acceptance receipts the lane must produce.
- **(f) Boundaries** carried in the lane prompt itself (install nothing / edit nothing / push nothing, as applicable).

No paste-ready launch block - Cowork runs the `orca` commands. Report the lane table to Clark instead.

## Starting a lane (the core flow)

Create a lane from a Linear issue so the branch names itself and the issue attaches (and, with status-sync on, the issue flips to In Progress).

**CLI (what Cowork uses; `orca` is at `/usr/local/bin/orca`):**

```bash
# Repo IDs - `repo list`, NOT `worktree ps` (ps shows names/paths, not ids)
orca repo list --json | python3 -c "import sys,json;[print(r['id'],r['displayName']) for r in json.load(sys.stdin)['result']['repos']]"

orca worktree create \
  --repo id:<repoId> --name <lane-name> \
  --linear-issue JAD-XX \        # NOT --issue: that takes a GitHub issue NUMBER
  --agent claude --setup skip \  # --setup skip for plan-only lanes (no deps needed)
  --prompt '<the full lane brief>' --json

orca terminal list --worktree path:<worktree-path> --json   # get the handle
orca terminal read --terminal <handle> --limit 25 --json
```

**Registered repo IDs** (stable; re-derive only if `repo list` disagrees):

| repo | id |
|---|---|
| The Wherehouse | `81d683f7-0187-4b43-8c5a-e20841bb3a81` |
| helmut-retrieval | `2841b3e0-6f15-4da1-9f4d-3f7af4d21f98` |
| helmut-review | `791677c2-5386-41fb-b656-8f4af82cfaa7` |
| actually-companion | `7cd4cb58-ee5b-4b3a-ae28-290d50fc1032` |

**`--issue` vs `--linear-issue` is a real trap:** `--issue` takes a GitHub issue *number*. Passing `JAD-97` to it does not error usefully. Linear issues need `--linear-issue`.

**Reading a lane:** `orca terminal read` on a live TUI can return empty or stale text (known gotcha). The reliable signal that a plan-mode lane finished is **the artifact on disk** - `ls -la <worktree>/PLAN.md` - not the terminal preview.

**GUI (first-time flows and one-offs):** open the Tasks/Linear drawer, find the issue, create a worktree from it, pick the repo. The default Claude terminal opens - paste the lane brief; open a second terminal, switch it to Codex, as the BLOCKING reviewer.

## Orchestration - the marathon fan-out

The Orchestration skill is installed on all three agents. A coordinator agent can hand off context to another agent or worktree, run **phased** child agents (each depends on the last) or **parallel** child agents (independent work), and split a large change into per-worktree PRs. For a marathon with many lanes, use the coordinator to fan out rather than hand-creating every worktree. This is the native version of what sol-prep formalizes.

## Closing a lane (archive at merge)

A lane's job ends when its PR merges (or its work otherwise lands) - archive the worktree as the last step of that merge: `orca worktree rm --worktree path:<worktree-path> --force` (works in any repo; `--force` handles live terminals and a not-fully-merged local branch, which is safe once the PR is on main). Skip it and merged lanes pile up until the projects window is dozens of dead worktrees hiding the few live ones - a real prune had to clear ~22 at once on 2026-07-13. Treat archive-at-merge like deleting a merged branch: automatic, part of finishing, not a separate cleanup you'll do "later."

**Archive-at-merge is a practice; the SWEEP is what enforces it.** A practice with no trigger is an aspiration - it decays silently, which is exactly how ~22 dead worktrees accumulated. The sweep is a real step, wired into `session-close-wherehouse` Step 3 (git loose-ends), and runnable any time:

```bash
# Every Orca worktree whose branch is already merged to origin/main = archive candidate
orca worktree ps --limit 50
# For each: is its branch merged?  git -C <repo> branch -r --merged origin/main | grep <branch>
# Merged -> orca worktree rm --worktree path:<path> --force
```

**Present the itemized candidate list to Clark and get approval before removing any.** A worktree may hold uncommitted work that never became a PR - `worktree rm --force` destroys it. This is a final action under the global review gate; the sweep *proposes*, Clark disposes. (2026-07-13: five merged worktrees were still open at the moment PR #7 landed the archive-at-merge practice - the practice cannot enforce itself.)

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
- **Cowork drives M1 through Desktop Commander, not computer-use** (see "Who drives Orca"). A Cowork bridge drop does not kill lanes already running inside Orca - they keep going on the Mac; just re-read them on reconnect. If you ever do fall back to computer-use, its control grant is session-scoped and can drop between turns; re-request when it does.

## Evolving this skill (the retro gate)

"Living skill - harden after each pilot and marathon" was the old instruction. It had **no artifact and no trigger**, which by the standard in Clark's own rules file makes it too weak to enforce - and it duly failed: this skill named the wrong bridge tool and shipped a wrong CLI flag for four days before anyone noticed.

The mechanism, not the aspiration:

**Trigger.** `session-close-wherehouse` asks, every close where an Orca lane ran: *did this session falsify or extend orca-ops?* Three prompts, cheap to answer:
1. Did any documented command, flag, path, or tool name turn out to be **wrong**? (-> correction, highest priority)
2. Did we derive a rule that isn't written down? (-> new convention)
3. Did a practice fail to fire because nothing triggered it? (-> it needs a gate, not better wording)

**Artifact.** Amendments surface as **candidates for Clark's approval** - never a silent overwrite. Same shape as the memory write protocol: state the claim, state where in the session it came from, ask. Approved candidates become a PR to `claurke-claude-kit` (this skill's canonical home since PR #7); rejected ones are dropped.

**Why a PR and not a cache edit.** Cowork's skill cache is read-only and reloads at session start, so an in-session edit is invisible and dies with the session. The kit repo is the only durable home. After merge: `bash ~/.claude/claurke-kit/bootstrap.sh --update`, and the plugin needs an **Update** in Cowork for bundled kit skills to refresh (existing gotcha).

Keep it to our conventions plus pointers. Do not let it grow into a mirror of onorca.dev.

### Amendment log

- **2026-07-13 (iteration 1)** - four defects found in one session: (a) the skill named **computer-use** as the bridge to M1 when the real bridge is **Desktop Commander**, which caused a Code kickoff prompt to be handed to Clark for lanes Cowork could fire itself; (b) `--issue <JAD-XX>` is **wrong** - Linear needs `--linear-issue`; (c) repo IDs were undocumented and had to be rediscovered; (d) archive-at-merge had no trigger, so five merged worktrees sat open. Added: the three-cockpits driver model, the Orca-lane kickoff variant, the lane-conflict-by-file rule, the worktree sweep, and this retro gate.

## Mechanics beyond our conventions

For anything not covered here, see `onorca.dev/docs`: "Your first 3-agent session", the CLI reference, Orchestration, the Linear items drawer, and the Settings reference.
