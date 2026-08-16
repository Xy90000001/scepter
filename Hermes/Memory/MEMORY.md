User wants a brief list of planned actions before the agent does anything ("always make a brief list of what you're about to do").
§
User prefers to apply changes himself when given the requirements — when he asks for specs/dependency lists, provide clean self-contained info so he can do the change.
§
User interrupts mid-task ('wait', 'stop') to take over — stop promptly and give a concise status summary of what's done vs pending.
§
User wants orchestrator pattern with specialist agents: coder (uses aider/claude-code/codex), researcher, reviewer. Subagents get goal+context, return summaries.
§
User's local proxy at localhost:20128/v1 serves auto/* model aliases. Graphify's openai backend hangs on this proxy despite direct API calls working.
§
User's second brain 'scepter': Obsidian vault + private GitHub repo (Xy90000001/scepter). Memory: symlink on PC (~/.hermes/memories → vault), sync-copy on Android (FUSE limitation). Sync: inotifywait watcher (vault_watch.sh) + unified vault_sync_desktop.sh (cross-platform), systemd user service enabled. Goal: centralized brain — same memory/sessions/config across devices.
§
Local proxy at localhost:20128/v1 (auto/* aliases). Graphify's OpenAI client hangs on proxy; direct API works. Need Gemini API key for semantic extraction.