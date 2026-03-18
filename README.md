# openrouter-free

A skill to fetch the most recent and powerful free models from https://openrouter.ai/models, including 'free' and 'alpha' models, and automatically configure Claude Code to use them.

## Features

- Automatically fetches top 3 free models from OpenRouter
- Filters for high-context (>128k) and coding-capable models
- Updates `~/.claude/settings.local.json` with optimal model mappings
- No manual model selection required

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

## 2. Quick Start

### Get OpenRouter API Key

1. Sign up at https://openrouter.ai (free, GitHub/Google login works)
2. Go to **Keys** → **Create key**
3. Copy your key (starts with `sk-or-v1-...`)

### Set Environment Variables

Add these to your shell config (`~/.zshrc`, `~/.bashrc`, or equivalent), then source the file:

```bash
export ANTHROPIC_BASE_URL="https://openrouter.ai/api/v1"
export ANTHROPIC_AUTH_TOKEN="sk-or-v1-your-openrouter-key-here"
export ANTHROPIC_API_KEY=""                  # <- must be empty!
export ANTHROPIC_MODEL=$(curl -s https://openrouter.ai/api/v1/models | /usr/local/bin/jq -r '.data[] | select(.id | endswith(":free")) | .id' | head -n 1)
```

> **Note:** If `jq` is not installed, run `brew install jq` first.

### Start Claude Code CLI

```bash
claude
```

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
1. Call the OpenRouter API to identify the top 3 free models
2. Filter for models with high context (>128k) and "coding" capability
3. Update `~/.claude/settings.local.json` with:
   - `ANTHROPIC_MODEL` – mapped to the #1 free model
   - `ANTHROPIC_SMALL_FAST_MODEL` – mapped to the fastest free model

### Current Top Free Models (as of March 2026)

| Rank | Model | Key Strength |
| :--- | :--- | :--- |
| 1 | `openrouter/hunter-alpha` | Reasoning/Logic |
| 2 | `stepfun/step-3.5-flash:free` | 1M Context/Speed |
| 3 | `nvidia/nemotron-3-nano-30b-a3b:free` | Concise Code |

## Example: settings.local.json

After running the skill, your `~/.claude/settings.local.json` will look like this:

```json
{
  "alwaysThinkingEnabled": true,
  "permissions": {
    "allow": [
      "*"
    ]
  },
  "env": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "ANTHROPIC_BASE_URL": "https://openrouter.ai/api",
    "ANTHROPIC_AUTH_TOKEN": "sk-or-v1-your-openrouter-api-key",
    "ANTHROPIC_API_KEY": "",
    "ANTHROPIC_MODEL": "openrouter/hunter-alpha",
    "ANTHROPIC_SMALL_FAST_MODEL": "nvidia/nemotron-3-nano-30b-a3b:free",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "64000",
    "API_TIMEOUT_MS": "3000000"
  },
  "modelOptions": [
    "openrouter/healer-alpha",
    "stepfun/step-3.5-flash:free",
    "arcee-ai/trinity-large-preview:free",
    "nvidia/nemotron-3-super-120b-a12b:free",
    "openai/gpt-oss-120b:free"
  ],
  "defaultMaxTokens": 8192
}
```

**Key settings explained:**
- `ANTHROPIC_MODEL` – Your primary model for complex tasks
- `ANTHROPIC_SMALL_FAST_MODEL` – Quick model for simple operations
- `modelOptions` – Additional models available via `/model` command
- `API_TIMEOUT_MS` – Extended timeout for free model responses
