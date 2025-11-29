# Live State Object (LSO)

The **Live State Object (LSO)** schema captures critical data points related to the planning trajectory, facilitating forensic debugging.

## Overview

To make the autonomous planning system auditable and debuggable, its internal state must be captured in a structured format. The LSO serves as this structured record.

## Key Components

Based on the requirements for forensic debugging and planning trajectory analysis, the LSO should include:

### 1. Planning Trajectory
- **Step-by-step execution path**: A chronological record of decisions made by the planner.
- **Decision rationale**: The reasoning behind each step.
- **Alternative paths considered**: Options that were evaluated but rejected.

### 2. State Snapshots
- **Pre-action state**: The system state before an action was taken.
- **Post-action state**: The system state after an action was completed.
- **Diffs**: Explicit changes to the environment or context.

### 3. Metadata
- **Timestamp**: Precise timing of each event.
- **Agent ID**: Identity of the agent performing the action.
- **Task ID**: Correlation with the high-level objective.

## Schema Definition (Proposed)

```json
{
  "lsoId": "string",
  "sessionId": "string",
  "timestamp": "ISO-8601",
  "agentId": "string",
  "taskId": "string",
  "trajectory": [
    {
      "stepId": "integer",
      "timestamp": "ISO-8601",
      "phase": "string",
      "action": "string",
      "rationale": "string",
      "stateSnapshot": {
        "pre": {},
        "post": {},
        "diffs": {}
      },
      "status": "pending|running|completed|failed"
    }
  ],
  "metrics": {
    "globalStabilityScore": "float",
    "confidenceLevel": "float",
    "efficiency": "float",
    "modelUncertainty": {
      "entropy": "float",
      "variance": "float",
      "convergenceRate": "float"
    }
  },
  "mountedTools": [
    {
      "name": "string",
      "uri": "string",
      "loadedAt": "integer",
      "costMetric": "float"
    }
  ],
  "thoughtBuffer": [
    {
      "stepId": "integer",
      "timestamp": "ISO-8601",
      "content": "string",
      "reasoningType": "string",
      "confidenceScore": "float"
    }
  ],
  "status": "idle|planning|executing|waiting|error|converged",
  "scipSnapshot": {
    "nodes": [],
    "edges": []
  }
}
```

## Integration

The LSO is designed to integrate with observability tools to provide real-time insights into the agent's behavior.
