#!/usr/bin/env bash_record
#cue와 나누어질 mp3, ogg, wav, wv, ape, flac등의 파일을 선택하면, cue파일을 기준으로 해당 단일음원 파일이 여러개로 눕니다.
source ~/.bash_profile
LOAD_USER_FUNTION

errorReport(){
	echo "Error : $1" >&2
	notify-send -u critical "CUE 풀기 : $1"
	exit
}

ConvertCommon(){
	local point=$(cuebreakpoints /tmp/CUE_$$.cue)
	if [ -z "$point" ]; then
		cuetag /tmp/CUE_$$.cue "$target"
		dupev_mv "$target" "$(cueprint -n 1 -t %t /tmp/CUE_$$.cue).$ext"
	else
		[ -n "$(ls split-track*.flac)" ] && errorReport '작업 대상과 중복되는 대상이 존재합니다.'
		shnsplit -o flac "$target" <<<"$point"
		cuetag /tmp/CUE_$$.cue split-track*.flac
		local n
		for n in $(seq -f %02g `cueprint -d %N /tmp/CUE_$$.cue`); do
			local title=$(cueprint -n $n -t %t /tmp/CUE_$$.cue)
			local name
			if [ -n "$title" ]; then
				name="$n. $title.flac"
			else
				name="Track$n.flac"
			fi
			dupev_mv split-track$n.flac "$name"
		done
	fi
}

cuePath=$(basename -- "$(grep -i '\.cue$' <<<"$CAJA_SCRIPT_SELECTED_FILE_PATHS")")
target=$(basename -- "$(grep -iv '\.cue$' <<<"$CAJA_SCRIPT_SELECTED_FILE_PATHS")")
[ -z "$cuePath" ] && errorReport 'CUE 파일이 선택되지 않았습니다.'

iconv -f=$(nkf -g "./$cuePath") -c -t=UTF-8 -o /tmp/CUE_$$.cue "$cuePath"
ext=$(ex_ext -d -- "$target")

case "$ext" in
ogg )
	#cuebreakpoints "$cue" | shnsplit -o 'cust ext=ogg oggenc - -o %f' -f CDImage.cue -t "%n.%p - %a - %t" CDImage.ape
	mp3splt -a -c /tmp/CUE_$$.cue "$target" -o "@n. @t"
	;;
mp3 )
	mp3splt -o "@n. @t" -c /tmp/CUE_$$.cue "$target" #-n
	;;
flac | ape | wav | wv )
	ConvertCommon
	;;
tta )
	
	TEMP=$(sed "s/$ext$/wav/" <<<"$target")
	[ -e "$TEMP" ] && errorReport '작업 대상과 중복되는 대상이 존재합니다.'
	pacpl --to wav "$target"
	trash-put -- "$target"
	target=$TEMP
	ext=wav
	ConvertCommon
	;;
* )
	errorReport '이 확장자에 대해선 처리 명령이 지정되지 않았습니다.'
	;;
esac

trash-put -- "$cuePath" "$target"
notify-send -i info "음원 압축해제 완료" "<a href='$PWD'>$target</a>을(를) 작업완료함"
exit