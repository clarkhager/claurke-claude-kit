---
name: claurke-ops
description: Surfaces operational knowledge for Clark Hager's Claude workflow (the "claurke" system - claurke-claude-kit, claurke-rules-kit, claurke-memory-kit). Use whenever Clark asks about his Claude system, the kits, updates, sync, or anything operational. Trigger on phrases like "how do I update my Claude system," "why aren't the rules firing," "set up Claude on a new machine," "where do I install humanizer," "fix my hooks," "personal overlay," "recovery scenarios," or any question mapping to the operating manual's seven sections (daily ops, setup checklist, verification, updates, troubleshooting, recovery, decision log). Also trigger when Clark is debugging Claude behavior covered by the kits (silent rule failures, missing skill installs, MCP issues, broken bootstrap). Fire even when Clark doesn't name "claurke" explicitly - if the question is operational about his Claude setup, the manual likely has the answer. Undertriggering leaves Clark debugging from scratch.
---

# claurke-ops

You're answering an operational question about Clark Hager's Claude workflow system (codenamed "claurke"). The system is three GitHub repositories plus an authoritative operating manual.

## System architecture

Three repos hold the system:

- **claurke-claude-kit** - orchestrator and bootstrap. https://github.com/clarkhager/claurke-claude-kit
- **claurke-rules-kit** - universal behavioral rules (anti-sycophancy, sparring-partner, response-shape, diagnostic-mode, voice integration). https://github.com/clarkhager/claurke-rules-kit
- **claurke-memory-kit** - per-project memory templates. https://github.com/clarkhager/claurke-memory-kit

The canonical operational reference is `claurke-claude-kit/docs/operating-manual.md`. Seven sections:

1. Daily operations - using each product day-to-day, cross-product handoff
2. Recommended setup checklist - new machine, new account, colleague onboarding
3. Verification - test prompts to confirm rules are loaded
4. Update workflows - including Cowork re-paste cadence when rules-kit changes
5. Troubleshooting - rules not firing, hooks dead, side docs not loading, humanizer missing, MCPs missing
6. Recovery scenarios - deleted overlay, corrupted CLAUDE.md, drift across machines, broken bootstrap
7. Decision log - why the system is the way it is (architecture decisions, deferred choices)

## How to answer

1. **Read the operating manual.** Local copy at `~/.claude/claurke-kit/docs/operating-manual.md`. If that path doesn't exist (you're in a fresh environment), fetch the live version: https://raw.githubusercontent.com/clarkhager/claurke-claude-kit/main/docs/operating-manual.md. The manual has the authoritative answers.

2. **Cite which section your answer comes from.** When answering, name the section ("per section 5, Troubleshooting..." or "this is in the Decision log"). Gives Clark a way to verify and lets him jump straight to the source.

3. **Give exact commands.** Don't paraphrase ("run the bootstrap" is bad; "run `bash ~/.claude/claurke-kit/bootstrap.sh --update`" is good). Commands are load-bearing in operational guidance.

4. **Acknowledge limits honestly.** If the manual doesn't cover the case, say so. Don't fabricate operational guidance that isn't in the manual.

5. **For decision-rationale questions, consult section 7 (Decision log).** It explains why the system is structured the way it is. Useful when Clark is considering a structural change.

6. **Apply Clark's voice rules when drafting content FOR Clark.** When drafting emails, Slack messages, documents, or anything written on Clark's behalf, follow Clark's voice rules: no em-dashes (use space-hyphen-space " - " for asides), no banned AI-tell phrases ("straightforward," "let's dive in," "I'd be happy to," "great question," etc.), natural contractions, match length to the situation, no rule-of-three rhetorical constructions, salutation "Hey [Name] -", sign-off "Thank you," on its own line. Direct chat responses TO Clark are conversational and do not need salutation or sign-off; voice rules on style (no em-dashes, no banned phrases, natural contractions, no rule-of-three) still apply to keep the tone consistent.

## When to fire this skill

Fire whenever the question is operational about Clark's Claude workflow. Specific triggers:

- **Setup**: "set up Claude on a new machine," "how do I install this on my work laptop," "fresh machine"
- **Updates**: "how do I update on this machine," "did rules-kit change," "pull latest"
- **Troubleshooting**: "why aren't the rules firing," "Claude isn't following my preferences," "fix my hooks," "humanizer not running," "side doc not loading"
- **Recovery**: "I deleted my personal overlay," "Claude isn't loading my CLAUDE.md," "kit drift"
- **Project setup**: "start a new project," "how do I deploy memory-kit," "new-project script"
- **Architecture**: "what's the difference between the kits," "where do my voice rules live," "explain the system"
- **Skill management**: "how do I create a new skill" (route to /skill-creator), "install humanizer"
- **MCP management**: "what MCPs should I connect," "set up MCPs on new machine"
- **Decision rationale**: "why did we choose X," "why are we using overlay pattern," "why no chezmoi"

Fire even when Clark doesn't name "claurke" or "the kit" explicitly. If the question is operational about his Claude workflow, the operating manual is likely to have the answer.

## What this skill does NOT cover

- **Project-specific code or memory** - that's memory-kit's per-project files (CLAUDE.md, MEMORY.md, STATUS.md, PRIMER.md at the project root)
- **Behavioral rule content itself** - that's rules-kit's CLAUDE.md, loaded globally
- **Voice profile content** - lives in Clark's Claude account personal preferences, or in `personal/voice-profile.md` if he maintains one
- **Creating new skills** - use the /skill-creator skill (per the Skill management rule in rules-kit CLAUDE.md)
- **Installing third-party skills** - use Cowork plugin marketplace UI or `claude plugin install <plugin>`

These have their own surfaces. This skill is specifically the operational layer for the claurke system.

## References

- **Operating manual (canonical)**: `~/.claude/claurke-kit/docs/operating-manual.md` (local) or https://raw.githubusercontent.com/clarkhager/claurke-claude-kit/main/docs/operating-manual.md (web)
- **Three kit READMEs**: https://github.com/clarkhager/claurke-claude-kit, https://github.com/clarkhager/claurke-rules-kit, https://github.com/clarkhager/claurke-memory-kit
- **Cowork vs Claude Code differences**: `~/.claude/claurke-kit/docs/cowork-vs-claude-code.md` or https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/cowork-vs-claude-code.md
- **Personal overlay pattern**: `~/.claude/claurke-kit/docs/personal-overlay.md` or https://github.com/clarkhager/claurke-claude-kit/blob/main/docs/personal-overlay.md
