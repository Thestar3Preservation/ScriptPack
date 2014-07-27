#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION

#사용법 페이지
usage () {
	cat <<-EOF
		타이머
		 일격 간격 마다 수를 세어 알려주고, 정지값에 도달하면 알려줍니다.

		사용법: `basename "$0"` [옵션] [정지값]
		 정지값은 -t 간격과 같은 단위를 가집니다. 아무런 단위도 쓰지 않는다면, 기본으로 초단위가 적용됩니다.

		  -t 간격        수치를 셀 간격을 의미합니다. 여기서는 1s가 기본으로 설정되어 있습니다. 단위 : 1s = 1초. 1m = 1분. 1h = 1시간, 1d = 1일.
		  -n 방식        수치를 모두 센뒤의 알람 방식을 설정합니다. 기본값은 notify입니다. notify : 한구석에 작은 알림박스를 띄움. none : 아무런 행동도 하지 않습니다. msgbox : 대화창을 띄웁니다.
		  --help, -h     도움말을 표시한뒤 종료합니다.
		  --             이 스크립트의 옵션 처리의 끝을 나타냅니다.

	EOF
}

#명령행 인자 처리
[[ $# = 0 ]] && { usage; exit; }
while [ $# -gt 0 ]; do
    case "$1" in
        --help | -h )
            usage
            exit 0;;
        -t)
			interver=$2
			shift 2;;
		-n)
			notitype=$2
			shift 2;;
		-- )
			shift
			break;;
        * )
            break;;
    esac
done
[ -z "$interver" ] && interver=1
case $(grep -o .\$ <<<$1) in
	m) count=60;;
	h) count=3600;;
	d) count=43200;;
	* | s) count=1;;
esac
eval "stop=\$(($(grep -oE ^[0-9]+ <<<$1)*count))"

for count in $(seq $stop); do
	sleep $interver
	echo $count
done

case $notitype in
	none) ;;
	msgbox) zenity --info --no-wrap --title='타이머' --text='지정된 시간에 도달했습니다.';;
	* | notify) notify-send '지정된 시간에 도달했습니다.';;
esac

exit