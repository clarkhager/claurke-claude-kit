# Personal overlay

The `personal/` directory is gitignored. It holds identity files and machine-specific config that don't belong in a public repo.

## Why an overlay

The public repo serves two purposes:

1. **Personal sync**: I clone it to each of my machines (personal laptop, work laptop) and bootstrap. The setup is identical across machines.
2. **Colleague onboarding**: someone forks it as a starting point for their own setup.

These two purposes pull in opposite directions. Personal sync wants "all my stuff." Colleague onboarding wants "generic enough to fork." The overlay pattern resolves this: the public repo holds the generic skeleton; the gitignored `personal/` folder holds the identity layer.

On my machines, `personal/` is populated with my identity files. On a colleague's machine, `personal/` is empty (or filled with their own identity), and the public skeleton still works.

## What goes in personal/

Good candidates:

- **Voice profile** (e.g., `clark_voice_profile.md`): tone, phrasing patterns, voice cues beyond what's in your account's personal preferences. Referenced by the rules-kit Voice section as the humanizer's source material.
- **MCP list** (`mcp-list.md`): which MCPs you connect on a new machine, with notes on accounts. Used as a checklist during bootstrap.
- **Account-specific notes** (`account-notes.md`): differences between your personal and work Claude accounts. What MCPs go on which, default project folders, etc.
- **Secrets references**: if you keep API keys in 1Password or age-encrypted, the references go here (not the secrets themselves).

Bad candidates (don't put here):

- **Raw secrets**: don't commit unencrypted credentials, even to a private repo. Use age (https://age-encryption.org) or a password manager.
- **Per-project context**: that's memory-kit's job. Project files go in the project's root, not in this overlay.
- **Behavioral rules**: that's rules-kit's job. Universal behavior goes there, not here.

## Syncing the overlay across your own machines

Since `personal/` is gitignored from this repo, you need to sync it separately. Three options:

1. **Second private GitHub repo.** Create a private repo (e.g., `yourname-claude-overlay`) and clone it into `personal/` on each machine. Most flexible, full git history, easiest to share between machines.
2. **Private gist.** Lighter weight for smaller overlays. Same pattern, just a gist instead of a full repo.
3. **Encrypted backup file.** age-encrypt the whole `personal/` tarball and store it somewhere syncable (iCloud, Dropbox, etc.). Smallest footprint, most setup overhead.

For the overlay to be useful on a fresh machine, the bootstrap script needs to know how to populate it. The pattern that works best: bootstrap script prints a manual step ("clone your private overlay repo into personal/"), you do it once per machine, done.

## What this kit's bootstrap does about personal/

In default (personal sync) mode: prints whether `personal/` is populated. If empty, gives instructions for populating from a private repo or gist.

In `--starter` mode (colleague install): skips personal/ entirely and prints guidance for the colleague to create their own overlay.

## Why not just commit personal stuff to a private repo?

Two reasons:

1. **Forkability.** The public repo is the entry point for colleagues. If they fork a repo that has my voice profile and MCP credentials baked in, they have to manually strip them out. The overlay pattern makes the public skeleton clean by default.
2. **Single source of truth.** I want one place that's authoritative for "how I work with Claude." Splitting personal and shareable across two repos creates drift; the shareable one goes stale because I'm not using it day-to-day. The overlay pattern keeps both in one repo, with one piece public and one piece private.
