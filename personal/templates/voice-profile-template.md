# Voice profile

Your personal voice profile. Referenced (optionally) by the rules-kit CLAUDE.md Voice section to inform how Claude drafts content on your behalf. Without a voice profile, voice rules from your Claude account's personal preferences still apply as the baseline.

## When to populate this

Create your own voice profile when:

- You want richer voice cues beyond what fits in your account's personal preferences
- You have specific phrasing patterns or examples you want Claude to match
- Your personal preferences are getting long enough that splitting voice rules out makes sense

If your personal preferences already cover voice rules adequately, you can skip this file. It's optional, not required.

## Structure

### Salutation

Your preferred opening for emails and messages.

Example: "Hey [Name] -" (space-hyphen-space, never a comma)

### Sign-off

Your preferred closing.

Example: "Thank you," on its own line

### Banned phrases

Phrases you never want Claude to use in your voice.

Example: "straightforward", "let's dive in", "I'd be happy to"

### Punctuation rules

Specific punctuation patterns you use or avoid.

Example: Never use em dashes (use " - " instead)

### Contractions

Whether you use contractions, and which ones feel natural.

Example: Natural contractions ("don't", "it's") yes; uncommon ones ("shan't") no

### Length matching

How length should match the situation.

Example: Short when short is right. No filler sentences.

### Tone notes

Specific tone patterns that distinguish your voice.

Example: Direct and honest. Own delays. Match the recipient's energy.

### Voice at its best (3-5 examples)

Real messages you've sent that capture your voice well. Paste 3-5 examples.

```
[Example 1 - paste an email or message that sounds like you]

[Example 2]

[Example 3]
```

### Voice failures to avoid (2-3 examples)

Messages where the voice was off (AI-generated or someone else's voice). Helpful as negative examples.

```
[Example of how it sounded wrong]

[Why it was off]
```

## Sync

This file is part of your personal overlay (gitignored from the public claurke-claude-kit repo). Sync it via your private personal-overlay repo or gist along with the other overlay files.
