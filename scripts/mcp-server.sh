#!/usr/bin/env bash
# MCP server proxy: ensures lore is installed, then starts lore-mcp.

set -euo pipefail

source "$(dirname "$0")/install.sh"

ensure_lore_installed

exec "$LORE_BIN_DIR/lore-mcp" "$@"
