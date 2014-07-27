#!/usr/bin/env bash_record
#hwp를 odt로 변환을 시도하고, 실패하면 txt로 변환을 시도한다. 그래도 실패하면 에러 알림을 띄운다.
source ~/.bash_profile
LOAD_USER_FUNTION
mkdir /tmp/hwp
cd /tmp/hwp
name=$(ex_name "$1")
if [ ! "$(hwp5odt "$1" 2>&1)" ]; then
	xdg-open "$name.odt"
else
	hwp5proc xml "$1" | html2text -nometa -utf8 | read text
	if [[ $(wc -l <<<"$text") == 1 ]] && grep -xiF '<?xml version="1.0" encoding="utf-8"?>' <<<"$text"; then
		echo "$text" > "$name.txt"
		xdg-open "$name.txt"
	else
		notify-send -i error 'hwp->odt 변환 오류' "<a href='`dirname "$1"`'>$(basename "$1")</a>를 변환시키는데 실패했습니다."
	fi
fi
exit
