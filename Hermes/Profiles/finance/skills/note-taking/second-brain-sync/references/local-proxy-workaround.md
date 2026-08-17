# Local Proxy Workaround for graphify

## Problem
When running `graphify` CLI directly (not via subagents in a coding assistant), semantic extraction uses the **openai backend** by default. If you have a local OpenAI-compatible proxy (e.g., `http://localhost:20128/v1` serving `auto/*` model aliases), graphify's openai backend may fail with 422/404 errors because:

1. The proxy's model names (`auto/best-coding`, `auto/best-fast`, etc.) don't match standard OpenAI model names
2. The proxy may not implement all OpenAI endpoints graphify expects

## Workarounds

### Option 1: Code-only extraction (no LLM needed)
```bash
graphify /path/to/project --code-only --no-viz
```
- Uses only AST extraction (deterministic, free, no API key)
- Works for code files (Python, JS, TS, Go, Rust, etc.)
- Skips all markdown/docs/papers/images
- Run `graphify cluster-only /path/to/project --no-viz` after to generate report

### Option 2: Set Gemini API key (graphify's preferred backend)
```bash
export GEMINI_API_KEY=your_key
graphify /path/to/project --no-viz
```
- Graphify uses Gemini (`gemini-3-flash-preview` by default) for semantic extraction
- Set `GRAPHIFY_GEMINI_MODEL` to override model
- Requires `pip install 'graphifyy[gemini]'`

### Option 3: Use `--backend` with a model your proxy actually serves
```bash
OPENAI_API_KEY=local OPENAI_BASE_URL=http://localhost:20128/v1 \
graphify /path/to/project --no-viz --model auto/best-fast
```
- May still fail if proxy doesn't implement `/v1/chat/completions` compatibly
- Test with a simple curl first

### Option 4: Run inside a coding assistant that dispatches subagents
- Claude Code, Cursor, Codex, etc. use the host agent as LLM when no Gemini key
- The skill's subagent flow (Step B2) handles this automatically
- Not applicable when running `graphify` CLI directly in terminal

## Testing your proxy
```bash
# Check models
curl -s http://localhost:20128/v1/models | jq '.data[].id'

# Test chat completion
curl -s http://localhost:20128/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer local" \
  -d '{"model":"auto/best-fast","messages":[{"role":"user","content":"test"}]}'
```

## Notes
- The skill's "No other API keys are read" statement applies to the **subagent dispatch flow** (Step B2) where the host agent acts as LLM
- The **CLI direct execution** path is different — it uses the openai Python package and requires a compatible backend
- For the scepter vault (mostly markdown), `--code-only` gives partial coverage (only 5 Python scripts); full coverage needs semantic extraction working