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
"""

import json
import sqlite3
import os
import sys
from datetime import datetime
from pathlib import Path

# Config (portable: override with VAULT_ROOT env var)
VAULT_ROOT = os.environ.get("VAULT_ROOT", os.path.expanduser("~/scepter"))
VAULT = Path(VAULT_ROOT)
SESSIONS_DIR = VAULT / "Hermes" / "Sessions"
DB_PATH = Path("~/.hermes/state.db").expanduser()

# Use correct python path for hermes venv
HERMES_PY = Path("~/.hermes/hermes-agent/venv/bin/python").expanduser()

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


def export_sessions():
    """Export filtered sessions from state.db to markdown files."""
    if not DB_PATH.exists():
        print(f"DB not found: {DB_PATH}")
        return
    
    SESSIONS_DIR.mkdir(parents=True, exist_ok=True)
    
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    # Get sessions with messages
    cursor.execute("""
        SELECT s.id, s.title, s.started_at, s.last_activity_at,
               GROUP_CONCAT(m.role || ': ' || m.content, '\n\n') as transcript
        FROM sessions s
        LEFT JOIN messages m ON m.session_id = s.id
        GROUP BY s.id
        ORDER BY s.last_activity_at DESC
    """)
    
    exported = 0
    skipped = 0
    
    for row in cursor.fetchall():
        title = row['title'] or f"session_{row['id'][:8]}"
        summary = row['transcript'][:500] if row['transcript'] else ""
        
        if not should_export(title, summary):
            skipped += 1
            continue
        
        # Convert unix timestamps to ISO
        started_at = datetime.fromtimestamp(row['started_at']).isoformat() if row['started_at'] else datetime.now().isoformat()
        updated_at = datetime.fromtimestamp(row['last_activity_at']).isoformat() if row['last_activity_at'] else datetime.now().isoformat()
        
        # Sanitize filename
        safe_title = "".join(c if c.isalnum() or c in " -_" else "_" for c in title)
        safe_title = safe_title[:80]
        filename = f"{started_at[:10]}_{safe_title}.md"
        filepath = SESSIONS_DIR / filename
        
        # Write markdown
        content = f"# {title}\n\n"
        content += f"**Session ID:** {row['id']}\n"
        content += f"**Created:** {started_at}\n"
        content += f"**Updated:** {updated_at}\n\n"
        content += "## Transcript\n\n"
        content += row['transcript'] or "*(empty)*"
        
        filepath.write_text(content, encoding='utf-8')
        exported += 1
    
    conn.close()
    print(f"Exported: {exported}, Skipped: {skipped}")


def import_sessions():
    """Import sessions from markdown files into state.db (append only)."""
    if not DB_PATH.exists():
        print(f"DB not found: {DB_PATH}")
        return
    
    if not SESSIONS_DIR.exists():
        print(f"Sessions dir not found: {SESSIONS_DIR}")
        return
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    imported = 0
    skipped = 0
    
    for md_file in SESSIONS_DIR.glob("*.md"):
        content = md_file.read_text(encoding='utf-8')
        
        # Extract session ID from content
        session_id = None
        for line in content.split('\n'):
            if line.startswith("**Session ID:**"):
                session_id = line.split("**Session ID:**")[1].strip()
                break
        
        if not session_id:
            continue
        
        # Check if already exists
        cursor.execute("SELECT 1 FROM sessions WHERE id = ?", (session_id,))
        if cursor.fetchone():
            skipped += 1
            continue
        
        # Parse title
        title = "Imported Session"
        for line in content.split('\n'):
            if line.startswith("# "):
                title = line[2:].strip()
                break
        
        # Parse timestamps
        created_at = datetime.now().isoformat()
        updated_at = datetime.now().isoformat()
        for line in content.split('\n'):
            if line.startswith("**Created:**"):
                created_at = line.split("**Created:**")[1].strip()
            elif line.startswith("**Updated:**"):
                updated_at = line.split("**Updated:**")[1].strip()
        
        # Insert session with all required NOT NULL columns
        cursor.execute("""
            INSERT INTO sessions (
                id, title, started_at, last_activity_at, profile_name,
                source, chat_type, message_count, tool_call_count,
                input_tokens, output_tokens, estimated_cost_usd, actual_cost_usd,
                model, system_prompt, compression_fallback_streak, compression_ineffective_count,
                archived, pinned, hidden
            ) VALUES (
                ?, ?, ?, ?, 'default',
                'import', 'conversation', 0, 0,
                0, 0, 0.0, 0.0,
                'unknown', '', 0, 0,
                0, 0, 0
            )
        """, (
            session_id,
            title,
            datetime.fromisoformat(created_at).timestamp() if created_at else datetime.now().timestamp(),
            datetime.fromisoformat(updated_at).timestamp() if updated_at else datetime.now().timestamp(),
        ))
        
        # Insert messages (simplified - just add as single system message)
        cursor.execute("""
            INSERT INTO messages (session_id, role, content, timestamp)
            VALUES (?, 'system', 'Imported from vault', ?)
        """, (session_id, datetime.now().timestamp()))
        
        imported += 1
    
    conn.commit()
    conn.close()
    print(f"Imported: {imported}, Skipped (existing): {skipped}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python session_sync.py [export|import]")
        sys.exit(1)
    
    if sys.argv[1] == "export":
        export_sessions()
    elif sys.argv[1] == "import":
        import_sessions()
    else:
        print("Unknown command. Use 'export' or 'import'")
        sys.exit(1)