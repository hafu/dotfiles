# dotfiles

These are my dotfiles and a simple script to manage them. The main
application for the scritp, is to init (bootstrap) dotfiles and add them
to the repository.

## install

```sh
git clone https://github.com/hafu/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./dotfiles.sh init
```

The name of the destination directory does not matter, it stores the
added dotfiles, a filemap and if necessary backups.

## commands

### init

Initialize (bootstraps) dotfiles. Any existing files will be backed up
to `<scriptdir>/backup/<timestamp>/<dir>/<filename>`. So an existing
`~/.vimrc` is saved under `backup/1234567890/.vimrc` and `~/.i3/config` under
`backup/1234567890/.i3/config`.

So it works:

0. checks if there is a FILEMAP
0. checks for branch with the same name as the hostname itself and ask
to use it or if not exist create one
0. reads the FILEMAP and creates a link for every item - existing files
will be backed up

Example:
```sh
./dotfiles.sh init
```

### add

Adds a file to the repository, so it will be moved to <scriptdir>/ and
added to the FILEMAP. The file will be renamed to be git-frendly.

Examples:
```sh
./dotfiles.sh add ~/.vimrc
./dotfiles.sh add ~/.i3/config
```

### del

Deletes a file from the repository and FILEMAP and/or from the
Filesystem.

Examples:
```sh
./dotfiles.sh del ./vimrc
./dotfiles.sh del ~/.i3/config
```
