#!/usr/bin/env bash_record
#cue와 나누어질 mp3, ogg, wav, wv, ape, flac등의 파일을 선택하면, cue파일을 기준으로 해당 단일음원 파일이 여러개로 눕니다.
source ~/.bash_profile
LOAD_USER_FUNTION

TEMP_DIR_PATH=/tmp/.convcue
TEMP_CONVERTED_CUE_PATH=$TEMP_DIR_PATH/$$.cue
WORKDIR_PATH=$PWD

errorReport(){
	echo "Error : $1" >&2
	notify-send -u critical "CUE 풀기 : $1"
	exit
}

ConvertCommon(){
	local point=$(cuebreakpoints $TEMP_CONVERTED_CUE_PATH)
	if [ -z "$point" ]; then
		cuetag $TEMP_CONVERTED_CUE_PATH "$target"
		dupev_mv "$target" "$(cueprint -n 1 -t %t $TEMP_CONVERTED_CUE_PATH).$ext"
	else
		[ -n "$(ls split-track*.flac)" ] && errorReport '작업 대상과 중복되는 대상이 존재합니다.'
		shnsplit -o flac "$target" <<<"$point" || errorReport 'shnsplit을 실패했습니다.'
		cuetag $TEMP_CONVERTED_CUE_PATH split-track*.flac
		local n
		for n in $(seq -f %02g `cueprint -d %N $TEMP_CONVERTED_CUE_PATH`); do
			local title=$(cueprint -n $n -t %t $TEMP_CONVERTED_CUE_PATH)
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

umask 0022

cuePath=$(basename -- "$(grep -i '\.cue$' <<<"$CAJA_SCRIPT_SELECTED_FILE_PATHS")")
target=$(basename -- "$(grep -iv '\.cue$' <<<"$CAJA_SCRIPT_SELECTED_FILE_PATHS")")
[ -z "$cuePath" ] && errorReport 'CUE 파일이 선택되지 않았습니다.'

mkdir -p $TEMP_DIR_PATH
iconv -f=$(nkf -g "./$cuePath") -t=UTF-8 -o $TEMP_CONVERTED_CUE_PATH "$cuePath" || errorReport 'CUE 파일의 인코딩 변환 작업이 실패했습니다. '
ext=$(ex_ext -d -- "$target")

case "$ext" in
ogg )
	#cuebreakpoints "$cue" | shnsplit -o 'cust ext=ogg oggenc - -o %f' -f CDImage.cue -t "%n.%p - %a - %t" CDImage.ape
	mp3splt -a -c $TEMP_CONVERTED_CUE_PATH "$target" -o "@n. @t"
	;;
	
mp3 )
	mp3splt -o "@n. @t" -c $TEMP_CONVERTED_CUE_PATH "$target" #-n
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
	
tak )
	TEMP=$(sed "s/$ext$/wav/" <<<"$target")
	[ -e "$TEMP" ] && errorReport '작업 대상과 중복되는 대상이 존재합니다.'
	TEMP_TAK_NAME=$$.tak
	TEMP_WAV_NAME=$$.wav
	rm -f $TEMP_DIR_PATH/$TEMP_WAV_PATH
	ln -fs "$PWD/$target" $TEMP_DIR_PATH/$TEMP_TAK_NAME
	cd $TEMP_DIR_PATH
	wine "$PATH_APPLICATIONDIR/TAK_2.3.0/Applications/Takc.exe" -d $TEMP_TAK_NAME $TEMP_WAV_NAME || errorReport 'TAK -> WAV 변환 도중 오류가 발생했습니다.'
	cd "$WORKDIR_PATH"
	mv $TEMP_DIR_PATH/$TEMP_WAV_NAME "$TEMP"
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
