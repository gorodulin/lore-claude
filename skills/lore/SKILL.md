---
name: lore
description: Manage codebase conventions with Lore facts. Use when working with .lore.json files, checking conventions for files, or when the user mentions "lore" or "facts". Also use when asked to find, identify, extract, create, record, edit, refine, propose, suggest, or review conventions, constraints, or codebase rules.
---

# Lore

Lore stores **facts** — short reminders about codebase conventions, attached to files via patterns.
Facts fire automatically when matching files are touched, preventing conventions from silently drifting.

**Never edit `.lore.json` files directly** — always use MCP tools or the `lore` CLI tool.

## Actions

| When | Do |
|------|----|
| Check what conventions apply to a file | `find_facts(file_path)` |
| Create a new fact | [Classify] → [Design] → discuss with user → `create_fact(...)` |
| Edit an existing fact | `read_fact(id)` → assess what needs changing → `edit_fact(id, ...)` |
| Remove an obsolete fact | `delete_fact(id)` |
| Propose a fact proactively | Notice convention → [Classify] → [Design] → present to user → `create_fact(...)` |

[Classify] and [Design] — see [classifying-and-designing-facts.md](classifying-and-designing-facts.md).

## Proactive convention discovery

When reading code during normal work, watch for implicit conventions, architectural boundaries,
or non-obvious constraints that aren't captured as facts yet. When you notice one:

1. **Classify** — is it really a fact, or better as a comment or document?
2. **Design** — compress to imperative text, choose precise matchers
3. **Propose** — present the fact text and patterns to the user for approval
4. **Create** — only after the user agrees

Users can amplify this behavior by creating a meta-fact that reminds the agent
to watch for conventions on every file read:

```bash
read -r fact <<'FACTTEXT'
While working in this codebase, watch for implicit conventions, architectural
boundaries, or non-obvious constraints worth capturing as lore facts.
When you notice one, propose it to the user.
FACTTEXT
lore create . --fact "$fact" --incl "g:**/*" --tag "hook:read" --tag "kind:convention"
```

## Quick reference

### Matcher syntax

- `g:<glob>` — file path pattern (e.g. `g:src/**/*.ts`, `g:**/*.py`)
- `r:<regex>` — file content pattern (e.g. `r:import logging`, `r:(?i)todo`)

### Matching pipeline

1. **Skip first** — if any `skip` pattern matches, the file is excluded
2. **Incl (OR)** — at least one `incl` pattern must match
3. **Regex gated by glob** — regex patterns are only tested if a glob already matched

### Tags

- `action:block` — hard stop, prevents the operation. Use only when no legitimate exception exists.
- `hook:read`, `hook:edit`, `hook:write` — restrict which operations surface the fact. Without hook tags, a fact fires on all operations.
- `kind:convention`, `kind:design`, `kind:commitment` — informational labels, no behavioral effect.

### Shell escaping (CLI)

Regex and fact text can be tricky to escape. Prefer heredoc variables:

```bash
read -r fact <<'FACTTEXT'
<fact text>
FACTTEXT
read -r regex1 <<'FACTREGEX1'
<regex pattern>
FACTREGEX1
lore create . --fact "$fact" --incl "g:<glob>" --incl "r:$regex1"
```

Note: plain `read -r` without `-d` is fully POSIX but only supports one-liners.
