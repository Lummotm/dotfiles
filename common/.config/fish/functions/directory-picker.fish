function directory-picker
    set selected ($HOME/bin/utils/directory-picker.sh)

    if test -n "$selected"
        cd "$selected"
        y
    end

    commandline -r ""
    commandline -f repaint
end
