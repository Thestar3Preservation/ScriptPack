#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

#사진 폴더에서 선택된 대상을 특정한 주제로 묶어 줍니다.

cd "$PATH_PICTURE/여러 이미지들"

# if [ -z "$CLIPBOARD" ]; then
# 	notify-send -u critical "클립보드가 비어있습니다."
# 	exit
# fi

THEME=$(zenity --entry --text '주제는?' | wl_replace) || exit
if [ -e "./$THEME" ]; then
	[ ! -d "./$THEME" ] && THEME=$(dupev_mkdir "./$THEME")
else
	mkdir "./$THEME"
fi

unset TARGET
for i in $(clip out); do
	if grep -q '^file:///' <<<"$i"; then
		i=$(sed 's#^file://##' <<<"$i" | url_decoding)
	fi
	TARGET+=( "$i" )
done
mv "${TARGET[@]}" "./$THEME"

notify-send '이동 작업 완료'

exit