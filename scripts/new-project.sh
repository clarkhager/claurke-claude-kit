#!/bin/bash
# new-project.sh - Initialize a new project with memory-kit
# Usage: bash new-project.sh [project_dir]
# Wraps memory-kit's deploy.sh for convenience.

set -euo pipefail

MEMORY_KIT_DIR="$HOME/.claude/memory-kit"

if [ ! -d "$MEMORY_KIT_DIR" ]; then
  echo "memory-kit not found at $MEMORY_KIT_DIR"
  echo "Run bootstrap.sh first to install both kits."
  exit 1
fi

bash "$MEMORY_KIT_DIR/deploy.sh" "$@"
