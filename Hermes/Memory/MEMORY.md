User wants a brief list of planned actions before the agent does anything ("always make a brief list of what you're about to do").
§
User prefers to apply changes himself when given the requirements — when he asks for specs/dependency lists, provide clean self-contained info so he can do the change.
§
User interrupts mid-task ('wait', 'stop') to take over — stop promptly and give a concise status summary of what's done vs pending.
§
User wants orchestrator pattern with specialist agents: coder (uses aider/claude-code/codex), researcher, reviewer. Subagents get goal+context, return summaries.
§
User is building a 'second brain' (Obsidian vault 'scepter') synced across Android (Termux/Hermes) and PC via private GitHub repo Xy90000001/scepter. Centralized memory so any agent on any device shares the same context. Local proxy at localhost:20128/v1 serves auto/* model aliases; Graphify's OpenAI client hangs on proxy but direct API works. Scepter vault: only agentic source/config/memory/session-markdown committed; generated artifacts (node_modules, graphify-out/, nohup.out, bin/, dist/) gitignored. gbrain installed globally via ~/.bun/bin/gbrain. Memory symlinks: ~/.hermes/memories → ~/scepter/Hermes/Memory (PC); Android uses copy.
§
User wants an agentic OS system to run a SaaS from scratch: CEO orchestrator (xorin) delegates to specialists (engineer, product, growth, finance, ops, ceo) via kanban. heromi is mobile-only (Termux). No crons/projects until product decided. Cross-platform: all scripts work on Linux PC and Android Termux. Profiles live in vault (Hermes/Profiles/) and symlink to ~/.hermes/profiles/. Environment guards enforce heromi=Termux-only, xorin=PC-only.