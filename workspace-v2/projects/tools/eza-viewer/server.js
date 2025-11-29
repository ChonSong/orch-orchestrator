const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const { spawn, exec } = require('child_process');
const path = require('path');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

const PORT = 3003;

// Serve static HTML file
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Server-Sent Events endpoint
app.get('/events', (req, res) => {
    res.writeHead(200, {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'Access-Control-Allow-Origin': '*'
    });

    const runEza = () => {
        exec("tree -C -L 2 -I 'node_modules|.git|proc|sys|dev|run|tmp|mnt|media|lost+found' /home/seanos1a", {
            maxBuffer: 1024 * 1024 * 50,
            timeout: 10000,
            env: { ...process.env, TERM: 'xterm-256color', COLUMNS: '80' }
        }, (error, stdout, stderr) => {
            if (error) {
                console.error(`Eza error: ${error.message}`);
                return;
            }
            if (stderr) {
                console.error(`Eza stderr: ${stderr}`);
            }
            const htmlOutput = ansiToHtml(stdout);
            res.write(`data: ${JSON.stringify({ output: htmlOutput, timestamp: Date.now() })}\n\n`);
        });
    };

    // Run immediately
    runEza();

    // Run every 1 second
    const intervalId = setInterval(runEza, 1000);

    // Clean up on client disconnect
    req.on('close', () => {
        clearInterval(intervalId);
    });
});

// WebSocket endpoint for real-time updates
io.on('connection', (socket) => {
    console.log('Client connected');

    const runEza = () => {
        console.log('Running tree via exec...');
        exec("tree -C -L 2 -I 'node_modules|.git|proc|sys|dev|run|tmp|mnt|media|lost+found' /home/seanos1a", {
            maxBuffer: 1024 * 1024 * 50,
            timeout: 10000,
            env: { ...process.env, TERM: 'xterm-256color', COLUMNS: '80' }
        }, (error, stdout, stderr) => {
            console.log('tree exec callback');
            if (error) {
                console.error(`Eza error: ${error.message}`);
                return;
            }
            if (stderr) {
                console.error(`Eza stderr: ${stderr}`);
            }
            console.log(`Eza output length: ${stdout.length}`);
            socket.emit('tree-update', {
                output: stdout,
                htmlOutput: ansiToHtml(stdout),
                timestamp: Date.now()
            });
        });
    };

    // Run immediately
    runEza();

    // Run every 2 seconds
    const intervalId = setInterval(runEza, 2000);

    socket.on('disconnect', () => {
        console.log('Client disconnected');
        clearInterval(intervalId);
    });
});

// Basic ANSI to HTML conversion (handles colors and formatting)
function ansiToHtml(text) {
    let html = text
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/\x1b\[31m/g, '<span style="color: #ff5555;">')  // Red
        .replace(/\x1b\[32m/g, '<span style="color: #50fa7b;">')  // Green
        .replace(/\x1b\[33m/g, '<span style="color: #f1fa8c;">')  // Yellow
        .replace(/\x1b\[34m/g, '<span style="color: #8be9fd;">')  // Blue
        .replace(/\x1b\[35m/g, '<span style="color: #bd93f9;">')  // Magenta
        .replace(/\x1b\[36m/g, '<span style="color: #8be9fd;">')  // Cyan
        .replace(/\x1b\[37m/g, '<span style="color: #f8f8f2;">')  // White
        .replace(/\x1b\[90m/g, '<span style="color: #6272a4;">')  // Gray
        .replace(/\x1b\[0m/g, '</span>')
        .replace(/\x1b\[1m/g, '<strong>')  // Bold
        .replace(/\x1b\[22m/g, '</strong>') // Reset bold
        .replace(/\x1b\[3m/g, '<em>')      // Italic
        .replace(/\x1b\[23m/g, '</em>')     // Reset italic
        .replace(/\x1b\[4m/g, '<u>')        // Underline
        .replace(/\x1b\[24m/g, '</u>');     // Reset underline

    // Convert newlines to <br>
    html = html.replace(/\n/g, '<br>');

    return html;
}

server.listen(PORT, () => {
    console.log(`EZA Tree Viewer server running on port ${PORT}`);
    console.log(`Access at: http://eza.codeovertcp.com`);
});