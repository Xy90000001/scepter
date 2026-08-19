# ADR-006: Lean Vault Isolation Protocol

**Status:** ACCEPTED  
**Date:** 2026-08-19  
**Deciders:** heromi  
**Technical Story:** Agentic OS architecture realignment

---

## Context
The original architecture had all profiles in the vault with symlinks. This caused several issues:
1. PC-only profiles (execution suite) were tracked in git, polluting cross-device sync
2. Session databases (state.db, kanban.db) risked git conflicts
3. Runtime caches and logs accumulated in profile directories
4. No clear boundary between "what syncs" and "what stays local"

---

## Decision
Implement **Lean Vault Isolation Protocol** with strict vault scope:

### Vault Contains ONLY
| Component | Location |
|---|---|
| Cross-platform profile | `Hermes/Profiles/heromi/` |
| Termux-staged profile | `Hermes/Profiles/xosin/` |
| Runtime memory | `Hermes/Memory/` |
| Knowledge base | `Brain/Knowledge/` |
| PARA content | `00_Inbox/`, `01_Tasks/`, `02_Projects/`, `03_Outreach/` |
| Scripts | `scripts/` |
| Heromi session exports | `Hermes/Sessions/heromi/` |

### Local-Only (Never in Git)
| Component | Location | Device |
|---|---|---|
| PC IT Ops | `~/.hermes/Profiles/xorin/` | PC |
| Execution suite | `~/.hermes/Profiles/{ceo,engineer,product,growth,finance,ops,agency-*}/` | PC |
| Termux IT Ops | `~/.hermes/Profiles/xosin/` | Termux |
| Session DBs | `~/.hermes/state.db`, `~/.hermes/kanban.db` | Both |
| Runtime caches | `Hermes/runtime/` | Both |
| Secrets | `~/.hermes/.env` | Both |

---

## Profile Architecture

| Profile | Role | Platform | In Vault |
|---|---|---|---|
| `heromi` | Primary Personal Assistant | PC + Termux | ✅ |
| `xosin` | Termux IT System Ops | Termux | ✅ (staged) |
| `xorin` | PC IT System Ops | PC | ❌ |
| `ceo` | Chief Executive | PC | ❌ |
| `engineer` | Lead Engineer | PC | ❌ |
| `product` | Product Manager | PC | ❌ |
| `growth` | Growth Lead | PC | ❌ |
| `finance` | Finance Lead | PC | ❌ |
| `ops` | Platform Engineer | PC | ❌ |
| `agency-*` | Specialized Agency | PC | ❌ |

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

---

## Sync Rules

| What | Sync Mechanism |
|---|---|
| `heromi` profile | Git (vault) |
| `xosin` profile | Git (vault) → copied to local on Termux |
| Runtime memory | Git + symlink (PC) / copy-sync (Android) |
| Knowledge base | Git |
| Kanban tasks | JSON export/import (`01_Tasks/kanban_tasks.json`) |
| Heromi sessions | Markdown export (`Hermes/Sessions/heromi/`) |
| PC profiles | Never — local only |
| Session DBs | Never — local only |

---

## Consequences

### Positive
- Clean git history — no runtime artifacts, no local-only profiles
- Clear ownership — vault = cross-platform only
- Faster sync — smaller vault
- No git conflicts on DBs or caches
- Clear deployment: Termux pulls vault, runs setup_symlinks.sh, gets heromi + xosin

### Negative
- PC profiles must be manually set up on each PC (mitigated: they're just local copies)
- xosin must be deployed to Termux on first run (mitigated: setup_symlinks.sh handles it)

---

## Related
- ADR-001: Scepter vault backbone
- ADR-002: Three-layer memory architecture
- ADR-003: Profile-based agent specialization (updated)
- ADR-004: Kanban as task routing layer
- ADR-005: Knowledge queries mandatory

---

## Implementation Notes
- `.gitignore` updated to exclude all PC profiles + non-heromi sessions
- `vault_sync.sh` exports only heromi sessions
- `session_sync.py` filters by profile
- `setup_symlinks.sh` creates platform-appropriate symlinks
- `Hermes/runtime/` created for live caches/logs