#!/usr/bin/env python3
"""
kanban_sync.py — Export/import Hermes kanban tasks to JSON for cross-device sync.
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
TASKS_FILE = VAULT / "01_Tasks" / "kanban_tasks.json"
DB_PATH = Path("~/.hermes/state.db").expanduser()


def export_tasks():
    """Export all kanban tasks from state.db to JSON file."""
    if not DB_PATH.exists():
        print(f"DB not found: {DB_PATH}")
        return

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Check if kanban_tasks table exists
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='kanban_tasks'")
    if not cursor.fetchone():
        print("kanban_tasks table not found")
        conn.close()
        return

    cursor.execute("""
        SELECT id, title, body, status, assignee, priority, idempotency_key,
               created_at, updated_at, board_id, column_id
        FROM kanban_tasks
        ORDER BY created_at DESC
    """)

    tasks = []
    for row in cursor.fetchall():
        tasks.append({
            "id": row["id"],
            "title": row["title"],
            "body": row["body"],
            "status": row["status"],
            "assignee": row["assignee"],
            "priority": row["priority"],
            "idempotency_key": row["idempotency_key"],
            "created_at": row["created_at"],
            "updated_at": row["updated_at"],
            "board_id": row["board_id"],
            "column_id": row["column_id"]
        })

    conn.close()

    TASKS_FILE.parent.mkdir(parents=True, exist_ok=True)
    TASKS_FILE.write_text(json.dumps({"tasks": tasks, "exported_at": datetime.now().isoformat()}, indent=2))
    print(f"Exported {len(tasks)} tasks to {TASKS_FILE}")


def import_tasks():
    """Import kanban tasks from JSON file into state.db (upsert by idempotency_key)."""
    if not DB_PATH.exists():
        print(f"DB not found: {DB_PATH}")
        return

    if not TASKS_FILE.exists():
        print(f"Tasks file not found: {TASKS_FILE}")
        return

    data = json.loads(TASKS_FILE.read_text())
    tasks = data.get("tasks", [])

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    imported = 0
    skipped = 0

    for task in tasks:
        # Check if task already exists (by idempotency_key)
        cursor.execute("SELECT id FROM kanban_tasks WHERE idempotency_key = ?", (task["idempotency_key"],))
        existing = cursor.fetchone()

        if existing:
            # Update existing
            cursor.execute("""
                UPDATE kanban_tasks SET
                    title = ?, body = ?, status = ?, assignee = ?, priority = ?,
                    updated_at = ?, board_id = ?, column_id = ?
                WHERE idempotency_key = ?
            """, (
                task["title"], task["body"], task["status"], task["assignee"],
                task["priority"], task["updated_at"], task["board_id"],
                task["column_id"], task["idempotency_key"]
            ))
            skipped += 1
        else:
            # Insert new
            cursor.execute("""
                INSERT INTO kanban_tasks (
                    id, title, body, status, assignee, priority, idempotency_key,
                    created_at, updated_at, board_id, column_id
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                task["id"], task["title"], task["body"], task["status"],
                task["assignee"], task["priority"], task["idempotency_key"],
                task["created_at"], task["updated_at"], task["board_id"],
                task["column_id"]
            ))
            imported += 1

    conn.commit()
    conn.close()
    print(f"Imported: {imported}, Updated: {skipped}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python kanban_sync.py [export|import]")
        sys.exit(1)

    if sys.argv[1] == "export":
        export_tasks()
    elif sys.argv[1] == "import":
        import_tasks()
    else:
        print("Unknown command. Use 'export' or 'import'")
        sys.exit(1)