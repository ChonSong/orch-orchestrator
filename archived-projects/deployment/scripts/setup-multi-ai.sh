#!/bin/bash
# Multi-AI Model Setup Script
# Sets up Gemini 3 and Kimik2 integration with Claude Code

set -e

echo "=================================="
echo "Multi-AI Model Setup"
echo "=================================="
echo ""

# Create bin directory if it doesn't exist
mkdir -p ~/bin

# Check if bin is in PATH
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo "Adding ~/bin to PATH..."
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/bin:$PATH"
fi

# Step 1: Install Node dependencies
echo "Step 1: Installing Node.js dependencies..."
npm install -g @google/generative-ai axios dotenv

# Step 2: Create API keys file if it doesn't exist
if [ ! -f ~/.ai-keys.env ]; then
    echo ""
    echo "Step 2: Setting up API keys file..."
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
    echo "✅ Created ~/.ai-keys.env"
    echo "⚠️  IMPORTANT: Edit ~/.ai-keys.env and add your API keys!"
else
    echo "Step 2: ~/.ai-keys.env already exists, skipping..."
fi

# Step 3: Create helper scripts
echo ""
echo "Step 3: Creating helper scripts..."

# Gemini 3 script
cat > ~/bin/gemini3 << 'EOFSCRIPT'
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
EOFSCRIPT

chmod +x ~/bin/gemini3
echo "✅ Created gemini3 script"

# Kimik2 script
cat > ~/bin/kimik2 << 'EOFSCRIPT'
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
EOFSCRIPT

chmod +x ~/bin/kimik2
echo "✅ Created kimik2 script"

# Step 4: Create Claude agents
echo ""
echo "Step 4: Creating Claude Code custom agents..."
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

echo "✅ Created gemini-coder agent"

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

echo "✅ Created kimik-fast agent"

# Step 5: Create slash commands
echo ""
echo "Step 5: Creating slash commands..."
mkdir -p ~/.claude/commands

cat > ~/.claude/commands/gemini.md << 'EOF'
---
description: Ask Gemini 3 for cutting-edge coding help
---
@gemini-coder {{args}}
EOF

cat > ~/.claude/commands/quick.md << 'EOF'
---
description: Quick answer with Kimik2
---
@kimik-fast {{args}}
EOF

echo "✅ Created /gemini and /quick commands"

# Step 6: Add bash aliases
echo ""
echo "Step 6: Adding bash aliases..."
if ! grep -q "# AI Model Shortcuts" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# AI Model Shortcuts
alias g3='gemini3'
alias k2='kimik2'
alias ai-gemini='claude --agent gemini-coder'
alias ai-kimik='claude --agent kimik-fast'
EOF
    echo "✅ Added aliases to ~/.bashrc"
else
    echo "ℹ️  Aliases already exist in ~/.bashrc"
fi

# Done
echo ""
echo "=================================="
echo "✅ Setup Complete!"
echo "=================================="
echo ""
echo "Next steps:"
echo "1. Edit ~/.ai-keys.env and add your API keys"
echo "2. Run: source ~/.bashrc"
echo "3. Test: gemini3 'Hello, Gemini!'"
echo "4. Test: kimik2 'What is 2+2?'"
echo ""
echo "In Claude Code, use:"
echo "  @gemini-coder for cutting-edge coding"
echo "  @kimik-fast for quick answers"
echo "  /gemini or /quick as shortcuts"
echo ""
echo "📖 Full guide: ~/AI_MODEL_INTEGRATION_GUIDE.md"
