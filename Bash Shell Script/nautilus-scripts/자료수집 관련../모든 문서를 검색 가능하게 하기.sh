#!/usr/bin/env bash_record
source ~/.bash_profile
echo "작업 위치 : $PWD"

#사전 점검.
if [ -e link -o -e error.log ]; then
	echo 'link 폴더와 error.log파일은 이 폴더에 존재하지 않아야 합니다.'
	notify-send --urgency=critical 'link 폴더와 error.log파일은 이 폴더에 존재하지 않아야 합니다.'
	exit 1
fi

#파일명을 모두 수정처리함.
echo -e '\n이 폴더 내에 존재하는 하위 모든 파일에서 파일명을 수정합니다.'
parent_pid=$$ "$PATH_BIN/파일명 한번에 고치기 하위 모든 영역에서.sh"

#찌꺼기 파일을 모두 삭제함.
echo -e '\n이 폴더 내에 존재하는 하위 모든 파일에서 찌꺼기 파일을 삭제합니다.'
full=y "$PATH_BIN/찌꺼기 파일을 알아서 잘 제거하기.sh"

#모든 문서를 변환함.
echo -e  '\n이 폴더 내에 존재하는 하위 모든 파일에서 문서를 변환시킵니다.'
convdoc2s -d -g -n -c .

exit