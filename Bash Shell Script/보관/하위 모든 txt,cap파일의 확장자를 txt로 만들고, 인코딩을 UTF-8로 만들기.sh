#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION
bashcolorset

#CP51932의 경우, UHC로 강제 -f를 붙여 iconv로 변환한다.

home=$PWD
mkdir -vp ./{tmp,link_txt} 2>/dev/null

echo_red(){ echo -en "$COL_RED"; echo -n "$1"; echo -e "$COL_RESET"; }

call_error_chen(){
	echo_red '이 문서를 해독할수 없습니다.' >&2
	ln -s "$PWD/$i" "$home/link_txt/$(dupev_name -p "$home/link_txt" -- "$i")"
	continue
}

for i in $(find "$PWD" -type f -iname '*.txt' -o -iname '*.cap'); do
	echo -en "\n>>>$COL_CYAN"; echo -n "$i"; echo -e "$COL_RESET<<<"
	cd "$(dirname -- "$i")"
	i=$(basename -- "$i")
	if grep -qi '\.cap$' <<<"$i"; then
		echo_red '이 문서는 확장자가 cap->txt로 변화됩니다.'
		tmp=$(dupev_name -p . -- "$(ex_name "$i").txt")
		mv -v "$i" "$tmp"
		i=$tmp
	fi
	encoding=$(nkf -g -- "./$i")
	case $encoding in
		UTF-8)
			echo_red '이 문서는 이미 UTF-8입니다.'
			continue;;
		*)
			for encoding in UHC JOHAB $encoding; do
				code=$(iconv -f $encoding -- "$i") && break
			done
			[ $? != 0 ] && call_error_chen;;
	esac
	echo_red '이 문서는 변화가 있습니다.'
	cat <<<"$code" > "$home/tmp/$i"
	trash-put -v -- "$i"
	mv "$home/tmp/$i" "$i"
done

ls -A "$home/link_txt" | stdincheck && xdg-open "$home/link_txt"
rmdir "$home/link_txt" 2>/dev/null
trash-put "$home/tmp"

exit