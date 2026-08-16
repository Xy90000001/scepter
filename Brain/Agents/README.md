# Brain/Agents — Shared Agent Definitions

This folder contains **prompt templates** for the orchestrator pattern. They live in the vault so any device can load them.

## Files

| File | Role | Loaded by |
|---|---|---|
| `orchestrator.md` | Main coordinator — breaks down goals, delegates | You (main agent) |
| `coder.md` | Implementation — writes code, uses CLI agents | Orchestrator via `delegate_task` |
| `researcher.md` | Information — searches, extracts, synthesizes | Orchestrator via `delegate_task` |
| `reviewer.md` | Quality gate — security, correctness, PR review | Orchestrator via `delegate_task` |

## How to Use

### From any device (Hermes session)

**Option 1: Load into context manually**
```markdown
# In your prompt to the main agent:
"Follow the orchestrator pattern in [[Brain/Agents/orchestrator.md]].
Use [[Brain/Agents/coder.md]] for coding tasks,
[[Brain/Agents/researcher.md]] for research,
[[Brain/Agents/reviewer.md]] for reviews."
```

**Option 2: Read via `read_file` tool** (agent does it)
```python
# In a skill or script:
read_file("/home/exash/scepter/Brain/Agents/orchestrator.md")
```

### Creating a new specialist

1. Add `specialist.md` in this folder
2. Update `orchestrator.md` "Available Specialists" table
3. Commit → sync → available on all devices

## Sync

These files are in the vault → synced via GitHub → Obsidian Git on phone/desktop.
No extra setup needed.

## Conventions

- All prompts are **self-contained** — subagents receive only `goal` + `context`
- Use `delegate_task` with `role="leaf"` (nesting is off: `max_spawn_depth=1`)
- Subagents return summaries; orchestrator synthesizes
- Verifiable output required (file paths, test results, URLs) — no "trust me"

## Extending

Want a `designer.md`, `devops.md`, `writer.md`? Same pattern:
1. Create the role file
2. Add to orchestrator's table
3. Delegate when needed