#!/usr/bin/env bash_record
#토렌트 파일 및 그 찌꺼기 파일, 빈 폴더, gedit 임시파일, doc임시 파일, 윈도우에서 생성한 그림인덱싱파일. 만약, 해당 작업 영역에서 편집기를 사용중이라면 모든 작업을 완료한뒤 시도해주세요.
source ~/.bash_profile
LOAD_USER_FUNTION
echo "'$PWD'에서 작업됨"
targetlist=( '*.torrent.added' '*.torrent.invalid' '.goutputstream-*' '.~lock.*' 'Thumbs.db' 'photothumb.db' '.fuse_hidden*' '.*.kate-swp' ) # '*.torrent'
for i in "${targetlist[@]}"; do
	target+=( -o -iname "$i" )
done
unset target[0]
for i in $(if [ -n "$full" ]; then find . -depth -mindepth 1 \( -type f \( "${target[@]}" \) \) -o -type d; else find . -depth -mindepth 1 -maxdepth 1 \( -type f \( "${target[@]}" \) \) -o -type d; fi); do
	#| xargs -I{} -d '\n' trash-put -- {}
	[ -d "$i" ] && { test -z "$(ls -A "$i")" || continue; }
	trash-put -v -- "$i"
done
test "$noNotity" = y || notify-send "$([ -n "$full" ] && echo '하위 모든 영역에서' || echo '현재 영역에서') 모든 찌꺼기 파일을 삭제하였습니다."
exit