# Plugin Startup Flow

How the lore plugin initializes when a Claude Code session starts.

```mermaid
flowchart TD
    A[Session Start] --> B[bootstrap/install.sh<br/>SessionStart hook]
    A --> C[mcp-server/server.sh<br/>MCP server init]

    B --> B1{uv available?}
    B1 -->|yes| B2[done]
    B1 -->|no| B3[install uv via curl]
    B3 --> B2

    C --> C1[source bootstrap/install.sh]
    C1 --> C2{lore-mcp found?}

    C2 -->|yes| C3{version matches<br/>LORE_VERSION?}
    C3 -->|yes| C6[exec lore-mcp]
    C3 -->|no| C4[upgrade lore]
    C4 --> C6

    C2 -->|no| C5[install lore]
    C5 --> C6

    subgraph installer [Install / Upgrade]
        direction TB
        D1{uv?} -->|yes| D2[uv tool install]
        D1 -->|no| D3{pipx?}
        D3 -->|yes| D4[pipx install]
        D3 -->|no| D5[python3 -m venv<br/>~/.lore/venv]
    end

    C4 --> installer
    C5 --> installer

    A --> E[hook/main.sh<br/>PreToolUse + other events]
    E --> E1{lore-hook-claude<br/>found?}
    E1 -->|yes| E2[exec lore-hook-claude]
    E1 -->|no| E3[pass through<br/>no-op]
```

## Key points

- **MCP server** handles install/upgrade — it runs before `lore-mcp` starts, so no running process is replaced
- **Bootstrap hook** only ensures `uv` is present (lightweight)
- **Hook proxy** delegates if `lore-hook-claude` exists, otherwise silently passes through
- **Installer priority**: `uv` > `pipx` > `python3 venv`
