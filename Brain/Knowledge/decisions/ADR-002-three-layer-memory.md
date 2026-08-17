# ADR-002: Three-Layer Memory Architecture

**Status:** ACCEPTED  
**Date:** 2026-08-17  
**Deciders:** xorin  
**Technical Story:** Agentic OS architecture session

---

## Context
Agents need different types of context at different times:
1. **Identity & Authority** — who am I, what can I do, who do I delegate to
2. **Runtime Facts** — user preferences, learned facts, session continuity
3. **Reference Knowledge** — frameworks, templates, past decisions, research

Mixing these causes context bloat and unclear boundaries.

---

## Decision
Three separate layers, each with distinct injection/query semantics:

| Layer | Location | Injected? | Queried? | Update Frequency |
|---|---|---|---|---|
| **SOUL (Identity)** | `~/.hermes/profiles/<name>/SOUL.md` | ✅ Profile load | ❌ | Rare (role change) |
| **Runtime Memory** | `~/scepter/Hermes/Memory/{MEMORY.md,USER.md}` | ✅ Every session | ❌ | Continuous (auto) |
| **Knowledge Base** | `~/scepter/Brain/Knowledge/` | ❌ | ✅ On demand (gbrain/graphify) | As decisions made |

---

## Layer Details

### 1. SOUL.md (Agent Identity)
- Defines the agent's role, authority, tools, delegation targets
- Loaded once at profile start
- Example: `xorin` = CEO orchestrator; `engineer` = implementation specialist
- Contains: role description, available tools, delegation rules, escalation paths

### 2. Hermes/Memory (Runtime Context)
- `MEMORY.md` — durable facts about user, preferences, environment
- `USER.md` — user profile, communication style, constraints
- Symlinked into `~/.hermes/memories` on PC; copied on Android
- Auto-updated by Hermes after each session
- **Injected into every session automatically**

### 3. Brain/Knowledge (Reference Library)
- Frameworks (market-analysis, mvp-scoping, tech-selection, prioritization)
- Templates (PRD, experiment, ADR, launch-checklist)
- Decisions (ADR-XXX immutable records)
- References (competitor landscape, pricing models)
- **NOT injected** — agents MUST query via `gbrain search` or `graphify query`
- Written by agents after significant work (decisions, research, retrospectives)

---

## Query Protocol (Enforced in AGENTS.md)

```
For code/architecture questions    → graphify query/path/explain
For memory/facts/sessions          → gbrain search/query/ask  
For frameworks/templates/decisions → gbrain search "keyword" in Brain/Knowledge
For raw file content               → ONLY after graph points to specific file
```

---

## Consequences

### Positive
- Token budget respected — only relevant knowledge loaded
- Clear ownership: SOUL=profile, Memory=Hermes, Knowledge=agents
- Cross-agent knowledge sharing via Brain/Knowledge
- Decisions immortalized as ADRs, not lost in sessions

### Negative
- Agents must remember to query (enforced by AGENTS.md)
- Three locations to understand (mitigated by documentation)

---

## Related
- ADR-001: Scepter vault backbone
- ADR-003: Profile-based agent specialization
- AGENTS.md: Token optimization rules