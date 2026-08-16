# R&D Memory

## Architecture Decisions (ADRs)
*(track in adrs/ subfolder — one file per decision)*
- **ADR-001 — Tech Stack** (`adrs/0001-tech-stack.md`, 2026-08-16): Scepter is a Markdown + Git + Obsidian + Hermes "second brain". No application framework or RDBMS — the vault IS the database. See Tech Stack section below for the full breakdown.

## Tech Stack

### Language / Framework
- **Shell (Bash)** — primary automation layer. Scripts live in `scripts/`:
  - `vault_sync.sh` — 15-min sync loop (pull --rebase → session export → memory sync → STRUCTURE.md → commit → push)
  - `vault_watch.sh` — inotify-based file-watcher alternative to timed cron
  - `tree_index.sh` — regenerates `STRUCTURE.md` from the vault tree
  - `backup.sh` — safety backup fallback
- **Python 3** — `export_sessions.py` (hybrid session export: digests of all sessions + full transcripts for the last 14 days).
- **No web framework / no compiled app** — the system is a portable CLI + sync toolkit, not a service.
- **Agent layer:** Hermes Agent (this process), models served via a local proxy at `localhost:20128` (`auto/*` model aliases).

### Database
- **Flat Markdown + Git** is the source of truth (Obsidian vault). No traditional RDBMS.
- **SQLite** is used locally and *never committed*:
  - `kanban.db` — Hermes `/kanban` task board
  - `state.db` — Hermes session/conversation store
  - `~/.hermes/*.db` — local only, gitignored
- Memory files (`MEMORY.md`, `USER.md`) are plain Markdown inside the vault and synced across devices.

### Infrastructure
- **Private GitHub repo** `Xy90000001/scepter` — the sync backbone (portable, versioned, conflict-safe via `pull --rebase`).
- **Termux** on Android — primary runtime; `cronie`/`crond` drives the sync loop; shared storage (FUSE) holds the live vault at `~/storage/shared/scepter`.
- **PC** — clone the same repo; Obsidian + Hermes with memory symlinked (`~/.hermes/memories` → `~/scepter/Hermes/Memory`).
- **Obsidian** — the human-facing UI on phone + PC (Obsidian Git plugin for mobile/desktop pull-push).

### Deployment
- **Git-based sync, not CI/CD.** Changes flow: edit → (Obsidian Git auto-commit on save) or `vault_sync.sh` every 15 min → `git push`.
- `pull --rebase` keeps phone ↔ PC ↔ Termux conflict-free.
- Credentials (PAT, `.env`, tokens) are per-device and gitignored — never in the repo.

### Monitoring
- **Hermes cron** `scepter-backup` (6h) — *paused*, superseded by the cronie loop; kept as fallback (wrapper now execs `vault_sync.sh`).
- **Session logs** — every Hermes session exported to `Hermes/Sessions/` (generated, never hand-edited) + indexed in `Brain/Index of Conversations.md`.
- **STRUCTURE.md** — auto-generated vault map for at-a-glance state.
- **Verify** after a sync: `git status` (clean), `git log --oneline -5`, `ls Hermes/Sessions/`.

## Standards & Conventions
- **Code Style:** Markdown-only vault; Bash scripts invoked via `bash` (FUSE ignores `chmod`); Python follows stdlib + std logging. Keep scripts portable and versioned in `scripts/`.
- **Testing Strategy:** No automated test suite yet. Manual verification per SETUP.md (`git status`/`log`, session export present). Treat `pull --rebase` failures as the primary failure mode to watch.
- **Git Workflow:** timestamped commits, skip-if-clean; rebase pulls; secrets (`.env`, `auth.json`, `*.db`, `*.jsonl`) always gitignored. Two parallel kanban layers: `01_Tasks/kanban.md` (portable checkboxes) + Hermes `/kanban` (kanban.db).
- **Documentation:** `AGENTS.md` (workspace conventions, auto-loaded), `SETUP.md` (phone/PC onboarding), `STRUCTURE.md` (generated tree), `Scepter-Spec.md` (agreed architecture + decisions). Date-stamp log entries (`2026-08-08`); daily notes in `Brain/Journal/YYYY-MM-DD.md`; prefer `[[wikilinks]]` over raw paths.

## Current Spikes / Experiments
- `vault_watch.sh` (inotifywait) as a file-change-based alternative to the 15-min timed cron — user prefers event-driven sync.

## Technical Debt
- No automated tests for `scripts/` — rely on manual `verify` steps.
- Dual kanban (Obsidian md + Hermes db) can drift; no automated reconciliation.

## Integrations & APIs
- **GitHub** — `git` CLI + Obsidian Git plugin (PAT auth, gitignored `data.json`).
- **Hermes Agent** — LLM access via local proxy `localhost:20128` (`auto/*` aliases: best-coding, best-reasoning, etc.); cron, memory, kanban, session export.
- **Obsidian** — vault UI; graph view replaces the dropped Graphify dependency.
- **cronie / crond** — schedules `vault_sync.sh` every 15 min on Termux.

## Performance Baselines
- **Sync loop:** every 15 min (cronie). Backup fallback: every 6 h (paused).
- **Session export:** digest of *all* sessions + full transcripts for the trailing 14 days.
- **Conflict handling:** `pull --rebase` expected to resolve phone↔PC↔Termux merges without manual intervention.

---
*Last updated: 2026-08-16*
*Profile: rd*
