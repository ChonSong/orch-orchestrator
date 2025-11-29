#!/usr/bin/env node

/**
 * UltraThink v6.1 Log Viewer
 * =========================
 *
 * A utility to view and analyze UltraThink v6.1 log files.
 * Provides readable summaries and filtering options.
 */

import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

class UltraThinkLogViewer {
  constructor() {
    this.logDir = path.join(__dirname, 'logs');
  }

  async getAvailableLogs() {
    try {
      const files = await fs.readdir(this.logDir);
      return files
        .filter(file => file.startsWith('ultrathink-') && file.endsWith('.log'))
        .sort()
        .reverse(); // Most recent first
    } catch (error) {
      console.error('No logs directory found:', error.message);
      return [];
    }
  }

  async readLogFile(filename) {
    try {
      const content = await fs.readFile(path.join(this.logDir, filename), 'utf8');
      return content.split('\n')
        .filter(line => line.trim())
        .map(line => JSON.parse(line));
    } catch (error) {
      console.error(`Failed to read log file ${filename}:`, error.message);
      return [];
    }
  }

  async displaySummary(filename) {
    const logs = await this.readLogFile(filename);

    console.log(`\n📋 UltraThink Log Summary: ${filename}`);
    console.log('=' .repeat(60));

    if (logs.length === 0) {
      console.log('No log entries found.');
      return;
    }

    // Get unique sessions
    const sessions = {};
    const sessionStats = {};

    logs.forEach(log => {
      const sessionId = log.sessionId;

      if (!sessions[sessionId]) {
        sessions[sessionId] = [];
        sessionStats[sessionId] = {
          startTime: null,
          endTime: null,
          duration: 0,
          filesCreated: [],
          featuresUsed: [],
          taskTypes: [],
          success: null
        };
      }

      sessions[sessionId].push(log);

      // Update session stats
      switch (log.level) {
        case 'SESSION_START':
          sessionStats[sessionId].startTime = log.data.startTime;
          break;
        case 'SESSION_END':
          sessionStats[sessionId].endTime = log.data.endTime;
          sessionStats[sessionId].duration = log.data.duration;
          break;
        case 'TASK_START':
          sessionStats[sessionId].taskTypes.push(log.data.taskType);
          break;
        case 'TASK_COMPLETE':
          sessionStats[sessionId].success = log.data.success;
          break;
        case 'FILE_OPERATION':
          if (log.data.operation === 'create' && log.data.result && log.data.result.created) {
            sessionStats[sessionId].filesCreated.push({
              fileName: log.data.fileName,
              size: log.data.fileSize,
              timestamp: log.timestamp
            });
          }
          break;
        case 'FEATURE_USED':
          sessionStats[sessionId].featuresUsed.push(log.data.feature);
          break;
      }
    });

    // Display session summaries
    Object.entries(sessionStats).forEach(([sessionId, stats], index) => {
      console.log(`\n🆔 Session ${index + 1}: ${sessionId}`);
      console.log(`📅 Start: ${stats.startTime || 'Unknown'}`);
      console.log(`⏱️ Duration: ${stats.duration}ms`);
      console.log(`✅ Success: ${stats.success ? 'Yes' : 'No'}`);

      if (stats.taskTypes.length > 0) {
        const uniqueTaskTypes = [...new Set(stats.taskTypes)];
        console.log(`🎯 Task Types: ${uniqueTaskTypes.join(', ')}`);
      }

      if (stats.filesCreated.length > 0) {
        const totalSize = stats.filesCreated.reduce((sum, file) => sum + (file.size || 0), 0);
        console.log(`📁 Files Created: ${stats.filesCreated.length} (${totalSize} bytes)`);
        stats.filesCreated.forEach(file => {
          console.log(`   - ${file.fileName} (${file.size} bytes)`);
        });
      }

      if (stats.featuresUsed.length > 0) {
        const uniqueFeatures = [...new Set(stats.featuresUsed)];
        console.log(`🔧 Features Used: ${uniqueFeatures.join(', ')}`);
      }
    });

    // Overall statistics
    const totalSessions = Object.keys(sessionStats).length;
    const successfulSessions = Object.values(sessionStats).filter(s => s.success).length;
    const totalFiles = Object.values(sessionStats).reduce((sum, s) => sum + s.filesCreated.length, 0);
    const totalSize = Object.values(sessionStats)
      .reduce((sum, s) => sum + s.filesCreated.reduce((innerSum, f) => innerSum + (f.size || 0), 0), 0);

    console.log(`\n📊 Overall Statistics:`);
    console.log(`Total Sessions: ${totalSessions}`);
    console.log(`Successful Sessions: ${successfulSessions} (${((successfulSessions/totalSessions)*100).toFixed(1)}%)`);
    console.log(`Total Files Created: ${totalFiles}`);
    console.log(`Total Size Created: ${totalSize} bytes`);

    console.log('\n' + '=' .repeat(60));
  }

  async displayDetails(filename, sessionId = null, level = null) {
    const logs = await this.readLogFile(filename);

    let filteredLogs = logs;

    if (sessionId) {
      filteredLogs = logs.filter(log => log.sessionId === sessionId);
    }

    if (level) {
      filteredLogs = filteredLogs.filter(log => log.level === level);
    }

    console.log(`\n📋 UltraThink Log Details: ${filename}`);
    if (sessionId) console.log(`🆔 Session: ${sessionId}`);
    if (level) console.log(`🏷️ Level: ${level}`);
    console.log('=' .repeat(80));

    filteredLogs.forEach(log => {
      const time = new Date(log.timestamp).toLocaleTimeString();
      const phase = log.phase ? `[${log.phase}]` : '';
      console.log(`${time} ${phase} ${log.level}: ${JSON.stringify(log.data, null, 2)}`);
      console.log('');
    });
  }

  async displayFileOperations(filename) {
    const logs = await this.readLogFile(filename);

    const fileOps = logs.filter(log => log.level === 'FILE_OPERATION');

    console.log(`\n📁 File Operations: ${filename}`);
    console.log('=' .repeat(80));

    fileOps.forEach(log => {
      const time = new Date(log.timestamp).toLocaleTimeString();
      const status = log.data.result && log.data.result.created ? '✅' : (log.data.error ? '❌' : '🔄');
      const size = log.data.fileSize ? ` (${log.data.fileSize} bytes)` : '';
      const operation = log.data.operation || 'unknown';

      console.log(`${time} ${status} ${operation.toUpperCase()}: ${log.data.fileName}${size}`);

      if (log.data.error) {
        console.log(`   Error: ${log.data.error}`);
      }
    });

    console.log('\n' + '=' .repeat(80));
  }

  async searchLogs(filename, searchTerm) {
    const logs = await this.readLogFile(filename);

    const matches = logs.filter(log => {
      const searchText = JSON.stringify(log).toLowerCase();
      return searchText.includes(searchTerm.toLowerCase());
    });

    console.log(`\n🔍 Search Results for "${searchTerm}" in ${filename}:`);
    console.log(`Found ${matches.length} matches`);
    console.log('=' .repeat(80));

    matches.forEach(log => {
      const time = new Date(log.timestamp).toLocaleTimeString();
      console.log(`${time} [${log.level}] ${JSON.stringify(log.data, null, 2)}`);
      console.log('');
    });
  }
}

// Command line interface
async function main() {
  const args = process.argv.slice(2);
  const viewer = new UltraThinkLogViewer();

  if (args.length === 0) {
    const logs = await viewer.getAvailableLogs();

    if (logs.length === 0) {
      console.log('No UltraThink log files found.');
      console.log('Run UltraThink v6.1 to generate logs first.');
      process.exit(1);
    }

    console.log('📋 Available UltraThink Log Files:');
    logs.forEach((log, index) => {
      console.log(`${index + 1}. ${log}`);
    });

    console.log('\nUsage:');
    console.log('  node ULTRATHINK_LOG_VIEWER.mjs <filename> [options]');
    console.log('');
    console.log('Options:');
    console.log('  --summary            Show session summary (default)');
    console.log('  --details            Show detailed log entries');
    console.log('  --files              Show file operations only');
    console.log('  --session <id>       Filter by session ID');
    console.log('  --level <level>      Filter by log level');
    console.log('  --search <term>      Search for term in logs');
    console.log('');
    console.log('Examples:');
    console.log('  node ULTRATHINK_LOG_VIEWER.mjs ultrathink-2025-11-25.log');
    console.log('  node ULTRATHINK_LOG_VIEWER.mjs ultrathink-2025-11-25.log --details');
    console.log('  node ULTRATHINK_LOG_VIEWER.mjs ultrathink-2025-11-25.log --files');
    console.log('  node ULTRATHINK_LOG_VIEWER.mjs ultrathink-2025-11-25.log --search "create"');

    process.exit(0);
  }

  const filename = args[0];

  // Parse options properly
  let options = {
    summary: !args.includes('--details') && !args.includes('--files') && !args.includes('--search'),
    details: args.includes('--details'),
    files: args.includes('--files'),
    session: null,
    level: null,
    search: null
  };

  // Extract option values
  const sessionIndex = args.indexOf('--session');
  if (sessionIndex !== -1 && args.length > sessionIndex + 1) {
    options.session = args[sessionIndex + 1];
  }

  const levelIndex = args.indexOf('--level');
  if (levelIndex !== -1 && args.length > levelIndex + 1) {
    options.level = args[levelIndex + 1];
  }

  const searchIndex = args.indexOf('--search');
  if (searchIndex !== -1 && args.length > searchIndex + 1) {
    options.search = args[searchIndex + 1];
  }

  if (!filename) {
    console.error('Error: Log filename required');
    process.exit(1);
  }

  if (options.search) {
    await viewer.searchLogs(filename, options.search);
  } else if (options.files) {
    await viewer.displayFileOperations(filename);
  } else if (options.details) {
    await viewer.displayDetails(filename, options.session, options.level);
  } else {
    await viewer.displaySummary(filename);
  }
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(console.error);
}

// Export for use as module
export { UltraThinkLogViewer };