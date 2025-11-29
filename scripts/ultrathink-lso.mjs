/**
 * Live State Object (LSO) Implementation
 * 
 * runtime implementation of the LSO schema defined in ultrathink-lso-schema.ts.
 */

/**
 * Live State Object (LSO) Implementation
 * 
 * runtime implementation of the LSO schema defined in ultrathink-lso-schema.ts.
 */

import fs from 'fs/promises';
import path from 'path';

export class LiveStateObject {
    constructor(sessionId, task) {
        this.data = {
            lsoId: `lso-${Date.now()}`,
            sessionId: sessionId || `session-${Date.now()}`,
            timestamp: new Date().toISOString(),
            agentId: 'ultrathink-v6.1',
            taskId: sessionId, // Using sessionId as taskId for now
            trajectory: [],
            metrics: {
                globalStabilityScore: 1.0,
                confidenceLevel: 1.0,
                efficiency: 0,
                modelUncertainty: {
                    entropy: 0,
                    variance: 0,
                    convergenceRate: 0
                },
                tokenUsage: 0,
                consecutiveLowStability: 0
            },
            mountedTools: [],
            thoughtBuffer: [],
            status: 'idle',
            circuitBreakerState: {
                status: 'HEALTHY',
                trippedBreaker: null,
                trippedAt: null,
                reason: null
            },
            scipSnapshot: {
                nodes: [],
                edges: []
            }
        };
        this.lsoFile = path.join(process.cwd(), 'orch_lso.json');
    }

    /**
     * Updates the LSO with a new trajectory step.
     * @param {string} phase - Current phase (analysis, planning, etc.)
     * @param {string} action - Action taken
     * @param {string} rationale - Reasoning behind the action
     * @param {Object} stateSnapshot - { pre: {}, post: {}, diffs: {} }
     */
    async update(phase, action, rationale, stateSnapshot = { pre: {}, post: {} }) {
        this.data.timestamp = new Date().toISOString();

        // Only update status if not halted
        if (this.data.status !== 'HALTED') {
            this.data.status = 'executing';
        }

        const step = {
            stepId: this.data.trajectory.length + 1,
            timestamp: new Date().toISOString(),
            phase: phase,
            action: action,
            rationale: rationale,
            stateSnapshot: stateSnapshot,
            status: 'completed'
        };

        this.data.trajectory.push(step);

        // Populate thought_buffer for epistemological access
        this.data.thoughtBuffer.push({
            stepId: this.data.trajectory.length,
            timestamp: new Date().toISOString(),
            content: rationale,
            reasoningType: phase,
            confidenceScore: this.data.metrics.confidenceLevel
        });

        // Check circuit breakers after update
        const breakerStatus = this.checkCircuitBreakers();
        if (breakerStatus.status === 'TRIPPED') {
            console.warn(`[LSO] ⚠️ CIRCUIT BREAKER TRIPPED: ${breakerStatus.trippedBreaker} - ${breakerStatus.reason}`);
        }

        await this.save();
    }

    /**
     * Checks circuit breakers and returns status.
     * @param {number} currentTokenUsage - Current total token usage
     * @returns {Object} { status: 'HEALTHY' | 'TRIPPED', reason: string }
     */
    checkCircuitBreakers(currentTokenUsage = 0) {
        if (currentTokenUsage > 0) {
            this.data.metrics.tokenUsage = currentTokenUsage;
        }

        // 1. Divergence Breaker
        if (this.data.metrics.globalStabilityScore < 0.3) {
            this.data.metrics.consecutiveLowStability++;
        } else {
            this.data.metrics.consecutiveLowStability = 0;
        }

        if (this.data.metrics.consecutiveLowStability >= 3) {
            return this.tripBreaker('DIVERGENCE_BREAKER', 'Global stability score < 0.3 for 3 consecutive steps');
        }

        // 2. Cost Breaker (Limit: 100k tokens approx $0.20-$1.00 depending on model)
        const TOKEN_LIMIT = 100000;
        if (this.data.metrics.tokenUsage > TOKEN_LIMIT) {
            return this.tripBreaker('COST_BREAKER', `Token usage ${this.data.metrics.tokenUsage} exceeded limit ${TOKEN_LIMIT}`);
        }

        // 3. Recursion Breaker
        if (this.detectRecursion()) {
            return this.tripBreaker('RECURSION_BREAKER', 'Semantic repetition detected across last 5 steps');
        }

        return { status: 'HEALTHY' };
    }

    tripBreaker(name, reason) {
        this.data.circuitBreakerState = {
            status: 'TRIPPED',
            trippedBreaker: name,
            trippedAt: new Date().toISOString(),
            reason: reason
        };
        this.data.status = 'HALTED';
        return this.data.circuitBreakerState;
    }

    detectRecursion() {
        const buffer = this.data.thoughtBuffer;
        if (buffer.length < 5) return false;

        const last5 = buffer.slice(-5);
        const current = last5[last5.length - 1].content;

        // Check if the current thought is significantly similar to at least 3 of the previous 4 thoughts
        // This implies we are stuck in a loop saying the same thing
        let similarCount = 0;
        for (let i = 0; i < 4; i++) {
            const prev = last5[i].content;
            if (this.calculateSimilarity(current, prev) > 0.9) {
                similarCount++;
            }
        }

        return similarCount >= 3;
    }

    calculateSimilarity(s1, s2) {
        if (!s1 || !s2) return 0;
        const set1 = new Set(s1.toLowerCase().split(/\s+/));
        const set2 = new Set(s2.toLowerCase().split(/\s+/));
        const intersection = new Set([...set1].filter(x => set2.has(x)));
        const union = new Set([...set1, ...set2]);
        return union.size === 0 ? 0 : intersection.size / union.size;
    }

    /**
     * Updates metrics.
     * @param {Object} metrics - Partial metrics object
     */
    async updateMetrics(metrics) {
        this.data.metrics = { ...this.data.metrics, ...metrics };
        // Check breakers on metric update too
        this.checkCircuitBreakers();
        await this.save();
    }

    /**
     * Logs a dynamically mounted tool.
     * @param {string} name - Tool name
     * @param {string} uri - Tool URI
     * @param {number} cost - Estimated cost metric
     */
    async mountTool(name, uri, cost = 0) {
        this.data.mountedTools.push({
            name,
            uri,
            loadedAt: Date.now(),
            costMetric: cost
        });
        await this.save();
    }

    /**
     * Updates the SCIP snapshot.
     * @param {Object} snapshot - { nodes: [], edges: [] }
     */
    async updateScip(snapshot) {
        this.data.scipSnapshot = snapshot;
        await this.save();
    }

    /**
     * Saves the LSO to disk.
     */
    async save() {
        try {
            await fs.writeFile(this.lsoFile, JSON.stringify(this.data, null, 2), 'utf8');

            // Also write to dashboard
            const dashboardPath = path.join(process.cwd(), 'projects/tools/observe-dashboard/public/live_state.json');
            try {
                await fs.mkdir(path.dirname(dashboardPath), { recursive: true });
                await fs.writeFile(dashboardPath, JSON.stringify(this.data, null, 2), 'utf8');
            } catch (e) {
                // Ignore dashboard write errors
            }
        } catch (error) {
            // Fail silently to not disrupt execution
            // console.error('Failed to save LSO:', error);
        }
    }

    /**
     * Returns the full state object.
     */
    getState() {
        return this.data;
    }

    /**
     * Helper to get the latest step.
     */
    getLatestStep() {
        if (this.data.trajectory.length === 0) return null;
        return this.data.trajectory[this.data.trajectory.length - 1];
    }

    /**
     * Exports the current LSO state to a LangSmith-compatible RunTree structure.
     * This allows for future direct API integration.
     * @returns {Object} RunTree compatible object
     */
    exportToLangSmithRunTree() {
        const rootRun = {
            id: this.data.sessionId,
            name: "UltraThink Execution",
            run_type: "chain",
            start_time: this.data.timestamp,
            inputs: { task: this.data.taskId }, // Assuming taskId is the initial prompt/task
            outputs: this.data.status === 'completed' ? { result: "Success" } : null,
            extra: {
                metadata: {
                    agent: this.data.agentId,
                    lso_id: this.data.lsoId,
                    global_stability_score: this.data.metrics.globalStabilityScore,
                    efficiency: this.data.metrics.efficiency
                }
            },
            child_runs: this.data.trajectory.map(step => ({
                id: `step-${step.stepId}`,
                name: `Step ${step.stepId}: ${step.phase}`,
                run_type: "tool",
                start_time: step.timestamp,
                end_time: step.timestamp, // In a real trace, we'd have duration
                inputs: {
                    action: step.action,
                    rationale: step.rationale
                },
                outputs: step.stateSnapshot,
                extra: {
                    metadata: {
                        phase: step.phase,
                        confidence: this.data.metrics.confidenceLevel
                    }
                }
            }))
        };
        return rootRun;
    }
}
