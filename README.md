# 🗡️ Scepter — Second Brain

Your portable second brain. Everything here is plain Markdown — readable by
Obsidian (phone/desktop), Hermes, and any text editor.

## Layout

| Path | What lives here |
|---|---|
| `Brain/` | Your notes, journal, ideas, research — the actual second brain |
| `Hermes/Memory/` | Hermes's persistent memory (`MEMORY.md`, `USER.md`) — canonical interchange; on PC `~/.hermes/memories` symlinks here, on Android it's synced here by the backup job |
| `Hermes/Sessions/` | Exported conversation digests (all) + full transcripts (recent) |
| `Hermes/SOUL.md` | Hermes persona |
| `scripts/` | Export tooling (session DB → markdown) |

## Sync

- **Termux/this device:** scheduled cron job exports sessions and commits/pushes.
- **Phone (Obsidian):** `obsidian-git` plugin auto-pulls/pushes (isomorphic-git, no extra app).
- **PC:** clone repo, point Obsidian at it, install Hermes — see `SETUP.md`.

## Rules of the road

- Private repo. Markdown only — secrets and raw DBs are gitignored.
- One note per session in `Hermes/Sessions/`, newest at the top of the index.
- **Memory on Android:** live files stay in `~/.hermes/memories` (shared storage
  can't flock them); the backup job syncs them into `Hermes/Memory/`. **On PC**
  the folder is symlinked directly. Don't edit `Hermes/Memory/` on Android —
  the next sync overwrites it.
