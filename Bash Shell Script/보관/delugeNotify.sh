#!/usr/bin/env bash
source ~/.bash_profile
#LOAD_USER_FUNTION

com=$1
shift

case $com in
add)
	notify-send -i deluge 'Add Torrent' "The torrent <b>$(sed -r 's/[ ]{0,1}&[ ]{0,1}/ 그리고 /g' <<<"$2")</b> has add downloading.";;
down)
	if grep -F \& <<<"$2"; then
		name=$(sed -r -e 's/[ ]{0,1}&[ ]{0,1}/ 그리고 /g' <<<"$2")
		mkdir /tmp/deluge_ln
		if ls "/tmp/deluge_ln/$name"; then
			num=1
			while true; do
				if ls "/tmp/deluge_ln/${name}_$num"; then
					((num >= 20)) && exit
					((num++))
				else
					break
				fi
			done
			ln -s "$3/$2" "/tmp/deluge_ln/${name}_$num"
		else
			ln -s "$3/$2" "/tmp/deluge_ln/$name"
		fi
		herf=/tmp/deluge_ln/$name${num:+_$num}
	else
		herf=$3/$2
		name=$2
	fi
	notify-send -i deluge "Finished Torrent" "The torrent <a href='$herf'>$name</a> has finished downloading.";;
esac

exit