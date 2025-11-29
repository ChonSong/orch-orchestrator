#!/bin/bash

# UltraThink Orchestrator Setup Script
# Installs and configures the UltraThink v3.0 system

echo "🧠 UltraThink Orchestrator v3.0 Setup"
echo "======================================"

# Check Node.js version
NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//' || echo "none")
if [[ "$NODE_VERSION" == "none" ]]; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

echo "✅ Node.js version: $NODE_VERSION"

# Make UltraThink executable
echo "📦 Installing UltraThink orchestrator..."
chmod +x /home/seanos1a/ultrathink-orchestrator.mjs

# Create symlink in PATH
if [[ ! -L "/usr/local/bin/ultrathink" ]]; then
    sudo ln -s /home/seanos1a/ultrathink-orchestrator.mjs /usr/local/bin/ultrathink
    echo "✅ Created ultrathink command in /usr/local/bin"
else
    echo "✅ ultrathink command already exists"
fi

# Create alias for easier access
ALIAS_FILE="/home/seanos1a/.bashrc"
if ! grep -q "alias ultrathink=" "$ALIAS_FILE"; then
    echo "" >> "$ALIAS_FILE"
    echo "# UltraThink Orchestrator aliases" >> "$ALIAS_FILE"
    echo "alias ultrathink='node /home/seanos1a/ultrathink-orchestrator.mjs'" >> "$ALIAS_FILE"
    echo "alias ut='ultrathink'" >> "$ALIAS_FILE"
    echo "alias ut-verbose='ultrathink --verbose'" >> "$ALIAS_FILE"
    echo "alias ut-auto='ultrathink --auto-approve'" >> "$ALIAS_FILE"
    echo "✅ Added UltraThink aliases to .bashrc"
else
    echo "✅ UltraThink aliases already exist"
fi

# Create config directory
CONFIG_DIR="/home/seanos1a/.ultrathink"
mkdir -p "$CONFIG_DIR"
echo "✅ Created config directory: $CONFIG_DIR"

# Create default config
CONFIG_FILE="$CONFIG_DIR/config.json"
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" << EOF
{
  "version": "3.0.0",
  "defaultCompressionStrategy": "smart",
  "compressionThreshold": 0.7,
  "maxContextTokens": 32000,
  "enableLearning": true,
  "qualityGates": true,
  "autoApprove": false,
  "verbose": false,
  "sessionTimeout": 3600000,
  "maxSessionHistory": 50,
  "agents": {
    "planner": { "timeout": 300000 },
    "coder": { "timeout": 900000 },
    "tester": { "timeout": 450000 },
    "reviewer": { "timeout": 300000 },
    "devops": { "timeout": 600000 }
  },
  "learning": {
    "recordSessions": true,
    "performanceTracking": true,
    "autoOptimization": true
  }
}
EOF
    echo "✅ Created default configuration"
else
    echo "✅ Configuration file already exists"
fi

# Test installation
echo ""
echo "🧪 Testing UltraThink installation..."
if node /home/seanos1a/ultrathink-orchestrator.mjs --help > /dev/null 2>&1; then
    echo "✅ UltraThink is working correctly!"
else
    echo "❌ UltraThink installation test failed"
    exit 1
fi

echo ""
echo "🎉 UltraThink Orchestrator v3.0 installation complete!"
echo ""
echo "📚 Usage Examples:"
echo "  ultrathink \"Deploy the sync server to production\""
echo "  ut \"Fix the authentication bug in React app\""
echo "  ut-verbose \"Add user registration system\""
echo "  ut-auto --compression aggressive \"Optimize database queries\""
echo ""
echo "🔧 Configuration: $CONFIG_FILE"
echo "📊 Session data: $CONFIG_DIR/sessions/"
echo ""
echo "💡 Pro tip: Use 'ultrathink --metrics' to see performance insights"
echo ""
echo "🧠 Ready for ultra-intelligent task orchestration!"