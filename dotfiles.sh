#!/bin/bash
# script to manage dotfiles



# The MIT License (MIT)
# 
# Copyright (c) 2015 Hannes Fuchs
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.



# get scriptdir
# from http://stackoverflow.com/a/246128
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# static vars
FILEMAP="$SCRIPTDIR/FILEMAP"
HOSTNAME=$(hostname)

# check if file is in filemap
function is_in_filemap {
	# check for argument
	if [ -z "$1" ]; then
		echo "is_in_filemap needs an argument"
		exit 1
	fi
	
	# create if not exists
	if [ ! -f "$FILEMAP" ]; then
		touch "$FILEMAP"
	fi
	echo $(grep "$1" "$FILEMAP" | wc -l)
}

# get the relative path of the file
function relative_path_of_file {
	echo $(cd $(dirname "$1") && pwd -P)/$(basename "$1")
}

# get the relative directory of the file
function relative_dir_of_file {
	echo $(cd $(dirname "$1") && pwd -P)
}

# ask yes or no question -> return 1 for yes and 0 for no
function ask_yes_no {
	L=0
	while [ $L -eq 0 ]; do
		read -p "Type yes/no:" YN
		case $YN in
			[Yy]* )
				L=1
				A=1
				;;
			[Nn]* )
				L=1
				A=0
				;;
			* )
				L=0
				echo "Enter yes or no"
				;;
		esac
	done

	return $A
}

# adds a file
function add {
	# check for argument
	if [ -z "$1" ]; then
		echo "add needs an argument"
		exit 1
	fi
	
	FILE_REL=$(relative_path_of_file "$1")
	FILE=${FILE_REL/$HOME/\~}

	# check if already in list
	if [ $(is_in_filemap "$FILE") -ge 1 -o -L "$FILE_REL" ]; then
		echo "file $FILE already in git?"
		exit 1
	fi

	# check if in $HOME
	if [[ ! "$FILE_REL"  =~ "$HOME" ]]; then
		echo "file $FILE_REL seems to be not in $HOME"
		exit 1
	fi	

	# create a "readable" filename
	FILENTMP=${FILE_REL//${HOME}\//}	# only filepath in HOME
	FILENTMP=${FILENTMP//\//_}		# replace / with _
	FILENTMP=${FILENTMP/#\./}		# remove first .

	echo "Adding file $1 (move, link and add to git repro)"

	# move the file, symlink and add to git
	mv "$FILE_REL" "$SCRIPTDIR/$FILENTMP"
	ln -s "$SCRIPTDIR/$FILENTMP" "$FILE_REL"
	git add "$SCRIPTDIR/$FILENTMP"

	# add to mapping
	echo "$FILENTMP $FILE" >> "$FILEMAP"

	echo "don't forget to commit the changes"
}

# deletes a file
function del {
	# check for argument
	if [ -z "$1" ]; then
		echo "delete needs an argument"
		exit 1
	fi

	FILE_REL=$(relative_path_of_file "$1")
	FILE_DIR=$(relative_dir_of_file "$1")

	# file in scriptdir?
	if [[ "$FILE_REL" =~ "$SCRIPTDIR" ]]; then
		FILE=${FILE_REL/$SCRIPTDIR/}
	elif [[ "$FILE_REL"  =~ "$HOME" ]]; then
		FILE=${FILE_REL/$HOME/\~}
	else
		echo "error on deleting file $1 - wrong dir"
		exit 1
	fi
	
	if [ $(is_in_filemap "$FILE") -ge 1 ]; then
		# get the line -> src and dst
		LINE=$(grep "$FILE" "$FILEMAP")
		SRC=$(echo "$LINE" | cut -d" " -f1)
		SRC="${SCRIPTDIR}/$SRC"
		DST=$(echo "$LINE" | cut -d" " -f2)
		DST="${DST/#\~/$HOME}"
	else
		echo "error on deleting file $1 - not in filemap"
		exit 1
	fi

	# both should exists
	if [ -z	"$SRC" -o -z "$DST" -o ! -e "$SRC" -o ! -e "$DST" ]; then
		echo "error on deleting file $1 -> src: $SRC dst: $DST"
		exit 1
	fi

	# delete symlink
	if [ ! -L "$DST" ]; then
	       echo "error on deleting file $1 -> $DST is not a link"
	       exit 1
        fi
	
	# maybe use unlink
	rm "$DST"     	       
	
	# copy to orign
	cp "$SRC" "$DST"
	
	# delete from FILEMAP
	sed -i "/$LINE/d" "$FILEMAP"

	# git rm file
	echo "delete file from git repro?"
	ask_yes_no
	RT=$?
	if [ $RT -eq 1 ]; then
		git rm "$SRC"
	fi

	# rm file
	echo "delete file from fs?"
	ask_yes_np
	RT=$?
	if [ $RT -eq 1 ]; then
		rm "$DST"
	fi

}

# initalizate 
function init {
	echo "initializate (backup, move and link)"
	if [ ! -f "$FILEMAP" -o ! -r "$FILEMAP" ]; then
		echo "couldn't read filemapping: $FILEMAP"
		exit 1
	fi

	#check branch
	if [ $(git branch --no-color --no-column --list "$HOSTNAME" | wc -l ) -eq 1 ]; then
		echo "found a branch for hostname ${HOSTNAME}, checkout?"
		ask_yes_no
		RV=$?
		if [ $RV -eq 1 ]; then
			git checkout "$HOSTNAME"
		fi
	else
		echo "do you want to create a branch for ${HOSTNAME}?"
		ask_yes_no
		RV=$?
		if [ $RV -eq 1 ]; then
			git branch "$HOSTNAME"
		fi
	fi	

	BAKDIR="$SCRIPTDIR/backup/$(date +%s)/"

	while read SRC DST
	do
		DST="${DST/#\~/$HOME}"
		SRC="${SCRIPTDIR}/$SRC"

		DSTDIR=$(relative_dir_of_file "$DST")

		# backup files, if exists
		if [ -e "$DST" -a ! -L "$DST" ]; then
			if [ ! -d "$BAKDIR" ]; then
				mkdir -p "$BAKDIR" || exit 1
			fi

			#if [[ ! "$FILE_REL"  =~ "$HOME" ]]; then
			if [[ "$DSTDIR" =~ "$HOME" ]]; then
				TBAKDIR="${BAKDIR}${DSTDIR/$HOME/}/"
				mkdir -p "$TBAKDIR" || exit 1
			else
				TBACKDIR="$BAKDIR"
			fi	
	
			echo "File $DST exists, creating backup"
			mv "$DST" "$TBAKDIR"
		fi

		if [ -e "$DST" -a -L "$DST" ]; then
			echo "$DST is already a symlink, skipping"
			continue
		fi

		# create dir
		if [ ! -e "$DSTDIR" ]; then
			mkdir -p "$DSTDIR" || exit 1
		elif [ -e "$DSTDIR" -a ! -d "$DSTDIR" ]; then
			echo "$DSTDIR exists and ist not a directory!"
			exit 1
		fi

		# creat symlinks
		ln -s "$SRC" "$DST"

	done < "$FILEMAP"
}

function usage {
	echo -e "usage: ${BASH_SOURCE[0]} [add|del|init] [file]\n
    init    initializes/bootstraps. All files in FILEMAP will be linked
            to its destination. Existing files will be saved in backup
	    folder. Branches can be used (default is to use the hostname
	    as Branch-name) for different hosts.
    add     adds a file
            The file should be in your home directory to be added. It 
	    moves the file to the git repository (renamed) and creates 
	    a link to its orign location. Finally it's added to the
	    repository. 
    del     deletes a file
            Deletes the specific file a.) from the repository b.) from
	    filesystem. You will be asket if you want to delete it from
	    the repository and the filesystem.\n
Also see the README"
}

case $1 in 
	a*)
		add "$2"
		;;
	d*)
		del "$2"
		;;
	i*)
		init
		;;
	*)
		usage
		;;
esac
