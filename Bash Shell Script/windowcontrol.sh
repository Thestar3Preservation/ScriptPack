#!/bin/bash

IFS='
'

window=`xdotool getwindowfocus`
url="/tmp/windowcontrol-`whoami`"

touch "$url"
chmod 700 "$url"

case $1 in
	minimize) #활성화된 창을 최소화 시킨다.
		while :
		do
			xdotool windowminimize $window && break
			count=`expr $count + 1`; [ $count -ge 10 ] && break
		done
		#echo "$window" | grep -x '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' && 
		[ "$window" -a "$window" != '669' ] && echo $window >> "$url";;
	restore) #이 스크립트로 최소화 시킨 창들을 차례로 복원시킨다. 만약, 이미 해당 창이 복원되어 있을 경우 전면으로 초점을 맞춘다.
		a=`tail -n 1 "$url"`
		while :
		do
			xdotool windowactivate $a && xdotool windowfocus $a && break
			count=`expr $count + 1`; [ $count -ge 10 ] && break
		done
		sed '$d' "$url" > "${url}.tmp"
		mv "${url}.tmp" "$url";;
	*) ;;
esac

exit
