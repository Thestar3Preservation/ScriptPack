#!/bin/bash

IFS='
'
gksu '/home/'$USER'/Home/쉘스크립트/virtual_disk_open.sh'
if [ "$CAJA_SCRIPT_SELECTED_FILE_PATHS" ]
then
 list=$CAJA_SCRIPT_SELECTED_FILE_PATHS
elif [ "$@" ]
then
 list=$@
else
 exit
fi
#[ "$CAJA_SCRIPT_SELECTED_FILE_PATHS" ] && list=$CAJA_SCRIPT_SELECTED_FILE_PATHS
#[ "$@" ] && list=$@

#gksu --message '가상 디스크를 마운트합니다.' 
for i in $list
do
 foldername=$RANDOM$RANDOM
 mkdir /tmp/mount-$foldername
 tvdfuse -t auto -v -f "$i" /tmp/mount-$foldername #"`pwd`/.$foldername"
 mkdir /tmp/mount-$foldername-1
 mount /tmp/mount-$foldername/Partition1 /tmp/mount-$foldername-1
done

exit
