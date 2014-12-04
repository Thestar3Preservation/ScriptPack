#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

#pdf 파일을 cbz로 변환하기. (pdf가 모두 이미지로만 되어 있는 경우에만 사용가능)

for filepath in *.pdf; do
	filename=$(ex_name "$filepath")
	tempflodername=$(dupev_mkdir "$filename")
	pdfimages -j "$filepath" "$tempflodername/image"
	[ -z $(ls "$tempflodername" | grep -oE '\.[a-z0-9]+$' | sort -u | grep -vx -e '\.png' -e '\.jpg' -e '\.pbm') ] || pause
	for image in "$tempflodername"/*.pbm; do
		convert -- "$image" "$tempflodername/$(ex_name "$image").png" || pause
		rm -- "$image"
	done
	zip -q0rD "$(dupev_name -p . -- "$filename.cbz")" "$tempflodername"
	rm -r "$tempflodername"
done

exit
