#!/bin/bash

# OpenRouter Sync Script
# Fetches alpha and free models from OpenRouter and updates Claude Code settings

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

# Function to fetch models from OpenRouter API
fetch_models() {
    curl -s "https://openrouter.ai/api/v1/models" \
        -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN" \
        -H "HTTP-Referer: https://claude.ai" \
        -H "X-Title: Claude Code"
}

# Function to extract alpha model info (uses OpenRouter's default ordering)
extract_model_info() {
    local models_json="$1"
    local filter_type="$2"  # "alpha" or "free"
    local limit="$3"

    echo "$models_json" | jq -r "
        .data[]
        | select(.id | test(\"${filter_type}\"))
        | select(.context_length > 128000)
        | select(.pricing.prompt == \"0\" and .pricing.completion == \"0\")
        | {id: .id, context_length: .context_length, name: .name // .id}
        | \"\\(.id)|\\(.context_length)|\\(.name)\"
    " | head -n "$limit"
}

# Function to extract free models sorted by token_processed_7d (7-day token volume)
extract_free_models() {
    local models_json="$1"
    local limit="$2"

    echo "$models_json" | jq -r "
        [.data[]
        | select(.id | test(\":free\"))
        | select(.context_length > 128000)
        | select(.pricing.prompt == \"0\" and .pricing.completion == \"0\")]
        | sort_by(-(.token_processed_7d // 0))
        | .[]
        | {id: .id, context_length: .context_length, name: .name // .id}
        | \"\\(.id)|\\(.context_length)|\\(.name)\"
    " | head -n "$limit"
}

# Main script logic
case "$1" in
    update)
        # Update the skill itself from GitHub
        echo "Updating openrouter-skill from GitHub..."
        SKILL_DIR="/Users/myarc/sandbox/openrouter-free/.claude/skills/openrouter-sync"
        TEMP_DIR=$(mktemp -d)

        # Clone the latest version (this assumes the skill is in a git repo)
        # For now, we'll just notify the user to manually update
        echo "To update this skill, please run:"
        echo "  cd /Users/myarc/.claude/plugins/marketplaces/openrouter-free && git pull"
        echo "Then copy the updated skill:"
        echo "  cp /Users/myarc/.claude/plugins/marketplaces/openrouter-free/.claude/skills/openrouter-sync/* /Users/myarc/sandbox/openrouter-free/.claude/skills/openrouter-sync/"
        rm -rf "$TEMP_DIR"
        exit 0
        ;;
    *)
        # Normal operation: fetch and configure models
        echo "Fetching models from OpenRouter API..."
        MODELS_JSON=$(fetch_models)

        if [[ -z "$MODELS_JSON" || "$MODELS_JSON" == "null" ]]; then
            echo "Error: Failed to fetch models from OpenRouter API"
            exit 1
        fi

        echo "Fetching top 3 alpha models..."
        ALPHA_MODELS=$(extract_model_info "$MODELS_JSON" "alpha" 3)

        echo "Fetching top 5 free models (sorted by token_processed_7d)..."
        FREE_MODELS=$(extract_free_models "$MODELS_JSON" 5)

        # Extract the top alpha model for primary use
        TOP_ALPHA=$(echo "$ALPHA_MODELS" | head -n 1 | cut -d'|' -f1)

        # Extract the top free model for fast use
        TOP_FREE=$(echo "$FREE_MODELS" | head -n 1 | cut -d'|' -f1)

        # Prepare model options list (combine alpha and free, deduplicate)
        ALL_MODELS=$(echo -e "$ALPHA_MODELS\n$FREE_MODELS" | sort -u | cut -d'|' -f1)

        # Build JSON for modelOptions
        MODEL_OPTIONS_JSON=""
        while IFS= read -r model_id; do
            if [[ -n "$model_id" ]]; then
                model_name=$(echo "$MODELS_JSON" | jq -r ".data[] | select(.id == \"$model_id\") | .name // .id" | head -n 1)
                if [[ -z "$MODEL_OPTIONS_JSON" ]]; then
                    MODEL_OPTIONS_JSON="[{\"id\": \"$model_id\", \"name\": \"$model_name\"}]"
                else
                    MODEL_OPTIONS_JSON=$(echo "$MODEL_OPTIONS_JSON" | jq ". += [{\"id\": \"$model_id\", \"name\": \"$model_name\"}]")
                fi
            fi
        done <<< "$ALL_MODELS"

        # Update Claude Code settings
        SETTINGS_FILE="$HOME/.claude/settings.local.json"

        # Create settings file if it doesn't exist
        if [[ ! -f "$SETTINGS_FILE" ]]; then
            echo "{}" > "$SETTINGS_FILE"
        fi

        # Update settings with new values - replace entire structure
        TMP_FILE=$(mktemp)
        jq --arg alpha_model "$TOP_ALPHA" \
           --arg free_model "$TOP_FREE" \
           --argjson model_options "$MODEL_OPTIONS_JSON" \
           '
           {
             "env": {
               "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
               "ANTHROPIC_MODEL": $alpha_model,
               "ANTHROPIC_SMALL_FAST_MODEL": $free_model,
               "API_TIMEOUT_MS": 600000,
               "CLAUDE_CODE_MAX_OUTPUT_TOKENS": 16384
             },
             "modelOptions": $model_options
           }
           ' "$SETTINGS_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$SETTINGS_FILE"

        echo "✅ Successfully updated Claude Code settings:"
        echo "  Primary model (ANTHROPIC_MODEL): $TOP_ALPHA"
        echo "  Fast model (ANTHROPIC_SMALL_FAST_MODEL): $TOP_FREE"
        echo "  Available models via /model command: $(echo "$ALL_MODELS" | wc -l) models"
        echo ""
        echo "Settings saved to: $SETTINGS_FILE"
        ;;
esac