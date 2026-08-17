# ADR-001: Scepter Vault as Agentic OS Backbone

**Status:** ACCEPTED  
**Date:** 2026-08-17  
**Deciders:** xorin  
**Technical Story:** Second brain setup session

---

## Context
We need a portable, version-controlled, cross-device foundation for an agentic OS that can run a SaaS business. The system must work on Android/Termux and Linux PC, survive device wipes, and sync automatically.

---

## Decision
Use a private GitHub repo (`Xy90000001/scepter`) cloned to shared storage as the single source of truth. The vault contains:
- Agent definitions (profiles + SOUL.md)
- Runtime memory (Hermes/Memory/ synced bidirectionally)
- Knowledge base (Brain/Knowledge/ — frameworks, templates, decisions)
- Project workspaces (02_Projects/)
- Sync automation (scripts/)

---

## Alternatives Considered
| Option | Pros | Cons | Why Rejected |
|---|---|---|---|
| Obsidian Sync (paid) | Native, easy | Vendor lock-in, no agent integration | Not programmable |
| Syncthing | P2P, free | No version history, conflict resolution weak | Not auditable |
| Google Drive / Dropbox | Simple | No git history, no hooks, no CI | Not agentic |
| Notion API | Rich UI | Rate limits, no offline, vendor lock-in | Not portable |

---

## Consequences

### Positive
- Full git history of every decision, memory change, session
- Works identically on Termux (Android) and Linux
- Agents can read/write via standard file ops + git
- Cron/gateway automation lives in repo

### Negative
- Android shared storage (FUSE) lacks `flock` → memory sync is copy-based on Android, symlink on PC
- Requires PAT management for Obsidian Git plugin
- Initial setup friction per device

### Risks / Mitigations
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Git conflicts on concurrent edits | Medium | Medium | 15-min pull --rebase cron; manual merge for conflicts |
| PAT leakage | Low | High | Fine-grained PAT, gitignored config, rotate quarterly |
| Vault grows too large | Low | Medium | .gitignore generated artifacts; archive old projects |

---

## Implementation Notes
- `scripts/vault_sync_desktop.sh` runs every 15 min via cronie (PC) / cronie + termux-services (Android)
- `hermes profile create` for each agent persona
- `AGENTS.md` at root enforces graphify/gbrain-first workflow

---

## Related
- ADR-002: Three-layer memory architecture
- ADR-003: Profile-based agent specialization
- SETUP.md: Device onboarding