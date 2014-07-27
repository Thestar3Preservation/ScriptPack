#!/bin/bash
#선택된 파일의 내용을 순차적으로 클립보드에 저장하고, 정지한뒤 계속진행 신호를 기다립니다.
IFS=$'\n'
echo PID : $$
kill -20 $$
for i in $(cat list.txt); do
	#xclip -i <<<"$i" #클립보드 조작 명령어
	firefox -new-tab "$i" &>/dev/null &
	echo "$i"
	#xdotool mousedown 2
	kill -20 $$
	#xclip -i -selection clip <<<"$i"
done
#계속진행 명령 : kill -18 $$
exit
