#!/usr/bin/env bash_record
source ~/.bash_profile
LOAD_USER_FUNTION
#작동시키면, 현재 위치에 존재하는 폴더 또는 선택된 폴더를 모두 중첩 해제시킨다. 또, 빈 폴더를 삭제시킨다.
#선택된 대상 혹은 선택된 대상이 없을 경우 해당 경로에 존재하는 파일 목록 전체를 i변수에 차례로 저장.
for i in ${*-*}; do
	echo "TARGET : $i"
	#대상이 디렉토리가 아닌 경우 다음 차례로 넘김
	[ -d "$i" ] || continue
	#디렉토리가 아닌 것을 찾아 j변수에 차례로 저장.
	find "$i" ! -type d | ( while read j; do
		((count++))
		#첫번째로 찾은 파일과 그 디렉토리를 기억공간에 저장
		if ((count==1)); then
			that=$j
			startdir=$(dirname "$j")
		fi
		#현재 검사중인 파일이 위치한 디렉토리가 최초로 검사 중인 디렉토리와 일치하지 않는 경우 검사 중단.
		[ "`dirname "$j"`" = "$startdir" ] || exit
		#임시변수에 현재 실행중인 값을 저장하여, 종류후에도 사용할수 있도록 함.
		jj=$j
	done
	#만약, 찾아낸 대상이 1개 이거나, 파일들이 모두 같은 폴더에 있는 경우
	#만약, 내부에 파일이 하나만 존재할 경우
	if ((count==1)); then
		#중복회피 이동함수를 통해, 파일을 검사 시작 부모 디렉토리로 이동
		dupev_mv -- "$that" .
	#만약, 내부에 파일이 두개 초과일 경우
	elif ((count>1)); then
		#파일을 가진 유일한 폴더 내의 파일을 검사 시작 부모 디렉토리 내로 이동
		if [ "`realpath "$jj" | dirname "$(cat)"`" != "`realpath "$i"`" ]; then
			ls -A "$startdir" | xargs -I{} -d '\n' mv "$startdir"/{} "$i"
			find "$i" -mindepth 1 -type d -prune | xargs -I{} -d '\n' trash-put {}
		fi
		continue
	fi
	#검사 대상 폴더를 삭제(아무것도 없을 경우에도 이 명령은 실행된다)
	trash-put "$i"; )
done
exit