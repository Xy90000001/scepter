# ADR-003: Profile-Based Agent Specialization

**Status:** ACCEPTED  
**Date:** 2026-08-17  
**Deciders:** xorin  
**Technical Story:** Agentic OS architecture session

---

## Context
A single generalist agent cannot effectively run a SaaS business. Different phases require different expertise: market analysis, product strategy, engineering, growth, finance, operations. We need specialized agents that can be composed by an orchestrator.

---

## Decision
Create 7 Hermes profiles, each with a dedicated SOUL.md defining its role, tools, and delegation authority:

| Profile | Role | SOUL Focus | Delegates To |
|---|---|---|---|
| `xorin` | **CEO Orchestrator** (PC) | Master coordinator, strategic decisions, task breakdown | All specialists |
| `heromi` | **Mobile Node** (Termux) | Sync, capture, quick research, mobile ops | — |
| `ceo` | **Chief Executive** | Vision, fundraising, hiring, board, high-level strategy | product, growth, finance, ops |
| `engineer` | **Lead Engineer** | Architecture, implementation, code quality, tech debt, deploy | — (uses aider/claude-code/codex) |
| `product` | **Product Manager** | PRD, user stories, prioritization, metrics, experiments | engineer, growth |
| `growth` | **Growth Lead** | Acquisition, retention, funnel, SEO, content, partnerships | engineer (landing pages), product |
| `finance` | **Finance Lead** | Unit economics, pricing, runway, fundraising, legal/compliance | — |
| `ops` | **Platform Engineer** | Infra, CI/CD, monitoring, security, scaling, vendor mgmt | engineer |

---

## Delegation Rules (Enforced in SOUL.md)

1. **Only `xorin`/`ceo` can spawn subagents** — they are the orchestrators
2. **Specialists are `leaf` agents** — they execute, don't delegate further
3. **Every delegation includes:** goal, context (files, decisions, constraints), success criteria
4. **Verification required** — orchestrator verifies output before marking done
5. **Cross-device dispatch** — `xorin` (PC) can dispatch to `heromi` (mobile) via kanban

---

## Profile Guards
- `xorin` — `pre_start_hook` fails if running in Termux
- `heromi` — `pre_start_hook` fails if NOT in Termux
- Other profiles — no environment guard (run on PC)

---

## Consequences

### Positive
- Clear separation of concerns
- Each agent has focused tool knowledge (engineer knows aider/claude-code; growth knows SEO tools)
- Scalable — add more specialists without changing orchestrator
- Portable — profiles sync via vault

### Negative
- More profiles to maintain
- Delegation overhead for simple tasks (mitigated: orchestrator can direct-execute via terminal)

---

## Related
- ADR-001: Scepter vault backbone
- ADR-002: Three-layer memory architecture
- ADR-004: Kanban as task routing layer
- SOUL.md files in `~/.hermes/profiles/<name>/`