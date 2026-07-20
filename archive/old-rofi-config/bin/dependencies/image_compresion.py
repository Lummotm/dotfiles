#!/usr/bin/env python3
import os
import sys

sys.path.insert(0, os.path.expanduser("~/dotfiles/common/bin/pylib"))
import image_optimizer

vault = sys.argv[1] if len(sys.argv) > 1 else None
image_optimizer.run_optimizer(vault)
