# --- Environment Variables ---
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"

# Ensure local user binaries are in PATH
export PATH="$HOME/.local/bin:$PATH"

# --- Zsh Options & Quality of Life ---
# Navigate to a directory without typing 'cd'
setopt AUTO_CD

# History Configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY  # Save commands to history as soon as they run
setopt SHARE_HISTORY       # Share history across all open terminal windows

# --- Aliases ---
# Dotfiles Bare Repository Alias
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Safe LazyGit Dotfiles Alias
alias lgdot="lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME"

# Quality of Life Shortcuts
alias ls='ls --color=auto'
alias la='ls -la --color=auto'
alias grep='grep --color=auto'

# --- Autocompletion ---
autoload -Uz compinit
compinit

# Enable interactive, menu-driven completion selection (arrow keys to pick)
zstyle ':completion:*' menu select

# --- Arch Native Plugins ---
# Syntax Highlighting (valid commands highlight green, invalid red)
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestions (press Right Arrow to accept greyed-out history suggestions)
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- Optional Integrations (Uncomment if installed) ---
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
