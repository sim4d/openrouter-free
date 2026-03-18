---
name: openrouter-sync
description: Fetches the top 3 currently free models from OpenRouter and updates the environment.
---

# OpenRouter Free Model Sync

When this skill is invoked, I will:
1. Call the OpenRouter API to identify the top 3 free models.
2. Filter for models with high context (e.g., > 128k) and "coding" capability.
3. Update `.claude/settings.local.json` with:
   - `ANTHROPIC_MODEL` (mapped to the #1 free model)
   - `ANTHROPIC_SMALL_FAST_MODEL` (mapped to the fastest free model)

## Current Top Free Models (as of March 2026)
| Rank | Model | Key Strength |
| :--- | :--- | :--- |
| 1 | `openrouter/hunter-alpha` | Reasoning/Logic |
| 2 | `stepfun/step-3.5-flash:free` | 1M Context/Speed |
| 3 | `nvidia/nemotron-3-nano-30b-a3b:free` | Concise Code |

