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

abspath() {
	echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

# backup_if_exists backup_dir path
backup_if_exists() {
	local backup_dir src dest

	backup_dir=$1
	src=$2
	dest="${backup_dir}/$(abspath "$src" | sed 's|^/\+||')"

	if ! [[ -e $src ]]; then
		return
	fi

	mkdir -p "$(dirname "$dest")"
	mv "$src" "$dest"
}

# link_dotfile backup_dir source_path target_path
link_dotfile() {
	local backup_dir source_path target_path

	backup_dir=$1; shift
	source_path=$1; shift
	target_path=$1; shift

	if [[ ! -e $source_path ]]; then
		return 0
	fi

	if [[ "$(readlink "$source_path" || true)" = "$target_path" ]]; then
		# path is already linked
		return 0
	fi

	backup_if_exists "${backup_dir}" "$target_path"
	ln -s "$source_path" "$target_path"
}

main() {
	local backup_dir
	if ! backup_dir=$(mkbackup_dir); then
		die "Could not create backup directory"
	fi
	log "Will backup existing files to \`$backup_dir'."

	local -r dotfiles_dir="${HOME}/.dotfiles"
	backup_if_exists "$backup_dir" "$dotfiles_dir"
	git clone "$REPO" "$dotfiles_dir"

	(cd "$dotfiles_dir" && git submodule update --init --recursive)

	local rel_dotfile git_dotfile rel_dir target_dir home_dotfile
	git -C "$dotfiles_dir" ls-tree --full-tree -r HEAD \
		| awk '{ print $4 }' \
		| while read -r rel_dotfile; do
			rel_dir=$(dirname "$rel_dotfile")
			target_dir="${HOME}/${rel_dir}"
			if ! mkdir -p "${target_dir}"; then
				die "Could not create directory ${target_dir}"
			fi

			git_dotfile="${dotfiles_dir}/${rel_dotfile}"
			home_dotfile="${HOME}/${rel_dotfile}"
			link_dotfile "$backup_dir" "$git_dotfile" "$home_dotfile"
	done

	for f in "${USELESS_FILES[@]}"; do
		rm -f "${HOME}/$f"
	done

	if ! rmdir "$backup_dir" >/dev/null 2>&1; then
		log "Existing files were backed up to \`${backup_dir}'."
	else
		log "No backups were required."
	fi

	log "Don't forget to run \`[nv]im-update'."
	log "dotfiles deployed, enjoy."
}

main "$@"
