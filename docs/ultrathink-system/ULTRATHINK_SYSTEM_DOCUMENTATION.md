# UltraThink System Documentation

## UltraThink Custom Workflow Engine

This section documents all UltraThink-related system files, configurations, and workflows.

---

## Core UltraThink Files (Root Directory)

### 1. `ULTRATHINK_V6_TEST_SUITE.mjs`
- **Type**: JavaScript ES Module
- **Purpose**: Comprehensive test suite for UltraThink V6 system
- **Size**: ~15KB
- **Dependencies**:
  - Node.js runtime
  - UltraThink libraries
  - Testing framework dependencies
- **Functions**:
  - Test orchestration
  - Workflow validation
  - Performance benchmarking
  - Error handling verification
- **Usage**: Run with `node ULTRATHINK_V6_TEST_SUITE.mjs`
- **Critical**: YES - Core testing infrastructure

### 2. `ultrathink-v6.1-reliable.mjs`
- **Type**: JavaScript ES Module
- **Purpose**: Main UltraThink V6.1 reliable workflow engine
- **Size**: ~25KB
- **Dependencies**:
  - Node.js runtime
  - AI model integrations (Gemini 3)
  - File system operations
  - Process orchestration
- **Functions**:
  - Agent delegation management
  - Workflow pipeline execution
  - Error recovery mechanisms
  - Context window management
  - Quality gate processing
- **Usage**: Core workflow orchestrator
- **Critical**: YES - Main application logic

### 3. `ultrathink-lso-schema.ts`
- **Type**: TypeScript Definition
- **Purpose**: Formal schema definition for the Live State Object (LSO)
- **Size**: ~1KB
- **Features**:
  - Stability metrics interfaces
  - Observability types
  - Agent status definitions
- **Critical**: YES - System Formalism

### 4. `ultrathink-lso.mjs`
- **Type**: JavaScript ES Module
- **Purpose**: Runtime implementation of the LSO
- **Features**:
  - State tracking
  - Stability score calculation
  - Thought buffering
- **Usage**: Imported by orchestrator
- **Critical**: YES - State Management

### 5. `mobile-responsive-layout.css`
- **Type**: CSS Stylesheet
- **Purpose**: Mobile-first responsive design system for UltraThink web interfaces
- **Size**: ~8KB
- **Features**:
  - CSS Grid and Flexbox layouts
  - Mobile-first breakpoints (375px viewport)
  - Component styling guidelines
  - Accessibility features
- **Usage**: Imported by web-based UltraThink interfaces
- **Critical**: YES - Frontend design system

---

## UltraThink Configuration Directories

### `/home/seanos1a/.claude/`
- **Purpose**: Claude Code configuration and custom prompts
- **Key Files**:
  - `CLAUDE.md` - Global instructions for Claude Code
  - `mobile-dev-prompt.md` - Mobile development workflow prompt
  - `commands/` - Custom slash commands directory
  - `hooks/` - Event hook configurations
- **Critical**: YES - Development environment configuration

### `/home/seanos1a/ultrathink-workflows/`
- **Purpose**: UltraThink workflow definitions and templates
- **Contents**:
  - Workflow JSON definitions
  - Agent configuration files
  - Pipeline templates
  - Error handling workflows
  - Quality gate definitions
- **Critical**: YES - Active workflow system

---

## UltraThink Integration Points

### Gemini 3 Agent Delegation System
- **Location**: `/home/seanos1a/gemini-delegation/`
- **Purpose**: Advanced agent orchestration using Gemini 3 models
- **Key Components**:
  - Agent selection algorithms
  - Context window optimization
  - Multi-agent pipeline management
  - Performance monitoring
  - Error recovery mechanisms

### Code Server Mobile Integration
- **Location**: `/home/seanos1a/code-server/`
- **Purpose**: Mobile-optimized development environment
- **Integration**: UltraThink workflows for mobile development
- **Features**:
  - Touch-optimized interface
  - Mobile-specific shortcuts
  - Responsive design testing

### Project Templates and Workflows
- **Location**: Various project directories
- **Purpose**: UltraThink templates for different project types
- **Templates Available**:
  - React component development
  - API endpoint creation
  - Database schema design
  - CI/CD pipeline setup
  - Security audit workflows

---

## UltraThink CLI Commands and Aliases

### Custom Bash Aliases (Documented in CLAUDE.md)
- `ut` - Alias for ultrathink
- `co` - Enhanced Claude orchestrator
- `orchestrate` - Multi-agent pipeline execution
- `c` - Start Claude Code
- `cdev` - Mobile Development Mode
- `cplan` - Plan Mode
- `ccont` - Continue last conversation

### UltraThink Workflow Commands
- `feature` - Feature development workflow
- `bugfix` - Bug fixing workflow
- `research` - Research workflow
- `review` - Code review workflow
- `architect` - Architecture design workflow
- `templates` - Template management

---

## UltraThink Data and Logging

### Logging System
- **Purpose**: UltraThink workflow execution logging
- **Location**: Various log files across projects
- **Features**:
  - Agent performance tracking
  - Error logging and analysis
  - Workflow execution metrics
  - Resource usage monitoring

### State Management
- **Purpose**: Persistent state for UltraThink workflows
- **Components**:
  - Workflow state persistence
  - Agent context management
  - Configuration state storage
  - Cache management for optimization

---

## UltraThink Dependencies and Integrations

### External AI Services
- **Gemini 3 Pro Preview** - Primary AI model for agent execution
- **Claude Sonnet 4.5** - Orchestrator and file operations
- **Model Context Protocol (MCP)** - Server integrations

### Development Tools
- **Node.js** - Runtime environment
- **Git** - Version control
- **VS Code/code-server** - Development environment
- **npm/yarn** - Package management

### System Integrations
- **Nginx** - Web server (not caddy, as specified in requirements)
- **PM2** - Process management
- **Docker** - Containerization (optional)

---

## UltraThink Security and Configuration

### Authentication
- **Google OAuth** - Client credentials stored in `client_secret_*.json`
- **API Keys** - Environment-specific configurations
- **Access Control** - Role-based permissions within workflows

### Configuration Files
- **Environment Variables** - `.env.local` files in projects
- **Service Configuration** - JSON files for service definitions
- **Agent Configuration** - Agent capability and behavior definitions

---

## UltraThink Monitoring and Maintenance

### Performance Metrics
- **Agent Response Times** - Tracking AI model performance
- **Workflow Success Rates** - Monitoring workflow completion
- **Resource Usage** - CPU, memory, and disk utilization
- **Error Rates** - Tracking and analyzing failures

### Maintenance Procedures
- **Log Rotation** - Managing log file sizes
- **Cache Cleanup** - Removing temporary data
- **Configuration Updates** - Keeping agent definitions current
- **Dependency Updates** - Maintaining package versions

---

## Criticality Assessment

### Mission Critical (DO NOT REMOVE)
- `ultrathink-v6.1-reliable.mjs` - Core workflow engine
- `ULTRATHINK_V6_TEST_SUITE.mjs` - Testing infrastructure
- `mobile-responsive-layout.css` - Frontend design system
- `gemini-delegation/` directory - Agent orchestration system
- `.claude/` configuration files - Development environment

### Important (KEEP)
- Workflow templates and definitions
- Configuration and state files
- Documentation and guides
- Integration scripts and utilities

### Replaceable (CAN BE REGENERATED)
- Cache files
- Temporary build artifacts
- Log files (old)
- Generated documentation

---

## Maintenance Schedule

### Daily
- Monitor UltraThink workflow performance
- Check log file sizes
- Verify agent connectivity

### Weekly
- Review workflow success rates
- Update agent configurations as needed
- Clean up temporary files

### Monthly
- Update UltraThink dependencies
- Review and optimize workflows
- Archive old log files
- Performance tuning and optimization

---

**Last Updated**: November 25, 2025
**System Version**: UltraThink V6.1
**Dependencies**: Current and verified operational