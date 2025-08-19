source_if_exists () {
    if test -r "$1"; then
        source "$1"
    fi
}

source_if_exists $HOME/.env.sh
source_if_exists $DOTFILES/zsh/secrets.zsh
source_if_exists $DOTFILES/zsh/zplug.zsh
source_if_exists $DOTFILES/zsh/git.zsh
source_if_exists ~/.fzf.zsh
source_if_exists $DOTFILES/zsh/aliases.zsh

# z/zoxide - detección por OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    source_if_exists /opt/homebrew/etc/profile.d/z.sh
else
    if command -v zoxide > /dev/null; then
        eval "$(zoxide init zsh)"
    fi
fi

if type "direnv" > /dev/null; then
    eval "$(direnv hook zsh)"
fi

autoload -U promptinit && promptinit
autoload -U colors && colors
autoload -Uz compinit && compinit

if test -z ${ZSH_HIGHLIGHT_DIR+x}; then
else
    source $ZSH_HIGHLIGHT_DIR/zsh-syntax-highlighting.zsh
fi

precmd() {
    source $DOTFILES/zsh/aliases.zsh
}
# Zsh theme light
SOBOLE_THEME_MODE='dark'

export VISUAL=nvim
export EDITOR=nvim
export PATH="$PATH:/usr/local/sbin:$DOTFILES/bin:$HOME/.local/bin:$HOME/.cargo/bin"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Fast Node Manager (fnm)
if [[ "$OSTYPE" == "darwin"* ]]; then
  if command -v fnm > /dev/null; then
    eval "$(fnm env --use-on-cd)"
  fi
else
  FNM_PATH="$HOME/.local/share/fnm"
  if [ -d "$FNM_PATH" ]; then
    export PATH="$FNM_PATH:$PATH"
    eval "$(fnm env --use-on-cd)"
  fi
fi

# pnpm - OS agnostic
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
