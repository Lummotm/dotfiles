#!/usr/bin/env python3
import os
import sys

sys.path.insert(0, os.path.expanduser("~/dotfiles/common/bin/pylib"))
import todos

NOTES_DIR = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/Documents/Obsidian")
todos.run_update(NOTES_DIR)
