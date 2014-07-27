#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

if [ $# = 0 ]; then
	echo '램덤값 생성기'
	echo '/dev/urandom을 사용합니다. 단시간에 여러번 반복하지 마십시오(같은 값이 나올수 있습니다).'
	echo '첫번째 인자의 값은 1이상의 정수여야 하며, 그 수치만큼의 길이로 랜덤값을 생성해옵니다. 출력은 hex값입니다.'
	exit 0
elif [ $# != 1 ]; then
	echo '인자의 갯수가 올바르지 않습니다!' >&2
	exit 1
fi

if [ -n "$1" -a "$1" != 0 ] && grep -qEx '[0-9]+' <<<"$1"; then
	size=$1
else
	echo '첫번째 인자는 1이상의 정수여야 합니다!' >&2
	exit 1
fi

TEMP=$(xxd -l $((size/2+1)) -p /dev/urandom)
(( size > 60 )) && TEMP=$(tr -d '\n' <<<"$TEMP")
echo "${TEMP:0:size}" | tr [:lower:] [:upper:]

exit 0