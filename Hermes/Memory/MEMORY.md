Building 'second brain' (Obsidian vault 'scepter') synced across Android (Termux/Hermes) and PC via private GitHub repo Xy90000001/scepter. Centralized memory so any agent on any device shares context. Local proxy at localhost:20128/v1 (auto/* aliases); Graphify OpenAI client hangs on proxy but direct API works. Scepter vault: only agentic source/config/memory/session-markdown committed; generated artifacts gitignored. gbrain global via ~/.bun/bin/gbrain. Memory symlinks: ~/.hermes/memories → ~/scepter/Hermes/Memory (PC); Android uses copy
§
Agentic OS profile architecture (verified 2026-08-20): heromi = primary personal assistant on BOTH PC and Termux (no platform guard, brain-dump + dispatch hub); xosin = Termux-only IT Ops (vault-staged, pre_start_hook guard); xorin = PC-only IT Ops; ceo/engineer/product/growth/finance/ops = PC-only execution suite (local-only, not in vault). Vault contains only: heromi + xosin profiles, Hermes/Memory, Brain/Knowledge, PARA folders, scripts, heromi session exports.
§
User wants cross-device profile management with platform-specific guards (heromi = BOTH PC+Termux no guard; xosin = Termux-only; xorin/engineer/etc = PC-only)
§
User wants kanban task sync across devices with environment enforcement (heromi runs on both PC+Termux; xosin tasks blocked on PC; PC specialist tasks blocked on Termux)
§
User prefers per-profile symlinks over full directory symlink for granular platform control
§
User runs Hermes with Scepter multi-agent architecture (8 profiles: ceo, engineer, finance, growth, ops, product, xorin, heromi). Active profile: default (~/.hermes/profiles/default/). Capitalized Profiles/ are symlinks to Scepter vault.
§
User installed Antigravity CLI (agy v1.1.13). 'Antigravity 2.0' = desktop GUI (tarball), not CLI.
§
agent-reach skill deps installed: yt-dlp, feedparser, mcporter (Exa MCP needs EXA_API_KEY). xreach not on PyPI. Probe script patched for empty mcporter config.