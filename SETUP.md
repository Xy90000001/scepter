# Scepter — Setup Guide

Repo: `https://github.com/Xy90000001/scepter` (private)

The vault lives in shared storage so **every device sees the same folder**:
- **Termux (this device):** `~/storage/shared/scepter`
- **Android shared storage:** `/storage/emulated/0/scepter` (same thing)
- **GitHub:** the source of truth for sync

---

## 📱 Phone / mobile (Obsidian)

### Same device (this phone)
1. Install **Obsidian** from the Play Store.
2. Open Obsidian → **Open folder as vault** → pick `scepter` from internal storage.
3. Install **Obsidian Git** plugin: Settings → Community plugins → Browse → "Obsidian Git".
4. Configure Obsidian Git:
   - **Authentication:** username `Xy90000001`, password = a **Personal Access Token**.
   - Get a token: github.com → Settings → Developer settings → Personal access tokens →
     **Fine-grained** → repo access: `scepter` → Contents: Read/Write → generate.
   - **Mobile uses built-in JS git** (isomorphic-git) — no extra app needed.
   - Turn on: *Auto backup after stopping edit* (~1 min), *Pull on startup*,
     *Commit/sync on save*.

### A different phone
1. Install **MGit** (or clone via Termux): clone `https://github.com/Xy90000001/scepter.git`
   into internal storage.
2. Open the cloned folder as an Obsidian vault, install Obsidian Git as above.

---

## 💻 PC (desktop)

### 1. Install Hermes
```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

### 2. Clone the brain
```bash
git clone https://github.com/Xy90000001/scepter.git ~/scepter
```

### 3. Open in Obsidian
Obsidian → Open folder as vault → `~/scepter`. Install **Obsidian Git** (native git works
on desktop; set the same PAT as the phone).

### 4. Point Hermes memory at the vault
```bash
# after the first `hermes` run creates ~/.hermes
rmdir ~/.hermes/memories
ln -s ~/scepter/Hermes/Memory ~/.hermes/memories
```

### 5. Credentials (per-device, never committed)
- `.env` lives in `~/.hermes/.env` on each machine — **secrets never go in the repo**.
- This device uses a local proxy at `localhost:20128` (`auto/*` aliases). On your PC
  either run the same backend or point Hermes at your own provider:
  `hermes model` / `hermes setup`.

### 6. Config template
`Hermes/Config/config.yaml` is a reference copy of this device's settings — edit and
adapt, never assume it's current.

---

## 🔁 How sync works

| Trigger | What runs |
|---|---|
| Every 6h (Termux cron `scepter-backup`) | Session export → `git commit` → `git push` |
| Obsidian Git (phone/PC) | Pull on startup, push on save — keeps `Brain/` + memory in sync |
| Manual | `bash ~/storage/shared/scepter/scripts/backup.sh` (or on PC: `~/scepter/scripts/backup.sh`) |

**Memory lives in the vault.** How the live files get there differs by platform:
- **PC (symlink):** `~/.hermes/memories` → `~/scepter/Hermes/Memory` — Hermes writes straight into the repo.
- **Android (sync):** live files stay in `~/.hermes/memories` because Android shared
  storage can't `flock` (FUSE limitation) — the `scepter-backup` cron copies them
  into `Hermes/Memory/` every 6h. Don't hand-edit `Hermes/Memory/` on Android; edits
  on PC sync down fine.

---

## 🧪 Verify

```bash
cd ~/scepter && git status        # clean
git log --oneline -5              # recent syncs
ls Hermes/Sessions/ | head        # session notes present
```

Obsidian: search `Index of Conversations` — you should see every session.
