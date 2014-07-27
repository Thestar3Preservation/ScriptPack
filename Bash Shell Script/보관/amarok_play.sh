#!/bin/bash
#탐색창에서 아마록에 재생 목록을 추가하는 명령어. 현재 목록을 초기화 시키고 추가시킨다.
amarok --pause --stop --load "$@" --play
exit

#4
IFS='
'
amarok --pause; amarok --stop
until [ -z "$1" ]
do
	list="$list \"$1\""
	shift
done
bash<<EOF
	amarok --load $list
EOF
amarok --play

#3
:<<\EOF
IFS='
'
amarok --pause; amarok --stop
home=`pwd`
until [ -z "$1" ]
do
	if [ -d "$1" ]
	then
		list="$list
`find "$1" -type f -not \( -path "$home/.*" -o -path "$home/*/.*" -prune \)`"
	else
		playlist="$playlist \"$1\""
	fi
	shift
done

for i in $list
do
	playlist="$playlist \"$i\""
done

bash<<EOF
	amarok --load $playlist
EOF
amarok --play

#2
:<<\EOF
until [ -z "$1" ]
do
	if [ -d "$1" ]
	then
		list="$list
`find "$1" -type f -not \( -path "`pwd`/.*" -o -path "`pwd`/*/.*" -prune \)`"
	else
		playlist="$playlist \"$1\""
	done
	shift
done

amarok --load --play "`echo "$list" | sed -n 1p`"
for i in $( echo "$list" | sed '1d' )
do
	playlist="$playlist \"$i\""
done
bash<<EOF
	amarok --append $playlist
EOF

#1
:<<\EOF
amarok --load --play "$1"
shift
until [ -z "$1" ]
do
	list="$list \"$1\""		
	shift
done
bash<<EOF
amarok --append $list
EOF

exit
