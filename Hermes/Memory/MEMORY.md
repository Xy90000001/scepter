User wants brief action list before execution ("always make a brief list of what you're about to do")
§
User prefers to apply changes themselves when given requirements — provide clean self-contained specs so they can do the change
§
User interrupts mid-task ('wait', 'stop') — stop promptly and give concise status summary of done vs pending
§
User wants orchestrator pattern with specialist agents: coder (uses aider/claude-code/codex), researcher, reviewer. Subagents get goal+context, return summaries
§
Building 'second brain' (Obsidian vault 'scepter') synced across Android (Termux/Hermes) and PC via private GitHub repo Xy90000001/scepter. Centralized memory so any agent on any device shares the same context. Local proxy at localhost:20128/v1 (auto/* aliases); Graphify OpenAI client hangs on proxy but direct API works. Scepter vault: only agentic source/config/memory/session-markdown committed; generated artifacts (node_modules, graphify-out/, nohup.out, bin/, dist/) gitignored. gbrain global via ~/.bun/bin/gbrain. Memory symlinks: ~/.hermes/memories → ~/scepter/Hermes/Memory (PC); Android uses copy.
§
Agentic OS to run SaaS from scratch: CEO orchestrator (xorin) delegates to specialists (engineer, product, growth, finance, ops, ceo) via kanban. heromi is mobile-only (Termux). No crons/projects until product decided. Cross-platform: all scripts work on Linux PC and Android Termux. Profiles live in vault (Hermes/Profiles/) and symlink to ~/.hermes/profiles/. Environment guards enforce heromi=Termux-only, xorin=PC-only. Kanban tasks sync via JSON (kanban_sync.py). Per-profile symlinks for granular platform control.
§
User wants execution plan listed before any multi-step action
§
User wants cross-device profile management with platform-specific guards (heromi only on Termux, xorin/engineer only on PC)
§
User wants kanban task sync across devices with environment enforcement (tasks for heromi blocked on PC)
§
User prefers per-profile symlinks over full directory symlink for granular platform control