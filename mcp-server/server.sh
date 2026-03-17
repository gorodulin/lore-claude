#!/usr/bin/env bash
# MCP server proxy: ensures lore is installed at the pinned version,
# then starts lore-mcp. Runs fresh per session, so upgrades are safe.

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LORE_REPO="git+https://github.com/gorodulin/lore"
PINNED_VERSION="$(cat "$PLUGIN_ROOT/LORE_VERSION" 2>/dev/null | tr -d '[:space:]')"

# Ensure uv is on PATH
for p in "$HOME/.local/bin" "$HOME/.cargo/bin" "/usr/local/bin"; do
  [ -x "$p/uv" ] && export PATH="$p:$PATH" && break
done

# Ensure lore-mcp is on PATH
for p in "$HOME/.local/bin" "$HOME/.cargo/bin" "/usr/local/bin"; do
  [ -x "$p/lore-mcp" ] && export PATH="$p:$PATH" && break
done

# Get currently installed version (empty if not installed)
INSTALLED_VERSION=""
if command -v lore-mcp &>/dev/null; then
  INSTALLED_VERSION="$(uv tool list 2>/dev/null | grep '^lore ' | sed 's/^lore v\{0,1\}//' | awk '{print $1}' || true)"
fi

# Install or upgrade if needed
if [ -z "$INSTALLED_VERSION" ]; then
  # Not installed — fresh install
  if [ -n "$PINNED_VERSION" ]; then
    uv tool install "${LORE_REPO}@v${PINNED_VERSION}" >&2
  else
    uv tool install "$LORE_REPO" >&2
  fi
  export PATH="$HOME/.local/bin:$PATH"
elif [ -n "$PINNED_VERSION" ] && [ "$INSTALLED_VERSION" != "$PINNED_VERSION" ]; then
  # Version mismatch — upgrade
  uv tool install --force "${LORE_REPO}@v${PINNED_VERSION}" >&2
fi

exec lore-mcp "$@"
