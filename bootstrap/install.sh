#!/usr/bin/env bash
# Bootstrap: installs or upgrades lore via uv tool install.
# Runs on every SessionStart — must be fast and idempotent.

set -euo pipefail

LORE_REPO="git+https://github.com/gorodulin/lore"

# Ensure uv is available
if ! command -v uv &>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# Install or upgrade lore
if command -v lore-mcp &>/dev/null; then
  # Already installed — upgrade only if needed
  uv tool upgrade lore 2>/dev/null || true
else
  uv tool install "$LORE_REPO"
fi

exit 0
