# Classifying and designing facts

## Is it a fact?

Not all knowledge belongs in `.lore.json`. Work through these checks.

### Decompose first

If the knowledge contains multiple independent constraints, classify each part separately.

*"We chose Postgres advisory locks over Redis because infra won't support Redis"*
→ two pieces: the rationale is a **comment** on the locking code; "don't introduce
Redis-based locking" is a **fact** (cross-cutting constraint visible from no single file).

### The three tests

> Agent needs to **remember a rule** when it touches a file → **Fact**
>
> Agent needs to **understand code it's looking at** → **Comment** (recommend to user)
>
> Agent needs to **understand why things are the way they are** before deciding → **Document** (recommend to user; a fact can link to the document)

### Scope check

- **One location**, consequences contained locally → **Comment**, not fact
- **Multiple files**, boundary enforcement, cross-module invariants → **Fact**
- **No identifiable file pattern** (glob or regex) → belongs in `CLAUDE.md`, not lore

### Examples

| Knowledge | → | Why |
|-----------|---|-----|
| "All currency amounts are integers in cents, never floats" | Fact | Multi-file convention, no single home |
| "`ORDER BY id` uses ULID for time-ordering, avoids seq scan on 200M rows" | Comment | One location, explains specific code in place |
| "Server layer must not import from CLI or MCP modules" | Fact | Architectural boundary, invisible from one file |
| "This `rescue StandardError` is intentionally broad — best-effort metrics flush" | Comment | Explains code in place, consequences contained |
| "Adding a new event type requires updating schema, serializer, handler registry, and a round-trip test" | Fact | Cross-module invariant, no single file tells the whole story |

## Designing effective facts

### Text compression

- **Lead with the imperative or constraint.** "Never import Path — use os.path functions" not "We have a convention where..."
- **Name specific entities.** Specific nouns, specific verbs.
- **Cut rationale unless it changes behavior.** If the rule is absolute, drop the explanation. If the agent needs the "why" to decide edge cases, keep it.

### Matcher precision

**Glob** — use the narrowest scope that covers the convention:

- `g:**/*.py` — every Python file (convention-level)
- `g:src/api/**/*.ts` — one subsystem
- `g:src/api/auth.ts` — one specific file

**Regex** — match file *content* that relates to the constraint. The regex both triggers the fact and tells the agent what code pattern it's about:

- `r:import Path` — catches a specific bad import
- `r:load_facts|locate_fact` — catches code crossing a module boundary
- `r:(?i)claude` with `skip: g:src/claude/**/*` — catches boundary violations outside the allowed module

Combine glob + regex to narrow precisely: the fact fires only when the file path matches AND its content contains the pattern.

### Advisory vs blocking

> "Could the agent ever have a legitimate reason to do this?"

- **Yes** → advisory (default). Agent sees the fact as context and decides.
- **Never** → add `action:block` tag. Hard stop, no exceptions.

Most facts should be advisory. Blocking + regex is the strongest form — use sparingly.

### The fact-with-link pattern

When a fact needs deeper reasoning to act on correctly, extract the actionable core as a fact and keep the reasoning in a document:

*"New event types require updating schema, serializer, handler registry, and a round-trip test — see docs/adding-events.md"*
