# Scepter — Workspace Context

This vault is the persistent, portable second brain for an agentic OS that runs a SaaS business. Any agent operating here must follow these conventions.

## Three-Layer Memory Architecture

| Layer | Location | Injected? | Queried? | Purpose |
|---|---|---|---|---|
| **SOUL (Identity)** | `~/.hermes/profiles/<name>/SOUL.md` | ✅ Profile load | ❌ | Who the agent is, authority, tools, delegation targets |
| **Runtime Memory** | `~/scepter/Hermes/Memory/{MEMORY.md,USER.md}` | ✅ Every session | ❌ | User facts, preferences, session continuity |
| **Knowledge Base** | `~/scepter/Brain/Knowledge/` | ❌ | ✅ On demand | Frameworks, templates, decisions, references |

See `Brain/Knowledge/decisions/ADR-002-three-layer-memory.md` for full details.

## Folder Map

| Folder | Purpose |
|---|---|
| `00_Inbox/` | Capture everything first — sort later |
| `01_Tasks/` | Kanban task board (Hermes `/kanban` + `kanban.md` mirror) |
| `02_Projects/` | Active projects — one folder per project with `spec.md`, `tasks.md`, `log.md` |
| `03_Outreach/` | Lead tracking + templates |
| `Brain/Knowledge/` | **Frameworks, templates, decisions, references** — queried via gbrain/graphify |
| `Hermes/` | Agent layer: `Memory/`, `Sessions/`, `SOUL.md` (reference), `Config/` |
| `scripts/` | Sync/export tooling (portable, versioned) |

## Agent Profiles (Hermes)

| Profile | Role | Device |
|---|---|---|
| `xorin` | CEO Orchestrator | PC |
| `heromi` | Mobile Node | Termux |
| `ceo` | Chief Executive | PC |
| `engineer` | Lead Engineer | PC |
| `product` | Product Manager | PC |
| `growth` | Growth Lead | PC |
| `finance` | Finance Lead | PC |
| `ops` | Platform Engineer | PC |

Each profile has a `SOUL.md` defining its role, tools, and delegation authority. See `Brain/Knowledge/decisions/ADR-003-profile-agents.md`.

## Task Rules

- **Kanban workflow:** Backlog → Discovery → Validating → Spec'ing → Building → Launching → Growing → Done
- **Only orchestrators (`xorin`, `ceo`) create tasks for specialists** — they own the pipeline
- **Specialists are leaf agents** — they execute, don't delegate further
- **Every task must include:** goal, context (linked docs, decisions), success criteria, assignee (profile name)
- **Done requires verification** — orchestrator checks output before closing
- In `01_Tasks/kanban.md` (Obsidian mirror): `- [ ]` = todo, `- [ ] #next` = next up, `- [x]` = done

## Sync Behavior

- `scripts/vault_sync.sh` runs every 15 min (cronie): pull --rebase → export heromi sessions → sync memory → STRUCTURE.md → graphify update (PC only) → gbrain embed (PC only) → commit (timestamped, skip if clean) → push.
- Hermes memory syncs from `~/.hermes/memories` — do not hand-edit `Hermes/Memory/` on Android; edits there get overwritten by the next sync.
- `Hermes/Sessions/` is generated — never edit by hand.
- `graphify update .` and `gbrain embed` run on every sync **on PC only**; Termux skips these.

## Token & Context Optimization Rules (MANDATORY)

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

4. **For frameworks, templates, decisions, references** → ALWAYS query `gbrain` in `Brain/Knowledge/`:
   ```bash
   gbrain search "market analysis framework"
   gbrain search "PRD template"
   ```

5. **You are strictly token-budgeted**. Only load raw file contents into the context window if the graph query points to it as an explicit, high-confidence match.

6. **Default workflow**:
   - Graph query → identify relevant files → read only those files
   - Never `grep -r` or `cat` entire directories
   - Use `graphify query` for structural/architectural questions
   - Use `gbrain search/query` for factual/memory/knowledge questions

## Secrets

- Never commit `.env`, `auth.json`, `*.db`, `*.jsonl`, tokens, or keys — all gitignored. `state.db` stays local in `~/.hermes/`.

## Knowledge Base Structure

```
Brain/Knowledge/
├── frameworks/           # Reusable decision frameworks
│   ├── market-analysis.md
│   ├── mvp-scoping.md
│   ├── tech-selection.md
│   └── prioritization.md
├── templates/            # Structured templates agents fill in
│   ├── prd.md
│   ├── experiment.md
│   ├── architecture-decision.md
│   └── launch-checklist.md
├── decisions/            # Immutable ADRs (Architecture Decision Records)
│   ├── README.md         # Index
│   ├── ADR-001-scepter-vault-backbone.md
│   ├── ADR-002-three-layer-memory.md
│   ├── ADR-003-profile-agents.md
│   ├── ADR-004-kanban-routing.md
│   └── ADR-005-knowledge-queries.md
└── references/           # External knowledge worth keeping
    └── (add as needed)
```

## Logging & Notes

- Date-stamp log entries: `2026-08-08`.
- Daily notes go in `Brain/Journal/` as `YYYY-MM-DD.md`.
- Prefer `[[wikilinks]]` over raw paths.
- Important decisions from sessions → new ADR in `Brain/Knowledge/decisions/`.