#!/usr/bin/env bash_record
source ~/.bash_profile
LOAD_USER_FUNTION
home=$PWD

#파일명을 모두 수정처리함.
echo -e '\n이 폴더 내에 존재하는 1단계 깊이의 모든 파일에서 파일명을 수정합니다.'
full=n noNotity=y parent_pid=$$ "$PATH_BIN/파일명 한번에 고치기 하위 모든 영역에서.sh"

#찌꺼기 파일을 모두 삭제함.
echo -e '\n이 폴더 내에 존재하는 하위 모든 파일에서 찌꺼기 파일을 삭제합니다.'
full=y noNotity=y "$PATH_BIN/찌꺼기 파일을 알아서 잘 제거하기.sh"

#cbz파일로 압축하기
for i in $(find . -mindepth 1 -maxdepth 2 -type d); do
	cd -- "$home"
	cd -- "$i"
	check1=$(find . -mindepth 1 -maxdepth 1 -type d -o \( -iname '*.zip' -o -iname '*.cbz' -type f \))
	check2=$(find . -mindepth 1 -maxdepth 1 -iname '*.jpg' -o -iname '*.bmp' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.jpeg')
	if [ -z "$check1" -a -n "$check2" ]; then
		cd ..
		"$PATH_BIN/cbz파일로 묶기.sh" "`basename -- "$i"`"
	fi
done

#‘~화,권’이라고된 폴더 리스트를 보기 좋게 정리함.
cd "$home"
echo -e '\n이 폴더 내에 존재하는 ‘~화,권’이라고된 폴더 리스트를 보기 좋게 정리합니다.'
"$PATH_BIN/‘~화,권’이라고된 폴더 리스트를 보기 좋게 정리하기.sh"

notify-send '만화 또는 책을 한꺼번에 정리했습니다.'

exit
