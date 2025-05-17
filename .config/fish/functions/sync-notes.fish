function sync-notes
    cd ~/Documents/Obsidian/
    git add .
    if not git diff --cached --quiet
        git commit -m "Sync desde PC (date '+%Y-%m-%d %H:%M')"
    end
    git pull --rebase
    git push
end
