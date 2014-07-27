#!/bin/bash
#두개의 파일을 선택(wav, cue)하고, 스크립트를 실행시키면, flac파일 생성.

IFS='
'

find ./ -type f -name '*.cue' | while read file; do
	home=`pwd`
	DIR=`dirname "$file"`
	file=`basename "$file" .cue`
	if ls "$DIR/$file.flac"
	then
		cd "$DIR"
		cuebreakpoints "$file.cue" | shnsplit -o flac "$file.flac"
		cuetag "$file.cue" split-track*.flac
	fi
	cd "$home"
done
notify-send -i info "음원 압축해제 완료" "<a href='$home'>`dirname "$home"`</a>을(를) 작업완료함"

exit
