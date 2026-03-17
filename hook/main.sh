#!/usr/bin/env bash
# Hook proxy: delegates to lore-hook-claude if available.

set -euo pipefail

source "$(dirname "$0")/../bootstrap/install.sh"

if _find_lore_mcp; then
  exec "$LORE_BIN_DIR/lore-hook-claude" "$@"
fi

# Not installed yet (MCP server will handle it) — pass through
cat > /dev/null
exit 0
