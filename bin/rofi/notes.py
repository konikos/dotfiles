#!/usr/bin/env python3
import os
import os.path
import sys
import subprocess


DROPBOX_NOTES='/home/konikos/Dropbox/Documents/Notes'


if len(sys.argv) > 1:
    file_path = os.path.join(DROPBOX_NOTES, sys.argv[1])
    open_program = 'xdg-open' if os.path.exists(file_path) else 'gvim'

    subprocess.Popen(
        [open_program, file_path],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    sys.exit()

unwalked_dirs = [DROPBOX_NOTES]
while unwalked_dirs:
    current_dir = unwalked_dirs.pop()

    files = []
    dirs = []
    for dir_entry in os.scandir(current_dir):
        if dir_entry.is_dir():
            dirs.append(dir_entry.path)
        else:
            files.append(dir_entry.path)

    for f in sorted(files):
        print(os.path.relpath(f, DROPBOX_NOTES))

    dirs.sort(reverse=True)
    unwalked_dirs.extend(dirs)
