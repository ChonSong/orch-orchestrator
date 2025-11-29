# Claude Code - AI Assistant for Software Engineering

## Overview

Claude Code is an interactive CLI tool and the official AI assistant from Anthropic designed specifically for software engineering tasks. It combines powerful AI capabilities with autonomous agents and specialized tools for reliable, production-ready code generation.

**Current Model**: Claude Sonnet 4.5 (claude-sonnet-4-5-20250929)

## Key Features

### Core Capabilities
- **File Operations**: Read, Write, Edit, and Glob tools for comprehensive file management
- **Code Search**: Advanced Grep functionality with regex support, file filtering, and context display
- **Bash Integration**: Execute terminal commands with persistent shell sessions
- **Task Management**: TodoWrite tool for planning and tracking multi-step tasks
- **Specialized Agents**: Deploy autonomous agents for complex tasks (Explore, Plan, code review, etc.)
- **Real-time Streaming**: Stream responses character-by-character for immediate feedback
- **Checkpoints & Rewind**: Automatic checkpoints before every edit (Esc + Esc to restore)
- **Project Memory**: Uses `claude.md` files to maintain context across sessions
- **Git Integration**: Automated commit creation, PR management via `gh` CLI

### Advanced Features
- **Test Pride Integration**: MCP server for autonomous testing (10-20 minute full test cycles)
- **Sandbox Mode**: `/sandbox` command for isolated execution of risky operations
- **Multiple Tool Calls**: Parallel execution of independent operations for efficiency
- **Web Operations**: WebFetch and WebSearch for accessing external information
- **Jupyter Notebooks**: Can read and edit .ipynb files
- **Image/PDF Reading**: Multimodal capabilities for visual content analysis

## Reliable Code Workflow

Claude Code follows a comprehensive workflow for shipping production-ready code:

### Phase 1: Planning and Implementation

**1. Start with a Clear Plan**
- Don't jump to "build this" - request a detailed step-by-step plan first
- Review and improve the plan until it's crystal clear
- Only allow Claude to code once the plan is solid
- This reduces bugs significantly

**2. Implement the Feature**
- Follow the plan precisely
- Test locally (e.g., `npm run dev`)
- Verify UI changes, state management, API logic, and edge cases

### Phase 2: Autonomous Testing (TDD Flow)

**3. Use Test Pride for Testing**
- Integrates via MCP server for autonomous testing
- Generates code summaries, PRDs, and test plans
- Executes tests with video playback and detailed logs
- Produces comprehensive reports with bug priorities
- Can test frontend, backend, or full codebase

### Phase 3: Safety and Consistency

**4. Use Checkpoints (Rewind)**
- Automatic checkpoints before every edit
- `Esc + Esc` to restore conversation, code, or both
- No manual backups needed

**5. Be Specific with Instructions**
- Specify tech stack, tools, implementation method, architecture
- Detailed input = better plans = better output
- Example: "use Radix components, stick to Tailwind classes, match color scheme"

**6. Use Sandbox for Risky Operations**
- `/sandbox` command for file operations, directory modifications
- Strict sandbox mode prevents accidental escapes

**7. Preserve Context (Update Memory)**
- Update project's `claude.md` file with custom instructions
- Keeps Claude aligned with project structure across sessions
- Prevents random decisions in later prompts

## Best Practices

### Code Quality
- **Avoid over-engineering**: Only make directly requested or clearly necessary changes
- **No premature abstractions**: Three similar lines > forced abstraction
- **Minimal error handling**: Only validate at system boundaries (user input, external APIs)
- **No backwards-compatibility hacks**: Delete unused code completely
- **Simple solutions**: Minimum complexity needed for current task

### Development Workflow
- **Start by reading directory contents**: When beginning work, use `ls` or `tree` to understand the current directory structure and available files
- **Read before editing**: Always read files before suggesting modifications
- **Use specialized tools**: Read/Edit/Write instead of bash cat/sed/echo
- **Parallel operations**: Execute independent tool calls simultaneously
- **Security awareness**: Avoid XSS, SQL injection, command injection, OWASP top 10
- **Minimize context usage**: Use Task tool for file searches

### Git Workflow
- **Only commit when requested**: Never proactively commit
- **Use GitHub CLI for all GitHub operations**: Always use `gh` CLI instead of web browser for GitHub interactions
  - Repository operations: `gh repo view`, `gh repo clone`, `gh repo create`
  - Pull requests: `gh pr create`, `gh pr view`, `gh pr list`, `gh pr merge`
  - Issues: `gh issue create`, `gh issue view`, `gh issue list`
  - Releases: `gh release create`, `gh release list`
  - Gists: `gh gist create`, `gh gist list`
  - Actions: `gh run list`, `gh run view`, `gh workflow list`
- **Safety protocol**:
  - Never update git config
  - Never skip hooks (--no-verify)
  - Never force push to main/master
  - Check authorship before amending
- **Commit message format**:
  ```
  Descriptive message focusing on "why" not "what"

  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

## Tool Usage Guidelines

### When to Use Specialized Tools
- **Read**: For viewing file contents (not cat/head/tail)
- **Edit**: For modifying files (not sed/awk)
- **Write**: For creating files (not echo/heredoc)
- **Grep**: For content search (not grep/rg commands)
- **Glob**: For file pattern matching (not find/ls)
- **Bash**: Only for actual terminal operations (git, npm, docker, etc.)

### Task Tool with Agents
Use specialized agents proactively:
- **Explore**: Quick codebase exploration, file pattern finding, keyword searches
- **Plan**: Planning implementation steps
- **claude-code-guide**: Looking up Claude Code documentation
- Other custom agents as defined

### TodoWrite Tool
Use frequently for:
- Complex multi-step tasks (3+ steps)
- Non-trivial implementations
- User-provided task lists
- Tracking progress throughout implementation

**Requirements**:
- Exactly ONE task must be in_progress at a time
- Mark tasks completed IMMEDIATELY after finishing
- Use imperative form for content, present continuous for activeForm
- Example: content: "Run tests", activeForm: "Running tests"

## Limitations

### Interactive Terminal Applications
Like Gemini CLI, Claude Code executes commands and returns output. It cannot provide real-time, interactive sessions for full-screen terminal applications like `htop`, `vim`, or `nano`.

If you ask Claude Code to run such applications, it will execute the command, but you won't be able to see or interact with the interface.

**Solution**: Run these applications directly in your own terminal.

### Other Limitations
- **Token budget**: 200,000 tokens per conversation
- **Bash timeout**: Default 2 minutes (max 10 minutes)
- **File read limit**: 2000 lines by default (can specify offset/limit)
- **Long lines**: Lines over 2000 characters get truncated
- **Background processes**: Can run but require monitoring via BashOutput tool
- **No placeholder values**: All tool parameters must have actual values

## Comparison: Claude Code vs Gemini CLI

### Claude Code Advantages
- **Autonomous agents** for complex tasks
- **Built-in checkpoints** and rewind functionality
- **Project memory** system (claude.md)
- **Test Pride integration** for autonomous testing
- **Parallel tool execution** for efficiency
- **Advanced file operations** (Edit tool with exact string replacement)
- **Git safety protocols** built-in
- **Todo list management** for multi-step tasks

### Shared Limitations
- Both execute commands and return output (no interactive sessions)
- Cannot run full-screen terminal apps interactively
- Both require external terminal for tools like vim, htop, nano

## Environment

**Working Directory**: /home/seanos1a
**Platform**: Linux 6.12.48+deb13-cloud-amd64
**Model**: Claude Sonnet 4.5 (claude-sonnet-4-5-20250929)
**Knowledge Cutoff**: January 2025
**GitHub CLI**: v2.83.1 (installed)

## Development Environment Setup

### Primary Terminal Interface: code-server
**URL**: https://dev.codeovertcp.com
**Password**: dawnofdoyle
**Type**: VS Code in browser (code-server)

**Why code-server?**
- Full VS Code experience in browser (perfect for mobile)
- Integrated terminal for Claude Code CLI
- File editor for verifying AI-generated code
- Extension support for full IDE capabilities
- "Zen Mode" for full-screen terminal experience

**Mobile Workflow**:
1. Open dev.codeovertcp.com on phone/tablet
2. Open terminal (hamburger menu → Terminal → New Terminal)
3. Use `F1` → "Toggle Maximized Panel" for full-screen terminal
4. Run Claude Code CLI in maximized terminal
5. Toggle back to editor when you need to verify/edit code

**Configuration**: Mobile-optimized settings in `~/.local/share/code-server/User/settings.json`
- Activity bar hidden for more space
- Larger font sizes (14px) for readability
- Better touch targets (20px tree indent)
- Terminal as primary interface

### Secondary Web Chat: gemini-assistant
**URL**: https://code.codeovertcp.com
**Type**: React web chat using Gemini 3 Pro Preview API

**Features**:
- Copy individual messages (hover to see button)
- Copy entire conversation
- Copy all assistant output
- Copy last response
- Toast notifications for feedback
- LocalStorage persistence

**Built with**: React 19, TypeScript, Vite, Tailwind CSS
**Location**: `/home/seanos1a/gemini-assistant`

**Use Cases**:
- Backup when code-server unavailable
- Quick questions without opening full IDE
- Testing Gemini 3 API
- Demonstrating web chat interface

### Recommendation
**Use code-server as primary interface**:
- **Desktop**: dev.codeovertcp.com (port 8080) - Standard UI
- **Mobile**: mobile.codeovertcp.com (port 8081) - Mobile-optimized UI

Both provide terminal access for Claude Code CLI and editor for verifying/editing code. The gemini-assistant is a backup option only.

See `CODE_SERVER_MOBILE_GUIDE.md` for detailed mobile workflow guide.

---

## Mobile Development Workflow

### Quick Start Commands

Added bash aliases for fast mobile workflow:
```bash
c          # Start Claude Code
cdev       # Start Claude Code in Mobile Development Mode (strict autonomy)
cplan      # Start Claude Code in Plan Mode
ccont      # Continue last conversation
```

### Mobile Development Mode

When using `cdev` alias, Claude operates with:
- **Strict Autonomy**: Uses Write/Edit tools directly, no copy-paste code blocks
- **Brevity**: Minimal text, bullet points only
- **Auto Git**: Handles version control automatically
- **Auto Verification**: Uses curl/grep to verify changes
- **Mobile-First**: Frontend code assumes 375px viewport

System prompt file: `~/.claude/mobile-dev-prompt.md`

### MCP Servers Configured

**Active MCP Servers**:
- `filesystem` - Enhanced file operations for `/home/seanos1a`
  - Command: `npx -y @modelcontextprotocol/server-filesystem /home/seanos1a`
  - Status: ✓ Connected

View MCP servers: `claude mcp list`

### Mobile-Optimized Settings

**mobile.codeovertcp.com** (Port 8081) includes:
- Terminal: 14px font, blinking cursor, 10k scrollback
- UI: Minimal distractions, 20px tree indent for touch
- Editor: 14px font, auto-save enabled
- Files: Preview disabled, auto-save after 1s delay

---

---

## AI Model Routing Strategy

**IMPORTANT**: Use the right AI model for each task type:

### 🚀 ORCH - Unified Orchestrator (Recommended)

**ORCH** consolidates all AI agent delegation into a single command. It replaces `co`, `ut`, `gemini3`, and `claude-orchestrator`.

**Basic Usage**:
```bash
orch "task description"                    # Auto-routing (default)
orch --deep "complex task"                 # Deep analysis (ultrathink)
orch --agent coder "specific task"         # Force specific agent
orch --workflow feature "new feature"      # Predefined workflow
orch --sessions                            # Session management
```

**Available Modes**:
- **Auto**: Intelligent agent selection (85-95% accuracy)
- **Deep**: Multi-layered reasoning for complex problems
- **Agent**: Force specific agent (coder, researcher, debugger, architect, etc.)
- **Workflow**: Feature development, bug fixing, research, review, architecture

**Performance**:
- 3x faster than manual agent selection
- 68% cost reduction (context compression)
- 32K optimal context window with smart management
- Automatic quality gates and error recovery

📖 **Complete Guide**: `/home/seanos1a/ORCHESTRATOR_GUIDE.md`

### Claude Sonnet 4.5 (File Operations)
**Use for:**
- File operations (Read/Write/Edit)
- Git workflows and commits
- Multi-step coordination
- Task management
- Codebase exploration
- Implementation execution

**Default for all file operations and project management.**

### Gemini 3 Pro Preview (Advanced AI)
**Use for:**
- Complex coding problems and algorithms
- Advanced reasoning tasks
- Cutting-edge implementation designs
- Performance optimization strategies
- Research and exploration

**Access via ORCH**:
```bash
orch --agent coder "complex algorithm"     # Coding tasks
orch --agent researcher "analyze topic"    # Research
orch --agent debugger "fix this issue"     # Debugging
orch --agent architect "design system"     # Architecture
```

📖 **Legacy Commands** (still supported but deprecated):
- `gemini3`, `co`, `ut`, `claude-orchestrator` → use `orch` instead

---

**Last Updated**: 2025-11-26
**Maintained By**: Claude Code + Developer Collaboration

## 🔄 Migration to ORCH Command

**Simplified Architecture**: All previous orchestrator commands (`co`, `ut`, `gemini3`, `claude-orchestrator`) are now consolidated into the single `orch` command.

### Migration Examples:
```bash
# OLD → NEW
co "task"                          → orch "task"
ut "complex task"                  → orch --deep "complex task"
gemini3 coder "task"               → orch --agent coder "task"
feature "new feature"              → orch --workflow feature "new feature"
bugfix "issue"                     → orch --workflow bug "issue"
claude-orchestrator "task"         → orch "task"
```

### 🎯 Benefits of ORCH:
- **Single command** to remember instead of 6+
- **Consistent interface** across all modes
- **Intelligent defaults** (auto-routing)
- **Backward compatibility** (old commands still work)
- **Enhanced features** (workflows, sessions, quality gates)

### 📚 Documentation:
- **Complete Guide**: `/home/seanos1a/ORCHESTRATOR_GUIDE.md`
- **Migration Details**: `/home/seanos1a/ORCH_COMMAND_SIMPLIFICATION.md`
- **Projects Inventory**: `/home/seanos1a/PROJECTS_INVENTORY_2025-11-26.md`
- we are using ngid not caddy
- I want to use gemini3 as agents for the orchestrator to use