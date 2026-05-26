# Voice profile

Your personal voice profile. This is the canonical source for the voice rules Claude follows when drafting content on your behalf (emails, Slack messages, documents, anything you'll send to another person).

The rules-kit CLAUDE.md Voice section loads this file by reference before any draft. Your Claude account's personal preferences hold a one-line fallback baseline for environments where this overlay isn't accessible (claude.ai web, a fresh sandbox, etc.) - they should not duplicate the rules below.

## When to populate this

Populate it on first machine setup. Every machine you sync the overlay to gets the same file. Without it, drafting falls back to the personal-preferences baseline, which is much thinner than what you can fit here.

Skip only if you genuinely don't want Claude to draft anything on your behalf.

## Structure

### Salutation

Your preferred opening for emails and messages.

Example: `Hey [Name] -` (space-hyphen-space, never a comma)

### Sign-off

Your preferred closing.

Example: `Thank you,` on its own line

### Punctuation

Specific punctuation patterns you use or avoid.

Example: Never use em dashes (use ` - ` instead). En dashes also off-limits for asides.

### Contractions

Whether you use contractions, and which ones feel natural.

Example: Natural contractions (don't, it's, I'm, we're) yes; uncommon ones (shan't, mayn't) no.

### Length matching

How length should match the situation.

Example: Short when short is right. No filler sentences. No trailing summaries.

### Tone notes

Specific tone patterns that distinguish your voice.

Example: Direct and honest. Own delays. Match the recipient's energy without mirroring it artificially.

### Banned phrases

Phrases you never want Claude to use in your voice. Be specific.

Example: straightforward, It's worth noting, Let's dive in, I'd be happy to, Great question, Absolutely (as standalone), So at sentence start.

### Banned constructions

Stylistic patterns that read as AI-generated.

Examples:
- Rule-of-three rhetorical constructions (three parallel items as flourish)
- Trailing summaries that restate what was just said
- Em dashes anywhere
- Negative parallelisms ("not just X, but Y")
- Stacked conjunctive sentence starters (Furthermore, Moreover, Additionally)

### Voice at its best (3-5 examples)

Real messages you've sent that capture your voice well. Paste 3-5 examples with brief context.

```
[Example 1 - paste a real message]
Context: [who it was to, what the situation was]
```

```
[Example 2]
Context: [who it was to, what the situation was]
```

### Voice failures to avoid (2-3 examples)

Messages where the voice was off (AI-generated or someone else's voice). Helpful as negative examples.

```
[Example of how it sounded wrong]
Why it was off: [one line]
```

## Enforcement

The rules above describe the rules. Enforcement requires the humanizer skill as a final pass on every draft before it's shown to you. Skipping the humanizer is not acceptable. If the humanizer skill isn't installed on the current machine, install it via the Cowork plugin marketplace (Anthropic Skills bundle) or `claude plugin install anthropic-skills` in Claude Code.

## Sync

This file is part of your personal overlay (gitignored from the public claurke-claude-kit repo). Sync it via your private personal-overlay repo or gist along with the other overlay files (mcp-list.md, skills-list.md, account-notes.md).
