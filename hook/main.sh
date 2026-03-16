#!/usr/bin/env bash
# Hook proxy: delegates to lore-hook-claude if available.

set -euo pipefail

# Check common uv tool bin locations
for p in "$HOME/.local/bin" "$HOME/.cargo/bin" "/usr/local/bin"; do
  [ -x "$p/lore-hook-claude" ] && export PATH="$p:$PATH" && break
done

if command -v lore-hook-claude &>/dev/null; then
  exec lore-hook-claude "$@"
fi

# Not installed yet — silently pass through
cat > /dev/null
exit 0
