Hermes on this device runs on Android/Termux with a custom provider: local OpenAI-compatible proxy at http://localhost:20128/v1 (owned_by "combo") that resolves the auto/* model aliases (best-coding, pro-*, etc.); the proxy maps alias → upstream model, not Hermes source. Hermes data lives in ~/.hermes (memories/, state.db, config.yaml).
§
User runs a persistent Hermes gateway on this device (Telegram DM); runtime state/traffic live in ~/.hermes (gateway_state.json, channel_directory.json, logs/gateway.log).
§
Second-brain vault "scepter": ~/storage/shared/scepter (Android shared storage), private GitHub repo Xy90000001/scepter. Memory stays in ~/.hermes/memories (FUSE can't flock); cronie runs scripts/vault_sync.sh every 15 min (pull --rebase → session export → memory sync → commit → push). Hermes cron scepter-backup is paused as fallback.
§
Hermes venv is Python 3.11 (TUR build); system pkg Python is unsupported — all pip installs / env changes must go inside ~/hermes-agent/venv, never system-wide.
§
Discord gateway deps are installed in the hermes venv (2026-08-09): discord.py 2.7.1, PyNaCl 1.5.0, brotlicffi 1.2.0.1, aiohttp 3.14.1 (must stay pinned ==3.14.1). A leftover WHATSAPP_ENABLED=true flag from a failed whatsapp attempt remains in the hermes secrets file.