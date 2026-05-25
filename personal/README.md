# personal/

This directory is for **your personal identity overlay**. Everything in here is gitignored (except this README and the templates folder) so the public repo stays generic.

## What goes in here

Files and config that are specific to you or your machine, not portable to a fork:

- `voice-profile.md` - your personal voice cues (tone, phrasing patterns, banned phrases, voice examples beyond the baseline in your account's personal preferences)
- `mcp-list.md` - the MCPs you connect on each Claude account, with notes on which account is which
- `skills-list.md` - the skills you install on each Claude account, with required vs. optional flagged
- `account-notes.md` - account-specific differences (personal vs. work Claude account, what MCPs go where, default project folders, etc.)
- API key or token references, encrypted secrets references (not raw values; use age or 1Password for actual secrets)

## Templates

In `personal/templates/` you'll find starting points for the most common overlay files:

- **voice-profile-template.md** - structure for a personal voice profile, with placeholder examples in each section
- **mcp-list-template.md** - MCPs to install, organized by always / dev / design / personal
- **skills-list-template.md** - skills to install, organized by required / always / dev / design / domain-specific / personal

On a new install, copy these templates into your personal overlay (private repo or gist) and fill in your actual values. The templates themselves stay in the public claurke-claude-kit repo and are versioned with everything else.

## Why this pattern

The public repo serves two purposes:

1. **Personal sync**: I clone it to each of my machines (personal laptop, work laptop) and bootstrap. The setup is identical across machines.
2. **Colleague onboarding**: someone forks it as a starting point for their own setup.

These two purposes pull in opposite directions. Personal sync wants "all my stuff." Colleague onboarding wants "generic enough to fork." The overlay pattern resolves this: the public repo holds the generic skeleton (including templates); the gitignored `personal/` folder (excluding templates) holds the identity layer.

On my machines, `personal/` is populated with my identity files (filled-in from templates). On a colleague's machine, `personal/` is empty (or filled with their own identity), and the public skeleton still works.

## Syncing the overlay across your own machines

Since populated overlay files are gitignored from this repo, you sync them separately. Three options:

1. **Second private GitHub repo.** Create a private repo (e.g., `yourname-claude-overlay`) and clone it into `personal/` on each machine. Most flexible, full git history, easiest to share between machines.
2. **Private gist.** Lighter weight for smaller overlays. Same pattern, just a gist instead of a full repo.
3. **Encrypted backup file.** age-encrypt the whole `personal/` tarball and store it somewhere syncable (iCloud, Dropbox, etc.). Smallest footprint, most setup overhead.

For the overlay to be useful on a fresh machine, the bootstrap script needs to know how to populate it. Pattern that works best: bootstrap script prints a manual step ("clone your private overlay repo into personal/"), you do it once per machine, done.

## What bootstrap does about personal/

In default (personal sync) mode: prints whether `personal/` is populated. If empty, gives instructions for populating from a private repo or gist or by copying the templates.

In `--starter` mode (colleague install): skips personal/ population and prints guidance for the colleague to create their own overlay from the templates.

## Why not just commit personal stuff to a private repo?

Two reasons:

1. **Forkability.** The public repo is the entry point for colleagues. If they fork a repo that has your voice profile and MCP credentials baked in, they have to manually strip them out. The overlay pattern makes the public skeleton clean by default.
2. **Single source of truth.** I want one place that's authoritative for "how I work with Claude." Splitting personal and shareable across two repos creates drift; the shareable one goes stale because I'm not using it day-to-day. The overlay pattern keeps both in one repo, with one piece public and one piece private.
