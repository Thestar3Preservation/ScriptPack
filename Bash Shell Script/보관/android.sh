#!/usr/bin/env bash
source ~/.bash_profile

help(){
	cat <<-EOF
		timesync	시각 동기화(데스크탑->타블렛)
		powerkey	전원키
		menukey		메뉴키
		wakeup		화면이 꺼진 상태에서 화면을 켜고, 잠금 상태를 해제하기
		down		기기 종료시키기
		clip		in:클립보드에 입력하기. out:클립보드 내용 보이기.
		help		도움말
	EOF
	exit
}

[ $# = 0 ] && help

if [ "$1" != help -a unknown = "$(adb get-state)" ]; then
	echo '장치가 연결되어 있지 않습니다!' >&2
	exit 1
fi

timesync(){
	adb shell date -s `date +%Y%m%d.%H%M%S`
}
powerkey(){
	adb shell sendevent /dev/input/event0 0001 116 1
	#adb shell sendevent /dev/input/event0 0000 0000 00000000
	#adb shell sendevent /dev/input/event0 0001 116 00000000
	#adb shell sendevent /dev/input/event0 0000 0000 00000000
}
menukey(){
	adb shell input keyevent 82
}
wakeup(){
	powerkey
	menukey
}
down(){
	adb shell shutdown
}
clip(){
	case ${1:-out} in
		in)
			echo '구현되지 않은 기능입니다.' >&2
		;;
		out)
			adb shell service call clipboard 3 | tail -n +3 | awk '{print $2,$3,$4,$5}' | tr ' ' '\n' | sed 's/^\(....\)\(....\)$/\2\1/' | tr -d ' \n' | sed -e 's/0000.*$//' -e 's/\(..\)/\\x\1/g' | echo -e "$(</dev/stdin)" #"`cat`"
		;;
	esac
}
compgen -A function | grep -xq "$*" || help
[ -n "$*" ] && "$@"
