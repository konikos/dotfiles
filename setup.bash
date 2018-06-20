#!/bin/bash
set -e


DOTFILES_DIR="${HOME}/.dotfiles"
DOTFILES_BAK_DIR=$(seq --equal-width 100000 | while read -r suffix; do
	dir="$HOME/dotfiles-backup-$(date +"%Y-%m-%d")-${suffix}"
	if [[ ! -e  "$dir" ]]; then
		echo "$dir"
		break
	fi
done)

REPO=https://konikos@github.com/konikos/dotfiles.git
USELESS_FILES=( setup.bash README.md .gitmodules .git )


log() {
	echo - "$@" >&2
}

# backup_if_exists DOTFILE
backup_if_exists() {
	if [[ ! -e "$1" ]]; then
		return 0
	fi

	log Dotfile "\`$1'" already exists, it will be moved to "\`$DOTFILES_BAK_DIR'".

	[[ -e "$DOTFILES_BAK_DIR" ]] || mkdir -p "$DOTFILES_BAK_DIR"
	mv "$1" "$DOTFILES_BAK_DIR/"
}

main() {
	if [[ -e "$DOTFILES_BAK_DIR" ]]; then
		log ERROR: The backup dir already exists: "\`$DOTFILES_BAK_DIR'"
		exit 1
	fi

	backup_if_exists "$DOTFILES_DIR"
	git clone "$REPO" "$DOTFILES_DIR"

	(cd "$DOTFILES_DIR" && git submodule update --init --recursive)

	find "$DOTFILES_DIR" -maxdepth 1 | while read -r dotfile; do
		if [[ "$(basename "$dotfile")" = "$(basename "$DOTFILES_DIR")" ]]; then
			continue
		fi

		target="${HOME}/$(basename "$dotfile")"
		backup_if_exists "$target"
		ln -s "$dotfile" "$target"
	done

	for f in "${USELESS_FILES[@]}"; do
		rm -f "${HOME}/$f"
	done

	log "Don't forget to run \`vim-update'."
	log "dotfiles deployed, enjoy."
}

main "$@"
