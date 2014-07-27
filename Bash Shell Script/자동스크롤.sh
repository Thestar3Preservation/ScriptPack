#!/bin/bash
scriptout() {
	rm /tmp/autoscroll
	pkill -f "$(basename "$0")"
}
if [ -e /tmp/autoscroll ]; then
	scriptout
else
	touch /tmp/autoscroll
fi
win=$(xdotool getactivewindow) || scriptout
while true; do
	time=$(zenity --entry --title "간격 시간 설정" --text "1이상의 정수를 입력하세요." --entry-text 10) || scriptout
	[ -z "${time//[0-9]/}" -a "$time" -ge 1 ] && break
done

while true; do
	sleep $time
	[ "$win" != "$(xdotool getactivewindow)" ] && scriptout
	xdotool key Down Next Down || scriptout #ctrl+Down Next Down
done
#while :; do sleep 35; xdotool key Down Next Down; done
exit
