#!/usr/bin/env bash_record
source ~/.bash_profile
LOAD_USER_FUNTION
bashcolorset

home=$PWD
mkdir -p ./link/html 2>/dev/null

echo_red(){
	echo -en "$COL_RED"; echo -n "$1"; echo -e "$COL_RESET"
}

call_error_chen(){
	echo_red '이 문서를 해독할수 없습니다.' >&2
	ln -s "$PWD/$i" "$home/link/html/$(dupev_name -p "$home/link/html" -- "$i")"
	continue
}

for i in $(find "$home" -type f -iname '*.htm' -o -iname '*.html'); do
	echo
	echo -en ">>>$COL_CYAN"; echo -n "$i"; echo -e "$COL_RESET<<<"
	unset change
	cd "$(dirname -- "$i")"
	i=$(basename -- "$i")
	name=$(dupev_name -n -p . .$$)
	encoding=$(nkf -g -- "$i")
	case $encoding in
		BINARY)
			call_error_chen;;
		UTF-8)
			code=$(cat -- "$i");;
		*)
			for encoding in UHC JOHAB $encoding; do
				code=$(iconv -f $encoding -- "$i") && break
			done
			[ $? != 0 ] && call_error_chen
			change=y;;
	esac
# 	if ! grep -iF -m 1 -e '<!DOCTYPE' -e '<html>' -- "$i"; then
# 		echo -en "$COL_RED"; echo -n '이 파일은 HTML문서가 아닙니다.'; echo -e "$COL_RESET"
# 		continue
# 	fi
	if check=$(grep -Ei 'charset=[^ "]+' -- "$i") && ! grep -Fi UTF-8 <<<"$check"; then
		change=y
		code=$(perl -0pe 'use encoding "utf8"; s/charset=[^ "]+/charset=UTF-8/' <<<"$code")
	fi
	if [ "$change" = y ]; then
		echo_red '이 문서는 변화가 있습니다.'
		cat <<<"$code" > "$name"
	else
		echo_red '이 문서는 변화가 없습니다.'
		continue
	fi
	trash-put -v -- "$i"
	mv "$name" "$i"
done

ls -A "$home/link/html" | stdincheck && xdg-open "$home/link/html"

exit