#!/bin/bash

set -e

REPO=https://konikos@github.com/konikos/dotfiles.git
DEPLOY_SCRIPT=deploy.bash

TEMPDIR=$(mktemp -d)
git clone "$REPO" "$TEMPDIR"

cd "$TEMPDIR"
git submodule update --init --recursive
git update-index --assume-unchanged "$DEPLOY_SCRIPT"
rm -f "$DEPLOY_SCRIPT"

cd "$HOME"
rsync -avr "${TEMPDIR}/" "${HOME}/"
rm -rf "$TEMPDIR"

echo "dotfiles deployed, enjoy."

