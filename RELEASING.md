# Releasing Lore Updates

Two repos are involved:

| Repo | What | Who updates |
|---|---|---|
| `gorodulin/lore` | The lore tool (Python package) | Developer |
| `gorodulin/lore-claude` | The Claude Code plugin (installs & wraps lore) | Developer |

## Release a new lore version

### 1. Tag the lore repo

```bash
cd lore/
# Bump version in pyproject.toml
git add pyproject.toml && git commit -m "Bump version to 0.2.0"
git tag v0.2.0
git push origin main --tags
```

### 2. Update the version pin in lore-claude

```bash
cd lore-claude/
echo "0.2.0" > LORE_VERSION
```

### 3. Bump the plugin version & push

```bash
# Update version in both files:
#   .claude-plugin/plugin.json
#   .claude-plugin/marketplace.json
git add LORE_VERSION .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "Bump lore to 0.2.0, plugin to 0.4.0"
git push origin main
```

### 4. Users receive the update

```
claude plugin marketplace update gorodulin
```

On next session start, `server.sh` detects the version mismatch and upgrades lore before starting the MCP server.

## How the upgrade works

1. `server.sh` reads `LORE_VERSION` (pinned version)
2. Compares to the installed version
3. If mismatched → reinstalls using `uv`, `pipx`, or `python3 -m venv` (whichever is available)
4. Then starts `lore-mcp`

The upgrade happens **before** `lore-mcp` starts, so no running process is replaced.

## Plugin-only changes (no lore update)

If you only change plugin files (skills, hooks config, etc.) without updating lore itself:

1. Bump version in `plugin.json` and `marketplace.json`
2. Push to `gorodulin/lore-claude`
3. Leave `LORE_VERSION` unchanged
