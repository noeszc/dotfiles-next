source ~/zplug/init.zsh

zplug mafredri/zsh-async, from:github
zplug "zsh-users/zsh-syntax-highlighting"
zplug "lib/history", from:oh-my-zsh
# zplug "geometry-zsh/geometry", from:github, as:theme
zplug "sobolevn/sobole-zsh-theme", from:github, as:theme
# zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme

if ! zplug check; then
  zplug install
fi

# Then, source plugins and add commands to $PATH
zplug load
if ! zplug check; then
    zplug install
fi

zplug load
