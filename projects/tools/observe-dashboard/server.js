const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3004;

app.use(express.static('public'));
app.use(bodyParser.json());

// Path to the live state file
// We expect orch to write to public/live_state.json
const STATE_FILE = path.join(__dirname, 'public', 'live_state.json');

app.get('/api/state', (req, res) => {
    if (fs.existsSync(STATE_FILE)) {
        res.header('Cache-Control', 'no-cache, no-store, must-revalidate');
        fs.createReadStream(STATE_FILE).pipe(res);
    } else {
        res.json({ nodes: [], edges: [], metrics: {}, history: [] });
    }
});

const HISTORY_FILE = path.join(process.env.HOME, 'orch_history.json');
const TELEMETRY_FILE = path.join(process.env.HOME, 'orch_telemetry.json');

app.get('/api/persistent-history', (req, res) => {
    if (fs.existsSync(HISTORY_FILE)) {
        res.header('Cache-Control', 'no-cache, no-store, must-revalidate');
        fs.createReadStream(HISTORY_FILE).pipe(res);
    } else {
        res.json([]);
    }
});

app.get('/api/telemetry', (req, res) => {
    if (fs.existsSync(TELEMETRY_FILE)) {
        res.header('Cache-Control', 'no-cache, no-store, must-revalidate');
        fs.createReadStream(TELEMETRY_FILE).pipe(res);
    } else {
        res.json({ traces: [] });
    }
});

app.post('/api/command', (req, res) => {
    const { command, type = 'orch' } = req.body;
    if (!command) return res.status(400).json({ error: 'Command required' });

    console.log(`[Command] Type: ${type}, Executing: ${command}`);

    const { spawn } = require('child_process');
    const workspaceRoot = path.resolve(__dirname, '../../..');

    let cmd, args;

    if (type === 'bash') {
        cmd = 'bash';
        args = ['-c', command];
    } else {
        // Default to Orchestrator
        cmd = 'node';
        args = ['scripts/orch', command];
    }

    console.log(`[Command] Spawning: ${cmd} ${args.join(' ')}`);

    const child = spawn(cmd, args, {
        cwd: workspaceRoot,
        stdio: 'ignore',
        detached: true
    });

    child.unref();

    return res.json({ status: 'started', message: `Command dispatched (${type})` });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🔭 Observe Dashboard running at http://0.0.0.0:${PORT}`);
});
