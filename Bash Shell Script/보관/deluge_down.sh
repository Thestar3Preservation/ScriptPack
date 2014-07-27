#!/bin/bash

IFS='
'

if echo "$2" | grep -F '&'
then
	name=$(echo "$2" | sed -r -e 's/[ ]{0,1}&[ ]{0,1}/ 그리고 /g')
	mkdir /tmp/deluge_ln
	if ls "/tmp/deluge_ln/$name"
	then
		num=1
		while :
		do
			if ls "/tmp/deluge_ln/${name}_$num"
			then
				test $num -eq 20 && exit
				num=`expr $num + 1`
			else
				break
			fi
		done
		ln -s "$3/$2" "/tmp/deluge_ln/${name}_$num"
	else
		ln -s "$3/$2" "/tmp/deluge_ln/$name"
	fi
	notify-send -i deluge "Finished Torrent" "The torrent <a href='/tmp/deluge_ln/$name${num:+_$num}'>$name</a> has finished downloading."
else
	notify-send -i deluge "Finished Torrent" "The torrent <a href='$3/$2'>$2</a> has finished downloading."
fi


exit
