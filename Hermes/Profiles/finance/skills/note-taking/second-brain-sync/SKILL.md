---
name: second-brain-sync
description: "Set up a portable second brain: Obsidian, Hermes, Git sync."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [Obsidian, Hermes, Second Brain, Sync, Git, Termux]
    related_skills: [obsidian, hermes-agent, cronjob]
---

## When to Use

- **Setting up a new machine** with the scepter second brain (clone, symlink, sync, Obsidian)
- **Troubleshooting sync issues** between Android/Termux and desktop
- **Understanding memory strategy differences** across platforms (symlink vs copy)
- **Configuring automated sync** (cronie, system cron, Hermes cronjob, Obsidian Git)

# Second Brain Sync -- Hermes + Obsidian + Git

A portable, Markdown-first second brain that works across:
- **Android/Termux** (shared storage, FUSE limitations)
- **Linux/macOS desktop** (native symlinks, cron)
- **Any device with Obsidian** (Obsidian Git plugin)

## Vault Structure (scepter)

```
scepter/
|-- 00_Inbox/           # Capture everything -- sort later
|-- 01_Tasks/           # kanban.md task board
|-- 02_Projects/        # One folder per active project
|-- 03_Outreach/        # Lead tracking + templates
|-- Brain/              # Knowledge base, journal, ideas (wikilinks)
|-- Hermes/             # Agent layer
|   |-- Memory/         # MEMORY.md, USER.md (synced)
|   |-- Sessions/       # Auto-generated session notes
|   |-- SOUL.md         # Agent identity
|   `-- Config/         # config.yaml reference copy
|-- scripts/            # Sync/export tooling (versioned)
|-- AGENTS.md           # Workspace conventions (auto-loaded)
|-- SETUP.md            # This setup guide
`-- README.md
```

## Memory Strategy -- Platform Differences

| Platform | Memory Location | Mechanism | Why |
|---|---|---|---|
| **Linux/macOS** | `~/.hermes/memories` -> `~/scepter/Hermes/Memory` | **Symlink** | Native FS supports flock; Hermes writes directly into repo |
| **Android/Termux** | `~/.hermes/memories` (live) -> `~/storage/shared/scepter/Hermes/Memory/` | **Copy via cron** | Shared storage (FUSE) can't flock; symlink breaks memory tool |

**Rule:** Never hand-edit `Hermes/Memory/` on Android -- the next sync overwrites it. On desktop, edits sync down fine.

## Sync Architecture

### Android (Termux) -- cronie every 15 min
`scripts/vault_sync.sh` runs:
1. **Export sessions** -- `export_sessions.py` reads `~/.hermes/state.db` -> writes digests + transcripts to `Hermes/Sessions/`
2. **Sync memory** -- `cp -u ~/.hermes/memories/{MEMORY.md,USER.md} ~/storage/shared/scepter/Hermes/Memory/`
3. **Update index** -- `tree_index.sh` regenerates `STRUCTURE.md`
4. **Commit** -- `git add -A`, commit if dirty (timestamped message)
5. **Pull --rebase** -> **Push** to GitHub (conflict-safe)

### Desktop (Linux/macOS) -- Replace cronie with:
- **Option A: System cron** -- `*/15 * * * * ~/scepter/scripts/vault_sync.sh`
- **Option B: Hermes cronjob** -- managed inside Hermes, survives reinstalls
- **Option C: Obsidian Git plugin** -- pull on startup, push on save (manual trigger)
- **Option D: inotifywait event-driven watcher** (RECOMMENDED) -- `scripts/vault_watch.sh` watches `Brain/`, `01_Tasks/`, `Hermes/Memory/`, etc. and runs `vault_sync.sh` within ~3s of any change. No polling, instant sync. See `scripts/vault_watch.sh`.

### Obsidian (all devices)
- Install **Obsidian Git** plugin
- Auth: username `Xy90000001`, password = **Fine-grained PAT** (repo: `scepter`, Contents: Read/Write)
- Mobile uses isomorphic-git (no extra app); desktop uses native git
- Enable: *Auto backup after stopping edit* (~1 min), *Pull on startup*, *Commit/sync on save*

## Session Export (`scripts/export_sessions.py`)

**Hybrid mode:**
- **Every session** -> digest note (title, date, platform, stats, kickoff message)
- **Recent sessions** (< `--recent-days`, default 14) -> **also** full transcript note (user + assistant messages only)

**Output:** `Hermes/Sessions/{YYYY-MM-DD_HHMM}_{session_id_short}.md` + `..._transcript.md` + `Index of Conversations.md`

**Idempotent:** Stable filenames -> safe to rerun.

## Setup Checklist (New Machine)

1. **Clone vault:** `git clone https://github.com/Xy90000001/scepter.git ~/scepter`
2. **Install Hermes:** `curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash`
3. **Symlink memory (desktop only):**
   ```bash
   rmdir ~/.hermes/memories && ln -s ~/scepter/Hermes/Memory ~/.hermes/memories
   ```
4. **Configure provider:** `hermes model` / `hermes setup` (or keep local proxy at `localhost:20128`)
5. **Set up local sync** (cronjob or system cron running `vault_sync.sh` every 15 min)
6. **Open in Obsidian** -> install Obsidian Git -> same PAT
7. **Verify:**
   ```bash
   cd ~/scepter && git status
   git log --oneline -5
   ls Hermes/Sessions/ | head
   ```

## Cross-Device Architecture -- What Actually Syncs

The vault is the source of truth for **content**, but NOT all agent state propagates by default. Know what reaches "the same guy everywhere":

| Component | Shared? | Mechanism |
|---|---|---|
| Memory (MEMORY.md, USER.md) | Yes | Symlink (desktop) / copy (Android) -> vault |
| Notes (Brain/, 00-04/, AGENTS.md) | Yes | Git + Obsidian Git |
| Agent role definitions (Brain/Agents/*.md) | Yes | Git -- plain markdown, any device loads |
| Config (config.yaml) | Partial | Symlink or copy vault's `Hermes/Config/config.yaml` |
| Session history (state.db) | **No** | Per-device SQLite; not synced (concurrent-write corruption risk) |
| Skills (~/.hermes/skills/) | **No** | Install per device (or copy dir) |
| Tools / toolsets | **No** | Defined by Hermes version + config |
| Subagents | **No** | Ephemeral -- spawn, work, die |
| Gateway (Telegram/Discord) | **No** | Per-device process |

**For full parity:**
- **Skills:** install same skills on each device, or `cp -r ~/.hermes/skills/`
- **Config:** `ln -s ~/scepter/Hermes/Config/config.yaml ~/.hermes/config.yaml` (or keep per-device)
- **Sessions:** see Shared Sessions below

## Shared Agent Roles (Brain/Agents/)

Store **prompt templates** for an orchestrator -> specialist pattern directly in the vault so every device loads the same roles:

```
Brain/Agents/
├── orchestrator.md   # Main coordinator -- routes, delegates, synthesizes
├── coder.md          # Implementation -- aider/claude-code/codex/opencode + direct tools
├── researcher.md     # Information -- web search, extract, cited synthesis
├── reviewer.md       # Quality gate -- security, correctness, PR readiness
└── README.md         # How to use + extend
```

**Pattern:** the main agent (orchestrator) breaks a goal into subtasks and delegates to leaf specialists via `delegate_task(role="leaf")` (nesting off by default: `max_spawn_depth=1`). Each specialist file is self-contained -- subagents receive only `goal` + `context`.

**Coder specialist uses CLI agents:** for multi-file work it shells out to `aider`, `claude-code`, `codex`, or `opencode` (skills available). For surgical edits it uses `read_file`/`write_file`/`patch`/`terminal`.

**Activation on any device:**
```
Follow the orchestrator pattern in [[Brain/Agents/orchestrator.md]].
Use coder.md for code, researcher.md for research, reviewer.md for review.
```

**Routing is manual** -- Hermes does NOT auto-route; the orchestrator decides and delegates explicitly.

## Code Knowledge Graphs (Graphify)

`graphify` builds a **local, embedding-free knowledge graph** from a codebase (code, docs, SQL, images, videos). Outputs: interactive HTML, GraphRAG-ready JSON, `GRAPH_REPORT.md`.

- Install: `pip install graphify` (or `uv tool install graphifyy`, `pipx`)
- Use: in a coding assistant type `/graphify .` to map the folder; then `graphify query "auth flow"`
- Fits the coder role: run once per repo, commit `graphify/` output, read `GRAPH_REPORT.md` for instant architecture context before editing.

**Local proxy caveat:** The CLI direct execution uses the openai backend and may fail with a local proxy serving `auto/*` aliases. See `references/local-proxy-workaround.md` for workarounds (code-only mode, Gemini key, or run inside a coding assistant that dispatches subagents).

## Shared Sessions (export/import loop)

Sessions are per-device (separate `state.db`). To make one device's conversations searchable on another:

- **Export (already built):** `scripts/export_sessions.py` reads `state.db` -> digest + transcript markdown in `Hermes/Sessions/`
- **Import (concept):** an `import_sessions.py` would read those markdown files and upsert into the local `state.db` by session ID, then `session_search` finds them on the new device.
- **Caveat:** This shares *searchable history*, not auto-injected context. Memory (MEMORY.md/USER.md) is the always-on layer that shapes every response.

## Pitfalls

- **Android FUSE + flock:** Symlink fails silently -- memory tool errors. Use copy strategy.
- **Gateway launch from Hermes CLI:** Wedges silently pre-log. Use `setsid env -i` with explicit HOME/PREFIX/PATH; startup takes ~7 min.
- **Android battery optimization:** Freezes Termux when minimized -> gateway stalls. Fix: Settings -> Termux -> Battery -> Unrestricted.
- **Obsidian Git PAT:** Must be fine-grained with Contents Read/Write on `scepter` repo only.
- **Secrets never in repo:** `.env`, `auth.json`, `*.db`, `*.jsonl`, tokens, keys -- all gitignored. `state.db` stays local in `~/.hermes/`.

## References

- `references/vault_sync.sh` -- The sync loop script (Android cronie / desktop cron)
- `references/export_sessions.py` -- Session export from state.db
- `references/tree_index.sh` -- STRUCTURE.md generator
- `references/SETUP.md` -- Full setup guide (copied from vault)
- `scripts/vault_watch.sh` -- inotifywait event-driven watcher (Option D above)
- `references/local-proxy-workaround.md` -- graphify semantic extraction with local OpenAI-compatible proxy