# ADR-001: Tech Stack for Scepter

- **Status:** Accepted
- **Date:** 2026-08-16
- **Decider:** rd (Hermes agent, on behalf of the Scepter owner)

## Context
The "Tech Stack Decisions" kanban task required documenting the technology choices
for the Scepter second-brain project. Scepter is a personal knowledge system that
syncs a Markdown/Obsidian vault across Android (Termux), PC, and a private GitHub
repo, with Hermes Agent providing the agent layer. The architecture was already
agreed in `Brain/Scepter-Spec.md` (10 decisions); this ADR records the concrete
tech stack and populates the blank *Tech Stack* section of `Hermes/Memory/RD/MEMORY.md`.

## Decision
Scepter intentionally uses **no application framework and no RDBMS**. The technology
stack is deliberately minimal:

| Layer | Choice |
|---|---|
| Language / Framework | Bash + Python 3 (CLI/sync toolkit); Hermes Agent for the agent layer |
| Database | Flat Markdown + Git (source of truth); SQLite only for local, gitignored state (kanban.db, state.db) |
| Infrastructure | Private GitHub `Xy90000001/scepter`; Termux (Android) + PC; Obsidian as the human UI |
| Deployment | Git-based sync (pull --rebase + commit + push); no CI/CD; per-device gitignored credentials |
| Monitoring | Hermes cron (paused fallback); STRUCTURE.md; session export + Index of Conversations |

## Rationale
- **Portability & longevity:** plain Markdown is readable by Obsidian, Hermes, and any
  editor, and survives platform changes.
- **Conflict-safe sync:** Git + `pull --rebase` resolves phone↔PC↔Termux merges cleanly.
- **No lock-in:** FUSE/shared-storage quirks (no `flock`, ignores `chmod`) drove the
  symlink-on-PC / sync-copy-on-Android memory design (Scepter-Spec decisions #2/#3).
- **Graphify dropped** (Spec #7): package does not exist on PyPI; Obsidian's native
  graph + `tree_index.sh` → STRUCTURE.md cover the need.

## Consequences
- The vault itself is the database — querying = `rg`/`grep`, Obsidian search, or scripts.
- No automated test suite; correctness is verified manually (SETUP.md `verify` steps).
- Two parallel kanban layers (`01_Tasks/kanban.md` + Hermes `/kanban`) need occasional
  manual reconciliation.

## References
- `Brain/Scepter-Spec.md` — agreed architecture & 10 decisions.
- `SETUP.md`, `AGENTS.md`, `STRUCTURE.md` — onboarding, conventions, generated tree.
- `Hermes/Memory/RD/MEMORY.md` — Tech Stack section (populated by this ADR).
