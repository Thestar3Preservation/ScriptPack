#!/bin/bash
#아마록에서 현재 재생중인 파일을 삭제하고 다음 곡을 재생.
source ~/Home/쉘스크립트/function.sh
file=$(dbus-send --print-reply --type=method_call --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.GetMetadata | grep -A 1 -m 1 'string "location"' | tail -n 1 | sed -e 's/"$//' -e 's/^.*file:\/\///' | url_decoding)
dbus-send --print-reply --type=method_call --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.Next
trash-put "$file"
exit
