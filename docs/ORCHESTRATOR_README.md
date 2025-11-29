# 🎻 Unified Orchestrator (`orch`) - Comprehensive Guide

**Version**: 3.0 (Enhanced Edition)
**Status**: ✅ Production Ready
**Location**: `scripts/orch`

The **Unified Orchestrator** (`orch`) is the central nervous system for the Gemini development environment. It consolidates multiple tools—agent delegation, deep analysis, workflow automation, system maintenance, and observability—into a single, intelligent CLI.

---

## 🚀 Quick Start

The orchestrator uses **Intelligent Routing** by default. Just describe your task, and it will route it to the appropriate mode (Simple, Workflow, or Deep Analysis).

```bash
# Auto-mode (Recommended)
orch "Fix the login bug in the auth service"

# Force specific modes
orch --deep "Design a microservices architecture for the new payment system"
orch --workflow fullstack "Create a user profile page"
orch --maintenance --save-report
```

---

## 🎮 Execution Modes

The orchestrator supports several specialized modes. You can let the system choose (Auto) or force a mode using flags.

### 1. 🧠 Auto Mode (Default)
**Command**: `orch "task"`
**Logic**: Uses a **Complexity Classification Matrix** to analyze the task:
- **Class A (Complex)**: Routes to **Deep Mode** (UltraThink).
- **Class B (Complicated)**: Routes to **Workflow Mode**.
- **Class C (Routine)**: Routes to **Simple Mode**.

### 2. 🌊 Deep Analysis Mode (`--deep`, `-d`)
**Command**: `orch --deep "task"`
**Engine**: `UltraThinkOrchestrator`
**Best For**: Strategic planning, architecture design, complex multi-step reasoning.
**Features**:
- Intelligent Task Planning
- Agent Coordination
- Learning System (records execution for future improvement)

### 3. 🔄 Workflow Mode (`--workflow`, `-w`)
**Command**: `orch --workflow <name> "task"`
**Engine**: `WorkflowEngine`
**Best For**: Standardized development processes.
**Built-in Workflows**:
- `fullstack` (or `feature`): Architect -> Coder -> Tester -> Reviewer -> Implement
- `bugfix` (or `bug`): Debugger -> Coder -> Tester -> Implement
- `quick`: Single researcher agent
- `general`: Analyze -> Execute
- `research`: Deep research -> Synthesis
- `review`: Security Audit -> Style Audit -> Final Review
- `arch`: Analysis -> Design -> Specs

### 4. 🤖 Agent Mode (`--agent`, `-a`)
**Command**: `orch --agent <name> "task"`
**Best For**: Single-turn tasks requiring a specific persona.
**Agents**: `coder`, `researcher`, `debugger`, `architect`, `reviewer`, etc.

### 5. ⚡ Simple Mode (`--simple`, `-s`)
**Command**: `orch --simple "query"`
**Best For**: Quick questions, explanations, or simple code generation. Uses a direct Gemini query.

### 6. 🔧 Maintenance Mode (`--maintenance`, `-m`)
**Command**: `orch --maintenance [options]`
**Engine**: `SystemAdmin`
**Features**:
- **Resource Monitoring**: Disk, Memory, CPU, Uptime.
- **Cleanup**: Docker prune, NPM cache, Temp files, Package cache.
- **Service Health**: Checks and restarts failed systemd services.
- **Security**: SSH connections, Firewall status, World-writable files.
- **Backups**: Checks status and can create snapshots.
**Options**:
- `--no-cleanup`: Skip cleanup tasks.
- `--no-backup`: Skip backup checks.
- `--save-report`: Save output to `/tmp/autoadmin-report.txt`.
- `--create-backup`: Create a quick tarball backup.
- `--verbose`: Detailed output.

### 7. 🔌 MCP Mode (`--mcp`)
**Command**: `orch --mcp [install <name>]`
**Engine**: `MCPManager`
**Features**:
- List active and available MCP servers.
- Install new MCP servers (e.g., `filesystem`, `git`, `memory`, `web-search`).

### 8. 🧪 Browser Mode (`--browser`, `--test`)
**Command**: `orch --browser "url_or_task"`
**Engine**: `BrowserTester`
**Features**:
- Runs multi-browser tests (Chromium, Firefox, WebKit).
- Simulates mobile devices (Pixel 5, iPhone 12).
- Checks functional, visual, responsive, and performance metrics.

### 9. 🔱 Tri-State Mode (`--tri-state`, `--tri`)
**Command**: `orch --tri-state "task"`
**Engine**: `TriStateOrchestrator`
**Concept**: Value-Driven Orchestration with three clusters:
1.  **Retrieval**: Internal Query + Web Scraper.
2.  **Knowledge**: Archival + Retrieval.
3.  **Content**: Drafter + Critique + Refinement.
**Process**:
- **Value Architect** creates a Master Plan.
- **Retrieval Cluster** gathers context.
- **Content Cluster** generates and refines artifacts in a recursive loop until "Value Convergence" is reached.
- **Marginal Utility Controller** prevents infinite loops by monitoring efficiency.

### 10. 🕸️ Living Graph Mode (`--living-graph`, `--graph`)
**Command**: `orch --living-graph "task"`
**Engine**: `LivingGraphOrchestrator`
**Concept**: Simulates the system state as a dynamic graph (LangGraph + Network Theory).
**Phases**:
1.  **War Room**: Adversarial construction of the graph topology.
2.  **Self-Healing Grid**: Optimizes the graph (e.g., splitting nodes with high centrality).
3.  **Time Travel**: Replays the history of state changes.

### 11. 🔴🟢 TDD Mode (`--tdd`)
**Command**: `orch --tdd "task"`
**Engine**: `WorkflowEngine` (TDD Pattern)
**Process**:
1.  Write failing test.
2.  Run test (expect fail).
3.  Write code.
4.  Run test (expect pass).
5.  Commit.

---

## 🏗️ System Architecture

### Core Components
- **Telemetry**: Logs Health (Tier 1), Traces (Tier 2), and Context (Tier 3) to `orch_telemetry.json`.
- **Context Middleware**: Optimizes context window usage via:
    - **Compression**: Summarizes history when >50% window usage.
    - **Formatting**: Primacy/Recency ordering (System -> RAG -> History).
    - **Inception**: Passes only specific artifacts to sub-agents.
- **FileSystem Observer**: Logs all file operations (`create`, `modify`, `delete`) to `orch_filesystem.log`.
- **Orchestrator Memory**: Centralized configuration object defining paths, protocols, and architecture.
- **A2A Protocol**: Standardized JSON envelope for Agent-to-Agent communication (`source`, `target`, `intent`, `payload`).

### Logs & Data
- **Telemetry**: `~/orch_telemetry.json`
- **File System Log**: `~/orch_filesystem.log`
- **Knowledge DB**: `~/orch_knowledge.json`
- **Maintenance Report**: `/tmp/autoadmin-report.txt`

---

## ⚙️ Configuration

The orchestrator loads environment variables from `.ai-keys.env`.
Key variables:
- `GEMINI_API_KEY`: Required for LLM operations.
- `LANGSMITH_API_KEY`: Optional. Enables tracing if present.

Configuration is centralized in the `OrchestratorMemory` object within the script. You can view the current configuration using:
```bash
orch --memory
```

---

## ❓ Troubleshooting

**"Command not found"**
Ensure `scripts/orch` is in your PATH or aliased.
```bash
alias orch='/home/seanos1a/gemini/scripts/orch'
```

**"Gemini API Error"**
Check your `.ai-keys.env` file and ensure `GEMINI_API_KEY` is valid.

**"Linter failed"**
Some agents have built-in linting guardrails. If they fail, the agent will retry or the step will error out. Check the logs for details.

**"Marginal utility dropped below threshold"**
In Tri-State mode, this means the system stopped refining the artifact because the cost of further improvements outweighed the value gain. This is a feature, not a bug.
