/**
 * Live State Object (LSO) Schema
 * 
 * This file defines the rigorous schema for capturing the internal state of the 
 * autonomous planning system. It ensures auditability, debuggability, and 
 * real-time control.
 */

// ==================== CORE LSO SCHEMA ====================

export interface LiveStateObject {
    /**
     * Unique identifier for the Live State Object.
     */
    lsoId: string;

    /**
     * Unique identifier for the planning session.
     */
    sessionId: string;

    /**
     * Timestamp when the session started (ISO-8601).
     */
    timestamp: string;

    /**
     * Identity of the agent performing the action.
     */
    agentId: string;

    /**
     * The high-level objective or task.
     */
    taskId: string;

    /**
     * Chronological record of decisions and actions.
     */
    trajectory: TrajectoryStep[];

    /**
     * Real-time metric for the convergence of the agent's reasoning process.
     * Range: 0.0 to 1.0
     */
    metrics: LSOMetrics;

    /**
     * Array of Model Context Protocol (MCP) servers dynamically loaded.
     */
    mountedTools: MountedTool[];

    /**
     * Internal reasoning steps and intermediate thoughts (Epistemological Access).
     */
    thoughtBuffer: ThoughtStep[];

    /**
     * Current status of the agent.
     */
    status: AgentStatus;

    /**
     * Snapshot of the SCIP graph state.
     */
    scipSnapshot?: ScipSnapshot;
}

// ==================== SUB-SCHEMAS ====================

export interface TrajectoryStep {
    stepId: number;
    timestamp: string;
    phase: string; // e.g., 'analysis', 'planning', 'execution', 'verification'
    action: string;
    rationale: string;
    stateSnapshot: StateSnapshot;
    status: 'pending' | 'running' | 'completed' | 'failed';
    error?: string;
}

export interface StateSnapshot {
    pre: Record<string, any>;
    post: Record<string, any>;
    diffs?: Record<string, any>;
}

export interface LSOMetrics {
    globalStabilityScore: number;
    confidenceLevel: number;
    efficiency?: number;
    modelUncertainty?: ModelUncertaintyMetrics;
}

export interface MountedTool {
    name: string;
    uri: string;
    loadedAt: number;
    costMetric: number; // Estimated cost impact
}

export interface ThoughtStep {
    stepId: number;
    timestamp: string;
    content: string;
    reasoningType: 'deduction' | 'induction' | 'abduction' | 'planning' | 'analysis' | 'execution' | 'verification';
    confidenceScore: number;
}

export type AgentStatus = 'idle' | 'planning' | 'executing' | 'waiting' | 'error' | 'converged';

export interface ModelUncertaintyMetrics {
    entropy: number;
    variance: number;
    convergenceRate: number;
}

export interface ScipSnapshot {
    nodes: any[];
    edges: any[];
}

// ==================== OBSERVABILITY INTEGRATION ====================

export interface ObservabilityConfig {
    langSmithEnabled: boolean;
    apmEndpoint?: string;
    logLevel: 'debug' | 'info' | 'warn' | 'error';
}
