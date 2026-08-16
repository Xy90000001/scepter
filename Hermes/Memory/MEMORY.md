Hermes on this device runs on Android/Termux with a custom provider: local OpenAI-compatible proxy at http://localhost:20128/v1 (owned_by "combo") that resolves the auto/* model aliases (best-coding, pro-*, etc.); the proxy maps alias → upstream model, not Hermes source. Hermes data lives in ~/.hermes (memories/, state.db, config.yaml).
§
User runs persistent Hermes gateway 'Heromi' on this device (Telegram + Discord, discord connected as heromi.#6139); runtime state/traffic in ~/.hermes (gateway_state.json, channel_directory.json, logs/gateway.log).
§
Second-brain vault "scepter": private GitHub repo Xy90000001/scepter; memory shared via vault (PC: ~/.hermes/memories → ~/scepter/Hermes/Memory symlink; Android: local ~/.hermes/memories, cronie vault_sync.sh every 15 min: pull --rebase → session export → memory sync → commit → push). Goal: centralised brain — same agent across devices; sessions stay per-device (export→import loop planned).
§
Discord gateway deps live in the hermes venv (discord.py 2.7.1, PyNaCl 1.5.0, brotlicffi 1.2.0.1, aiohttp pinned ==3.14.1); WHATSAPP_ENABLED=true leftover in secrets file.
§
Termux Hermes venv (~/hermes-agent/venv) is Python 3.11.15 from TUR; user requires ALL package/env changes stay inside that venv — never the system pkg python. User sometimes takes over manual setup steps; hand over exact pinned commands/requirements when asked.
§
Gateway launcher on this device: ~/.shortcuts/heromi.sh (wake-lock + omniroute + gateway). Pitfalls: launching gateway from inside a hermes CLI session wedges it silently pre-log — must use `setsid env -i` with explicit HOME/PREFIX/PATH; startup takes ~7 min (not dead — wait). Android freezes Termux when minimized (cgroup freezer): gateway stalls, drains queued msgs only on refocus; fix = Android Settings Termux battery 'Unrestricted' (manual). Phone memory-constrained (~7.5GB RAM, heavy swap, LMK SIGKILL under pressure).
§
PC brain setup (2026-08-14): vault ~/scepter (git main), memory symlink active, Obsidian Git configured. PC prefers event-driven sync (inotifywait watcher / systemd Path unit) over 15-min cron. Hermes v0.20.0, local proxy localhost:20128.