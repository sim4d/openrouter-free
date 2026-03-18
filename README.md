# openrouter-free

A skill to fetch alpha and free models from https://openrouter.ai/models and automatically configure Claude Code to use them.

## Features

- Automatically fetches top 3 alpha models and top 5 free models from OpenRouter
- Filters for high-context (>128k), zero-cost ($0 prompt/$0 completion), and coding-capable models
- Sets primary model to #1 alpha model (for complex tasks)
- Sets fast model to #1 free model by top-weekly token volume
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
```

```
/plugin install openrouter-sync
```

### Usage

```
/openrouter-sync
```

---

## Example: Output settings.local.json

After running `/openrouter-sync`, your `~/.claude/settings.local.json` will look like this:

```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "ANTHROPIC_MODEL": "openrouter/hunter-alpha",
    "ANTHROPIC_SMALL_FAST_MODEL": "stepfun/step-3.5-flash:free",
    "API_TIMEOUT_MS": 600000,
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": 16384
  },
  "modelOptions": [
    {
      "id": "openrouter/hunter-alpha",
      "name": "Hunter Alpha"
    },
    {
      "id": "openrouter/healer-alpha",
      "name": "Healer Alpha"
    },
    {
      "id": "stepfun/step-3.5-flash:free",
      "name": "StepFun: Step 3.5 Flash (free)"
    },
    {
      "id": "arcee-ai/trinity-large-preview:free",
      "name": "Arcee AI: Trinity Large Preview (free)"
    },
    {
      "id": "nvidia/nemotron-3-super-120b-a12b:free",
      "name": "NVIDIA: Nemotron 3 Super (free)"
    },
    {
      "id": "z-ai/glm-4.5-air:free",
      "name": "Z.ai: GLM 4.5 Air (free)"
    },
    {
      "id": "nvidia/nemotron-3-nano-30b-a3b:free",
      "name": "NVIDIA: Nemotron 3 Nano 30B A3B (free)"
    }
  ]
}
```

**Key settings explained:**
- `ANTHROPIC_MODEL` – Primary model for complex tasks
- `ANTHROPIC_SMALL_FAST_MODEL` – Fast model for simple operations
- `modelOptions` – All models available via `/model` command
- `API_TIMEOUT_MS` – Extended timeout for free model responses
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS` – Increased output token limit
