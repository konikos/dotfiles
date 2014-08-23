#!/bin/bash

set -e

REPO=https://konikos@github.com/konikos/dotfiles.git
USELESS_FILES=( deploy.bash README.md )

TEMPDIR=$(mktemp -d)
git clone "$REPO" "$TEMPDIR"

cd "$TEMPDIR"
git submodule update --init --recursive

for F in "${USELESS_FILES[@]}"; do
	git update-index --assume-unchanged "$F"
	rm -f "$F"
done

cd "$HOME"
rsync -avr "${TEMPDIR}/" "${HOME}/"
rm -rf "$TEMPDIR"

echo "dotfiles deployed, enjoy."

