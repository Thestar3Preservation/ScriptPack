#!/usr/bin/env bash
#주의! loop장치로 마운트한 장치의 경우 강제 마운트됩니다. 해당 장치를 언마운트 하기 위해 해당 장치에 엑세스 중인 모든 프로세서는 강제 종료되니 주의하세요!
#loop장치로 마운트된 경우, 노틸러스 스크립트로 마운트된 지점 내에 있는 상태로 언마운트 할수 없는것 같습니다.
#/mnt에선 해당 영역에 있는 모든 cd를 언마운트합니다. 폴더를 선택한 경우 대상은 언마운트합니다. 만약 아무것도 선택되지 않았으면, /mnt가 아닌 경우 현재위치를 언마운트합니다.

#loopUmount(){
	#fuser -ck "$1"
	#위 명령은 해당 마운트 위치에 엑세스 중인 모든 프로세스를 종료시키는 명령이다. 이 명령을 사용하니, 로그아웃이 일어나기에 주석처리한다. 현재로선, 루프 언마운트는 엑세스 중일시 언마운트 처리를 하지 않는걸로 하였다.
#	umount -- "$1" && rmdir -- "$1"
#}

if [ -n "$*" ]; then
	target=( "$@" )
elif [ "$PWD" = /mnt ]; then
	eval "target=( `ls -A --quoting-style=shell-always` )"
else
	target=$PWD
	#fusermount -zu . || loopUmount "$PWD"
fi

for t in "${target[@]}"; do
	if ! fusermount -zu -- "$t"; then
		umount -- "$1"
		rmdir -- "$1"
	fi
done

[ "$PWD" = /mnt ] && rmdir .* *

exit