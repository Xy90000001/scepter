#!/usr/bin/env python3
"""Export Hermes session history from state.db into the scepter vault.

Hybrid mode:
  - EVERY session gets a digest note (title, date, platform, stats, kickoff).
  - Sessions with recent activity (< --recent-days, default 14) ALSO get a
    full transcript note (user + assistant messages; tool output excluded).

Usage:
  export_sessions.py [--db PATH] [--out DIR] [--recent-days N]

Pure stdlib, read-only on the DB. Idempotent: notes are overwritten by
stable per-session filenames, so reruns are safe.
"""

import argparse
import os
import sqlite3
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

RECENT_DAYS_DEFAULT = 14
INDEX_NAME = "Index of Conversations.md"


def ts_to_str(value) -> str:
    """SQLite timestamps: unix epoch (int/float) or ISO string -> readable."""
    if value is None:
        return "?"
    if isinstance(value, (int, float)):
        try:
            dt = datetime.fromtimestamp(value, tz=timezone.utc)
            return dt.strftime("%Y-%m-%d %H:%M UTC")
        except (OverflowError, OSError, ValueError):
            return str(value)
    return str(value)


def safe_title(title) -> str:
    return (title or "Untitled session").strip().replace("\n", " ")[:120]


def truncate(text: str, limit: int) -> str:
    text = (text or "").strip()
    if len(text) <= limit:
        return text
    return text[:limit].rstrip() + " ..."


def fmt_content(content) -> str:
    """Keep code blocks; strip terminal escape noise."""
    if not content:
        return ""
    return content.replace("\r\n", "\n").replace("\r", "\n").strip()


def fetch_sessions(con):
    cur = con.cursor()
    cur.execute(
        """
        SELECT id, source, chat_type, title, started_at, ended_at,
               message_count, tool_call_count, input_tokens, output_tokens,
               estimated_cost_usd, actual_cost_usd, model,
               last_activity_at, last_activity_description
        FROM sessions
        ORDER BY COALESCE(started_at, last_activity_at) ASC
        """
    )
    cols = [d[0] for d in cur.description]
    return [dict(zip(cols, row)) for row in cur.fetchall()]


def fetch_messages(con, session_id):
    cur = con.cursor()
    cur.execute(
        """
        SELECT role, content, tool_name, timestamp
        FROM messages
        WHERE session_id = ? AND active != 0
        ORDER BY id ASC
        """,
        (session_id,),
    )
    return cur.fetchall()


def session_filename(session) -> str:
    started = session.get("started_at")
    if isinstance(started, (int, float)):
        dt = datetime.fromtimestamp(started, tz=timezone.utc)
        day = dt.strftime("%Y-%m-%d_%H%M")
    else:
        day = str(started or "unknown")[:16].replace(":", "").replace(" ", "_")
    short_id = str(session["id"])[:8]
    return f"{day}_{short_id}"


def render_digest(session, transcript_name) -> str:
    sid = session["id"]
    title = safe_title(session.get("title"))
    started = ts_to_str(session.get("started_at"))
    last = ts_to_str(session.get("last_activity_at"))
    model = session.get("model") or "?"
    cost = session.get("actual_cost_usd") or session.get("estimated_cost_usd")
    cost_str = f"${cost:.4f}" if isinstance(cost, (int, float)) and cost else "--"

    kickoff = "--"
    msgs = fetch_messages(_CON, sid)
    for role, content, tool_name, _ts in msgs:
        if role == "user" and content:
            kickoff = truncate(fmt_content(content), 400)
            break

    lines = [
        f"# {title}",
        "",
        f"> **Session:** `{sid}`",
        f"> **Date:** {started}",
        f"> **Platform:** {session.get('source') or '?'} / {session.get('chat_type') or '?'}",
        f"> **Last activity:** {last}",
        "",
        "## Stats",
        "",
        f"- Messages: {session.get('message_count') or 0}",
        f"- Tool calls: {session.get('tool_call_count') or 0}",
        f"- Tokens: {session.get('input_tokens') or 0} in / {session.get('output_tokens') or 0} out",
        f"- Cost: {cost_str}",
        f"- Model: `{model}`",
        "",
        "## Kickoff",
        "",
        kickoff,
        "",
    ]
    if transcript_name:
        lines += [
            "## Full transcript",
            "",
            f"[[{transcript_name}]]",
            "",
        ]
    desc = session.get("last_activity_description")
    if desc:
        lines += ["## Last activity", "", str(desc), ""]
    return "\n".join(lines)


def render_transcript(session, messages) -> str:
    title = safe_title(session.get("title"))
    sid = session["id"]
    lines = [f"# {title} -- transcript", "", f"> Session `{sid}` -- user & assistant messages only (tool output omitted)", ""]
    for role, content, tool_name, ts in messages:
        if role not in ("user", "assistant"):
            continue
        content = fmt_content(content)
        if not content:
            continue
        speaker = "**You**" if role == "user" else "**Hermes**"
        lines.append(f"### {speaker} \u00b7 {ts_to_str(ts)}" if ts else f"### {speaker}")
        lines.append("")
        lines.append(content)
        lines.append("")
    return "\n".join(lines)


def render_index(entries) -> str:
    lines = [
        "# Index of Conversations",
        "",
        "All sessions with Hermes, newest first. Full transcripts are available for recent sessions.",
        "",
        "| Date | Title | Type |",
        "|------|-------|------|",
    ]
    for session, fname, is_full in entries:
        title = safe_title(session.get("title")).replace("|", "/")
        started = session.get("started_at")
        if isinstance(started, (int, float)):
            day = datetime.fromtimestamp(started, tz=timezone.utc).strftime("%Y-%m-%d")
        else:
            day = str(started or "?")[:10]
        kind = "**transcript**" if is_full else "digest"
        lines.append(f"| {day} | [[{fname}|{title}]] | {kind} |")
    lines.append("")
    lines.append("_Generated automatically -- do not edit by hand._")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--db", default=os.environ.get(
        "HERMES_STATE_DB", str(Path.home() / ".hermes" / "state.db")))
    parser.add_argument("--out", default=os.environ.get(
        "SCEPTER_SESSIONS_DIR",
        str(Path.home() / "storage" / "shared" / "scepter" / "Hermes" / "Sessions")))
    parser.add_argument("--recent-days", type=int, default=RECENT_DAYS_DEFAULT)
    args = parser.parse_args()

    db_path = Path(args.db).expanduser()
    out_dir = Path(args.out).expanduser()
    out_dir.mkdir(parents=True, exist_ok=True)

    global _CON
    _CON = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)

    cutoff = datetime.now(timezone.utc) - timedelta(days=args.recent_days)
    sessions = fetch_sessions(_CON)

    entries = []
    written = 0
    for session in sessions:
        base = session_filename(session)
        last = session.get("last_activity_at") or session.get("started_at")
        is_full = isinstance(last, (int, float)) and datetime.fromtimestamp(last, tz=timezone.utc) >= cutoff

        transcript_name = None
        if is_full:
            messages = fetch_messages(_CON, session["id"])
            if messages:
                transcript_name = f"{base}_transcript"
                (out_dir / f"{transcript_name}.md").write_text(
                    render_transcript(session, messages), encoding="utf-8")
                written += 1

        digest_name = f"{base}"
        (out_dir / f"{digest_name}.md").write_text(
            render_digest(session, transcript_name), encoding="utf-8")
        written += 1
        entries.append((session, digest_name, is_full))

    (out_dir / INDEX_NAME).write_text(render_index(entries), encoding="utf-8")
    written += 1
    _CON.close()

    print(f"Exported {len(sessions)} sessions -> {out_dir} ({written} files, "
          f"recent window {args.recent_days}d)")


if __name__ == "__main__":
    main()