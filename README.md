# openrouter-free

A skill to fetch free models from https://openrouter.ai/models and automatically configure Claude Code to use them.

## Features

- Automatically fetches top 5 free models from OpenRouter
- Filters for high-context (>128k), zero-cost ($0 prompt/$0 completion) models
- Sets primary model to #1 free model by top-weekly token volume
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
export ANTHROPIC_MODEL="openrouter/free"
```

### Install jq
> **Note:** If `jq` is not installed, run `brew install jq` first.

---

## 3. Run openrouter-sync Skill in Claude Code

### Deployment

In Claude Code:
```
/plugin marketplace add sim4d/openrouter-free
```

```
/plugin install openrouter-sync@openrouter-free
```

### Run

```
run /openrouter-sync
```

### Change to use new model

```
! cat ~/.claude/settings.local.json
```

```
/model stepfun/step-3.5-flash:free
```

---

#### Example: Output settings.local.json

After running `/openrouter-sync`, your `~/.claude/settings.local.json` will look like this:

```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "ANTHROPIC_MODEL": "stepfun/step-3.5-flash:free",
    "ANTHROPIC_SMALL_FAST_MODEL": "nvidia/nemotron-3-super-120b-a12b:free",
    "API_TIMEOUT_MS": 600000,
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": 16384
  },
  "modelOptions": [
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

---

## 4. Config for ChatGPT Codex CLI

Create `~/.codex/config.toml`:

```toml
model_provider = "openrouter"
model_reasoning_effort = "high"
disable_response_storage = true

[model_providers.openrouter]
name = "openrouter"
base_url = "https://openrouter.ai/api/v1"
env_key = "OPENROUTER_API_KEY"
wire_api = "responses"
model = "stepfun/step-3.5-flash:free"
```

Make sure to set the `OPENROUTER_API_KEY` environment variable (same key as above).

