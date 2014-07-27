#!/bin/bash
#현재 기본 재생 프로그램은 bashee로 등록되어 있습니다.
source ~/.bash_profile
LOAD_USER_FUNTION

FALSE=boolean:false
Repeat_NO=0 #반복 기능 해제 상태
Repeat_ALL=1 #모두 반복 상태
Repeat_ONE=2 #한 곡 반복 상태

control(){ dbus-send --print-reply --type=method_call --session --dest=org.bansheeproject.Banshee /org/bansheeproject/Banshee/${1//./\/} org.bansheeproject.Banshee.$1.$2 $3; }
stop(){ control PlayerEngine Close; }
play(){ control PlayerEngine Play; }
next(){ control PlaybackController Next $FALSE; }
getData(){ tail -n1 | grep -oP "$1"; }
getPath(){ control PlayerEngine GetCurrentUri | getData '(?<="file://).*(?=")' | url_decoding; }
notify(){ notify-send --urgency=low "$@"; }

case "$1" in
#기존의 재생목록을 비우고, 선택된 대상들로 부터 음원파일 목록을 만들어 해당 음원목록을 재생합니다.
load)
	stop
# 	sqlite3 -batch ~/.config/banshee-1/banshee.db <<<"DELETE FROM coretracks WHERE PrimarySourceID = (SELECT PrimarySourceID FROM CorePrimarySources WHERE StringID = 'FileSystemQueueSource-file-system-queue');"
	shift
	banshee --play-enqueued "$@"
	play
	;;
ToggleRepeat)
	SetRepeat(){ control PlaybackController SetRepeatMode int32:$1; }
	case $(control PlaybackController GetRepeatMode | getData '[0-9]+$') in
	$Repeat_NO)
		SetRepeat $Repeat_ALL
		notify '밴시 : 모두 반복이 설정되었습니다.'
		;;
	$Repeat_ALL)
		SetRepeat $Repeat_ONE
		notify '밴시 : 한 곡 반복이 설정되었습니다.'
		;;
	$Repeat_ONE)
		SetRepeat $Repeat_NO
		notify '밴시 : 반복 기능이 해제되었습니다.'
		;;
	esac
	;;
ToggleShuffle)
	SetShuffleMode(){ control PlaybackController SetShuffleMode string:$1; }
	case $(control PlaybackController GetShuffleMode | getData '(?<=").*(?=")') in
	song)
		SetShuffleMode off
		notify '밴시 : 순서 섞기 기능이 해제되었습니다.'
	;;
	*)
		SetShuffleMode song
		notify '밴시 : 순서 섞기 기능이 설정되었습니다.'
	;;
	esac
	;;
show) 
	control ClientWindow Present
	;;
hide) 
	control ClientWindow Hide
	;;
play) 
	play
	;;
stop) 
	stop
	;;
AddMusicList)
	T1=$(getPath)
	T2=$PATH_MUSIC/$(basename "$T1")
	if [ -f "$T2" ] && [[ $(md5sum --binary "$T1" "$T2" | cut -d' ' -f1 | sort -u | wc -l) == 1 ]]; then
		notify '사용자 음악 폴더에 이미 추가된 파일입니다.'
	else
		notify '사용자 음악 폴더에 현재 재생중인 파일을 복사합니다.'
		dupev_cp "$T1" "$PATH_MUSIC"
	fi
	;;
TogglePlayStop) control PlayerEngine TogglePlaying;;
DeletePlayTrack)
	TEMP=$(getPath)
	if grep -Eqi "^$(g_quote "$PATH_MUSIC")/" <<<"$TEMP"; then
		next
		notify '현재 재생중인 파일을 삭제 합니다.'
		trash-put -v "$TEMP"
		#[ $(control Tracks.Track GetTrackCount | tail -n1 | grep -oE '[0-9]+$') == 0 ] && stop
	else
		notify '사용자 음악 폴더에 있지 않은 파일은 삭제가 금지되어 있습니다.'
	fi
	;;
next) 
	next
	;;
previous) 
	control PlaybackController Previous $FALSE
	;;
esac

exit