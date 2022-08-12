# Set up the prompt
autoload -Uz promptinit
promptinit
PS_PART1="%(!.%F{red}.%F{fg}%n@%F{green})%m%F{black}:%F{blue}%(!.%1~.%~)"
PS_PART2="%(!.%F{red}#.%F{fg}$)%f "

# history opts, see http://zsh.sourceforge.net/Doc/Release/Options.html#History
#setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
#setopt INC_APPEND_HISTORY_TIME
setopt SHARE_HISTORY

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e
#bindkey -v

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=500000
SAVEHIST=500000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
##zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
#zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

setopt COMPLETE_ALIASES

settermtitle () {
    case $TERM in
        *xterm*|rxvt|(dt|k|E)term|alacritty)
            print -Pn "\e]0;%n@%m: %~\a"
            ;;
    esac
}

# VCS integration
# TODO: only for git atm, use internal for other VCS
if [[ -r /usr/lib/git-core/git-sh-prompt ]]; then
    source /usr/lib/git-core/git-sh-prompt
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_STATESEPARATOR=":"
    precmd() {
        __git_ps1 "$PS_PART1%F{magenta}" "%f$PS_PART2" " (%s)"
        settermtitle
    }
else
    # fallback to internal
    autoload -Uz vcs_info
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:*' unstagedstr '*'
    zstyle ':vcs_info:*' stagedstr '+'
    zstyle ':vcs_info:*' formats ' (%b%u%c)'
    zstyle ':vcs_info:*' actionformats ' (%b|%a%u%c)'

    precmd() {
        vcs_info
        if [[ -n ${vcs_info_msg_0_} ]]; then
            PS1="${PS_PART1}%F{magenta}${vcs_info_msg_0_}%f${PS_PART2}"
        else
            PS1="${PS_PART1}${PS_PART2}"
        fi
        settermtitle
    } 
fi

# aliases
if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# set term on ssh connections
alias ssh='TERM=xterm-256color ssh'

# expand path
export PATH=$PATH:$HOME/bin
# https://superuser.com/questions/691395/git-tag-with-gpg-agent-and-pinentry-curses
# use tty/ncurses for gpg git signing
export GPG_TTY=$(tty)

# Alt+. may improve
bindkey '\e.' insert-last-word
