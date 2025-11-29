---
description: Configure LangSmith Dashboard for Orchestrator Tracing
---

# Configure LangSmith Dashboard

This workflow guides you through setting up LangSmith tracing for the Orchestrator system. This allows you to visualize agent traces, debug workflows, and monitor costs in the LangChain dashboard.

## Prerequisites

- A LangSmith account (sign up at [smith.langchain.com](https://smith.langchain.com/)).
- The `langsmith` npm package (already installed in this project).

## Steps

1.  **Get your API Key**:
    - Log in to LangSmith.
    - Go to **Settings** (gear icon) -> **API Keys**.
    - Create a new API Key. Copy it.

2.  **Add to Environment Variables**:
    - Open your `.ai-keys.env` file:
      ```bash
      nano /home/seanos1a/gemini/.ai-keys.env
      ```
    - Add the following line (replace `<your-key>` with your actual key):
      ```env
      LANGSMITH_API_KEY=<your-key>
      ```
    - (Optional) To group traces under a specific project name:
      ```env
      LANGCHAIN_TRACING_V2=true
      LANGCHAIN_PROJECT=gemini-orchestrator
      ```
    - Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

3.  **Verify Configuration**:
    - Run a simple orchestrator command:
      ```bash
      orch --simple "Test LangSmith connection"
      ```
    - Check your LangSmith dashboard. You should see a new run appear under the "Default" project (or the project you specified).

## Troubleshooting

- **No traces appearing?**
  - Ensure `dotenv` is correctly loading the `.ai-keys.env` file. The orchestrator logs `[dotenv] injecting env...` at startup.
  - Check if `LANGSMITH_API_KEY` is set in the current session: `echo $LANGSMITH_API_KEY`.
- **Errors in logs?**
  - If you see "Failed to start LangSmith run", check your internet connection and API key validity.
