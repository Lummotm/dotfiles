# Dotfiles Agent Guide

## Repo Overview

Personal Arch Linux dotfiles for Wayland (niri/hyprland), managed with GNU stow. Modular structure where configs are symlinked from the repo to `$HOME`.

## Key Directories

- `common/` — Shared configs (fish, nvim, waybar, rofi, niri, dunst, etc.)
- `desktop/` / `laptop/` — Machine-specific configs (energy, GPU, monitors)
- `themes/` — Visual profiles (waybar, rofi, niri styles). Applied via `theme-selector.sh`
- `install/` — Deploy scripts (`install.sh` = full system install, `apply.sh` = dotfiles only)
- `extra/` — Root-required files (greetd, keyd, sudoers, GPU scripts). Copied manually, NOT stowed

## Critical Conventions

### Stow ignores
`apply.sh` runs `git update-index --assume-unchanged` on these files — they are personal and must NOT be committed:
```
common/.config/rofi/colors.rasi
common/.config/waybar/colors.css
common/.config/zathura/zathurarc
common/.config/dunst/dunstrc
common/.config/nvim/lazy-lock.json
common/.config/discord/settings.json
common/.config/sioyek/prefs_user.config
common/.config/niri/colors.kdl
```

### Username substitution
`install.sh` runs `sed -i "s/davidn/$USER/g"` on all files during deploy. Avoid hardcoding the username in new configs.

### Resources archive
Fonts, icons, themes, and wallpapers live in `extra/resources.7z`. The apply script extracts and syncs this bidirectionally.

## Common Workflows

### Apply dotfiles after editing
```bash
cd ~/dotfiles
stow --target=$HOME --restow common
stow --target=$HOME --restow desktop   # or laptop
```

### Switch visual theme
```bash
~/dotfiles/common/bin/ui/theme-selector.sh --theme <theme-name>
# Interactive mode: run without args
```

### Run install modules independently
```bash
cd ~/dotfiles/install
./install.sh --dotfiles   # only clone + apply
./install.sh --login      # only session manager (greetd/ly)
./install.sh --sudoers     # only sudoers rules
./install.sh --gpu         # only GPU toggle scripts (laptop)
./install.sh --full        # full install (interactive)
```

### Re-stow a single package
```bash
stow --target=$HOME -D <package>   # remove symlinks
stow --target=$HOME <package>       # re-create
```

## System Info

- Distro: Arch Linux (CachyOS)
- WMs: niri (primary), hyprland (alternative)
- Shell: fish with vi bindings
- Display manager: greetd (autologin on desktop) or ly (manual on laptop)
- GPU: amd + nvidia (desktop), intel + nvidia (laptop)
- Package manager: pacman + yay (AUR)
- Audio: pipewire + mpd
