# Scepter — Workspace Context

This vault is the persistent, portable second brain. Any agent operating here
must follow these conventions.

## Folder map

| Folder         | Purpose                                                   |
| -------------- | --------------------------------------------------------- |
| `00_Inbox/`    | Capture everything first — sort later                     |
| `01_Tasks/`    | `kanban.md` task board; checkboxes move `- [ ]` → `- [x]` |
| `02_Projects/` | Music, Ecom, saas, Coding — one folder per active project |
| `03_Outreach/` | Lead tracking + templates                                 |
| `Brain/`       | Knowledge base, notes, journal (Obsidian wikilinks)       |
| `Hermes/`      | Agent layer: `Memory/`, `Sessions/`, `SOUL.md`, `Config/` |
| `scripts/`     | Sync/export tooling (portable, versioned)                 |

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

## Token & Context Optimization Rules

1. **NEVER use text-scanning commands** (like `grep`, `cat`, or `find`) to search across directories if a Knowledge Graph tool is available.

2. **For codebase, architecture, or technical dependency queries** → ALWAYS query `graphify` first:
   ```bash
   graphify query "how does X work"
   graphify path "ModuleA" "ModuleB"
   graphify explain "Concept"
   ```

3. **For personal memories, past sessions, timelines, or note cross-references** → ALWAYS query `gbrain` first:
   ```bash
   gbrain search "query"
   gbrain query "question"
   gbrain ask "question"
   ```

4. **You are strictly token-budgeted**. Only load raw file contents into the context window if the graph query points to it as an explicit, high-confidence match.

5. **Default workflow**:
   - Graph query → identify relevant files → read only those files
   - Never `grep -r` or `cat` entire directories
   - Use `graphify query` for structural/architectural questions
   - Use `gbrain search/query` for factual/memory/session questions
