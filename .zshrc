# --- Environment Variables ---
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"

# Keep PATH free of duplicates (nested shells would otherwise add entries again)
typeset -U path PATH

# Ensure local user binaries are in PATH
export PATH="$HOME/.local/bin:$PATH"
# Tools installed with `cargo install` (cargo itself is in /usr/bin via rustup)
export PATH="$HOME/.cargo/bin:$PATH"
export SUDO_EDITOR=nvim

# --- Zsh Options & Quality of Life ---
# Navigate to a directory without typing 'cd'
setopt AUTO_CD

# History Configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY         # Save commands immediately and share across all open terminal windows
setopt HIST_IGNORE_ALL_DUPS  # Drop older copies of a repeated command

# --- Aliases ---
# Dotfiles Bare Repository Alias
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Safe LazyGit Dotfiles Alias
alias lgdot="lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME"

# Quality of Life Shortcuts
alias ls='ls --color=auto'
alias la='ls -la --color=auto'
alias grep='grep --color=auto'

# Remote desktop
alias rdp-desktop="xfreerdp3 /v:192.168.1.178 /u:jensk2k@gmail.com /dynamic-resolution /gfx /sound /clipboard /cert:tofu"

# --- Autocompletion ---
autoload -Uz compinit
compinit

# Enable interactive, menu-driven completion selection (arrow keys to pick)
zstyle ':completion:*' menu select

# fzf colours: the desktop scheme's fzf port, written by ~/.config/theme/apply and
# read on every fzf run, so open shells follow theme switches too
export FZF_DEFAULT_OPTS_FILE="$HOME/.config/theme/generated/fzf.opts"

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# --- Arch Native Plugins ---
# Autosuggestions (press Right Arrow to accept greyed-out history suggestions)
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax Highlighting (valid commands highlight green, invalid red)
# Must be sourced last so it can wrap every widget defined above
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
