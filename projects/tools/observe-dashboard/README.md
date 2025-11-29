# Observe Dashboard

The **Observe Dashboard** is a real-time observability and control interface for the Agentic System. It provides deep visibility into the agent swarm's state, metrics, and topology, while offering a powerful command interface for direct interaction.

## Features

### 1. System Observability
- **Real-time Metrics**: Monitor key performance indicators including:
  - **Stability**: Global system stability score.
  - **Cost**: Accumulated token usage/cost.
  - **Entropy**: System uncertainty/randomness levels.
  - **Step**: Current execution step count.
- **Topology Graph**: Visual representation of active agents (nodes) and their communication pathways (edges).
- **Event Log**: Live feed of system events, agent actions, and state changes.

### 2. Command Interface
The dashboard features a dual-mode command bar for controlling the system:

#### 🤖 Orchestrator Mode
- **Purpose**: Send high-level natural language instructions to the agent swarm.
- **Handler**: Routes commands to the `orch` script, which uses intelligent routing (Simple/Deep/Workflow) to execute tasks.
- **Examples**:
  - "Find and fix issues in project X"
  - "Analyze system logs"
  - "Run maintenance"

#### 💻 Bash Terminal Mode
- **Purpose**: Execute direct shell commands on the host server.
- **Handler**: Executes commands via `bash -c`.
- **Examples**:
  - `ls -la`
  - `top -b -n 1`
  - `df -h`

### 3. User Experience
- **Smart Suggestions**: Context-aware chips that populate the input with common commands based on the selected mode.
- **Autocomplete**: Native browser autocomplete for command history.
- **Responsive Design**: Modern, dark-themed UI optimized for desktop and mobile.
- **Live Updates**: Polling mechanism to fetch the latest system state every second.

## Technical Stack
- **Frontend**: Vanilla HTML5, CSS3, JavaScript (ES6+).
- **Backend**: Node.js, Express.
- **Visualization**: Cytoscape.js (for graph topology).
- **Deployment**: Nginx reverse proxy serving `observe.codeovertcp.com`.

## API Endpoints
- `GET /api/state`: Returns the current system state (metrics, graph, logs).
- `POST /api/command`: Executes a command.
  - Body: `{ "command": "string", "type": "orch" | "bash" }`

## Setup
1. Install dependencies: `npm install`
2. Start the server: `node server.js`
3. Access at `http://localhost:3004` or via the configured domain.
