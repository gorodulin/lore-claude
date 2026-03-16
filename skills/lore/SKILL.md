---
name: lore
description: Manage codebase conventions with Lore facts. Use when working with .lore.json files, checking conventions for files, or when the user mentions "lore" or "facts".
---

# Lore

Lore stores **facts** — short reminders about codebase conventions, attached to files via patterns.
Facts fire automatically when matching files are touched, preventing conventions from silently drifting.

## Available MCP Tools

- `find_facts` — check what conventions apply to a file
- `create_fact` — record a new convention
- `read_fact` / `edit_fact` / `delete_fact` — manage existing facts

## When to Use

- Before editing a file, check if any facts apply: `find_facts`
- When you notice a convention worth preserving, propose a fact to the user
- When the user asks about project conventions or rules
