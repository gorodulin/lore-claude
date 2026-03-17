#!/usr/bin/env bash
# Bootstrap: ensures uv is available for lore installation.
# Lore itself is installed by mcp-server/server.sh (before lore-mcp starts).

set -euo pipefail

if command -v uv &>/dev/null; then
  exit 0
fi

curl -LsSf https://astral.sh/uv/install.sh | sh >&2
