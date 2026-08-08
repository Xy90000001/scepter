# Scepter — Workspace Context

This vault is the persistent, portable second brain. Any agent operating here
must follow these conventions.

## Folder map

| Folder | Purpose |
|---|---|
| `00_Inbox/` | Capture everything first — sort later |
| `01_Tasks/` | `kanban.md` task board; checkboxes move `- [ ]` → `- [x]` |
| `02_Projects/` | Music, Ecom, saas, Coding — one folder per active project |
| `03_Outreach/` | Lead tracking + templates |
| `Brain/` | Knowledge base, notes, journal (Obsidian wikilinks) |
| `Hermes/` | Agent layer: `Memory/`, `Sessions/`, `SOUL.md`, `Config/` |
| `scripts/` | Sync/export tooling (portable, versioned) |

## Task rules

- In `01_Tasks/kanban.md`: `- [ ]` = todo, `- [x]` = done, `- [ ] #next` = next up.
- Move done items to the Done column when a column layout is used.
- Projects get a `tasks.md` + `log.md` inside their folder when they grow.

## Sync behavior

- `scripts/vault_sync.sh` runs every 15 min (cronie): pull --rebase → export
  sessions → sync memory → commit (timestamped, skip if clean) → push.
- Hermes memory syncs from `~/.hermes/memories` — do not hand-edit
  `Hermes/Memory/` on Android; edits there get overwritten by the next sync.
- `Hermes/Sessions/` is generated — never edit by hand.

## Logging & notes

- Date-stamp log entries: `2026-08-08`.
- Daily notes go in `Brain/Journal/` as `YYYY-MM-DD.md`.
- Prefer `[[wikilinks]]` over raw paths.

## Secrets

- Never commit `.env`, `auth.json`, `*.db`, `*.jsonl`, tokens, or keys —
  all gitignored. `state.db` stays local in `~/.hermes/`.
