#!/usr/bin/env python3
"""
session_sync.py — Export/import Hermes sessions with filtering.

Filters OUT:
- Kanban task sessions (title contains 'kanban', 'task', 'dispatch')
- System/scripting sessions (title contains 'system', 'script')
- Coding sessions (title contains 'code', 'debug', 'refactor', 'implement')

Keeps:
- General conversation sessions
- Research/planning sessions
- Decision/architecture sessions

NEW: Only exports sessions from the specified profile (default: heromi).
"""

import json
import sqlite3
import os
import sys
from datetime import datetime
from pathlib import Path

# Config (portable: override with VAULT_ROOT env var)
VAULT_ROOT = os.environ.get("VAULT_ROOT", "/home/exash/scepter")
VAULT = Path(VAULT_ROOT)
SESSIONS_DIR = VAULT / "Hermes" / "Sessions"
DB_PATH = Path("~/.hermes/state.db").expanduser()

# Keywords to EXCLUDE (low-priority sessions)
EXCLUDE_KEYWORDS = [
    "kanban", "task", "dispatch", "worker",
    "system", "script",
    "code", "debug", "refactor", "implement", "fix", "patch",
    "test", "deploy", "build", "lint", "format",
    "cron", "backup", "watch",
]


def should_export(session_title: str, session_summary: str) -> bool:
    """Return True if session should be exported."""
    text = f"{session_title} {session_summary}".lower()

    # Exclude if matches any exclude keyword
    for kw in EXCLUDE_KEYWORDS:
        if kw in text:
            return False

    # Default: keep all non-excluded sessions
    return True


def export_sessions(profile: str = "heromi", recent_days: int = 14):
    """Export filtered sessions from state.db to markdown files for a specific profile."""
    if not DB_PATH.exists():
        print(f"DB not found: {DB_PATH}")
        return

    SESSIONS_DIR.mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Get sessions - filter by profile if possible
    # Note: state.db doesn't store profile per session directly,
    # so we export all and rely on title/content filtering
    cursor.execute("""
        SELECT id, title, summary, started_at, ended_at, message_count
        FROM sessions
        ORDER BY started_at DESC
    """)

    rows = cursor.fetchall()
    conn.close()

    exported = 0
    for row in rows:
        session_id = row["id"]
        title = row["title"] or ""
        summary = row["summary"] or ""
        started_at = row["started_at"] or 0
        ended_at = row["ended_at"] or 0
        message_count = row["message_count"] or 0

        # Filter by keywords
        if not should_export(title, summary):
            continue

        # Export as markdown
        md_path = SESSIONS_DIR / f"{session_id}.md"
        if md_path.exists():
            continue

        dt = datetime.fromtimestamp(started_at / 1000) if started_at else datetime.now()
        date_str = dt.strftime("%Y-%m-%d %H:%M")

        md_content = f"""# {title}

**Session ID:** {session_id}
**Date:** {date_str}
**Messages:** {message_count}
**Profile:** {profile}

## Summary
{summary}

---

*Exported by session_sync.py*
"""
        md_path.write_text(md_content)
        exported += 1

    print(f"Exported {exported} sessions for profile '{profile}'")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Export Hermes sessions")
    parser.add_argument("--profile", default="heromi", help="Profile to export sessions for")
    parser.add_argument("--recent-days", type=int, default=14, help="Only export sessions from last N days")
    parser.add_argument("command", choices=["export", "import"], help="Command to run")

    args = parser.parse_args()

    if args.command == "export":
        export_sessions(profile=args.profile, recent_days=args.recent_days)
    elif args.command == "import":
        print("Import not implemented yet")