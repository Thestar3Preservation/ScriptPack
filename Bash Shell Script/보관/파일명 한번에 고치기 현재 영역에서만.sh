#!/usr/local/bin/bash_record --changename "파일명을 한번에 고치기"
source ~/.bash_profile
LOAD_USER_FUNTION
echo "PWD : $PWD"
if [ -n "$*" ]; then
	ls=( "$@" )
else
	eval "ls=( `ls -A --quoting-style=shell-always` )"
fi
for source in "${ls[@]}"; do
	grep '^\.' <<<"$source" && continue
	[ -f "$source" ] && op=-e
	unset op
	dupev_mv -t -- "$source" "$(trim_webname $op -- "$source")"
done
notify-send '현재 영역에서 파일명 수정 작업이 끝났습니다.'
exit