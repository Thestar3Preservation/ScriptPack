#!/usr/bin/env bash_record
source ~/.bash_profile
LOAD_USER_FUNTION
echo "PWD : $PWD"
for i; do
	echo "TARGET : $i"
	if [ -d "$i" ]; then
		icon=folder
	elif grep -q -i -e '\.html$' -e '\.htm$' <<<"$i"; then
		icon=gnome-fs-bookmark
	else
		icon=emblem-symbolic-link
	fi
	count=0
	until ((++count > 10)); do
		name=$RANDOM$RANDOM
		[ ! -e $name.desktop ] && break
	done
	if [ $? != 0 ]; then
		echo '링크 파일 작성 중 오류가 발생했습니다!' >&2
		continue
	fi
	echo "\"$i\"의 바로가기 $name.desktop을 만듭니다." >&2
	{ echo '[Desktop Entry]'
	echo 'Encoding=UTF-8'
	echo 'Type=Link'
	echo "Icon=$icon"
	echo "Name=$(sed 's/\\/\\\\/g; s/^/\\n/' <<<"$i" | tr -d '\n' | sed 's/^\\n//')의 바로가기"
	echo "URL=file://$(url_encoding --path "$PWD/$i")"; } > "$name.desktop"
done
exit