# Tech Selection Framework

> Use when choosing stack, tools, or infrastructure for a project.

## Decision Matrix

| Criterion | Weight (1-5) | Option A | Option B | Option C |
|---|---|---|---|---|
| Team expertise | | | | |
| Hiring pool | | | | |
| Time to MVP | | | | |
| Scaling ceiling | | | | |
| Operational burden | | | | |
| Cost at scale | | | | |
| Ecosystem/libraries | | | | |
| Type safety / DX | | | | |
| Deployment simplicity | | | | |
| Vendor lock-in risk | | | | |

## Process
1. List 3-5 realistic options per category (language, framework, DB, hosting, etc.)
2. Score each (1-5) on weighted criteria
3. Discuss trade-offs for top 2
3. Document decision with rationale

## Categories to Decide
- **Language/Backend:** 
- **Frontend:** 
- **Database:** 
- **Auth:** 
- **Payments:** 
- **Hosting/Infra:** 
- **Monitoring/Logging:** 
- **CI/CD:** 

## Output
**Chosen Stack:**
| Layer | Choice | Rationale |
|---|---|---|

**Rejected Alternatives:**
| Layer | Option | Why Not |
|---|---|---|

**Revisit Trigger:** (e.g., "when team > 5", "when traffic > 10k req/s")