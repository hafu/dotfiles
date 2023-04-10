# https://wiki.archlinux.org/title/GnuPG#SSH_agent
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
	export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
	export TERMINAL=/usr/bin/alacritty
	exec startx
fi
