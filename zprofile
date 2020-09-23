if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
	export TERMINAL=/usr/bin/alacritty
	exec startx
fi
