#!/usr/bin/env bash_record
source ~/.bash_profile
LOAD_USER_FUNTION
#대상은 UTF-8로 예상되며, 잘못된 문자는 제외시켜 엽니다.
if test -z "$*"; then
	echo '작업 대상이 지정되지 않아 작업을 종료합니다.' >&2
	exit
fi
echo "작업 위치 : $PWD"
savepath=/tmp/convert_txt
mkdir "$savepath" 2>/dev/null
chmod 700 "$savepath"
for target; do
	echo "작업 대상 : $target"
	ext=$(ex_ext -- "$target")
	that=$savepath/`ex_name "$target"`_변환됨${ext:+.$ext}
	iconv -c "$target" -o "$that"
	pluma "$that"
done
exit
