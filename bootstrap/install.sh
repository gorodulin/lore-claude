#!/usr/bin/env bash
# Bootstrap: ensures lore is installed at the pinned version.
# Called by mcp-server/server.sh and hook/main.sh.
# Tries uv, then pipx, then falls back to a self-managed venv.
#
# Usage: source this script, then call ensure_lore_installed
# After sourcing, LORE_BIN_DIR is set to the directory containing lore-mcp.

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LORE_REPO="https://github.com/gorodulin/lore"
LORE_VENV_DIR="${HOME}/.lore/venv"
PINNED_VERSION="$(cat "$PLUGIN_ROOT/LORE_VERSION" 2>/dev/null | tr -d '[:space:]')"

LORE_BIN_DIR=""

_find_lore_mcp() {
  for p in "$HOME/.local/bin" "$LORE_VENV_DIR/bin" "/usr/local/bin"; do
    if [ -x "$p/lore-mcp" ]; then
      LORE_BIN_DIR="$p"
      return 0
    fi
  done
  return 1
}

_installed_version() {
  local ver=""
  if command -v uv &>/dev/null; then
    ver="$(uv tool list 2>/dev/null | grep '^lore ' | sed 's/^lore v\{0,1\}//' | awk '{print $1}')" || true
  fi
  if [ -z "$ver" ] && [ -x "$LORE_VENV_DIR/bin/lore-mcp" ]; then
    ver="$("$LORE_VENV_DIR/bin/python" -c "import importlib.metadata; print(importlib.metadata.version('lore'))" 2>/dev/null)" || true
  fi
  if [ -z "$ver" ] && command -v pipx &>/dev/null; then
    ver="$(pipx list --short 2>/dev/null | grep '^lore ' | awk '{print $2}')" || true
  fi
  echo "$ver"
}

_install_with_uv() {
  local pkg="git+${LORE_REPO}"
  [ -n "$PINNED_VERSION" ] && pkg="${pkg}@v${PINNED_VERSION}"

  if [ "$1" = "upgrade" ]; then
    uv tool install --force "$pkg" >&2
  else
    uv tool install "$pkg" >&2
  fi
  LORE_BIN_DIR="$HOME/.local/bin"
}

_install_with_pipx() {
  local pkg="git+${LORE_REPO}"
  [ -n "$PINNED_VERSION" ] && pkg="${pkg}@v${PINNED_VERSION}"

  if [ "$1" = "upgrade" ]; then
    pipx install --force "$pkg" >&2
  else
    pipx install "$pkg" >&2
  fi
  LORE_BIN_DIR="$HOME/.local/bin"
}

_find_python() {
  # Prefer python3.12+, fall back to python3.11, then python3.10, then python3
  for py in python3.14 python3.13 python3.12 python3.11 python3.10 python3; do
    if command -v "$py" &>/dev/null; then
      echo "$py"
      return 0
    fi
  done
  return 1
}

_install_with_venv() {
  local pkg="git+${LORE_REPO}"
  [ -n "$PINNED_VERSION" ] && pkg="${pkg}@v${PINNED_VERSION}"

  local py
  py="$(_find_python)" || { echo "ERROR: No suitable Python found" >&2; return 1; }

  if [ "$1" = "upgrade" ] || [ ! -d "$LORE_VENV_DIR" ]; then
    rm -rf "$LORE_VENV_DIR"
    "$py" -m venv "$LORE_VENV_DIR" >&2
  fi
  "$LORE_VENV_DIR/bin/pip" install --quiet "$pkg" >&2
  LORE_BIN_DIR="$LORE_VENV_DIR/bin"
}

_install_lore() {
  local mode="${1:-install}"  # "install" or "upgrade"

  if command -v uv &>/dev/null; then
    _install_with_uv "$mode"
  elif command -v pipx &>/dev/null; then
    _install_with_pipx "$mode"
  else
    _install_with_venv "$mode"
  fi
}

ensure_lore_installed() {
  local installed_ver

  if _find_lore_mcp; then
    # Already installed — check if upgrade needed
    if [ -n "$PINNED_VERSION" ]; then
      installed_ver="$(_installed_version)"
      if [ "$installed_ver" != "$PINNED_VERSION" ]; then
        _install_lore "upgrade"
      fi
    fi
  else
    # Not installed — fresh install
    _install_lore "install"
  fi

  # Final check
  _find_lore_mcp
}
