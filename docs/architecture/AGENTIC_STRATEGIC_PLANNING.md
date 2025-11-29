# Agentic Strategic Planning Formalisms

## 1. Conceptual Framework: The Automated Construction Firm

The Agentic Strategic Planning system operates analogously to a modern, automated construction firm. This model ensures that autonomous agents operate within a structured, observable, and economically rational framework.

*   **The Blueprint (SCIP Graph)**: A digitized, logically linked representation of the project state and requirements.
*   **The Architect (Gemini3)**: The high-level planner that designs the approach and optimizes resources.
*   **The Controller (Marginal Utility Convergence)**: A financial safety mechanism that halts work when costs exceed value.
*   **The Crew (A2A Protocol)**: Specialized agents (Workers, QA) communicating via a strict protocol.
*   **The Cockpit (LSO)**: A real-time observability dashboard for the human overseer.

---

## 2. Core Formalisms

### 2.1 SCIP Graph (Structured Context & Information Protocol)
**Definition**: The SCIP Graph is the "digital twin" of the project's state. It represents knowledge not as a flat text stream, but as a directed graph of dependencies, requirements, and current status.

*   **Nodes**: Represent discrete units of information (e.g., "User Auth Requirement", "Database Schema", "Login Component").
*   **Edges**: Represent relationships (e.g., "Depends On", "Implements", "Verifies").
*   **Function**: Allows the Architect Agent to query the state of the project without parsing the entire history, enabling O(1) access to critical context.

### 2.2 Architect Agent (Gemini3) & Complexity Classification Matrix
**Definition**: The Architect Agent is the primary decision-maker, responsible for breaking down high-level objectives into executable tasks.

*   **Complexity Classification Matrix**: A heuristic model used to categorize tasks and assign appropriate resources.
    *   **Class C (Routine)**: Simple implementation, handled by single agents (e.g., "Fix typo").
    *   **Class B (Complicated)**: Requires coordination between multiple agents (e.g., "Add feature").
    *   **Class A (Complex)**: Requires deep analysis and strategic planning (e.g., "Design architecture").
*   **Role**: The Architect uses this matrix to decide whether to route a request to a simple `orch` command or a deep `ultrathink` session.

### 2.3 Live State Object (LSO)
**Definition**: The "Cockpit View" for the human overseer. A JSON-serializable object that captures the instantaneous state of the entire system. It transforms the agent from a "Black Box" into an auditable engineering platform.

*   **Schema Components**:
    *   **`current_objective`**: The active goal being pursued.
    *   **`active_agents`**: List of agents currently executing tasks.
    *   **`scip_snapshot`**: A reference or diff of the current SCIP Graph state.
    *   **`global_stability_score`**: A real-time metric (0.0 - 1.0) representing the convergence of the agent's reasoning.
    *   **`mounted_tools`**: Array of MCP servers dynamically loaded, providing visibility into tool usage and cost.
    *   **`thought_buffer`**: Captures the internal monologue (`content`) and `type` (e.g., REASONING) of the Planning Agent at every superstep.
    *   **`efficiency_metric`**: Current value of the Marginal Utility function.

### 2.4 A2A Protocol (Agent-to-Agent)
**Definition**: A standardized communication protocol ensuring specialized agents can collaborate effectively without "context pollution."

*   **Structure**: Messages between agents must follow a strict schema:
    *   `Source`: Agent ID
    *   `Target`: Agent ID
    *   `Intent`: Request, Response, or Update
    *   `Payload`: Structured data (code, diffs, analysis)
    *   `Context Pointer`: Reference to relevant SCIP nodes
*   **Benefit**: Prevents the "telephone game" effect where instructions degrade as they are passed between agents.

---

## 3. Metrics & Control Protocols

### 3.1 Objective Metrics for Performance
To ensure the system remains reliable and cost-efficient, we define specific metrics for evaluation:

*   **Marginal Utility Convergence ($f(t)$)**:
    *   **Formula**: $Efficiency = \frac{\Delta Utility}{\Delta Cost}$
    *   **$\Delta Utility$**: Progress made towards the objective (measured by SCIP node completion).
    *   **$\Delta Cost$**: Tokens consumed, time elapsed, and compute resources used.
    *   **Goal**: Prevent "agent loops" where resources are consumed without tangible progress.

*   **Global Stability Score**:
    *   **Definition**: A confidence metric derived from the agent's self-evaluation of its plan.
    *   **Thresholds**:
        *   $> 0.8$: Stable, proceed autonomously.
        *   $0.3 - 0.8$: Monitor closely.
        *   $< 0.3$: Unstable, trigger intervention.

### 3.2 Control Protocols (Circuit Breakers)
Deterministic mechanisms to manage stochastic behavior and prevent runaway costs.

*   **Divergence Breaker**: If `global_stability_score` drops below 0.3 for 3 consecutive steps, execution halts.
*   **Cost Breaker**: If `token_usage` exceeds the session budget (e.g., $2.00), the agent enters "Cool Down" mode.
*   **Recursion Breaker**: If `thought_buffer` detects semantic repetition (similarity > 0.9) across 5 steps, the loop is forcibly broken.
*   **Human-in-the-Loop (HITL)**: For "High Stakes" operations (e.g., file deletion, deployment), the agent must suspend execution via `await_user_confirmation` until explicit authorization is received.

---

## 4. Observability & Tool Integration

### 4.1 Target Integration: LangSmith
To reduce debugging complexity for agent architectures, the system is designed to integrate with **LangSmith** (or similar LLM observability platforms).
*   **Run Tree**: Visualizes the semantic components (Retrievers, Tools) of an execution trace.
*   **Prompt Playground**: Allows developers to instantly load a failed trace's prompt configuration, tweak it, and re-run it.
*   **Current Status**: LSO exports are structured to be compatible with LangSmith's trace format, but direct API integration is pending.

### 4.2 Specialized vs. Generalist APM
*   **Generalist APM (Grafana/Datadog)**: Good for latency/errors, but misses semantic drift.
*   **Specialized Monitoring**: Treats "LLM Calls" as first-class citizens, tracking:
    *   **Semantic Drift**: Degradation in reasoning quality.
    *   **Token Usage**: Granular cost tracking per step.

---

## 5. Integration Strategy

These formalisms are implemented across the system stack:

1.  **Orchestrator (`orch`)**: Acts as the **Architect**, using the **Complexity Matrix** to route tasks.
2.  **UltraThink**: Implements the **SCIP Graph** (context), **LSO** (state tracking), and **Circuit Breakers** (control).
3.  **Gemini Delegation**: Implements the **A2A Protocol** for inter-agent communication.
4.  **Logging & Monitoring**: Enhanced to emit **LSO** snapshots.

---

## 6. System Status (as of 2025-11-28)

| Component | Status | Implementation |
| :--- | :--- | :--- |
| **SCIP Graph** | ✅ Active | `ultrathink-v6.1-reliable.mjs` (Context Management) |
| **LSO Schema** | ✅ Active | `ultrathink-lso.mjs` |
| **Circuit Breakers** | ✅ Active | `ultrathink-lso.mjs` (Divergence, Cost, Recursion) |
| **A2A Protocol** | ✅ Active | Implemented in `orch` & `ultrathink-v6.1-reliable.mjs` |
| **LangSmith** | 🚧 In Progress | `exportToLangSmithRunTree()` added to LSO |
| **Marginal Utility** | ✅ Active | `efficiency_metric` in LSO |
