
# AI API Keys
if [ -f ~/.ai-keys.env ]; then
    source ~/.ai-keys.env
    export GEMINI_API_KEY
    export KIMIK2_API_KEY
    export GEMINI_ENDPOINT
    export KIMIK2_ENDPOINT
fi
