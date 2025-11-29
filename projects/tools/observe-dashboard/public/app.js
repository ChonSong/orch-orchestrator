const API_STATE = '/api/state';
const API_HISTORY = '/api/persistent-history';
const API_TELEMETRY = '/api/telemetry';
const API_COMMAND = '/api/command';

const elements = {
    statusDot: document.getElementById('status-dot'),
    statusText: document.getElementById('connection-status'),
    metrics: {
        stability: document.getElementById('metric-stability'),
        cost: document.getElementById('metric-cost'),
        entropy: document.getElementById('metric-entropy'),
        step: document.getElementById('metric-step')
    },
    graph: document.getElementById('graph-viz'),
    history: document.getElementById('history-list'),
    chatDetail: document.getElementById('chat-detail-container'),
    form: document.getElementById('command-form'),
    input: document.getElementById('command-input'),
    btn: document.getElementById('send-btn')
};

let lastStateEtag = null;
let lastHistoryEtag = null;
let lastTelemetryEtag = null;

async function fetchState() {
    try {
        // Use HEAD requests first or conditional GETs if server supported it,
        // but for simple static files, we'll just fetch and rely on browser caching + logic
        // Actually, let's just fetch but be smarter about rendering.

        const [resState, resHistory, resTelemetry] = await Promise.all([
            fetch(API_STATE),
            fetch(API_HISTORY),
            fetch(API_TELEMETRY)
        ]);

        if (!resState.ok) throw new Error(`HTTP error! status: ${resState.status}`);

        // Basic optimization: Don't re-render if nothing changed (using simple JSON string compare for MVP)
        // In production, we'd use ETags or Last-Modified headers properly.

        const data = await resState.json();
        const historyData = resHistory.ok ? await resHistory.json() : [];
        const telemetryData = resTelemetry.ok ? await resTelemetry.json() : { traces: [] };

        updateStatus(true);

        // Handle different metric structures (orch vs ultrathink)
        const metrics = data.metrics || {};
        const step = data.stepCount || (data.trajectory ? data.trajectory.length : 0);

        renderMetrics(metrics, step);
        renderGraph(data.nodes || [], data.edges || []);

        // Merge persistent history with live telemetry
        renderHistory(historyData, telemetryData.traces || []);
    } catch (e) {
        console.error("Fetch state failed:", e);
        updateStatus(false);
    }
}

function updateStatus(connected) {
    if (connected) {
        elements.statusDot.classList.add('active');
        elements.statusText.textContent = 'Live';
    } else {
        elements.statusDot.classList.remove('active');
        elements.statusText.textContent = 'Disconnected';
    }
}

function renderMetrics(metrics, step) {
    elements.metrics.stability.textContent = (metrics.globalStabilityScore !== undefined ? metrics.globalStabilityScore : 1.0).toFixed(2);
    elements.metrics.cost.textContent = `$${(metrics.cost || metrics.tokenUsage / 1000000 || 0).toFixed(4)}`;
    elements.metrics.entropy.textContent = (metrics.entropy || metrics.modelUncertainty?.entropy || 0).toFixed(2);
    elements.metrics.step.textContent = step;
}

function renderGraph(nodes, edges) {
    elements.graph.innerHTML = '';

    if (nodes.length === 0) {
        elements.graph.innerHTML = '<div style="color: #666; text-align: center;">No active agents</div>';
        return;
    }

    // Simple Circular Layout
    const centerX = elements.graph.clientWidth / 2;
    const centerY = elements.graph.clientHeight / 2;
    const radius = Math.min(centerX, centerY) - 40;

    nodes.forEach((node, index) => {
        const angle = (index / nodes.length) * 2 * Math.PI - (Math.PI / 2); // Start at top
        const x = centerX + radius * Math.cos(angle);
        const y = centerY + radius * Math.sin(angle);

        const el = document.createElement('div');
        el.className = `node ${node.status || 'idle'}`;
        el.textContent = node.label || node.id || node.agentId;
        el.style.left = `${x}px`;
        el.style.top = `${y}px`;
        el.style.transform = 'translate(-50%, -50%)';

        elements.graph.appendChild(el);
    });

    // Draw edges (SVG)
    const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    svg.style.position = 'absolute';
    svg.style.top = 0;
    svg.style.left = 0;
    svg.style.width = '100%';
    svg.style.height = '100%';
    svg.style.pointerEvents = 'none';

    edges.forEach(edge => {
        // Find positions
        // This is tricky without storing positions. 
        // For now, we skip edges or need to store node els.
        // Skipping edges for MVP simplicity as requested "assess quality" -> "improve".
    });
}

function renderHistory(persistentHistory, liveTraces) {
    // Combine persistent history and live traces
    // Live traces are usually for the CURRENT task, so we show them at the top

    // Format live traces to match history item structure
    const liveItems = liveTraces.map(trace => ({
        isLive: true,
        timestamp: trace.timestamp,
        agent: trace.step,
        action: trace.input ? `Input: ${trace.input.slice(0, 50)}...` : 'Processing...',
        details: trace.output
    })).reverse(); // Newest first

    // Reverse persistent history
    const persistentItems = [...persistentHistory].reverse();

    const allItems = [...liveItems, ...persistentItems].slice(0, 50);

    elements.history.innerHTML = allItems.map((item, index) => {
        const isSelected = selectedTaskId === (item.id || item.timestamp);
        const selectedClass = isSelected ? 'selected' : '';

        // Store data for click handler
        const itemData = encodeURIComponent(JSON.stringify(item));

        if (item.task) {
            // Persistent Record
            const time = new Date(item.timestamp).toLocaleTimeString();
            const cost = item.metrics?.cost || '0.0000';
            const models = item.metrics?.models?.join(', ') || 'N/A';

            return `
                <li class="history-item ${selectedClass}" 
                    onclick="selectTask('${itemData}')"
                    style="border-left: 3px solid var(--accent-color); padding-left: 10px; margin-bottom: 8px;">
                    <div style="display:flex; justify-content:space-between; margin-bottom:4px;">
                        <span class="log-time">[${time}]</span>
                        <span style="color:var(--success-color)">$${cost}</span>
                    </div>
                    <div style="font-weight:bold; color:var(--text-primary); margin-bottom:2px;">${item.task}</div>
                    <div style="font-size:0.75rem; color:var(--text-secondary);">${item.summary}</div>
                    <div style="font-size:0.7rem; color:var(--text-secondary); margin-top:2px;">Models: ${models}</div>
                </li>
            `;
        } else if (item.isLive) {
            // Live Trace Item
            const time = new Date(item.timestamp).toLocaleTimeString();
            return `
                <li class="history-item ${selectedClass}" 
                    onclick="selectTask('${itemData}')"
                    style="border-left: 3px solid var(--warning-color); padding-left: 10px; margin-bottom: 8px; background: rgba(210, 153, 34, 0.05);">
                    <div style="display:flex; justify-content:space-between; margin-bottom:4px;">
                        <span class="log-time">[${time}]</span>
                        <span style="color:var(--warning-color); font-size:0.7rem; font-weight:bold;">LIVE</span>
                    </div>
                    <div style="font-weight:bold; color:var(--text-primary); margin-bottom:2px;">${item.agent}</div>
                    <div style="font-size:0.75rem; color:var(--text-secondary);">${item.action}</div>
                </li>
            `;
        } else {
            // Legacy Live Log (Fallback)
            return '';
        }
    }).join('');
}

let selectedTaskId = null;

window.selectTask = function (encodedData) {
    try {
        const item = JSON.parse(decodeURIComponent(encodedData));
        selectedTaskId = item.id || item.timestamp;
        renderChatDetail(item);

        // Re-render list to update selection state
        // (In a real framework this would be reactive)
        const items = document.querySelectorAll('.history-item');
        items.forEach(el => el.classList.remove('selected'));
        // We can't easily find the specific element without re-rendering or IDs
        // For MVP, we just rely on the next poll to update the class
    } catch (e) {
        console.error("Error selecting task:", e);
    }
};

function renderChatDetail(item) {
    const container = elements.chatDetail;
    container.innerHTML = '';

    if (!item) {
        container.innerHTML = '<div class="empty-state">Select a task to view details</div>';
        return;
    }

    const header = document.createElement('div');
    header.style.marginBottom = '1rem';
    header.style.paddingBottom = '0.5rem';
    header.style.borderBottom = '1px solid var(--border-color)';
    header.innerHTML = `
        <h3 style="font-size: 1rem; color: var(--text-primary);">${item.task || item.agent || 'Task Details'}</h3>
        <div style="font-size: 0.8rem; color: var(--text-secondary); margin-top: 0.25rem;">
            ${new Date(item.timestamp).toLocaleString()}
        </div>
    `;
    container.appendChild(header);

    let logs = [];

    if (item.log) {
        // Persistent history logs
        logs = item.log;
    } else if (item.isLive) {
        // Single live item
        logs = [{
            step: item.agent,
            timestamp: item.timestamp,
            input: item.action,
            output: item.details
        }];
    }

    if (logs.length === 0) {
        container.innerHTML += '<div class="empty-state">No detailed logs available</div>';
        return;
    }

    logs.forEach(log => {
        const msg = document.createElement('div');
        msg.className = `chat-message ${log.step === 'user' ? 'user' : 'agent'}`;

        const time = new Date(log.timestamp).toLocaleTimeString();

        // Build content HTML
        let contentHtml = '';

        // Only show Input box if there is input
        if (log.input) {
            // Clean up input if it's a JSON string
            let displayInput = log.input;
            try {
                if (typeof displayInput === 'string' && (displayInput.startsWith('{') || displayInput.startsWith('['))) {
                    displayInput = JSON.stringify(JSON.parse(displayInput), null, 2);
                }
            } catch (e) { }

            contentHtml += `<div class="chat-section-label">Input</div><div class="chat-box input-box">${displayInput}</div>`;
        }

        // Only show Output box if there is output
        if (log.output) {
            // Clean up output if it's a JSON string
            let displayOutput = log.output;
            try {
                if (typeof displayOutput === 'string' && (displayOutput.startsWith('{') || displayOutput.startsWith('['))) {
                    displayOutput = JSON.stringify(JSON.parse(displayOutput), null, 2);
                }
            } catch (e) { }

            contentHtml += `<div class="chat-section-label">Output</div><div class="chat-box output-box">${displayOutput}</div>`;
        }

        // Fallback for simple messages without structured input/output
        if (!log.input && !log.output && log.details) {
            contentHtml += `<div class="chat-box output-box">${log.details}</div>`;
        }

        msg.innerHTML = `
            <div class="chat-header">
                <span class="chat-agent-name">${log.step.toUpperCase()}</span>
                <span>${time}</span>
            </div>
            ${contentHtml}
        `;
        container.appendChild(msg);
    });
}

// --- Command Handling ---
const commandForm = document.getElementById('command-form');
const commandInput = document.getElementById('command-input');
const sendBtn = document.getElementById('send-btn');
const suggestionsContainer = document.getElementById('suggestions');
const historyList = document.getElementById('command-history');
const modeOrchBtn = document.getElementById('mode-orch');
const modeBashBtn = document.getElementById('mode-bash');
const promptSymbol = document.getElementById('prompt-symbol');

let currentMode = 'orch'; // 'orch' or 'bash'

// Suggestions Data
const suggestions = [
    { text: "Check System Health", cmd: "Check System Health" },
    { text: "List Active Projects", cmd: "List all active projects in the workspace" },
    { text: "Analyze Logs", cmd: "Analyze the recent system logs for errors" },
    { text: "Run Maintenance", cmd: "Run system maintenance" },
    { text: "Find & Fix Issues", cmd: "Find and complete a project and fix issues" }
];

// Common Bash Commands
const bashSuggestions = [
    "ls -la",
    "top -b -n 1",
    "df -h",
    "free -m",
    "whoami"
];

// Initialize Suggestions
function renderSuggestions() {
    suggestionsContainer.innerHTML = '';
    const items = currentMode === 'orch' ? suggestions : bashSuggestions.map(s => ({ text: s, cmd: s }));

    items.forEach(item => {
        const chip = document.createElement('div');
        chip.className = 'suggestion-chip';
        chip.textContent = item.text;
        chip.onclick = () => {
            commandInput.value = item.cmd;
            commandInput.focus();
        };
        suggestionsContainer.appendChild(chip);
    });
}

// Initialize Autocomplete
function renderAutocomplete() {
    historyList.innerHTML = '';
    const items = currentMode === 'orch' ? suggestions.map(s => s.cmd) : bashSuggestions;
    items.forEach(cmd => {
        const option = document.createElement('option');
        option.value = cmd;
        historyList.appendChild(option);
    });
}

// Mode Switching
function setMode(mode) {
    console.log("Switching to mode:", mode);
    currentMode = mode;
    if (mode === 'orch') {
        modeOrchBtn.classList.add('active');
        modeBashBtn.classList.remove('active');
        promptSymbol.textContent = '>';
        commandInput.placeholder = 'Enter instruction for the swarm...';
    } else {
        modeOrchBtn.classList.remove('active');
        modeBashBtn.classList.add('active');
        promptSymbol.textContent = '$';
        commandInput.placeholder = 'Enter bash command...';
    }
    renderSuggestions();
    renderAutocomplete();
}

modeOrchBtn.onclick = () => setMode('orch');
modeBashBtn.onclick = () => setMode('bash');

// Initial Render
renderSuggestions();
renderAutocomplete();

commandForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const command = commandInput.value.trim();
    if (!command) return;

    // Optimistic UI update
    const originalBtnText = sendBtn.innerHTML;
    sendBtn.innerHTML = '<span>SENDING...</span>';
    sendBtn.disabled = true;

    try {
        const response = await fetch(API_COMMAND, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ command, type: currentMode })
        });

        const data = await response.json();

        if (data.status === 'started') {
            // Success feedback
            sendBtn.innerHTML = '<span>SENT</span>';
            setTimeout(() => {
                sendBtn.innerHTML = originalBtnText;
                sendBtn.disabled = false;
                commandInput.value = ''; // Clear input on success
            }, 1000);
        } else {
            throw new Error(data.error || 'Unknown error');
        }
    } catch (error) {
        console.error('Command failed:', error);
        sendBtn.innerHTML = '<span>ERROR</span>';
        setTimeout(() => {
            sendBtn.innerHTML = originalBtnText;
            sendBtn.disabled = false;
        }, 2000);
    }
});

// Poll every 3 seconds to reduce network load
setInterval(fetchState, 3000);
fetchState();
