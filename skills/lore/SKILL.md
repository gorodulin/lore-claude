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
lore create . --fact "$fact" --incl "p:**/*" --tag "hook:read" --tag "kind:convention"
```

## Quick reference

### Matcher syntax

File-event targets (fire on Read/Edit/Write):

- `p:<glob>` — file path pattern (e.g. `p:src/**/*.ts`, `p:**/*.py`)
- `c:<regex>` — file content pattern (e.g. `c:import logging`, `c:(?i)todo`)

Command-event targets (fire on Bash, Task, WebFetch, WebSearch):

- `d:<regex>` — description / query text (e.g. `d:(?i)deploy|infra`)
- `x:<regex>` — raw command text, Bash only (e.g. `x:rm -rf`, `x:\|\s*sh`)

### Matching pipeline

1. **Skip first** — if any `skip` group matches, the fact is excluded
2. **Incl** — matchers group by target (`p:`, `c:`, `d:`, `x:`). OR within each group, AND between groups. Empty group = vacuously true.
3. **No source = no match** — if an incl group's target isn't provided by the event (e.g. `d:` on a file Edit), that group is False; the fact won't fire.

### Tags

- `action:block` — hard stop, prevents the operation. Use only when no legitimate exception exists.
- `hook:read`, `hook:edit`, `hook:write`, `hook:bash`, `hook:agent`, `hook:webfetch`, `hook:websearch` — restrict which tool events surface the fact. Without hook tags, the fact fires on any event whose available targets satisfy the incl groups.
- `kind:convention`, `kind:design`, `kind:commitment` — informational labels, no behavioral effect.

### Template variables

Fact text can include `{{variable}}` placeholders — resolved at display time from the triggering file path.

| Variable | Value | Example (for `src/api/auth.ts`) |
|----------|-------|---------------------------------|
| `{{filepath}}` | project-relative path | `src/api/auth.ts` |
| `{{fullpath}}` | absolute path | `/home/user/proj/src/api/auth.ts` |
| `{{folder}}` | directory with trailing `/` | `src/api/` |
| `{{filename}}` | basename | `auth.ts` |
| `{{basename}}` | filename without extension | `auth` |
| `{{ext}}` | extension with dot | `.ts` |

Unresolved variables (missing from context) are left as-is.

Use templates to make generic facts read as file-specific guidance:
- `"{{filepath}}: must not import from CLI modules"`
- `"Scripts in {{folder}} should have no .py extension"`
- `"Each unit should have corresponding test_{{basename}}.py unit test"`

### Shell escaping (CLI)

Regex and fact text can be tricky to escape. Prefer heredoc variables:

```bash
read -r fact <<'FACTTEXT'
<fact text>
FACTTEXT
read -r regex1 <<'FACTREGEX1'
<regex pattern>
FACTREGEX1
lore create . --fact "$fact" --incl "p:<glob>" --incl "c:$regex1"
```

Note: plain `read -r` without `-d` is fully POSIX but only supports one-liners.
