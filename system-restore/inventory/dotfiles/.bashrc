# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Oh My Posh
export PATH=$PATH:~/.local/bin
eval "$(oh-my-posh init bash --config ~/.cache/oh-my-posh/themes/jandedobbeleer.omp.json)"

# Claude Code Aliases (Mobile Development)
export PATH="$HOME/bin:$PATH"

# AI Model Shortcuts
alias g3='gemini3'
alias k2='kimik2'
alias ai-gemini='claude --agent gemini-coder'
alias ai-kimik='claude --agent kimik-fast'

# Claude Code Aliases (Mobile Development)
alias c="claude"
alias cdev="claude --append-system-prompt 'MOBILE DEVELOPMENT MODE: Use strict autonomy. Never output code blocks for copy-paste - use write/edit tools directly. Keep responses brief with bullet points. Handle git operations automatically. Verify actions with curl/grep. Mobile-first viewport (375px) for frontend code.'"
alias cplan="claude --permission-mode plan"
alias ccont="claude --continue"
export PATH="$HOME/.local/bin:$PATH"

# Gemini 3 AI Model Shortcuts
alias gemini3='gemini-delegate coder'           # Complex coding & algorithms
alias gemini-research='gemini-delegate researcher'  # Research & exploration
alias gemini-debug='gemini-delegate debugger'      # Bug fixing
alias gemini-arch='gemini-delegate architect'      # System design
alias gemini-test='gemini-delegate tester'         # Test generation
alias gemini-review='gemini-delegate reviewer'     # Code review

# Claude Orchestrator - Intelligent Auto-Routing
alias co="claude-orchestrator"
alias orchestrate="claude-orchestrator"

# Enhanced Claude Orchestrator Aliases (Default)
alias co='enhanced-orchestrator'
alias orchestrate='enhanced-orchestrator'
alias claude-orchestrator='enhanced-orchestrator'
alias workflow='enhanced-orchestrator --workflow'

# Quick workflow shortcuts
alias feature='enhanced-orchestrator --workflow feature-development'
alias bugfix='enhanced-orchestrator --workflow bug-fix'
alias research='enhanced-orchestrator --workflow research'
alias review='enhanced-orchestrator --workflow code-review'
alias architect='enhanced-orchestrator --workflow architecture-design'

# Template manager
alias templates='node /home/seanos1a/gemini-delegation/workflow-templates.js'

# Enhanced Orchestrator Environment
export ENHANCED_ORCHESTRATOR_DEFAULT=true
export WORKFLOW_ENGINE_PATH="/home/seanos1a/gemini-delegation/automated-workflow.js"
export WORKFLOW_TEMPLATES_PATH="/home/seanos1a/gemini-delegation/workflow-templates.js"

# UltraThink Orchestrator aliases - VERSION 6.1 RELIABLE (with comprehensive logging)
alias ultrathink='node /home/seanos1a/ultrathink-v6.1-reliable.mjs'
alias ut='node /home/seanos1a/ultrathink-v6.1-reliable.mjs'
alias ut-verbose='node /home/seanos1a/ultrathink-v6.1-reliable.mjs --verbose'
alias ut-auto='node /home/seanos1a/ultrathink-v6.1-reliable.mjs --auto-approve'

# Legacy aliases pointing to old versions (kept for compatibility if needed)
alias ut-old='node /home/seanos1a/ultrathink-v6-comprehensive.mjs'
alias ut-v3='node /home/seanos1a/ultrathink-orchestrator.mjs'
alias ut-v5='node /home/seanos1a/ultrathink-orchestrator.mjs'

# Log viewer utility
alias ut-logs='node /home/seanos1a/ULTRATHINK_LOG_VIEWER.mjs'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias cdev="claude --prompt ~/.claude/mobile-dev-prompt.md"
alias c="claude"

# AI API Keys
if [ -f ~/.ai-keys.env ]; then
    source ~/.ai-keys.env
    export GEMINI_API_KEY
    export KIMIK2_API_KEY
    export GEMINI_ENDPOINT
    export KIMIK2_ENDPOINT
fi

# opencode
export PATH=/home/seanos1a/.opencode/bin:$PATH
