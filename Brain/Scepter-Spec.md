# Scepter — Project Spec

> Established 2026-08-08. This is the agreed architecture — review before
> changing anything structural.

## Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | Private GitHub repo `Xy90000001/scepter` is the sync backbone | Portable, versioned, conflict-safe |
| 2 | **Memory: sync, NOT symlinks, on Android** | FUSE lacks `flock` — symlinks break the memory tool (ENOSYS, verified) |
| 3 | Memory: symlink on PC (`~/.hermes/memories` → vault) | PC filesystems support flock; Hermes writes straight into the repo |
| 4 | Single sync loop: `scripts/vault_sync.sh` on cronie every 15 min | One place to debug; gateway-agnostic; pull --rebase handles phone↔PC |
| 5 | Hermes cron `scepter-backup` (6h) → **paused** | Replaced by cronie loop; kept as fallback (wrapper now execs vault_sync.sh) |
| 6 | Hybrid session export (digests all + 14-day transcripts) | Full fidelity where it matters, compact elsewhere |
| 7 | Graphify **dropped** | Package doesn't exist on PyPI; Obsidian has native graph; `tree_index.sh` → STRUCTURE.md instead |
| 8 | Both kanban layers | `01_Tasks/kanban.md` (portable, Obsidian checkboxes) + Hermes `/kanban` (agent layer, kanban.db) |
| 9 | Secrets stay local | `.env`, `auth.json`, `*.db`, `*.jsonl` gitignored — never in repo |
| 10 | Launcher: `~/.shortcuts/heromi.sh` (Widget) | wake-lock → vault cd → runsvdir/crond ensure → OmniRoute :20128 → gateway → ping |

## Layout

```
00_Inbox/           capture
01_Tasks/kanban.md  tasks
02_Projects/        Music, Ecom, saas, Coding
03_Outreach/        leads + templates
Brain/              knowledge base
Hermes/             Memory, Sessions, SOUL.md, Config
scripts/            export_sessions.py, vault_sync.sh, tree_index.sh, backup.sh
AGENTS.md           conventions (auto-loaded)
SETUP.md            phone/PC onboarding
```

## Known quirks

- Shared storage (FUSE): no `flock`, ignores `chmod` → run scripts via `bash`, keep live memory internal.
- `safe.directory` needed for git under `/storage/emulated/0` (dubious-ownership).
- `.obsidian/plugins/obsidian-git/data.json` holds the PAT → gitignored.
