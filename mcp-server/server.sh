#!/usr/bin/env bash
# MCP server proxy: ensures lore is installed, then delegates to lore-mcp.

set -euo pipefail

# Check common uv tool bin locations
for p in "$HOME/.local/bin" "$HOME/.cargo/bin" "/usr/local/bin"; do
  [ -x "$p/lore-mcp" ] && export PATH="$p:$PATH" && break
done

# If lore-mcp not found, install it now
if ! command -v lore-mcp &>/dev/null; then
  # Ensure uv is available
  if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh >&2
    export PATH="$HOME/.local/bin:$PATH"
  fi
  uv tool install "git+https://github.com/gorodulin/lore" >&2
  export PATH="$HOME/.local/bin:$PATH"
fi

exec lore-mcp "$@"
