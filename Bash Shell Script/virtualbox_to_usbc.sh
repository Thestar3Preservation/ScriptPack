#!/bin/bash

MountDir='/media/Temple of The Binary Data'

CODE='sefho023wt0pva34thwtu'
VM_NAME='Window 7'

#외장 하드 디스크가 마운트되어있음이 확인되면
if [ -d "$MountDir" ]; then
	#폴더를 열고
	caja "$MountDir" 
#마운트되어있지 않다면 
else
	#가상머신을 실행합니다.
	/usr/lib/virtualbox/VirtualBox --comment "$VM_NAME" --startvm "$CODE"
fi

exit
