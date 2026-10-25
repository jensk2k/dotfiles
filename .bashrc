# --- Environment Variables ---
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"

# Ensure local user binaries are in PATH
export PATH="$HOME/.local/bin:$PATH"

# --- Aliases ---
# Dotfiles Bare Repository Alias
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Safe LazyGit Dotfiles Alias (opens bare repo without touching $HOME root)
alias lgdot="lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME"

# Quality of Life Shortcuts
alias ls='ls --color=auto'
alias la='ls -la --color=auto'
alias grep='grep --color=auto'
