#!/bin/bash
#다운로드 디렉토리에 새로운 파일이 나타났을 경우 실행됩니다. 파일명 변경도 이동으로 감지함.
#iwatch %f로 인자를 넘겨줄 경우 무조건 인자는 하나.
#iwatch는 상대경로로 인자를 넘겨줌. 불러와진 프로그램 역시 iwatch와 동일 경로에서 실행됨.
watchdir=$HOME/Home/Downloads
cd "$watchdir" || exit
source ~/Home/쉘스크립트/function.sh
IFS=$'\n'
P_image=( '\.jpg$' '\.jpeg$' '\.png$' '\.gif$' )
P_trash=( '\.torrent\.added$' '\.torrent\.invalid$' '^\.goutputstream-' '^\.~lock\..*' )
P_subtitle=( '\.smi$' '\.ass$' )
P_ignore=( '\.torrent$' '\.part$' )
while true; do
	target=$(inotifywait --format %f -e create -e moved_to "$watchdir")
	if [ -f "$target" ]; then
		name=$(ex_name "$target")
		ext=$(ex_ext "$target")
		if grep -i "${P_ignore[*]}" <<<"$target"; then
			exit
		elif grep -i "${P_image[*]}" <<<"$target"; then
			dupev_mv -- "$target" "$HOME/Home/Pictures/`trim_webname "$name"`.$ext"
		elif grep -i "${P_trash[*]}" <<<"$target"; then
			trash-put "$target"
		else #파이어폭스 다운로드를 감지
		target=$(inotifywait --format %f -e create -e moved_to "$watchdir")
			if ! grep -ix '\.part$' <<<"$target" && ! ls "$target.part"; then
				if grep -i "${P_subtitle[*]}" <<<"$target"; then
					"$HOME/Home/.usersys/bin/subtitleconveting.sh" "$target"
				fi
				dupev_mv -- "$target" "`trim_webname "$name"`.$ext"
			fi
		fi
	fi
done
exit
