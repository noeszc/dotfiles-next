# ALIASES ---------------------------------------------------------------------

# System Utilities
alias unmount_all_and_exit='unmount_all && exit'
alias c='clear'

# Docker
alias d='docker'
alias dc='docker-compose'
alias dkill="pgrep \"Docker\" | xargs kill -9"

# Text Editors
alias v='nvim -w ~/.vimlog "$@"'
alias vi='nvim -w ~/.vimlog "$@"'
alias vim='nvim -w ~/.vimlog "$@"'

# Notes
alias zn='vim $NOTES_DIR/$(date +"%Y%m%d%H%M.md")'

# Tmux
alias ta='tmux attach -t'

# File Listing
alias l='eza -lah'
alias ls=eza
alias sl=eza

# Source Zsh
alias s='source ~/.zshrc'

# Heroku
alias h=heroku

# JSON Pretty Print
alias jj='pbpaste | jsonpp | pbcopy'

# Move to Trash
alias rm=trash

# Trim Whitespace
alias trim="awk '{\$1=\$1;print}'"

# Navigate Notes Directory
alias notes="cd $NOTES_DIR && nvim 00\ HOME.md"

# GIT ALIASES -----------------------------------------------------------------

# Git Basics
alias gc='git commit'
alias gco='git checkout'
alias ga='git add'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch -D'
alias gcp='git cherry-pick'

# Git Diffs
alias gd='git diff -w'
alias gds='git diff -w --staged'
alias grs='git restore --staged'

# Git Status
alias gst='git rev-parse --git-dir > /dev/null 2>&1 && git status || eza'

# Git Reset
alias gu='git reset --soft HEAD~1'

# Git Prune
alias gpr='git remote prune origin'
alias ff='gpr && git pull --ff-only'

# Git Rebase
alias grd='git fetch origin && git rebase origin/master'

# Git Branch Switching
alias gbb='git-switchbranch'
alias gbf='git branch | head -1 | xargs' # top branch

# Git Logs
alias gl=pretty_git_log
alias gla=pretty_git_log_all

# Current Git Branch
alias git-current-branch="git branch | grep \* | cut -d ' ' -f2"

# Git Rebase Continue/Abort
alias grc='git rebase --continue'
alias gra='git rebase --abort'

# Git Edit Conflicts
alias gec='git status | grep "both modified:" | cut -d ":" -f 2 | trim | xargs nvim -'

# Git Amend Last Commit
alias gcan='gc --amend --no-edit'

# Git Push and Open Pull Request
alias gp="git push -u 2>&1 | tee >(cat) | grep \"pull/new\" | awk '{print \$2}' | xargs open"

# Git Force Push with Lease
alias gpf='git push --force-with-lease'

# Git Branch Management
alias gbdd='git-branch-utils -d'
alias gbuu='git-branch-utils -u'
alias gbrr='git-branch-utils -r -b develop'

# Git Interactive Branch Switch
alias gg='git branch | fzf | xargs git checkout'

# Set Upstream Branch
alias gup='git branch --set-upstream-to=origin/$(git-current-branch) $(git-current-branch)'

# Git Checkout Next/Previous Commit
alias gnext='git log --ancestry-path --format=%H ${commit}..master | tail -1 | xargs git checkout'
alias gprev='git checkout HEAD^'

# FUNCTIONS -------------------------------------------------------------------

# Create a Directory and Navigate to It
function take {
    mkdir -p $1
    cd $1
}

# Log Notes with Date
note() {
    echo "date: $(date)" >> $HOME/drafts.txt
    echo "$@" >> $HOME/drafts.txt
    echo "" >> $HOME/drafts.txt
}

# Unmount All External Disks
function unmount_all {
    diskutil list |
    grep external |
    cut -d ' ' -f 1 |
    while read file
    do
        diskutil unmountDisk "$file"
    done
}

# Fast-Forward Merge
mff () {
    local curr_branch=`git-current-branch`
    gco master
    ff
    gco $curr_branch
}

# Source Job-Specific Aliases
JOBFILE="$DOTFILES/job-specific.sh"
if [ -f "$JOBFILE" ]; then
    source "$JOBFILE"
fi

# Docker Cleanup
dclear () {
    docker ps -a -q | xargs docker kill -f
    docker ps -a -q | xargs docker rm -f
    docker images | grep "api\|none" | awk '{print $3}' | xargs docker rmi -f
    docker volume prune -f
}
alias docker-clear=dclear

# Docker Full Reset
dreset () {
    dclear
    docker images -q | xargs docker rmi -f
    docker volume rm $(docker volume ls | awk '{print $2}')
    rm -rf ~/Library/Containers/com.docker.docker/Data/*
    docker system prune -a
}

# Extract Audio and Video from Media File
extract-audio-and-video () {
    ffmpeg -i "$1" -c:a copy obs-audio.aac
    ffmpeg -i "$1" -c:v copy obs-video.mp4
}

# Show HTTP Status
hs () {
    curl https://httpstat.us/$1
}

# Copy Line to Clipboard
copy-line () {
  rg --line-number "${1:-.}" | sk --delimiter ':' --preview 'bat --color=always --highlight-line {2} {1}' | awk -F ':' '{print $3}' | sed 's/^\s+//' | pbcopy
}

# Open Editor at Specific Line
open-at-line () {
  vim $(rg --line-number "${1:-.}" | sk --delimiter ':' --preview 'bat --color=always --highlight-line {2} {1}' | awk -F ':' '{print "+"$2" "$1}')
}

# Alias for Ledger with File Path
alias ledger='ledger -f "$(find $NOTES_DIR -name transactions.ledger)"'

# Yarn Install with Pure Lockfile
alias yip='yarn install --pure-lockfile'

# Toggle Terminal Dark Mode
alias dark="$DOTFILES/bin/toggle-terminal-dark-mode.sh"

