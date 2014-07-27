#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION

echo 'mp3 비트레이트 평균값으로 삭제함. 소수점 버린값으로 계산함. 256kbps미만 모두 휴지통으로.'
for i in $(find . -type f -iname '*.mp3'); do
	code=$(mp3info -r a -p '%r' "$i" | grep -xE '[.0-9]+' | cut -d . -f 1);
	[ -n "$code" ] && (( 256 > code )) && trash-put "$i";
done

exit