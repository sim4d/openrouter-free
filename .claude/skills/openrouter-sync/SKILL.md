---
name: openrouter-sync
description: Fetches the top free models from OpenRouter and automatically configures Claude Code settings.
---

# OpenRouter Model Sync

This skill fetches alpha and free models from https://openrouter.ai/models and automatically configures Claude Code to use them.

## What This Skill Does

When invoked, I will:
1. Call the OpenRouter API to identify the top 3 alpha models and top 5 free models
2. Filter for models with high context (>128k) and coding capability
3. Update `~/.claude/settings.local.json` with:
   - `ANTHROPIC_MODEL` – mapped to the #1 alpha model (primary model for complex tasks)
   - `ANTHROPIC_SMALL_FAST_MODEL` – mapped to the #1 free model (fast model for simple operations)
   - `modelOptions` – additional alpha and free models available via `/model` command
   - `API_TIMEOUT_MS` – extended timeout for model responses
   - `CLAUDE_CODE_MAX_OUTPUT_TOKENS` – increased output token limit

When invoked with `/openrouter-sync update`, I will:
- Fetch the latest version of this skill from the GitHub repository
- Replace the local skill with the updated version

## How It Works

This skill uses a bash script (`scripts/openrouter_sync.sh`) that:
- Fetches model data from the OpenRouter API
- Filters for alpha models (top 3) and free models (top 5) with >128k context
- Updates your Claude Code settings with the best models
- Provides an update mechanism to get the latest skill version

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

| Rank | Model | Key Strength |
| :--- | :--- | :--- |
| 1 | `openrouter/hunter-alpha` | Reasoning/Logic |
| 2 | `stepfun/step-3.5-flash:free` | 1M Context/Speed |
| 3 | `nvidia/nemotron-3-nano-30b-a3b:free` | Concise Code |

## Usage

Simply run:
```
/openrouter-sync
```

