function sync-notes
    cd ~/Documents/Obsidian/

    # Añadir .gitkeep en carpetas vacías
    find . -type d -empty -exec touch {}/.gitkeep \;

    git add .
    if not git diff --cached --quiet
        set fecha (date '+%Y-%m-%d %H:%M')
        git commit -m "Sync desde PC ($fecha)"
    end
    git pull --rebase
    git push
end
