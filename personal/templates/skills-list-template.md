# Skills list

Skills to install on each Claude account. Skills are account-bound, not machine-bound - install once per account and they sync across machines.

## Required

Dependencies of the claurke-rules-kit CLAUDE.md or shipped as part of the claurke system. Without these, certain rules or workflows silently fail.

| Skill | Why required |
|-------|--------------|
| humanizer | Voice rule references it as final pass on drafted content |
| skill-creator | Skill management rule requires it for creating and modifying skills |
| claurke-ops | Operational knowledge skill for the claurke system - surfaces the operating manual on demand. Shipped with claurke-claude-kit at `skills/claurke-ops/` and auto-installed by bootstrap.sh to `~/.claude/skills/claurke-ops/`. For Cowork, may also need manual install via Plugins panel. |

## Always install (general utility)

| Skill | Use |
|-------|-----|
| docx | Word document creation and editing |
| xlsx | Spreadsheet handling |
| pptx | Slide deck creation |
| pdf | PDF manipulation |
| doc-coauthoring | Structured documentation workflow |
| typography | Typography enforcement in UI work |
| ui-ux-pro-max | UI/UX design intelligence |
| impeccable | Frontend design pipeline: `/impeccable shape`, `audit`, `polish` + `npx impeccable detect` (deterministic, no-LLM slop check). Marketplace `pbakaus/impeccable`; install user-scoped in Code and via Settings > Plugins in Cowork. Companion to ui-ux-pro-max for the Rule 21 design pipeline. |

## Install when starting development projects

| Skill | Use |
|-------|-----|
| mcp-builder | Building new MCP servers |
| webapp-testing | Local web app testing with Playwright |

## Install when starting design projects

| Skill | Use |
|-------|-----|
| theme-factory | Theming artifacts consistently |
| web-artifacts-builder | Complex multi-component HTML artifacts |

## Domain-specific (install when relevant)

| Skill | Use | When |
|-------|-----|------|
| bizzabo-api-toolkit | Bizzabo Public API knowledge | When working on or near Bizzabo |

## Personal additions

Skills specific to your workflow that aren't in the recommended list above. These often need to be created via /skill-creator for your specific use case.

| Skill | Use | Notes |
|-------|-----|-------|
| home-assistant-best-practices | Home Assistant config and automation guidance | For HA users; Clark uses this personally |
| [your-skill] | [your use case] | [created via skill-creator] |

## How to install

- **Cowork**: Settings > Plugins > install from marketplace
- **Claude Code**: `claude plugin install <plugin>`
- **Create new skills**: invoke /skill-creator (per the Skill management rule in rules-kit)
- **Do not** place skill files manually in arbitrary directories - that bypasses account-level installation and breaks cross-machine sync
- **Exception**: skills shipped with claurke-claude-kit (currently just claurke-ops) install via bootstrap.sh's filesystem copy to `~/.claude/skills/`, because they're versioned in the kit repo and the kit's update flow keeps them in sync
