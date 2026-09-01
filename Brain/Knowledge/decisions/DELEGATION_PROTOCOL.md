# Delegation Protocol

**Version:** 1.0
**Status:** ACTIVE
**Location:** `Brain/Knowledge/decisions/DELEGATION_PROTOCOL.md`

---

## Overview

This protocol defines how tasks are delegated, tracked, and reported across the Agentic OS. It ensures every handoff carries sufficient context, every report enables verification, and the human remains the final decision authority.

---

## 1. Handoff Package (heromi → Agent)

When `heromi` delegates a task, the following package MUST be created in the task description (kanban) or session context:

### Required Fields
```yaml
task_id: "t_<idempotency_key>"          # Unique, stable ID
title: "One-line outcome description"
assignee: "<profile_name>"               # xorin | ceo | product | growth | finance | engineer | ops
context_summary: |
  - What triggered this task
  - Key facts from gbrain/Mnemosyne (search results)
  - Relevant prior decisions (ADR links)
  - Human preferences/constraints
acceptance_criteria:
  - "Specific, measurable outcome 1"
  - "Specific, measurable outcome 2"
dependencies:
  - "t_other_task_id"                    # Blocks this task
  - "external_dependency"                # API key, approval, etc.
priority: 1                              # 1=critical, 2=high, 3=normal, 4=low
deadline: "ISO8601 or 'none'"            # Optional
tags: ["saas", "infra", "research"]      # For filtering
```

### Context Enrichment (heromi responsibility)
Before delegating, `heromi` MUST:
1. Query `gbrain` for relevant knowledge: `gbrain query "topic"`
2. Check `graphify` for code dependencies: `graphify path "A" "B"`
3. Retrieve Mnemosyne facts: `mnemosyne_recall "user preference X"`
4. Include relevant session summaries from `Hermes/Sessions/heromi/`

---

## 2. Report Package (Agent → heromi)

When an agent completes or blocks on a task, it MUST return a structured report:

### On Completion (DONE)
```yaml
task_id: "t_<id>"
status: "DONE"
deliverable:
  type: "file | code | decision | document | config"
  path: "absolute/path/to/output"
  summary: "One-paragraph what was produced"
decisions_made:
  - "Decision 1 with rationale"
  - "Decision 2 with trade-off"
artifacts_created:
  - "path/to/new/file.md"
  - "path/to/code/"
follow_up_needed: false
```

### On Blocked (BLOCKED)
```yaml
task_id: "t_<id>"
status: "BLOCKED"
block_reason: "Specific reason (missing credential, ambiguous requirement, dependency)"
block_kind: "external | clarification | dependency | resource"
needs_from_heromi:
  - "Human decision on X"
  - "API key for Y"
  - "Clarification on acceptance criteria"
can_continue_partial: true/false
```

### On Clarification Needed (NEEDS_CLARIFICATION)
```yaml
task_id: "t_<id>"
status: "NEEDS_CLARIFICATION"
questions:
  - "Question 1?"
  - "Question 2?"
options_provided:
  - "Option A: ..."
  - "Option B: ..."
recommendation: "Option A because ..."
```

---

## 3. Kanban Dependency Tracking

The `kanban_tasks.json` schema is extended with:

```json
{
  "id": "t_...",
  "title": "...",
  "assignee": "engineer",
  "status": "in_progress",
  "depends_on": ["t_other_id"],        // Array of task IDs this task waits on
  "blocks": ["t_another_id"],          // Array of task IDs waiting on this
  "block_kind": "external|clarification|dependency|resource",
  "acceptance_criteria": [...],
  "context_ref": "session_id or gbrain_query"
}
```

**Rules:**
- `heromi` sets `depends_on` at creation time
- When a task completes, `heromi` checks `blocks` array and unblocks dependent tasks
- Circular dependencies are rejected at creation

---

## 4. Escalation Triggers (heromi → Human)

`heromi` MUST escalate to human (pause delegation, request approval) when:

| Trigger | Examples |
|---|---|
| **Budget** | Any spend > $50 (configurable); recurring costs > $10/mo |
| **Strategic Pivot** | Change of target market, product direction, pricing model |
| **Security/Legal** | Data handling changes, compliance requirements, vulnerability |
| **Deadline at Risk** | Critical path task > 48h overdue with no mitigation |
| **Agent Conflict** | Two agents produce contradictory deliverables/recommendations |
| **Human Preference Unknown** | Decision requires human taste/values not in Mnemosyne |
| **Architecture Change** | `xorin` or `engineer` proposes infra/stack change affecting >2 services |

**Escalation Format:**
```yaml
escalation_id: "esc_<timestamp>"
task_id: "t_<id>"
trigger: "budget | strategic | security | deadline | conflict | preference | architecture"
summary: "One-paragraph context"
options:
  - "Option A: ... (impact: ...)"
  - "Option B: ... (impact: ...)"
heromi_recommendation: "Option A because ..."
human_decision_required_by: "ISO8601"
```

---

## 5. SaaS Execution Sub-Delegation (ceo → Specialists)

When `ceo` delegates to specialists, the same protocol applies with these additions:

### ceo Responsibilities
- Translates high-level SaaS goals into specialist tasks
- Sets cross-specialist dependencies (e.g., "growth campaign depends on product landing page")
- Aggregates specialist reports into weekly SaaS status for heromi

### Specialist Cross-Delegation Matrix
| From → To | Allowed For |
|---|---|
| `growth` → `engineer` | Landing pages, tracking pixels, A/B test infrastructure |
| `growth` → `product` | Launch coordination, messaging alignment |
| `product` → `engineer` | Feature implementation, technical spikes |
| `product` → `growth` | Launch announcements, content briefs |
| `engineer` → `ops` | Infra provisioning, CI/CD changes, monitoring |
| `ops` → `engineer` | Performance tuning, debugging production issues |
| `finance` → `ceo`/`heromi` | Budget approvals, pricing validation |

**Forbidden:** Specialists delegating to `xorin` or `heromi` directly. All cross-cutting requests route through `ceo` → `heromi`.

---

## 5. Verification Loop (heromi → Human)

After collecting reports, `heromi` presents to human:

```yaml
verification_package:
  period: "daily | weekly | on_demand"
  completed_tasks: [t_id_1, t_id_2, ...]
  blocked_tasks: [t_id_3, ...]
  escalations_pending: [esc_id_1, ...]
  saas_metrics_delta:
    - "Metric: value → value (change)"
  heromi_summary: "Executive summary of progress, risks, decisions needed"
  human_actions_required:
    - "Approve esc_..."
    - "Clarify task t_..."
```

---

## 6. Session Continuity

- Every delegation creates a session entry in `Hermes/Sessions/heromi/`
- On handoff, `heromi` includes `session_id` in context so receiving agent can load history
- `session_sync.py export` runs every vault sync to persist to markdown

---

## 7. Idempotency & Deduplication

- Every task gets an `idempotency_key` (e.g., `saas-prd-q3`, `infra-terraform-setup`)
- `kanban_sync.py` uses this to deduplicate across devices
- Re-delegating same intent with same key updates existing task, doesn't create duplicate

---

## Change Log

| Date | Version | Change |
|---|---|---|
| 2026-09-01 | 1.0 | Initial protocol based on corrected architecture |

---

**Enforcement:** This protocol is part of the Agentic OS contract. Any agent operating in this vault MUST follow it. Deviations are treated as task failures requiring human review.