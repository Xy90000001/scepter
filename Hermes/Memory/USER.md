User wants a brief list of planned actions before the agent does anything ("always make a brief list of what you're about to do").
§
User's second brain "scepter": Obsidian vault + private GitHub backup. Memory architecture: symlink on PC (~/.hermes/memories → vault), sync-copy on Android (FUSE lacks flock — symlink breaks the memory tool). Mobile access + same Hermes setup on PC planned.
§
User prefers to apply changes himself when given the requirements — when he asks for specs/dependency lists, provide clean self-contained info so he can do the change.
§
User interrupts mid-task ('wait', 'stop') to take over — stop promptly and give a concise status summary of what's done vs pending.
§
User is building a "second brain" (Obsidian vault "scepter") synced across Android (Termux/Hermes) and PC via private GitHub repo. Wants centralized memory so any agent on any device shares the same context ("talk to the same guy everywhere").
§
User prefers: brief action list before execution; file-change-based sync (inotifywait) over timed cron; applying changes themselves when given clean specs; interrupting mid-task to take over.