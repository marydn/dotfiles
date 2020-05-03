#!/bin/bash

dotfiles_dir="$HOME/.dotfiles"

dotfiles=".tmux.conf \
.zshrc \
.tmux \
.zsh \
.oh-my-zsh \
"

nvim_config="$HOME/.config/nvim/init.vim"

# make git be quiet
quiet_git() {
	stdout=$(mktemp)
	stderr=$(mktemp)

	if ! git "$@" </dev/null >"$stdout" 2>"$stderr"; then
		cat "$stderr" >&2
		rm -f "$stdout" "$stderr"
		exit 1
	fi

	rm -f "$stdout" "$stderr"
}

# backup dotfiles
backup_dotfiles() {
	echo "Backing up old dotfiles..."
	for d in $dotfiles; do
	  echo " Backing up $HOME/$d to $dotfiles_dir.backup/$d"
		cp -rfH "$HOME/$d" "$dotfiles_dir.backup/$d" 2>/dev/null || :
	done
	cp -rf "$dotfiles_dir" "$dotfiles_dir.backup" 2>/dev/null || :
	cp -f "$nvim_config" "$HOME/.config/nvim/init.vim.backup" 2>/dev/null || :
	cp -rf "$HOME/.oh-my-zsh" "$HOME/.oh-my-zsh.backup" 2>/dev/null || :
	echo "Done"
}

# install dotfiles
install_dotfiles() {
	echo "Installing dotfiles into $dotfiles_dir..."
	quiet_git clone "$dotfiles_repo" "$dotfiles_dir"
	echo "Symbollically linking dotfiles to home directory (e.g. ln -s $dotfiles_dir/.zshrc $HOME/.zshrc)"
	find "$dotfiles_dir" -type f -name ".*" -exec ln -sf {} "$HOME" \; >/dev/null 2>&1
	if [ ! -d "$HOME/.config/nvim" ]; then
		mkdir -p "$HOME/.config/nvim"
	fi
	ln -s "$dotfiles_dir/init.vim" "$nvim_config"
}

# remove dotfiles
remove_old_dotfiles() {
	echo "Removing old dotfiles..."
	for d in $dotfiles; do
		rm -rf "${HOME:?}"/"$d"
	done
	rm -rf "$dotfiles_dir"
	rm -f "$nvim_config"
	rm -rf "$HOME/.oh-my-zsh"
	echo "Done"
}

# backup and remove dotfiles
if [ -d "$dotfiles_dir" ]; then
	echo "Old dotfiles exist"
	echo
	backup_dotfiles
	echo
	remove_old_dotfiles
	echo
fi

# install dotfiles
# install_dotfiles