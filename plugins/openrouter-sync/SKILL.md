---
name: openrouter-sync
description: Fetches the top free models from OpenRouter and automatically configures Claude Code settings.
---

# OpenRouter Model Sync

This skill fetches free models from https://openrouter.ai/models and automatically configures Claude Code to use them.

## What This Skill Does

When invoked, I will:
1. Call the OpenRouter API to identify free models
2. Filter for models with:
   - High context (>128k tokens)
   - Zero cost ($0 prompt and $0 completion)
3. Select top 5 free models sorted by top-weekly token volume — identical ranking to https://openrouter.ai/models?order=top-weekly&q=free
4. Update `~/.claude/settings.local.json` with:
   - `env` object containing:
     - `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` – set to "1" to disable non-essential traffic
     - `ANTHROPIC_MODEL` – mapped to the #1 free model (primary model)
     - `ANTHROPIC_SMALL_FAST_MODEL` – mapped to the #1 free model (fast model for simple operations)
     - `API_TIMEOUT_MS` – extended timeout for model responses
     - `CLAUDE_CODE_MAX_OUTPUT_TOKENS` – increased output token limit
   - `modelOptions` – top 5 free models available via `/model` command

When invoked with `/openrouter-sync update`, I will:
- Fetch the latest version of this skill from the GitHub repository
- Replace the local skill with the updated version

## How It Works

This skill uses a bash script (`scripts/openrouter_sync.sh`) that:
- Fetches model data from the OpenRouter API
- Filters for zero-cost models ($0 prompt/$0 completion) with >128k context
- Selects top 5 free models sorted by top-weekly token volume via `/api/frontend/models/find?order=top-weekly&q=free` — identical to https://openrouter.ai/models?order=top-weekly&q=free
- Updates your Claude Code settings with the best free models

## Prerequisites

Before running this skill, ensure you have:

1. **OpenRouter API Key** – Sign up at https://openrouter.ai (free, GitHub/Google login works)
   - Go to **Keys** → **Create key**
   - Copy your key (starts with `sk-or-v1-...`)

2. **Environment Variables** – Set these in your shell config (`~/.zshrc`, `~/.bashrc`):
   ```bash
   export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
   export ANTHROPIC_AUTH_TOKEN="sk-or-v1-your-openrouter-key-here"
   export ANTHROPIC_API_KEY=""                  # <- must be empty!
   ```

3. **jq installed** – Run `brew install jq` if not already installed

## Current Top Free Models (as of March 2026)

Ranked by top-weekly token volume — see live ranking at https://openrouter.ai/models?order=top-weekly&q=free

| Rank | Model | Key Strength |
| :--- | :--- | :--- |
| 1 | `stepfun/step-3.5-flash:free` | Speed, 256k Context |
| 2 | `arcee-ai/trinity-large-preview:free` | Creative Writing, 131k Context |
| 3 | `nvidia/nemotron-3-super-120b-a12b:free` | Concise Code, 262k Context |
| 4 | `z-ai/glm-4.5-air:free` | Efficient, 131k Context |
| 5 | `nvidia/nemotron-3-nano-30b-a3b:free` | Lightweight, 256k Context |

## Usage

Simply run:
```
/openrouter-sync
```

