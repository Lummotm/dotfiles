# Abreviaturas rápidas
abbr vim  nvim
abbr vi   nvim
abbr n    nvim

abbr gc   'git commit -m'
abbr gp   'git push -u origin main'

abbr lg "lazygit"
abbr oo " cd ~/Documents/Obsidian/ && nvim"
abbr ot "cd ~/Documents/Obsidian/00\ -\ todo && nvim inbox.md"
abbr sn "~/bin/sys/sync-git.sh ~/Documents/Obsidian/"
abbr wiki  'wikiman'

abbr yayf "yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:75% | xargs -ro yay -S"

# Print en blanco y negro una vez
abbr printbn "lp -d ENVY_4500 -o sides=two-sided-long-edge -o ColorModel=Gray"

abbr a "z"

abbr py "python3"

abbr mg "media-grabber"

abbr mount-user "sudo mount -o uid=$(id -u),gid=$(id -g),umask=000"

abbr tray-kill "pkill -f -9 discord && pkill -f -15 steam" 

abbr matlab "sudo systemctl start docker && distrobox enter  matlab -- clear && ~/.local/MATLAB/R2025b/bin/matlab -nodesktop"
abbr update-grub "sudo grub-mkconfig -o /boot/grub/grub.cfg"


# Install abbr
abbr s "yay -Ss"
abbr i "yay -S"
abbr r "yay -Rns"
abbr fbin "pacman -F"
