# ADR-003: Profile-Based Agent Specialization

**Status:** ACCEPTED
**Date:** 2026-09-02
**Deciders:** heromi
**Technical Story:** Corrected architecture after delegation review session

---

## Context

A single generalist agent cannot effectively run a SaaS business. Different phases require different expertise: market analysis, product strategy, engineering, growth, finance, operations. We need specialized agents that can be composed by an orchestrator.

**Correction (2026-09-02):** Previous version incorrectly identified `xorin` as the CEO Orchestrator. The correct hierarchy places `heromi` as the Main Orchestrator (Human Interface) and `xorin` as PC System Ops only.

---

## Decision

Create 8 Hermes profiles, each with a dedicated SOUL.md defining its role, tools, and delegation authority:

| Profile | Role | Device | Delegation Authority | Reports To |
|---|---|---|---|---|
| `heromi` | **Main Orchestrator / Human Interface** — Primary Personal Assistant, life organizer, brainstorms & plans with human, delegates specialist tasks based on intent, reports SaaS updates to human | PC + Termux | **Delegates to ALL agents** (xorin, ceo, product, growth, finance, engineer, ops) | Human |
| `xorin` | **PC System Ops** — PC host-level system maintenance, tool installations, script setups, PC Hermes workspace, architecture maintenance | PC only | Receives from heromi; no further delegation | heromi |
| `ceo` | **SaaS Executive** — Owns SaaS execution, delegates SaaS tasks to specialists | PC only | **Delegates to specialists** (product, growth, finance, engineer, ops); reports to heromi | heromi |
| `product` | **Product Manager** — PRDs, prioritization, metrics, user stories, experiments | PC only | Receives from ceo; delegates to engineer/growth | ceo → heromi |
| `growth` | **Growth Lead** — Acquisition, retention, funnel optimization, SEO, content, partnerships | PC only | Receives from ceo; delegates to engineer/product | ceo → heromi |
| `finance` | **Finance Lead** — Unit economics, pricing, runway, fundraising, legal/compliance | PC only | Receives from ceo; advises heromi/xorin/ceo | ceo → heromi |
| `engineer` | **Lead Engineer** — Architecture, implementation, code quality, technical debt, deployment | PC only | Receives from ceo; delegates to ops | ceo → heromi |
| `ops` | **Platform Engineer** — Infrastructure, CI/CD, monitoring, security, scaling, vendor management | PC only | Receives from ceo/engineer; enables engineer | ceo → heromi |

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

---

## Delegation Protocol

See `DELEGATION_PROTOCOL.md` for full handoff format, report templates, escalation triggers, and kanban dependency tracking.

---

## Consequences

- **Positive:** Clear separation of concerns; human never talks to specialists directly; single point of verification.
- **Negative:** `heromi` becomes a bottleneck if overloaded; mitigated by delegation granularity and kanban queue.
- **PC-only profiles** (`xorin`, `ceo`, `product`, `growth`, `finance`, `engineer`, `ops`) are never instantiated on Termux/Android.
- **Cross-platform** (`heromi`) is the only profile running on both devices.

---

## Change Log

| Date | Version | Change |
|---|---|---|
| 2026-08-17 | 1.0 | Initial architecture (xorin as CEO Orchestrator) |
| 2026-09-02 | 2.0 | **Corrected:** heromi = Main Orchestrator; xorin = PC System Ops; ceo = SaaS Execution |