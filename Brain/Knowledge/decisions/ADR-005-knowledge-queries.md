# ADR-005: Knowledge Queries Mandatory Before Action

**Status:** ACCEPTED  
**Date:** 2026-08-17  
**Deciders:** xorin  
**Technical Story:** Agentic OS architecture session

---

## Context
Agents waste tokens and hallucinate when they search files blindly or rely on stale context. We have two powerful knowledge graphs: `graphify` for code/architecture relationships and `gbrain` for semantic memory/search. These must be the first stop for any question.

---

## Decision
**Enforced in AGENTS.md** — every agent MUST query the appropriate graph before reading files or acting:

| Question Type | Tool | Example Query |
|---|---|---|
| Codebase: "how does X call Y?" | `graphify query` | `graphify query "how does vault sync work"` |
| Codebase: "what connects A to B?" | `graphify path` | `graphify path "vault_sync" "Hermes/Memory"` |
| Codebase: "explain concept C" | `graphify explain` | `graphify explain "Orchestrator Agent"` |
| Memory: "what did we decide about X?" | `gbrain search` | `gbrain search "tech stack decision"` |
| Memory: "answer question from sessions" | `gbrain query` | `gbrain query "what is our sync interval"` |
| Knowledge: "framework for market analysis" | `gbrain search` | `gbrain search "market analysis framework"` |
| Knowledge: "PRD template" | `gbrain search` | `gbrain search "PRD template"` |

---

## Workflow (Mandatory)

```
1. Receive task / question
2. IDENTIFY question type (code / memory / knowledge)
3. QUERY appropriate graph (graphify OR gbrain)
4. READ only files the graph points to
5. ACT / ANSWER based on retrieved context
```

**NEVER:**
- `grep -r` or `find` across vault
- `cat` entire directories
- Assume you know the answer without querying

---

## Token Budget Enforcement
- Graph queries return scoped subgraphs (typically <50 nodes)
- Only load full file content for high-confidence matches from graph
- Default: query → identify → read minimal set

---

## Consequences

### Positive
- Drastically reduced token usage
- Answers grounded in actual codebase/memory, not hallucination
- Forces agents to use the knowledge infrastructure we built
- Cross-session continuity via gbrain

### Negative
- Extra step before action (mitigated: becomes habit, enforced by AGENTS.md)
- Requires graphs to be current (mitigated: auto-update on vault sync)

---

## Related
- ADR-001: Scepter vault backbone
- ADR-002: Three-layer memory architecture
- AGENTS.md: Token optimization rules (Section 5)
- `graphify update .` runs on every vault sync