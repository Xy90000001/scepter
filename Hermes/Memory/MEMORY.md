Hermes on this device runs on Android/Termux with a custom provider: local OpenAI-compatible proxy at http://localhost:20128/v1 (owned_by "combo") that resolves the auto/* model aliases (best-coding, pro-*, etc.); the proxy maps alias → upstream model, not Hermes source. Hermes data lives in ~/.hermes (memories/, state.db, config.yaml).
§
User runs persistent Hermes gateway 'Heromi' on this device (Telegram + Discord, discord connected as heromi.#6139); runtime state/traffic in ~/.hermes (gateway_state.json, channel_directory.json, logs/gateway.log).
§
Second-brain vault "scepter": ~/storage/shared/scepter (Android shared storage), private GitHub repo Xy90000001/scepter. Memory stays in ~/.hermes/memories (FUSE can't flock); cronie runs scripts/vault_sync.sh every 15 min (pull --rebase → session export → memory sync → commit → push). Hermes cron scepter-backup is paused as fallback.
§
Discord gateway deps are installed in the hermes venv (2026-08-09): discord.py 2.7.1, PyNaCl 1.5.0, brotlicffi 1.2.0.1, aiohttp 3.14.1 (must stay pinned ==3.14.1). A leftover WHATSAPP_ENABLED=true flag from a failed whatsapp attempt remains in the hermes secrets file.
§
Termux Hermes venv (~/hermes-agent/venv) is Python 3.11.15 from TUR; user requires ALL package/env changes stay inside that venv — never the system pkg python. User sometimes takes over manual setup steps; hand over exact pinned commands/requirements when asked.
§
Gateway launcher on this device: ~/.shortcuts/heromi.sh (wake-lock + omniroute + gateway). Pitfalls: launching gateway from inside a hermes CLI session wedges it silently pre-log — must use `setsid env -i` with explicit HOME/PREFIX/PATH; startup takes ~7 min (not dead — wait). Android freezes Termux when minimized (cgroup freezer): gateway stalls, drains queued msgs only on refocus; fix = Android Settings Termux battery 'Unrestricted' (manual). Phone memory-constrained (~7.5GB RAM, heavy swap, LMK SIGKILL under pressure).