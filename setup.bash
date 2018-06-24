#!/bin/bash
set -e


declare -r REPO=https://konikos@github.com/konikos/dotfiles.git
declare -r -a USELESS_FILES=( setup.bash README.md .gitmodules .gitignore )

log() {
	echo "[+]" "$@" >&2
}

die() {
	log "ERROR:" "$@"
	exit 1
}

mkbackup_dir() {
	local -r template="dotfiles-backup-$(date +"%Y%m%d")-XXXXXXXXXX"

	if [[ $OSTYPE = darwin* ]] || [[ "$(uname -s)" = "Darwin" ]]; then
		mktemp -d "$template"
	else
		mktemp -d -t "$template"
	fi
}

# backup_if_exists BACKUP_DIR DOTFILE
backup_if_exists() {
	local -r backup_dir=$1
	local -r dotfile=$2

	if [[ ! -e "$dotfile" ]]; then
		return 0
	fi

	mv "$dotfile" "${backup_dir}/"
}

main() {
	local backup_dir
	if ! backup_dir=$(mkbackup_dir); then
		die "Could not create backup directory"
	fi

	local -r dotfiles_dir="${HOME}/.dotfiles"
	backup_if_exists "$backup_dir" "$dotfiles_dir"
	git clone "$REPO" "$dotfiles_dir"

	(cd "$dotfiles_dir" && git submodule update --init --recursive)

	local dotfile rel_dir target_dir link_source
	git -C "$dotfiles_dir" ls-tree --full-tree -r HEAD \
		| awk '{ print $4 }' \
		| while read -r dotfile; do
			rel_dir=$(dirname "$dotfile")
			target_dir="${HOME}/${rel_dir}"
			if ! mkdir -p "${target_dir}"; then
				die "Could not create directory ${target_dir}"
			fi

			link_source="${HOME}/${dotfile}"
			backup_if_exists "$backup_dir" "$link_source"
			ln -s "${dotfiles_dir}/$dotfile" "$link_source"
	done

	for f in "${USELESS_FILES[@]}"; do
		rm -f "${HOME}/$f"
	done

	if ! rmdir "$backup_dir" >/dev/null >&2; then
		log "Existing files were backed up to \`${backup_dir}'"
	fi

	log "Don't forget to run \`[nv]im-update'."
	log "dotfiles deployed, enjoy."
}

main "$@"
