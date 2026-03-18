# openrouter-free

A skill to fetch alpha and free models from https://openrouter.ai/models and automatically configure Claude Code to use them.

## Features

- Automatically fetches top 3 alpha models and top 5 free models from OpenRouter
- Filters for high-context (>128k), zero-cost ($0 prompt/$0 completion), and coding-capable models
- Sets primary model to #1 alpha model (for complex tasks)
- Sets fast model to #1 free model (for simple operations)
- Updates `~/.claude/settings.local.json` with optimal model mappings
- Provides update mechanism to get latest skill version
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
```

```
/plugin install openrouter-sync
```

### Usage

Simply run the skill:
```
/openrouter-sync
```

The skill will:
1. Call the OpenRouter API to identify alpha and free models
2. Filter for models with high context (>128k), zero cost, and coding capability
3. Rank free models by `token_processed_7d` (7-day token volume) — mirrors https://openrouter.ai/models?q=free
4. Update `~/.claude/settings.local.json` with optimal settings

---

## Example: Output settings.local.json

After running `/openrouter-sync`, your `~/.claude/settings.local.json` will look like this:

```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "ANTHROPIC_MODEL": "openrouter/hunter-alpha",
    "ANTHROPIC_SMALL_FAST_MODEL": "nvidia/nemotron-3-super-120b-a12b:free",
    "API_TIMEOUT_MS": 600000,
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": 16384
  },
  "modelOptions": [
    {
      "id": "arcee-ai/trinity-large-preview:free",
      "name": "Arcee AI: Trinity Large Preview (free)"
    },
    {
      "id": "minimax/minimax-m2.5:free",
      "name": "MiniMax: MiniMax M2.5 (free)"
    },
    {
      "id": "nvidia/nemotron-3-super-120b-a12b:free",
      "name": "NVIDIA: Nemotron 3 Super (free)"
    },
    {
      "id": "openrouter/free",
      "name": "Free Models Router"
    },
    {
      "id": "openrouter/healer-alpha",
      "name": "Healer Alpha"
    },
    {
      "id": "openrouter/hunter-alpha",
      "name": "Hunter Alpha"
    },
    {
      "id": "stepfun/step-3.5-flash:free",
      "name": "StepFun: Step 3.5 Flash (free)"
    }
  ]
}
```

**Key settings explained:**
- `ANTHROPIC_MODEL` – Your primary model for complex tasks
- `ANTHROPIC_SMALL_FAST_MODEL` – Quick model for simple operations
- `modelOptions` – Additional models available via `/model` command with display names
- `API_TIMEOUT_MS` – Extended timeout for free model responses
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS` – Increased output token limit

---

## How It Works

The skill fetches:
- **Top 3 alpha models** (zero-cost, >128k context, OpenRouter default ordering) → Primary model set to #1 alpha
- **Top 5 free models** (zero-cost, >128k context, sorted by `token_processed_7d`) → Fast model set to #1 free
- All qualifying models available via `/model` command

## Current Top Models (as of March 2026)

### Alpha Models (Top 3 - Zero Cost, >128k Context)
| Rank | Model | Key Strength |
| :--- | :--- | :--- |
| 1 | `openrouter/hunter-alpha` | Reasoning/Logic, 1M Context |
| 2 | `openrouter/healer-alpha` | Healing Focus, 256k Context |

### Free Models (Top 5 - Zero Cost, >128k Context, sorted by `token_processed_7d`)
Ranked by 7-day token volume — see live ranking at https://openrouter.ai/models?q=free

| Rank | Model | Key Strength |
| :--- | :--- | :--- |
| 1 | `nvidia/nemotron-3-super-120b-a12b:free` | Concise Code, 262k Context |
| 2 | `minimax/minimax-m2.5:free` | Multimodal, 196k Context |
| 3 | `openrouter/free` | Free Models Router, 200k Context |
| 4 | `stepfun/step-3.5-flash:free` | Speed, 256k Context |
| 5 | `arcee-ai/trinity-large-preview:free` | Creative Writing, 131k Context |
