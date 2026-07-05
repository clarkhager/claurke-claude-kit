# MCP list

The MCPs to connect on a new machine. Each MCP requires OAuth or API key per Claude account; not portable across accounts without re-auth.

## Always install

Useful in any context (knowledge work or development).

| MCP | Account | Use |
|-----|---------|-----|
| Gmail | [personal / work] | Email read, search, draft, send |
| Slack | [personal / work] | Read, search, send, channels |
| Notion | [personal / work] | Pages, databases, search |
| GitHub | [personal / work] | Code, PRs, issues, search |
| Atlassian / Jira | [work] | Issues, project tracking |
| Postman | [personal / work] | API testing, collection management |
| Claude in Chrome | [either] | Browser navigation, page interaction |
| PDF Viewer | [either] | PDF inspection |
| Context7 | [either] | Up-to-date library docs and API references |

## Install when starting development projects

| MCP | Use |
|-----|-----|
| Railway | Deployment and infrastructure |
| Supabase | Backend, DB, edge functions |
| Sentry | Error monitoring |
| Apify | Web scraping |
| Jam | Browser session recording, debugging |
| Desktop Commander | File system and process management |

## Install when starting design projects

| MCP | Use |
|-----|-----|
| Figma | Design files, comments, exports |
| Canva | Templates, design generation |
| Replicate | Model inference |
| Higgsfield | Image and video generation |
| Gemini Image | Image generation and editing |

## Personal additions

This is your space to track MCPs specific to your personal workflow that aren't in the recommended list above. Examples: lifestyle MCPs (Spotify, Home Assistant), personal calendar tools (Amie), or company-specific connectors you've built.

| MCP | Account | Why |
|-----|---------|-----|
| [your tool] | [personal / work] | [your use case] |

## Notes

- Cowork MCPs: connect via Settings > Connectors per account
- Claude Code MCPs: configure `.mcp.json` per project, or globally via settings.json
- Cross-tool sync: apc-cli or mcp-config-manager can keep configs aligned across tools (Claude Code, Cowork, Cursor)
- MCPs are account-bound, not machine-bound; install once per account and they apply across all your machines on that account
