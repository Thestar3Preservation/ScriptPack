#!/usr/local/bin/bash_record --changename "파일명을 한번에 고치기"
source ~/.bash_profile
LOAD_USER_FUNTION

#하위 모든 영역을 작업한다면 y. 현재 연영만 작업한다면 n.
[ -z "$full" ] && full=y

#현재 위치를 알림
echo "현재 위치는 '$PWD'입니다."$'\n'

#알림창을 띄움.
if [ "$full" = y ]; then
	echo > /tmp/.progress-$$
	while true; do
		check=$(</tmp/.progress-$$)
		if [ "$check" = 100 ]; then
			break
		else
			echo
		fi
		sleep .1
	done | { zenity --title '일괄 파일명 수정' --text '파일명을 수정하는 중...' --auto-close --pulsate  --progress || { echo '>>작업이 취소되었습니다.<<'; kill $$ $parent_pid; exit; }; } &
fi

#하위 모든 영역에서 작업을 하는 옵션이 켜지면
if [ "$full" = y ]; then
	#목록 만들기
	mklist(){
		#exec < <(find "$1" -depth -print0) #>&0
		for((;;)); do
			IFS=$'\0' read -r -d $'\0' i || break
			ls+=( "$i" )
		done < <(find "$1" -depth -print0)
	}

	#작업 대상 시작점의 경우에 따라
	if [ -n "$*" ]; then
		#작업 대상 목록을 변수에 저장.
		for target; do
			mklist "./$target"
		done
	else
		mklist .
		unset ls[$((${#ls[@]}-1))]
	fi

#현재 영역에서만 작업을 하는 옵션이 켜지면
else
	if [ -n "$*" ]; then
		ls=( "$@" )
	else
		eval "ls=( `ls -A --quoting-style=shell-always` )"
	fi
fi

#작업을 함.
home=$PWD
for source in "${ls[@]}"; do
	cd -- "$home"
	cd -- "`dirname -- "$source"`"
	echo ">>>TARGET : $source<<<"
	source=$(basename -- "$source")
	grep -z '^\.' <<<"$source" && continue
	unset op
	[ -f "$source" ] && op=-e
	dupev_mv -t -- "$source" "$(trim_webname $op -- "$source")"
	echo
done

#작업 종료 처리
[ "$full" = y ] && echo 100 > /tmp/.progress-$$
[ "$noNotity" = y ] || notify-send "$([ "$full" = y ] && echo '하위 모든 영역' || echo '현재 영역')에서 파일명 수정 작업이 끝났습니다."
exit 15