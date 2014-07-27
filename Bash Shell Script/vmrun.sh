#!/bin/bash
# 선택된 가상머신을 특정 스냅샷으로 되돌린뒤 시작하고 숨깁니다.
# vmrun.sh '가상머신 설정파일의 위치' '스냅샷 이름' '가상머신 이름'

IFS=$'\n'

if [ -z "$(vmrun list | grep -Fi "$1")" ]; then
	vmrun -T ws revertToSnapshot "$1" "$2"
	vmrun -T ws start "$1" &
	while [ -z "$(vmrun list | grep -Fi "$1")" ]; do
		xdotool search --name "$3 - VMware Workstation" | sort | xargs -I{} xdotool windowunmap {}
		sleep 1
	done
	xdotool search --name "$3 - VMware Workstation" | sort | xargs -I{} xdotool windowmap {}
fi

exit