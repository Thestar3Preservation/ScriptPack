#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION

#하위 모든 영역에서 swf파일을 찾고, 이 파일의 음성을 mp3파일 또는 지정된 확장자로 저장.

ext=${1:-acc}

#swf -> mp3
#ffmpeg -i apehouse.swf -acodec copy apehouse.mp3
#flasm -x cnc-audio11.swf
#mplayer -dumpaudio cnc-audio11.swf -dumpfile dr.aspley-ivterview-pt1.mp3

for i in $(find "$PWD" -type f -iname '*.swf'); do
	cd "$(dirname "$i")"
	ffmpeg -i "$i" -acodec copy "$(dupev_name -p . -- $(ex_name "$i").$ext)"
done

exit