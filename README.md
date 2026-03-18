# openrouter-free

A skill to fetch the most recent and powerful free models from https://openrouter.ai/models, including 'free' and 'alpha' models, and automatically configure Claude Code to use them.

## Features

- Automatically fetches top free models from OpenRouter
- Filters for high-context (>128k) and coding-capable models
- Updates `~/.claude/settings.local.json` with optimal model mappings
- No manual model selection required

---

## 1. Preparation

### Install Claude Code (if not already installed)

**macOS / Linux / WSL:**
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://claude.ai/install.ps1 | iex
```

**Or via npm / brew:**
```bash
npm install -g @anthropic-ai/claude-code
# or
brew install claude-code
```

---

## 2. Quick Start

### Get OpenRouter API Key

1. Sign up at https://openrouter.ai (free, GitHub/Google login works)
2. Go to **Keys** → **Create key**
3. Copy your key (starts with `sk-or-v1-...`)

### Set Environment Variables

Add these to your shell config (`~/.zshrc`, `~/.bashrc`, or equivalent), then source the file:

```bash
export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
export ANTHROPIC_AUTH_TOKEN="sk-or-v1-your-openrouter-key-here"
export ANTHROPIC_API_KEY=""                  # <- must be empty!
export ANTHROPIC_MODEL=$(curl -s https://openrouter.ai/api/v1/models | jq -r '.data[] | select(.id | endswith(":free")) | .id' | head -n 1)
```

> **Note:** If `jq` is not installed, run `brew install jq` first.

---

## 3. Run openrouter-sync Skill

### Deployment

In Claude Code:
```
/plugin marketplace add sim4d/openrouter-free
/plugin install openrouter-sync
```

### Usage

Simply run the skill:
```
/openrouter-sync
```

The skill will:
1. Call the OpenRouter API to identify the top free models
2. Filter for models with high context (>128k) and coding capability
3. Update `~/.claude/settings.local.json` with optimal settings

---

## Example: Output settings.local.json

After running `/openrouter-sync`, your `~/.claude/settings.local.json` will look like this:

```json
{
  "ANTHROPIC_MODEL": "openrouter/hunter-alpha",
  "ANTHROPIC_SMALL_FAST_MODEL": "stepfun/step-3.5-flash:free",
  "modelOptions": [
    {
      "id": "openrouter/hunter-alpha",
      "name": "Hunter Alpha (1M Context)"
    },
    {
      "id": "stepfun/step-3.5-flash:free",
      "name": "Step 3.5 Flash (256k Context)"
    },
    {
      "id": "nvidia/nemotron-3-nano-30b-a3b:free",
      "name": "Nemotron 3 Nano 30B (256k Context)"
    },
    {
      "id": "nvidia/nemotron-3-super-120b-a12b:free",
      "name": "Nemotron 3 Super 120B (262k Context)"
    },
    {
      "id": "openai/gpt-oss-120b:free",
      "name": "OpenAI gpt-oss-120b (131k Context)"
    }
  ],
  "API_TIMEOUT_MS": 600000,
  "CLAUDE_CODE_MAX_OUTPUT_TOKENS": 16384
}
```

**Key settings explained:**
- `ANTHROPIC_MODEL` – Your primary model for complex tasks
- `ANTHROPIC_SMALL_FAST_MODEL` – Quick model for simple operations
- `modelOptions` – Additional models available via `/model` command with display names
- `API_TIMEOUT_MS` – Extended timeout for free model responses
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS` – Increased output token limit

---

## Current Top Free Models (as of March 2026)

| Rank | Model | Key Strength |
| :--- | :--- | :--- |
| 1 | `openrouter/hunter-alpha` | Reasoning/Logic, 1M Context |
| 2 | `stepfun/step-3.5-flash:free` | Speed, 256k Context |
| 3 | `nvidia/nemotron-3-nano-30b-a3b:free` | Concise Code, 256k Context |
