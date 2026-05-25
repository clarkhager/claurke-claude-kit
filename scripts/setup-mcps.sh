#!/bin/bash
# setup-mcps.sh - Walk through MCP connection setup
# MCPs require OAuth or API keys per account, so install can't be fully automated.
# This script lists what to connect and points at tools that help.

set -euo pipefail

BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}>${NC} MCP setup notes"
echo ""
echo "MCPs (Model Context Protocol servers) require OAuth or API-key setup per account."
echo "They can't be fully automated. Here's what to do manually:"
echo ""
echo "In Cowork:"
echo "  Settings > Connectors > add the MCPs you use"
echo "  Typical: Gmail, Google Calendar, Slack, Notion, GitHub"
echo ""
echo "In Claude Code:"
echo "  Configure MCPs in .mcp.json at the project root, or globally via settings.json"
echo "  Reference: https://docs.claude.com/en/docs/claude-code/mcp"
echo ""
echo "Cross-tool MCP sync (helpful if you use Claude Code AND Cowork AND Cursor):"
echo "  apc-cli:             https://github.com/FZ2000/apc-cli"
echo "  mcp-config-manager:  https://github.com/itsocialist/mcp-config-manager"
echo ""
echo "If you maintain a personal mcp-list.md in the personal/ overlay,"
echo "refer to it for the canonical list of MCPs to set up on a new machine."
echo ""
