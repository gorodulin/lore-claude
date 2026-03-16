# lore-claude

Claude Code plugin for [Lore](https://github.com/gorodulin/lore) — a fact injection system that attaches codebase conventions to files via patterns.

## What it does

- **Hook** — injects matching facts as context when files are touched
- **MCP server** — exposes fact management tools (`find_facts`, `create_fact`, `edit_fact`, `delete_fact`)
- **Skill** — teaches Claude when and how to use Lore
- **Bootstrap** — installs Lore automatically on first session

## Install

Two steps: add the marketplace, then install the plugin.

```bash
claude plugin marketplace add gorodulin/lore-claude
claude plugin install lore@gorodulin
```

Restart Claude Code (or run `/reload-plugins`) to activate.

## Update

```bash
claude plugin marketplace update gorodulin
claude plugin update lore@gorodulin
```

Restart to apply changes.

## Uninstall

```bash
claude plugin uninstall lore@gorodulin
```

To also remove the marketplace:

```bash
claude plugin marketplace remove gorodulin
```

## Development

Test locally without installing:

```bash
claude --plugin-dir ./lore-claude
```
