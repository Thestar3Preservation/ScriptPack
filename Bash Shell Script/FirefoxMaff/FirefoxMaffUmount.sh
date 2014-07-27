#파이어폭스가 종료되었을 경우, 자동으로 mount된 maff파일을 umount시킵니다.
UmountMaffFiles(){
	local lockFileName=/tmp/firefoxMaffUmount.lock maffMountPoint=/tmp/webarchiveMountPoint
	[ -e "$lockFileName" ] && exit
	touch -- "$lockFileName"
	while true; do
		sleep 1
		pgrep -x firefox && continue
		rm -- "$lockFileName"
		cd -- "$maffMountPoint" || exit
		eval "ls=( `ls -A --quoting-style=shell-always` )"
		for((i = 0; i < ${#ls[@]}; i++)); do
			#만약 fusermount에서 mount 명령이 지체되는 경우를 대비하여 백그라운 명령으로 서브 프로세서로 실행하고, 멀티태스크합니다.
			fusermount -zu -- "${ls[i]}" &
			#7개씩 작업합니다.
			((i + 1 % 7 == 0)) && wait
		done
		wait
		rm -r -- "$maffMountPoint"
		exit
	done
}
export -f UmountMaffFiles
nohup bash -c UmountMaffFiles &>/dev/null &