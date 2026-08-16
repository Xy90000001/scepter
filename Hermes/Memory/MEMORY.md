Second-brain vault "scepter": private GitHub repo Xy90000001/scepter; memory shared via vault (PC: ~/.hermes/memories → ~/scepter/Hermes/Memory symlink; Android: local ~/.hermes/memories, cronie vault_sync.sh every 15 min: pull --rebase → session export → memory sync → commit → push). Goal: centralised brain — same agent across devices; sessions stay per-device (export→import loop planned).
§
User wants a brief list of planned actions before the agent does anything ("always make a brief list of what you're about to do").
§
User's second brain "scepter": Obsidian vault + private GitHub backup (Xy90000001/scepter). Memory architecture: symlink on PC (~/.hermes/memories → vault), sync-copy on Android (FUSE lacks flock — symlink breaks the memory tool). Mobile access + same Hermes setup on PC planned.
§
User prefers to apply changes himself when given the requirements — when he asks for specs/dependency lists, provide clean self-contained info so he can do the change.
§
User interrupts mid-task ('wait', 'stop') to take over — stop promptly and give a concise status summary of what's done vs pending.
§
User wants file-change-triggered sync (inotifywait) rather than time-based cron for the vault. Pulls first on change, then pushes.
§
User wants orchestrator pattern with specialist agents: coder (uses aider/claude-code/codex), researcher, reviewer. Subagents get goal+context, return summaries.
§
User's local proxy at localhost:20128/v1 serves auto/* model aliases. Graphify's openai backend hangs on this proxy despite direct API calls working.