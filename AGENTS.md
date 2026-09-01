# Scepter — Workspace Context

This vault is the persistent, portable second brain for an agentic OS that runs a SaaS business. Any agent operating here must follow these conventions.

## Three-Layer Memory Architecture

| Layer | Location | Injected? | Queried? | Purpose |
|---|---|---|---|---|
| **SOUL (Identity)** | `~/.hermes/profiles/<name>/SOUL.md` | ✅ Profile load | ❌ | Who the agent is, authority, tools, delegation targets |
| **Runtime Memory** | `~/scepter/Hermes/Memory/{MEMORY.md,USER.md}` | ✅ Every session | ❌ | User facts, preferences, session continuity |
| **Knowledge Base** | `~/scepter/Brain/Knowledge/` | ❌ | ✅ On demand | Frameworks, templates, decisions, references |

See `Brain/Knowledge/decisions/ADR-002-three-layer-memory.md` for full details.

## Folder Map

| Folder | Purpose |
|---|---|
| `00_Inbox/` | Capture everything first — sort later |
| `01_Tasks/` | Kanban task board (Hermes `/kanban` + `kanban.md` mirror) |
| `02_Projects/` | Active projects — one folder per project with `spec.md`, `tasks.md`, `log.md` |
| `03_Outreach/` | Lead tracking + templates |
| `Brain/Knowledge/` | **Frameworks, templates, decisions, references** — queried via gbrain/graphify |
| `Hermes/` | Agent layer: `Memory/`, `Sessions/`, `SOUL.md` (reference), `Config/` |
| `scripts/` | Sync/export tooling (portable, versioned) |
| `skills/` | Agentic skills (symlinked to `~/.hermes/skills/`) |

## Agent Profiles (Hermes)

| Profile | Role | Device | Delegation Authority |
|---|---|---|---|
| `heromi` | **Main Orchestrator / Human Interface** — Primary Personal Assistant, life organizer, brainstorms & plans with human, delegates specialist tasks based on intent, reports SaaS updates to human | PC + Termux | **Delegates to ALL agents** (xorin, ceo, product, growth, finance, engineer, ops) |
| `xorin` | **PC System Ops** — PC host-level system maintenance, tool installations, script setups, PC Hermes workspace, architecture maintenance | PC only | Receives from heromi; no further delegation |
| `ceo` | **SaaS Executive** — Owns SaaS execution, delegates SaaS tasks to specialists | PC only | **Delegates to specialists** (product, growth, finance, engineer, ops); reports to heromi |
| `product` | **Product Manager** — PRDs, prioritization, metrics, user stories, experiments | PC only | Receives from ceo; delegates to engineer/growth |
| `growth` | **Growth Lead** — Acquisition, retention, funnel optimization, SEO, content, partnerships | PC only | Receives from ceo; delegates to engineer/product |
| `finance` | **Finance Lead** — Unit economics, pricing, runway, fundraising, legal/compliance | PC only | Receives from ceo; advises heromi/xorin/ceo |
| `engineer` | **Lead Engineer** — Architecture, implementation, code quality, technical debt, deployment | PC only | Receives from ceo; delegates to ops |
| `ops` | **Platform Engineer** — Infrastructure, CI/CD, monitoring, security, scaling, vendor management | PC only | Receives from ceo/engineer; enables engineer |

### Delegation Hierarchy

```
HUMAN (you)
    │ verifies / approves
    ▼
heromi  ── Main Orchestrator / Human Interface / Life Organizer
    │ delegates
    ├── xorin  (PC System Ops) ──────────────────────────► reports to heromi
    ├── ceo    (SaaS Executive) ─────────────────────────► reports to heromi
    │       │ delegates
    │       ├── product  (Product Manager) ──────────────► reports to ceo → heromi
    │       ├── growth   (Growth Lead) ──────────────────► reports to ceo → heromi
    │       ├── finance  (Finance Lead) ─────────────────► reports to ceo → heromi
    │       ├── engineer (Lead Engineer) ────────────────► reports to ceo → heromi
    │       └── ops      (Platform Engineer) ─────────────► reports to ceo → heromi
```

**Key Rules:**
- `heromi` is the **single delegation hub** — all agents ultimately report to heromi
- `xorin` handles **PC infrastructure only** — no SaaS decisions
- `ceo` handles **SaaS execution only** — delegates to 5 specialists
- **All agents report to heromi** → heromi verifies with human
- Human is the final approver for strategic decisions, budget, pivots

## Delegation Protocol

See `Brain/Knowledge/decisions/DELEGATION_PROTOCOL.md` for full handoff format, report templates, escalation triggers, and kanban dependency tracking.

## Tooling

| Tool | Purpose | Access |
|---|---|---|
| `gbrain` | Memory, knowledge, semantic search, code graph | MCP (all agents) |
| `graphify` | Code structure, AST relationships, file dependencies | CLI skill (all agents) |
| `Mnemosyne` | Personal facts, preferences, session continuity | Internal (all agents) |
| `kanban` | Task board with assignee, status, dependencies | `01_Tasks/kanban_tasks.json` |
| Coding agents | `claude-code`, `codex`, `opencode`, `aider` | `engineer` profile |

## Cross-Device Sync

- **Vault** (`~/scepter/`) — Git synced to GitHub (private repo)
- **PC** — Full profiles, gbrain, graphify, cron sync (15 min)
- **Termux** — `heromi` profile only, vault sync, no gbrain/graphify
- **Sync script** — `scripts/vault_sync.sh` (cron on both devices)

## Guardrails

- **PC-only profiles:** `xorin`, `ceo`, `product`, `growth`, `finance`, `engineer`, `ops` (never on Termux)
- **Cross-platform:** `heromi` only
- **Environment guards** in `scripts/setup_symlinks.sh` enforce device-specific profiles
- **No cron/projects** until product is decided