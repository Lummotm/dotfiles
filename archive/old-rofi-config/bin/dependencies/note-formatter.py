#!/usr/bin/env python3
import os
import sys

sys.path.insert(0, os.path.expanduser("~/dotfiles/common/bin/pylib"))
import note_formatter

NOTES_DIR = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/Documents/Obsidian")

if len(sys.argv) < 3:
    for line in note_formatter.list_notes(NOTES_DIR):
        print(line)
else:
    path = note_formatter.resolve_path(NOTES_DIR, sys.argv[2])
    if path:
        print(path)
