# personal/

This directory is for **your personal identity overlay**. Everything in here is gitignored (except this README) so the public repo stays generic.

## What goes in here

Files and config that are specific to you or your machine, not portable to a fork:

- `clark_voice_profile.md` (or your own voice profile) - tone, phrasing patterns, banned phrases, voice cues beyond the personal-preferences baseline
- `mcp-list.md` - a list of MCPs you connect on a new machine (Gmail, Slack, Notion, etc.) with notes on which account to use
- `account-notes.md` - account-specific differences (personal vs. work Claude account, what MCPs go on which, etc.)
- API keys, OAuth tokens, anything secret - although the recommended pattern is to use a password manager (1Password, age) and reference those rather than committing the secrets here

## Why this pattern

The public repo serves two purposes: my personal sync across machines, and colleague onboarding as a starter kit. The overlay pattern lets one repo do both - public content is the generic skeleton; the overlay holds the identity layer that makes it specifically mine on my machines.

See `docs/personal-overlay.md` for the longer explanation.

## Syncing the overlay across your own machines

Since the overlay is gitignored from this public repo, you sync it separately. Two common patterns:

1. **Second private repo.** Keep `personal/` content in a private GitHub repo (e.g., `clarkhager-personal-overlay`). On a new machine, after bootstrap, clone that private repo into this `personal/` directory.
2. **Private gist.** Lighter weight for smaller overlays. Same pattern, just a gist instead of a repo.

For secrets specifically, don't commit raw values even to a private repo. Use age (https://age-encryption.org) or 1Password CLI to reference them.
