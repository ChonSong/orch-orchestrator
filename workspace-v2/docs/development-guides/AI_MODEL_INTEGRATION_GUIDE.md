# AI Model Integration Guide
## Using Gemini 3 & Kimik2 Alongside Claude Code

**Last Updated**: 2025-11-23

---

## Overview

This guide sets up a multi-model AI workflow:
- **Claude Sonnet 4.5**: Project management, file operations, git workflows
- **Gemini 3 Pro Preview**: Cutting-edge coding and reasoning tasks
- **Kimik2**: Fast, lightweight tasks requiring speed

---

## Architecture

```
┌─────────────────────────────────────────┐
│     Claude Code (Orchestrator)          │
│  - File operations (Read/Write/Edit)    │
│  - Git workflows                         │
│  - Task management                       │
│  - Project coordination                  │
└──────────────┬──────────────────────────┘
               │
               │ Delegates to:
               │
       ┌───────┴────────┐
       │                │
       ▼                ▼
┌─────────────┐  ┌──────────────┐
│  Gemini 3   │  │   Kimik2     │
│  Pro Preview│  │              │
├─────────────┤  ├──────────────┤
│ - Coding    │  │ - Quick Q&A  │
│ - Reasoning │  │ - Fast tasks │
│ - Complex   │  │ - Simple ops │
│   logic     │  │ - Speed-first│
└─────────────┘  └──────────────┘
```

---

## Setup Instructions

### Step 1: Install Required Dependencies

```bash
# Install Node.js packages for API access
npm install -g @google/generative-ai axios dotenv
```

### Step 2: Set Up API Keys

Create `.env` file in your home directory:

```bash
cat > ~/.ai-keys.env << 'EOF'
# Gemini API Key
GEMINI_API_KEY=your_gemini_api_key_here

# Kimik2 API Key (if different endpoint)
KIMIK2_API_KEY=your_kimik2_api_key_here

# Optional: Custom endpoints
GEMINI_ENDPOINT=https://generativelanguage.googleapis.com/v1beta
KIMIK2_ENDPOINT=https://api.kimik.ai/v1
EOF

chmod 600 ~/.ai-keys.env
```

### Step 3: Create Helper Scripts

#### 3.1 Gemini 3 Helper Script

```bash
cat > ~/bin/gemini3 << 'EOF'
#!/usr/bin/env node

require('dotenv').config({ path: process.env.HOME + '/.ai-keys.env' });
const { GoogleGenerativeAI } = require('@google/generative-ai');
const readline = require('readline');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: 'gemini-3-pro-preview' });

async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    // Interactive mode
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      prompt: 'Gemini> '
    });

    console.log('Gemini 3 Pro Preview - Interactive Mode');
    console.log('Type your question or paste code. Press Ctrl+D to submit.\n');

    let input = '';
    rl.on('line', (line) => {
      input += line + '\n';
    });

    rl.on('close', async () => {
      if (input.trim()) {
        await query(input.trim());
      }
    });

  } else {
    // Single query mode
    const query_text = args.join(' ');
    await query(query_text);
  }
}

async function query(text) {
  try {
    const result = await model.generateContent(text);
    const response = await result.response;
    console.log(response.text());
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();
EOF

chmod +x ~/bin/gemini3
```

#### 3.2 Kimik2 Helper Script

```bash
cat > ~/bin/kimik2 << 'EOF'
#!/usr/bin/env node

require('dotenv').config({ path: process.env.HOME + '/.ai-keys.env' });
const axios = require('axios');

const KIMIK2_ENDPOINT = process.env.KIMIK2_ENDPOINT || 'https://api.kimik.ai/v1';
const KIMIK2_API_KEY = process.env.KIMIK2_API_KEY;

async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.error('Usage: kimik2 "your question here"');
    process.exit(1);
  }

  const query = args.join(' ');

  try {
    const response = await axios.post(
      `${KIMIK2_ENDPOINT}/chat/completions`,
      {
        model: 'kimik2-fast',
        messages: [{ role: 'user', content: query }],
        stream: false
      },
      {
        headers: {
          'Authorization': `Bearer ${KIMIK2_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );

    console.log(response.data.choices[0].message.content);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();
EOF

chmod +x ~/bin/kimik2
```

### Step 4: Create Claude Code Custom Agents

#### 4.1 Gemini Coding Agent

```bash
mkdir -p ~/.claude/agents

cat > ~/.claude/agents/gemini-coder.md << 'EOF'
---
name: gemini-coder
description: Use Gemini 3 Pro Preview for cutting-edge coding and reasoning tasks
model: haiku
---

You are a delegation agent that routes coding tasks to Gemini 3 Pro Preview.

When invoked, you should:
1. Take the user's coding request
2. Call the gemini3 helper script via Bash tool
3. Return the response to the user

Use this command pattern:
```bash
gemini3 "User's coding question or task here"
```

For complex multi-file operations:
1. Get the solution from Gemini 3
2. Use Claude's file tools (Read/Write/Edit) to implement the changes
3. Report back to the user

Remember: Gemini 3 is best for:
- Complex coding problems
- Advanced reasoning tasks
- Cutting-edge algorithm design
- Performance optimization
EOF
```

#### 4.2 Kimik2 Speed Agent

```bash
cat > ~/.claude/agents/kimik-fast.md << 'EOF'
---
name: kimik-fast
description: Use Kimik2 for quick, speed-focused tasks
model: haiku
---

You are a delegation agent that routes quick tasks to Kimik2.

When invoked, you should:
1. Take the user's quick question
2. Call the kimik2 helper script via Bash tool
3. Return the response immediately

Use this command pattern:
```bash
kimik2 "Quick question here"
```

Kimik2 is best for:
- Simple questions requiring fast answers
- Quick code snippets
- Syntax checks
- Brief explanations
- Rapid prototyping ideas
EOF
```

### Step 5: Add Bash Aliases

```bash
cat >> ~/.bashrc << 'EOF'

# AI Model Shortcuts
alias g3='gemini3'
alias k2='kimik2'
alias ai-gemini='claude --agent gemini-coder'
alias ai-kimik='claude --agent kimik-fast'
EOF

source ~/.bashrc
```

---

## Usage Guide

### Direct CLI Usage

**Gemini 3 - Single Query:**
```bash
gemini3 "Write a binary search tree implementation in TypeScript"
```

**Gemini 3 - Interactive Mode:**
```bash
gemini3
# Paste your code or question, then Ctrl+D to submit
```

**Kimik2 - Quick Query:**
```bash
kimik2 "What's the time complexity of merge sort?"
```

### Claude Code Integration

**Using @-mention:**
```bash
# In Claude Code session
@gemini-coder help me optimize this database query
@kimik-fast what's the syntax for Python list comprehension
```

**Using Slash Commands:**
Create custom commands in `~/.claude/commands/`:

```bash
cat > ~/.claude/commands/gemini.md << 'EOF'
---
description: Ask Gemini 3 for coding help
---
@gemini-coder {{args}}
EOF

cat > ~/.claude/commands/quick.md << 'EOF'
---
description: Quick answer with Kimik2
---
@kimik-fast {{args}}
EOF
```

Then use:
```bash
/gemini how do I implement OAuth2 flow?
/quick what's the difference between let and const?
```

---

## When to Use Each Model

### Use Claude Code (Sonnet 4.5) For:
✅ File operations (Read/Write/Edit)
✅ Git workflows and commits
✅ Multi-step project coordination
✅ Task management (TodoWrite)
✅ Codebase exploration
✅ Production deployments

### Use Gemini 3 Pro Preview For:
✅ Complex coding problems
✅ Advanced reasoning tasks
✅ Cutting-edge algorithm design
✅ Mathematical computations
✅ Performance optimization
✅ Research and exploration

### Use Kimik2 For:
✅ Quick syntax questions
✅ Simple code snippets
✅ Fast lookups
✅ Brief explanations
✅ Rapid idea validation
✅ Speed-critical tasks

---

## Workflow Examples

### Example 1: Complex Feature Development

```bash
# 1. Plan with Claude
claude
> Create a todo list for implementing user authentication

# 2. Get cutting-edge implementation from Gemini
@gemini-coder Design a secure OAuth2 + JWT authentication flow with refresh tokens

# 3. Claude implements the files
> Based on Gemini's design, implement this in our codebase

# 4. Quick questions with Kimik2
@kimik-fast What HTTP status code for expired tokens?

# 5. Claude commits the changes
> Create a git commit for this authentication feature
```

### Example 2: Quick Debugging

```bash
# Fast answer
kimik2 "Why is my async function returning Promise<pending>?"

# If need more depth, escalate to Gemini
gemini3 "Explain Promise execution order in Node.js event loop with examples"
```

### Example 3: Performance Optimization

```bash
claude
> Read src/utils/data-processing.ts

@gemini-coder Analyze this code and suggest performance optimizations

# Gemini provides detailed analysis

> Implement Gemini's top 3 optimization suggestions
```

---

## Advanced: MCP Server for Multi-Model

For seamless integration, create an MCP server that exposes Gemini/Kimik2 as tools:

```bash
cat > ~/.claude/mcp-servers/multi-model-ai.js << 'EOF'
#!/usr/bin/env node
// Multi-Model AI MCP Server
// Exposes Gemini 3 and Kimik2 as Claude Code tools

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');

// Implementation details...
// (Full implementation available on request)
EOF
```

---

## Troubleshooting

### "Module not found" errors
```bash
cd ~ && npm install @google/generative-ai axios dotenv
```

### Permission denied
```bash
chmod +x ~/bin/gemini3 ~/bin/kimik2
```

### API key not found
```bash
source ~/.ai-keys.env
echo $GEMINI_API_KEY  # Should show your key
```

### Scripts not in PATH
```bash
export PATH="$HOME/bin:$PATH"
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
```

---

## Security Notes

⚠️ **Important**:
- Keep `.ai-keys.env` private (chmod 600)
- Never commit API keys to git
- Add to `.gitignore`: `*.env`, `.ai-keys.env`
- Rotate keys periodically
- Use environment-specific keys for production

---

## Next Steps

1. Set up your API keys in `~/.ai-keys.env`
2. Test the helper scripts: `gemini3 "test"` and `kimik2 "test"`
3. Try the custom agents: `@gemini-coder` and `@kimik-fast`
4. Update this guide with your actual API endpoints
5. Create additional custom commands as needed

**Remember**: Always use Gemini 3 for cutting-edge coding and reasoning, Kimik2 for speed!
