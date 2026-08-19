# Scepter — Workspace Context

This vault is the persistent, portable second brain for an agentic OS that runs a SaaS business. Any agent operating here must follow these conventions.

## Lean Vault Isolation Protocol

### Vault Scope (Git-Tracked)
| Component | Location | Synced? |
|---|---|---|
| **Cross-Platform Profile** | `Hermes/Profiles/heromi/` | ✅ SOUL.md + config.yaml + skills |
| **Termux-Staged Profile** | `Hermes/Profiles/xosin/` | ✅ SOUL.md + config.yaml (staged for Termux deployment) |
| **Runtime Memory** | `Hermes/Memory/{MEMORY.md,USER.md}` | ✅ Symlink (PC) / Copy-sync (Android) |
| **Knowledge Base** | `Brain/Knowledge/` | ✅ Frameworks, templates, ADRs |
| **PARA Folders** | `00_Inbox/`, `01_Tasks/`, `02_Projects/`, `03_Outreach/` | ✅ |
| **Scripts** | `scripts/` | ✅ |
| **Config Reference** | `Hermes/Config/config.yaml` | ✅ |
| **Heromi Sessions** | `Hermes/Sessions/heromi/` | ✅ Markdown exports |

### Local-Only (Never Git-Tracked)
| Component | Location | Device |
|---|---|---|
| **PC IT Ops** | `~/.hermes/Profiles/xorin/` | PC |
| **PC Execution Suite** | `~/.hermes/Profiles/{ceo,engineer,product,growth,finance,ops,agency-*}/` | PC |
| **Termux IT Ops** | `~/.hermes/Profiles/xosin/` | Termux |
| **Session DBs** | `~/.hermes/state.db`, `~/.hermes/kanban.db` | Both |
| **Runtime Caches** | `Hermes/runtime/` | Both |
| **Secrets** | `~/.hermes/.env` | Both |

---

## Agent Profiles (Hermes)

### Cross-Platform (Synced via Vault)
| Profile | Role | Device |
|---|---|---|
| `heromi` | **Primary Personal Assistant** | PC + Termux |
| `xosin` | **Termux IT System Ops** (staged) | Termux only |

### PC-Only (Local, Not in Vault)
| Profile | Role | Device |
|---|---|---|
| `xorin` | PC IT System Ops | PC |
| `ceo` | Chief Executive | PC |
| `engineer` | Lead Engineer | PC |
| `product` | Product Manager | PC |
| `growth` | Growth Lead | PC |
| `finance` | Finance Lead | PC |
| `ops` | Platform Engineer | PC |
| `agency-*` | Specialized Agency (future) | PC |

---

## Dispatch Architecture

```
Human Request
      ↓
┌─────────────────────────────────────────────┐
│  heromi (Primary Assistant) — Runs on PC &  │
│  Termux. Captures intent, creates kanban    │
│  tasks, dispatches to specialists.          │
└─────────────────────────────────────────────┘
      ↓                    ↓                    ↓
   System PC          System Termux           SaaS Execution (PC)
      ↓                    ↓                    ↓
  xorin (PC IT)       xosin (Termux IT)    ceo, engineer, product,
                                                growth, finance, ops,
                                                agency-*
```

### Dispatch Rules (MANDATORY)

1. **Human request received** → `heromi` analyzes intent
2. **System maintenance (PC)** → Create task with `assignee: xorin`
3. **System maintenance (Termux)** → Create task with `assignee: xosin`
4. **SaaS execution work** → Create task with appropriate PC profile assignee
5. **Tasks for PC profiles** sit in `pending` until PC instance claims them
4. **Tasks for `xosin`** sit in `pending` until Termux instance claims them

---

## Task Rules

- **Kanban workflow:** Backlog → Discovery → Validating → Spec'ing → Building → Launching → Growing → Done
- **`heromi` creates all tasks** — it's the dispatcher
- **Task transport:** `01_Tasks/kanban_tasks.json` (Git-synced JSON)
- **Local execution:** `hermes kanban` tools operate on local `kanban.db`
- **Sync:** `vault_sync.sh` runs `kanban_sync.py` export (PC) / import (Termux) every 15 min
- In `01_Tasks/kanban.md` (Obsidian mirror): `- [ ]` = todo, `- [ ] #next` = next up, `- [x]` = done

---

## Sync Behavior

- `scripts/vault_sync.sh` runs every 15 min (cronie): pull --rebase → export **heromi** sessions → sync memory → graphify update → commit (timestamped, skip if clean) → push.
- Hermes memory syncs from `~/.hermes/memories` — symlink on PC, copy-sync on Android.
- `Hermes/Sessions/heromi/` is generated — never edit by hand.
- `graphify update .` runs on every vault sync to keep code graph current.
- `Hermes/runtime/` holds live logs, caches, temp files — never committed.

---

## Token & Context Optimization Rules (MANDATORY)

1. **NEVER use text-scanning commands** (like `grep`, `cat`, or `find`) to search across directories if a Knowledge Graph tool is available.

2. **For codebase, architecture, or technical dependency queries** → ALWAYS query `graphify` first:
   ```bash
   graphify query "how does X work"
   graphify path "ModuleA" "ModuleB"
   graphify explain "Concept"
   ```

3. **For personal memories, past sessions, timelines, or note cross-references** → ALWAYS query `gbrain` first:
   ```bash
   gbrain search "query"
   gbrain query "question"
   gbrain ask "question"
   ```

4. **For frameworks, templates, decisions, references** → ALWAYS query `gbrain` in `Brain/Knowledge/`:
   ```bash
   gbrain search "market analysis framework"
   gbrain search "PRD template"
   ```

5. **You are strictly token-budgeted**. Only load raw file contents into the context window if the graph query points to it as an explicit, high-confidence match.

6. **Default workflow**:
   - Graph query → identify relevant files → read only those files
   - Never `grep -r` or `cat` entire directories
   - Use `graphify query` for structural/architectural questions
   - Use `gbrain search/query` for factual/memory/knowledge questions

---

## Secrets

- Never commit `.env`, `auth.json`, `*.db`, `*.jsonl`, tokens, or keys — all gitignored. `state.db` stays local in `~/.hermes/`.

---

## Knowledge Base Structure

```
Brain/Knowledge/
├── frameworks/           # Reusable decision frameworks
│   ├── market-analysis.md
│   ├── mvp-scoping.md
│   ├── tech-selection.md
│   └── prioritization.md
├── templates/            # Structured templates agents fill in
│   ├── prd.md
│   ├── experiment.md
│   ├── architecture-decision.md
│   └── launch-checklist.md
├── decisions/            # Immutable ADRs (Architecture Decision Records)
│   ├── README.md         # Index
│   ├── ADR-001-scepter-vault-backbone.md
│   ├── ADR-002-three-layer-memory.md
│   ├── ADR-003-profile-agents.md
│   ├── ADR-004-kanban-routing.md
│   └── ADR-005-knowledge-queries.md
└── references/           # External knowledge worth keeping
    └── (add as needed)
```

---

## Logging & Notes

- Date-stamp log entries: `2026-08-08`.
- Daily notes go in `Brain/Journal/` as `YYYY-MM-DD.md`.
- Prefer `[[wikilinks]]` over raw paths.
- Important decisions from sessions → new ADR in `Brain/Knowledge/decisions/`.