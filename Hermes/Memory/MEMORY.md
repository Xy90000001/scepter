Building 'second brain' (Obsidian vault 'scepter') synced across Android (Termux/Hermes) and PC via private GitHub repo Xy90000001/scepter. Centralized memory so any agent on any device shares context. Local proxy at localhost:20128/v1 (auto/* aliases); Graphify OpenAI client hangs on proxy but direct API works. Scepter vault: only agentic source/config/memory/session-markdown committed; generated artifacts gitignored. gbrain global via ~/.bun/bin/gbrain. Memory symlinks: ~/.hermes/memories → ~/scepter/Hermes/Memory (PC); Android uses copy
§
User prefers per-profile symlinks over full directory symlink for granular platform control
§
User installed Antigravity CLI (agy v1.1.13). 'Antigravity 2.0' = desktop GUI (tarball), not CLI.
§
agent-reach skill deps installed: yt-dlp, feedparser, mcporter (Exa MCP needs EXA_API_KEY). xreach not on PyPI. Probe script patched for empty mcporter config.
§
gbrain is an MCP server (1024-dim, omniroute 'brain' combo) for vault knowledge. Mnemosyne is the active episodic/working memory provider. heromi is the sole human interface; all agents report to heromi, who verifies with the user.
§
SaaS Agentic OS (Scepter) architecture: heromi (human interface/orchestrator, PC+Termux) delegates to xorin (PC IT Ops) and ceo (SaaS Strategy) -> specialists. All profiles and skills reside in the vault (~/scepter/Hermes/Profiles/) for cross-platform portability. Lean Vault Isolation Protocol syncs heromi, memory, PARA; excludes local-only PC agents. Tasks routed via Kanban.