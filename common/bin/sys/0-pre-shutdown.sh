#!/usr/bin/env bash

mpc stop
systemd-inhibit \
  --what=handle-lid-switch \
  --who="PowerMenu" \
  --why="Git sync before poweroff" \
  --mode=block \
  bash -c 'time  --kill-after=5 10 
      "$HOME/bin/sys/sync-git.sh" ~/Documents/Obsidian/ ~/Documents/Keepass/; 
      systemctl poweroff'
