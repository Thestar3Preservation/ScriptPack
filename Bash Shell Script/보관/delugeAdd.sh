#!/usr/bin/env bash
source ~/.bash_profile

notify-send -i deluge 'Add Torrent' "The torrent <b>$(sed 's/&/＆/g' <<<"$2")</b> has add downloading."
#notify-send -i deluge 'Add Torrent' "The torrent <b>$(sed -r 's/[ ]{0,1}&[ ]{0,1}/ 그리고 /g' <<<"$2")</b> has add downloading."

exit