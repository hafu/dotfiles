# Set up the prompt
autoload -Uz promptinit
promptinit

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

precmd_functions+=(settermtitle)


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
# https://wiki.archlinux.org/title/GnuPG#gpg-agent
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
      export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
# https://superuser.com/questions/691395/git-tag-with-gpg-agent-and-pinentry-curses
# use tty/ncurses for gpg git signing
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

# Alt+. may improve
bindkey '\e.' insert-last-word

# https://starship.rs/
eval "$(/home/hfuchs/git/starship/target/release/starship init zsh)"

# Created by `pipx` on 2023-06-20 09:00:47
export PATH="$PATH:/home/hfuchs/.local/bin"

