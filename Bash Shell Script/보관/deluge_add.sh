#!/bin/bash
IFS=$'\n'
grep -F '&' <<<"$2" && name=$(echo "$2" | sed -r 's/[ ]{0,1}&[ ]{0,1}/ 그리고 /g')
notify-send -i deluge "Add Torrent" "The torrent <b>$2</b> has add downloading."
exit
