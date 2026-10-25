# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

#VI-style keybindigs
bindkey -v

# Autocompletion 
autoload -Uz compinit
compinit

# Enable menu-driven completion selection
#zstyle :compinstall filename '/home/jk/.zshrc'
zstyle ':completion:*' menu select

# Environment Variables
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="foot"
export PATH="$HOME/.local/bin:$PATH"

# Load Arch Native Plugins
# (Pathing on Arch Linux for these packages)
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
