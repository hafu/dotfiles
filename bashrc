#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ignore duplicate lines or lines starting with space
HISTCONTROL='ignoreboth:erasedups'

# let's keep all
# see http://stackoverflow.com/a/19533853
HISTFILESIZE=
HISTSIZE=
HISTFILE=~/.bash_large_history
# change format
HISTTIMEFORMAT='%F %T '
# save after command
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# more colorful output
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# TODO add svn support
# set a fancy PS1
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
	. /usr/share/git/completion/git-prompt.sh
	GIT_PS1_SHOWDIRTYSTATE=1
	GIT_PS1_SHOWSTASHSTATE=1
	GIT_PS1_SHOWUNTRACKEDFILES=1
	GIT_PS1_SHOWUPSTREAM="auto"
	GIT_PS1_STATESEPARATOR=":"
	#GIT_PS1_SHOWCOLORHINTS=1
	#PS1='[\e[1;30m\]\u\e[m\]@\e[0;32m\]\h\e[m\]:\e[0;34m\]\w\e[m\]$(__git_ps1 " \e[0;35m\](%s)\e[m\]")]\n\\$ \e[m\]'
	PS1='[\[\033[1;30m\]\u\[\033[0m\]@\[\033[0;32m\]\h\[\033[0m\]:\[\033[0;34m\]\w\[\033[0m\]$(__git_ps1 " \[\033[0;35m\](%s)\[\033[0m\]")]\n\$ '
else
	#PS1='[\e[1;30m\]\u\e[m\]@\e[0;32m\]\h\e[m\]:\e[0;34m\]\w\e[m\]\e[m\]")]\n\\$ \e[m\]'
	#PS1='[\e[1;30m\u\e[m@\e[0;32m\h\e[m:\e[0;34m\w\e[m]\n\\$ \e[m'
	PS1='[\[\033[1;30m\]\u\[\033[0m\]@\[\033[0;32m\]\h\[\033[0m\]:\[\033[0;34m\]\w\[\033[0m\]]\n\$ '
fi

# load aliases
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# start ssh-agent
ssh-add -l &>/dev/null
if [ "$?" == 2 ]; then
	test -r ~/.ssh-agent && \
		eval "$(<~/.ssh-agent)" >/dev/null

	ssh-add -l &>/dev/null
	if [ "$?" == 2 ]; then
		(umask 066; ssh-agent > ~/.ssh-agent)
		eval "$(<~/.ssh-agent)" >/dev/null
	fi
fi
