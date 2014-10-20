#!/bin/bash

set -e

REPO=https://konikos@github.com/konikos/dotfiles.git
USELESS_FILES=( deploy.bash README.md .gitmodules .git )

DOTFILES_DIR="${HOME}/.dotfiles"
git clone "$REPO" "$DOTFILES_DIR"

cd "$DOTFILES_DIR"
git -C "$DOTFILES_DIR" submodule update --init --recursive

find "$DOTFILES_DIR" -maxdepth 1 | while read F; do
	ln -s "$F" "${HOME}/$(basename "$F")"
done

for F in "${USELESS_FILES[@]}"; do
	rm -f "${HOME}/$F"
done

echo "dotfiles deployed, enjoy."

