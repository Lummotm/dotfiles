# --- completions ---
complete -c yt-x --no-files --arguments "completions" --condition 'not __fish_contains_opt sort-by S e edit-config s preferred-selector  E generate-desktop-entry rofi-theme'

complete -c yt-x --no-files --short-option h --long-option help --description 'Print a short help text and exit'
complete -c yt-x --no-files --short-option v --long-option version --description 'Print a short version string and exit' --condition 'not __fish_seen_subcommand_from completions'

complete -c yt-x --no-files --short-option e --long-option edit-config --description 'Edit yt-x config file' --condition 'not __fish_seen_subcommand_from completions'
complete -c yt-x --no-files --short-option U --long-option update --description 'update the script' --condition 'not __fish_seen_subcommand_from completions'
complete -c yt-x --no-files --short-option p --long-option player --description 'the video player to use' --condition 'not __fish_seen_subcommand_from completions' --exclusive --arguments 'mpv vlc'
complete -c yt-x --no-files --short-option x --long-option extension --description 'The extension to use' --condition 'not __fish_seen_subcommand_from completions' --exclusive --arguments "(command ls /home/davidn/.config/yt-x/extensions)"
complete -c yt-x --no-files --short-option s --long-option preferred-selector --description 'your preferred selector' --condition 'not __fish_seen_subcommand_from completions' --exclusive --arguments 'fzf rofi'
complete -c yt-x --no-files --short-option E --long-option generate-desktop-entry --description 'generate desktop entry info' --condition 'not __fish_seen_subcommand_from completions' 

complete -c yt-x --no-files --long-option preview --description 'enable preview window' --condition 'not __fish_seen_subcommand_from completions' 
complete -c yt-x --no-files --long-option no-preview --description 'disable preview window' --condition 'not __fish_seen_subcommand_from completions' 

complete -c yt-x --force-files --long-option rofi-theme --description 'the path to your rofi config file' --condition 'not __fish_seen_subcommand_from completions' 

complete -c yt-x --no-files --short-option z --long-option zsh --description 'print zsh completions' --condition '__fish_seen_subcommand_from completions'
complete -c yt-x --no-files --short-option b --long-option bash --description 'print bash completions' --condition '__fish_seen_subcommand_from completions'
complete -c yt-x --no-files --short-option f --long-option fish --description 'print fish completions' --condition '__fish_seen_subcommand_from completions'
    
