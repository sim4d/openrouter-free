#!/bin/bash

# OpenRouter Sync Script
# Fetches free models from OpenRouter and updates Claude Code settings

set -e

# Check for required dependencies
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install it with: brew install jq"
    exit 1
fi

# Check for required environment variables
if [[ -z "$ANTHROPIC_BASE_URL" || -z "$ANTHROPIC_AUTH_TOKEN" ]]; then
    echo "Error: Required environment variables not set:"
    echo "  ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL"
    echo "  ANTHROPIC_AUTH_TOKEN=$ANTHROPIC_AUTH_TOKEN"
    echo "Please set these in your shell config (~/.zshrc, ~/.bashrc):"
    echo "  export ANTHROPIC_BASE_URL=\"https://openrouter.ai/api\""
    echo "  export ANTHROPIC_AUTH_TOKEN=\"sk-or-v1-your-openrouter-key-here\""
    echo "  export ANTHROPIC_API_KEY=\"\"  # must be empty!"
    exit 1
fi

# Function to fetch free models sorted by top-weekly server-side
# Uses the same endpoint as https://openrouter.ai/models?order=top-weekly&q=free
fetch_free_models_ordered() {
    curl -s "https://openrouter.ai/api/frontend/models/find?order=top-weekly&q=free" \
        -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN" \
        -H "HTTP-Referer: https://claude.ai" \
        -H "X-Title: Claude Code"
}

# Function to extract free models in top-weekly order (ordering applied server-side)
# Response uses .data.models[].slug (without :free suffix) and .endpoint.is_free
extract_free_models() {
    local models_json="$1"
    local limit="$2"

    echo "$models_json" | jq -r "
        .data.models[]
        | select(.endpoint.is_free == true)
        | select(.context_length > 128000)
        | {id: (.slug + \":free\"), context_length: .context_length, name: .name // .slug}
        | \"\(.id)|\(.context_length)|\(.name)\"
    " | head -n "$limit"
}

# Main script logic
case "$1" in
    update)
        # Update the skill itself from GitHub
        echo "To update this skill, please run:"
        echo "  cd /Users/myarc/.claude/plugins/marketplaces/openrouter-free && git pull"
        exit 0
        ;;
    *)
        # Normal operation: fetch and configure models
        echo "Fetching free models from OpenRouter API..."
        FREE_MODELS_JSON=$(fetch_free_models_ordered)

        if [[ -z "$FREE_MODELS_JSON" ]]; then
            echo "Error: Failed to fetch models from OpenRouter API"
            exit 1
        fi

        echo "Fetching top 5 free models (sorted by top-weekly token volume)..."
        FREE_MODELS=$(extract_free_models "$FREE_MODELS_JSON" 5)

        # Extract the top free model for primary use
        TOP_FREE=$(echo "$FREE_MODELS" | head -n 1 | cut -d'|' -f1)

        # Build JSON for modelOptions using id and name from the pipe-delimited list
        MODEL_OPTIONS_JSON=""
        while IFS='|' read -r model_id model_ctx model_name; do
            if [[ -n "$model_id" ]]; then
                if [[ -z "$MODEL_OPTIONS_JSON" ]]; then
                    MODEL_OPTIONS_JSON="[{\"id\": \"$model_id\", \"name\": \"$model_name\"}]"
                else
                    MODEL_OPTIONS_JSON=$(echo "$MODEL_OPTIONS_JSON" | jq ". += [{\"id\": \"$model_id\", \"name\": \"$model_name\"}]")
                fi
            fi
        done <<< "$FREE_MODELS"

        # Update Claude Code settings
        SETTINGS_FILE="$HOME/.claude/settings.local.json"

        # Create settings file if it doesn't exist
        if [[ ! -f "$SETTINGS_FILE" ]]; then
            echo "{}" > "$SETTINGS_FILE"
        fi

        # Update settings with new values - replace entire structure
        TMP_FILE=$(mktemp)
        jq --arg free_model "$TOP_FREE" \
           --argjson model_options "$MODEL_OPTIONS_JSON" \
           '
           {
             "env": {
               "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
               "ANTHROPIC_MODEL": $free_model,
               "ANTHROPIC_SMALL_FAST_MODEL": $free_model,
               "API_TIMEOUT_MS": 600000,
               "CLAUDE_CODE_MAX_OUTPUT_TOKENS": 16384
             },
             "modelOptions": $model_options
           }
           ' "$SETTINGS_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$SETTINGS_FILE"

        echo "✅ Successfully updated Claude Code settings:"
        echo "  Primary model (ANTHROPIC_MODEL): $TOP_FREE"
        echo "  Available models via /model command: $(echo "$FREE_MODELS" | grep -c '|') models"
        echo ""
        echo "Settings saved to: $SETTINGS_FILE"
        ;;
esac
