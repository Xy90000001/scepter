# 🗡️ Scepter — Second Brain

Your portable second brain. Everything here is plain Markdown — readable by
Obsidian (phone/desktop), Hermes, and any text editor.

## Layout

| Path | What lives here |
|---|---|
| `00_Inbox/` | Capture everything — sorted later |
| `01_Tasks/` | Task board (`kanban.md`) |
| `02_Projects/` | Music, Ecom, saas, Coding |
| `03_Outreach/` | Lead tracking & templates |
| `Brain/` | Knowledge base, journal, ideas — the actual second brain |
| `Hermes/` | Agent layer: `Memory/`, `Sessions/`, `SOUL.md`, `Config/` |
| `scripts/` | Sync/export tooling (portable, versioned) |
| `AGENTS.md` | Workspace conventions (auto-loaded by agents) |

## Sync

- **Termux (this device):** `cronie` runs `scripts/vault_sync.sh` every 15 min — pull → session export → memory sync → commit → push.
- **Phone (Obsidian):** `obsidian-git` plugin auto-pulls/pushes (isomorphic-git, no extra app).
- **PC:** clone repo, point Obsidian at it, install Hermes — see `SETUP.md`.

## Rules of the road

- Private repo. Markdown only — secrets and raw DBs are gitignored.
- One note per session in `Hermes/Sessions/`, newest at the top of the index.
- **Memory on Android:** live files stay in `~/.hermes/memories` (shared storage
  can't flock them); the backup job syncs them into `Hermes/Memory/`. **On PC**
  the folder is symlinked directly. Don't edit `Hermes/Memory/` on Android —
  the next sync overwrites it.
