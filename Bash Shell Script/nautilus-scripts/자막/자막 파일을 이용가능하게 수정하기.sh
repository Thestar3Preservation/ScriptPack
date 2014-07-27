#!/usr/bin/env bash_record
source ~/.bash_profile
#SMI,ASS자막 파일의 인코딩을 변경하고, SMI의 인식식별자를 감지해서 없을 경우 추가한다.
#어차피 읽어들일 파일은 무조건 UHC포멧이다. 미리 어떤 TYPE의 인코딩이 우선하는지 지정되어, 작업의 완성도가 보다 높아졌다.

convertingerror(){
		notify-send -i error '자막 변환 오류 발생!' "'$target'은 인식할수 없는 포멧형식을 가지고 있습니다\!"
		continue
}

for target in ${*-$(ls -A | grep -iE '\.(smi|ass)$')}; do
	encoding=$(nkf -g "$target")
	if [ $encoding = BINARY ]; then
		if converting=$(iconv -f UHC -t UTF-8 "$target"); then
			change=y
		else
			convertingerror
		fi
	elif [ $encoding = UTF-8 ]; then
		converting=$(cat "$target")
	else #인코딩이 인식할수 있으며, UTF-8이 아닌 경우
		for encoding in UHC $encoding; do
			converting=$(iconv -f $encoding -t UTF-8 "$target") && break
		done
		test $? != 0 && convertingerror
		change=y
	fi
	if grep -i '\.smi$' <<<"$target"; then
		if ! grep -m 1 -i '<SAMI>' <<<"$converting"; then
			converting='<SAMI>'$'\n'"$converting"
			change=y
		fi
	fi
	if grep -iEq '&#[0-9]+;?' <<<"$converting"; then
		change=y
		converting=$(perl -e 'use Encode; use CGI qw(unescapeHTML); while ( <STDIN> ) { while ( /(&#[0-9]+);?/i ) { $a = unescapeHTML($1.";"); Encode::_utf8_off( $a); $_ = $`.$a.$'\''; }; print $_; }' <<<"$converting")
	fi
	if [ "$change" = y ]; then
		trash-put "$target"
		cat <<<"$converting" >"$target"
	fi
done
exit