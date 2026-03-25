#!/bin/bash
export QT_QPA_PLATFORM=xcb
export TERM=dumb
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true'

cd ~
exec "$HOME/matlab/bin/matlab" -desktop
