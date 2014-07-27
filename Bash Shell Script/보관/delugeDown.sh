#!/usr/bin/env bash
source ~/.bash_profile

if grep -F \& <<<"$2"; then
	#name=$(sed -r -e 's/[ ]{0,1}&[ ]{0,1}/ 그리고 /g' <<<"$2")
	name=$(sed 's/&/＆/g' <<<"$2")
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
		link=${name}_$num
	else
		link=$name
	fi
	ln -s "$3/$2" "/tmp/deluge_ln/$link"
	herf=/tmp/deluge_ln/$name${num:+_$num}
else
	herf=$3/$2
	name=$2
fi

notify-send -i deluge "Finished Torrent" "The torrent <a href='$herf'>$name</a> has finished downloading."

exit