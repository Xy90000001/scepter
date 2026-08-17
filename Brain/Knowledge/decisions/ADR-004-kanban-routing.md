# ADR-004: Kanban as Task Routing Layer

**Status:** ACCEPTED  
**Date:** 2026-08-17  
**Deciders:** xorin  
**Technical Story:** Agentic OS architecture session

---

## Context
Tasks need to flow through a defined pipeline from idea to shipped feature. The orchestrator (`xorin`/`ceo`) needs visibility into what's being worked on, by whom, and what's next. Tasks must be dispatchable across devices (PC → mobile).

---

## Decision
Use Hermes Kanban as the single task routing layer with a SaaS-aligned workflow:

### Columns (Workflow Stages)
| Column | Purpose | Owner | Entry Criteria |
|---|---|---|---|
| **Backlog** | Ideas, opportunities, someday | `xorin` | Any captured idea |
| **Discovery** | Research, interviews, validation | `growth`/`product` | Hypothesis written |
| **Validating** | Active experiments, landing pages | `growth` | Experiment designed |
| **Spec'ing** | PRD, tech spec, architecture | `product`/`engineer` | Experiment validated |
| **Building** | Implementation sprints | `engineer` | PRD + tech spec approved |
| **Launching** | Beta, pre-launch, launch week | `product`/`growth` | Build complete + tested |
| **Growing** | Post-launch optimization | `growth`/`product` | Launched + metrics baseline |
| **Done** | Shipped features, completed experiments | — | Acceptance criteria met |

### Task Fields
- `assignee` — Hermes profile name (xorin, heromi, ceo, engineer, product, growth, finance, ops)
- `priority` — 1 (critical) → 5 (nice to have)
- `idempotency-key` — prevents duplicate dispatch
- `body` — full context: goal, constraints, success criteria, linked docs

### Routing Rules
1. **Only `xorin`/`ceo` create tasks for others** — they own the pipeline
2. **Tasks move forward only** — no backward transitions without orchestrator approval
3. **`Done` requires verification** — orchestrator checks output before closing
4. **Cross-device** — `xorin` (PC) creates task with `assignee: heromi` → mobile picks up

---

## Consequences

### Positive
- Single source of truth for all work
- Visible pipeline for CEO/orchestrator
- Atomic task claiming (no double-work)
- Portable across devices via vault sync

### Negative
- Kanban becomes bottleneck if orchestrator overwhelmed
- Requires discipline to update status (mitigated: automation via gateway)

---

## Related
- ADR-003: Profile-based agent specialization
- ADR-005: Knowledge queries mandatory
- `hermes kanban` CLI for task management