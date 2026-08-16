# Graph Report - scepter  (2026-08-14)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 23 nodes · 34 edges · 6 communities (2 shown, 4 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `456d265e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- export_sessions.py
- render_transcript
- vault_watch.sh
- backup.sh
- tree_index.sh
- vault_sync.sh

## God Nodes (most connected - your core abstractions)
1. `main()` - 7 edges
2. `render_digest()` - 7 edges
3. `render_transcript()` - 5 edges
4. `safe_title()` - 4 edges
5. `fmt_content()` - 4 edges
6. `ts_to_str()` - 4 edges
7. `fetch_messages()` - 3 edges
8. `render_index()` - 3 edges
9. `fetch_sessions()` - 2 edges
10. `session_filename()` - 2 edges

## Surprising Connections (you probably didn't know these)
- `main()` --calls--> `render_transcript()`  [EXTRACTED]
  scripts/export_sessions.py → scripts/export_sessions.py  _Bridges community 0 → community 1_

## Import Cycles
- None detected.

## Communities (6 total, 4 thin omitted)

### Community 0 - "export_sessions.py"
Cohesion: 0.47
Nodes (8): fetch_messages(), fetch_sessions(), main(), render_digest(), render_index(), safe_title(), session_filename(), truncate()

### Community 1 - "render_transcript"
Cohesion: 0.40
Nodes (5): fmt_content(), SQLite timestamps: unix epoch (int/float) or ISO string → readable., Keep code blocks; strip terminal escape noise., render_transcript(), ts_to_str()

## Knowledge Gaps
- **3 isolated node(s):** `backup.sh script`, `tree_index.sh script`, `vault_sync.sh script`
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `fmt_content()` connect `render_transcript` to `export_sessions.py`?**
  _High betweenness centrality (0.053) - this node is a cross-community bridge._
- **Why does `ts_to_str()` connect `render_transcript` to `export_sessions.py`?**
  _High betweenness centrality (0.053) - this node is a cross-community bridge._
- **Why does `render_digest()` connect `export_sessions.py` to `render_transcript`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._
- **What connects `backup.sh script`, `tree_index.sh script`, `vault_sync.sh script` to the rest of the system?**
  _3 weakly-connected nodes found - possible documentation gaps or missing edges._