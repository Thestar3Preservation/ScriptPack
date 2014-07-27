#!/usr/bin/env bash_record
source ~/.bash_profile
LOAD_USER_FUNTION

[ $# = 0 ] && exit

#사용법 : 추가 창 영역을 생성시키고, 자막과 동영상이 존재하는 위치로 각각 이동한다. 적용될 정렬될수 있는 파일들을 선택한뒤 스크립트를 실행시킨다. 이때, 자막파일들의 시작과 동영상 파일들의 시작이 같고, 서로 짝이 맞아야 한다. 선택된 동영상이 자막 보다 많아서는 안된다.
if echo "$CAJA_SCRIPT_SELECTED_FILE_PATHS" | grep -iE '\.(ass|smi)$'; then
	s=$CAJA_SCRIPT_SELECTED_FILE_PATHS #자막의 위치
	t=$CAJA_SCRIPT_NEXT_PANE_SELECTED_FILE_PATHS #기준 이름의 위치
else
	s=$CAJA_SCRIPT_NEXT_PANE_SELECTED_FILE_PATHS
	t=$CAJA_SCRIPT_SELECTED_FILE_PATHS
fi
if [ -z "$t" -o -z "$s" ]; then
	notify-send -u critical '창을 분할하여 자막과 동영상을 각기 선택하십시오!'
	exit
fi
s=$(sort <<<"$s" | sed 1d)
t=$(sort <<<"$t" | sed 1d)
if (($(wc -l <<<"$s") != $(wc -l <<<"$t"))); then
	notify-send -u critical '선택된 수를 일치시키십시오!'
	exit
fi
count=0
for i in $s; do
	((++count));
	dest=$(sed -n ${count}p <<<"$t" | ex_name).$(ex_ext -- "$i")
	if [ -e "$dest" ]; then
		notify-send -u critical '파일이 중복되고 있습니다!'
		exit
	fi
	mv "$i" "$dest"
done

exit
