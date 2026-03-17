# Plugin Startup Flow

How the lore plugin initializes when a Claude Code session starts.

```mermaid
flowchart TD
    A[Claude Code<br/>Session Start] --> B[MCP server init<br/>mcp-server/server.sh]
    A --> H[Hook events<br/>hook/main.sh]

    %% MCP server path
    B --> B1[source bootstrap/install.sh<br/>ensure_lore_installed]
    B1 --> B2{lore-mcp<br/>found?}

    B2 -->|no| B3[install lore]
    B3 --> B6[exec lore-mcp]

    B2 -->|yes| B4{version matches<br/>LORE_VERSION pin?}
    B4 -->|yes| B6
    B4 -->|no| B5[upgrade lore]
    B5 --> B6

    subgraph installer [Install / Upgrade fallback chain]
        direction TB
        D1{uv available?} -->|yes| D2[uv tool install]
        D1 -->|no| D3{pipx available?}
        D3 -->|yes| D4[pipx install]
        D3 -->|no| D5[python3 -m venv<br/>~/.lore/venv + pip install]
    end

    B3 --> installer
    B5 --> installer

    %% Hook path
    H --> H1[source bootstrap/install.sh<br/>_find_lore_mcp]
    H1 --> H2{lore-hook-claude<br/>found?}
    H2 -->|yes| H3[exec lore-hook-claude]
    H2 -->|no| H4[pass through / no-op]
```

## Key points

- **MCP server** (`server.sh`) is the only place that installs or upgrades lore — it calls `ensure_lore_installed` before starting `lore-mcp`
- **Hook proxy** (`hook/main.sh`) only checks if `lore-hook-claude` exists — it does **not** install. If lore isn't installed yet, it silently passes through
- **Installer fallback**: `uv` > `pipx` > `python3 -m venv` (no external dependencies required)
- **Version pin**: `LORE_VERSION` file controls which lore version is installed. Upgrade only triggers when the pin changes (via plugin update)
