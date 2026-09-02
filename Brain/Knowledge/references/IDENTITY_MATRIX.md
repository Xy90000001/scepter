# Identity Matrix — Quick Reference

**Purpose:** Single-page cheat sheet for all Agentic OS profiles. Use this to verify roles, device targets, and delegation chains without loading individual SOUL.md files.

---

## Profiles Overview

| Profile | Role | Device | Primary Model | Delegates To | Reports To | Key Tools |
|---|---|---|---|---|---|---|
| **heromi** | **Main Orchestrator / Human Interface** | PC + Termux | `auto/best-reasoning` | **ALL** (xorin, ceo, product, growth, finance, engineer, ops) | **Human** | kanban, web_search, gbrain, graphify, agent-reach, mnemosyne |
| **xorin** | **PC System Ops** | PC only | `auto/best-reasoning` | None (executes only) | heromi | terminal, setup scripts, cron, docker, systemd |
| **ceo** | **SaaS Executive** | PC only | `auto/best-reasoning` | Specialists: product, growth, finance, engineer, ops | heromi | strategic planning, delegation, metrics review |
| **product** | **Product Manager** | PC only | `auto/best-reasoning` | engineer (build), growth (launch) | ceo → heromi | PRD templates, prioritization frameworks, metrics |
| **growth** | **Growth Lead** | PC only | `auto/best-reasoning` | engineer (landing pages), product (launch) | ceo → heromi | SEO tools, funnel analysis, content planning |
| **finance** | **Finance Lead** | PC only | `auto/best-reasoning` | Advises only (no delegation) | ceo → heromi | spreadsheets, unit economics, runway modeling |
| **engineer** | **Lead Engineer** | PC only | `auto/best-coding` | ops (infra) | ceo → heromi | coding agents (claude-code, codex, opencode), graphify |
| **ops** | **Platform Engineer** | PC only | `auto/best-reasoning` | engineer (performance) | ceo → heromi | infra-as-code, CI/CD, monitoring, security |

---

## Delegation Flow (Visual)

```
HUMAN (You)
    │
    ▼ verifies / approves
┌────────────────────────────────────────┐
│ heromi — Main Orchestrator             │
│ • Brainstorms & plans with human       │
│ • Delegates based on intent            │
│ • Life organizer + SaaS coordinator    │
└────────────────┬───────────────────────┘
                 │ delegates
       ┌─────────┼─────────┐
       ▼         ▼         ▼
   ┌──────┐ ┌───────┐ ┌──────────────────────────────┐
   │ xorin │ │  ceo  │ │ 5 Specialists (SaaS Exec)  │
   │ PC IT │ │ SaaS  │ │ • product  → PRDs/Metrics  │
   │ Ops   │ │ Exec  │ │ • growth   → Funnel/Content│
   │       │ │       │ │ • finance  → Economics     │
   └──────┘ └───────┘ │ • engineer → Code/Deploy    │
                     │ • ops      → Infra/Monitor   │
                     └──────────────┬───────────────┘
                                    │ report
                                    ▼
                              ┌──────────┐
                              │ heromi   │
                              └──────────┘
```

---

## Device Assignment

| Device | Active Profiles | Notes |
|---|---|---|
| **PC (Desktop)** | `heromi`, `xorin`, `ceo`, `product`, `growth`, `finance`, `engineer`, `ops` | Full suite |
| **Termux (Android)** | `heromi` only | `xorin`, `ceo`, and specialists **never** run on mobile |
| **Obsidian (Phone)** | Read-only | Markdown vault access only |

---

## Kanban Assignment Rules

| Task Type | Assignee |
|---|---|
| System maintenance, tool installs, scripts | `xorin` |
| SaaS strategy, funding, hiring | `ceo` |
| PRDs, prioritization, user stories | `product` |
| Acquisition, SEO, funnel, content | `growth` |
| Unit economics, pricing, runway | `finance` |
| Architecture, implementation, deploy | `engineer` |
| Infra, CI/CD, monitoring, security | `ops` |
| General tasks, quick research, capture | `heromi` |

---

## Escalation Path

```
Agent blocked 
    │
    ▼
heromi (orchestrator)
    │
    ├── Can resolve? → Resolves, re-delegates
    │
    └── Cannot resolve? → ESCALATES TO HUMAN
        • Budget > $50 / recurring > $10/mo
        • Strategic pivot (market, product, pricing)
        • Security/legal/compliance risk
        • Deadline at risk (>48h overdue)
        • Agent conflict
        • Unknown human preference
```

---

## Configuration References

| Profile | Config File | SOUL File |
|---|---|---|
| heromi | `~/.hermes/profiles/heromi/config.yaml` | `~/.hermes/profiles/heromi/SOUL.md` |
| xorin | `~/.hermes/profiles/xorin/config.yaml` | `~/.hermes/profiles/xorin/SOUL.md` |
| ceo | `~/.hermes/profiles/ceo/config.yaml` | `~/.hermes/profiles/ceo/SOUL.md` |
| product | `~/.hermes/profiles/product/config.yaml` | `~/.hermes/profiles/product/SOUL.md` |
| growth | `~/.hermes/profiles/growth/config.yaml` | `~/.hermes/profiles/growth/SOUL.md` |
| finance | `~/.hermes/profiles/finance/config.yaml` | `~/.hermes/profiles/finance/SOUL.md` |
| engineer | `~/.hermes/profiles/engineer/config.yaml` | `~/.hermes/profiles/engineer/SOUL.md` |
| ops | `~/.hermes/profiles/ops/config.yaml` | `~/.hermes/profiles/ops/SOUL.md` |

---

## Quick Commands

```bash
# Switch to heromi (orchestrator)
hermes profile use heromi

# Switch to xorin (PC IT Ops)
hermes profile use xorin

# List all profiles
hermes profile list

# View current profile config
hermes config show
```

---

## Related Documents

| Document | Path |
|---|---|
| Delegation Protocol | `Brain/Knowledge/decisions/DELEGATION_PROTOCOL.md` |
| Three-Layer Memory | `Brain/Knowledge/decisions/ADR-002-three-layer-memory.md` |
| Vault Isolation | `Brain/Knowledge/decisions/ADR-006-lean-vault-isolation.md` |
| Kanban Routing | `Brain/Knowledge/decisions/ADR-004-kanban-routing.md` |
| AGENTS.md (Workspace Rules) | `AGENTS.md` |

---

*Last Updated: 2026-09-02 — Aligned with corrected delegation architecture*