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
VAULT_ROOT = os.environ.get("VAULT_ROOT", os.path.expanduser("~/scepter"))
VAULT = Path(VAULT_ROOT)
TASKS_FILE = VAULT / "01_Tasks" / "kanban_tasks.json"
DB_PATH = Path("~/.hermes/kanban.db").expanduser()

# Valid assignees (current profile architecture)
VALID_ASSIGNEES = {"heromi", "xosin", "xorin", "ceo", "engineer", "product", "growth", "finance", "ops"}

def export_tasks():
    """Export all kanban tasks from state.db to JSON file."""
    if not DB_PATH.exists():
        print(f"DB not found: {DB_PATH}")
        return

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Check if kanban_tasks table exists
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='tasks'")
    if not cursor.fetchone():
        print("tasks table not found")
        conn.close()
        return

    cursor.execute("""
        SELECT id, title, body, status, assignee, priority, idempotency_key,
               created_at, started_at, completed_at, claim_lock, block_kind,
               session_id, skills, model_override, provider_override
        FROM tasks
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
            "started_at": row["started_at"],
            "completed_at": row["completed_at"],
            "claim_lock": row["claim_lock"],
            "block_kind": row["block_kind"],
            "session_id": row["session_id"],
            "skills": row["skills"],
            "model_override": row["model_override"],
            "provider_override": row["provider_override"]
        })

    conn.close()

    TASKS_FILE.parent.mkdir(parents=True, exist_ok=True)
    TASKS_FILE.write_text(json.dumps({"tasks": tasks, "exported_at": datetime.now().isoformat()}, indent=2))
    print(f"Exported {len(tasks)} tasks to {TASKS_FILE}")


def import_tasks():
    """Import kanban tasks from JSON file into state.db (upsert by idempotency_key, then by id)."""
    if not DB_PATH.exists():
        print(f"DB not found: {DB_PATH}")
        return

    if not TASKS_FILE.exists():
        print(f"Tasks file not found: {TASKS_FILE}")
        return

    data = json.loads(TASKS_FILE.read_text())
    tasks = data.get("tasks", [])

    # Filter out tasks with invalid assignees (only keep valid ones)
    valid_tasks = []
    for task in tasks:
        assignee = task.get("assignee")
        if assignee in VALID_ASSIGNEES or not assignee:
            valid_tasks.append(task)
        else:
            print(f"  Skipping task with invalid assignee: {task['id']} (assignee: {assignee})")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    imported = 0
    updated = 0
    skipped = 0

    for task in valid_tasks:
        # Try upsert by idempotency_key first (if present)
        if task.get("idempotency_key"):
            cursor.execute("SELECT id FROM tasks WHERE idempotency_key = ?", (task["idempotency_key"],))
            existing = cursor.fetchone()
            
            if existing:
                # Update existing by idempotency_key
                cursor.execute("""
                    UPDATE tasks SET
                        title = ?, body = ?, status = ?, assignee = ?, priority = ?,
                        started_at = ?, completed_at = ?, claim_lock = ?, block_kind = ?,
                        session_id = ?, skills = ?, model_override = ?, provider_override = ?
                    WHERE idempotency_key = ?
                """, (
                    task["title"], task["body"], task["status"], task["assignee"], task["priority"],
                    task["started_at"], task["completed_at"], task["claim_lock"], task["block_kind"],
                    task["session_id"], task["skills"], task["model_override"], task["provider_override"],
                    task["idempotency_key"]
                ))
                updated += 1
            else:
                # Insert new
                cursor.execute("""
                    INSERT INTO tasks (
                        id, title, body, status, assignee, priority, idempotency_key,
                        created_at, started_at, completed_at, claim_lock, block_kind,
                        session_id, skills, model_override, provider_override
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (
                    task["id"], task["title"], task["body"], task["status"],
                    task["assignee"], task["priority"], task["idempotency_key"],
                    task["created_at"], task["started_at"], task["completed_at"],
                    task["claim_lock"], task["block_kind"], task["session_id"],
                    task["skills"], task["model_override"], task["provider_override"]
                ))
                imported += 1
        else:
            # No idempotency_key — try by id
            cursor.execute("SELECT id FROM tasks WHERE id = ?", (task["id"],))
            existing = cursor.fetchone()
            
            if existing:
                # Update existing by id
                cursor.execute("""
                    UPDATE tasks SET
                        title = ?, body = ?, status = ?, assignee = ?, priority = ?,
                        started_at = ?, completed_at = ?, claim_lock = ?, block_kind = ?,
                        session_id = ?, skills = ?, model_override = ?, provider_override = ?,
                        idempotency_key = ?
                    WHERE id = ?
                """, (
                    task["title"], task["body"], task["status"], task["assignee"], task["priority"],
                    task["started_at"], task["completed_at"], task["claim_lock"], task["block_kind"],
                    task["session_id"], task["skills"], task["model_override"], task["provider_override"],
                    task.get("idempotency_key"),
                    task["id"]
                ))
                updated += 1
            else:
                # Insert new
                cursor.execute("""
                    INSERT INTO tasks (
                        id, title, body, status, assignee, priority, idempotency_key,
                        created_at, started_at, completed_at, claim_lock, block_kind,
                        session_id, skills, model_override, provider_override
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (
                    task["id"], task["title"], task["body"], task["status"],
                    task["assignee"], task["priority"], task.get("idempotency_key"),
                    task["created_at"], task["started_at"], task["completed_at"],
                    task["claim_lock"], task["block_kind"], task["session_id"],
                    task["skills"], task["model_override"], task["provider_override"]
                ))
                imported += 1

    # Clean up orphaned tasks (invalid assignees) from local DB
    placeholders = ",".join(["?"] * len(VALID_ASSIGNEES))
    cursor.execute(f"DELETE FROM tasks WHERE assignee NOT IN ({placeholders})", list(VALID_ASSIGNEES))
    deleted = cursor.rowcount
    if deleted:
        print(f"  Cleaned {deleted} orphaned tasks with invalid assignees")

    conn.commit()
    conn.close()
    print(f"Imported: {imported}, Updated: {updated}, Skipped: {skipped}")


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