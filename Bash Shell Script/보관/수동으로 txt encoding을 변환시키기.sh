#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION
bashcolorset

#테스트 완료. 정상적으로 작동함.
#일부 문서 변환시, 문자열을 밀려들어와서 read가 자동으로 패스되어 버리는 사태가 발생함.
#입력기와 보여주기를 따로 분리시켜서, 명령을 받아들일수 있도록 함. 터미널 두개, 네임드 파이프 1개.
#혹은 저장된 내용을 화면에 출력하게 하지 않고, 다른 터미널에서 자동으로 읽어오도록 시키면도 될것 같다.

mkfifo /tmp/txtconvfifo
mate-terminal --command "bash -c \"while true; do cat /tmp/txtconvfifo; echo -e ' ===================================================\n'; done\""

#작업한 심볼릭 링크들이 위치한 곳에서 실행시켜야 함.
mkdir -p /tmp/tmp_txt_converting
for i in $(ls -A); do
	for encoding in UHC JOHAB UTF-8; do
		iconv -f $encoding -c -- "$i" | tee /tmp/tmp_txt_converting/"$i" &> /tmp/txtconvfifo
		echo -en "\n>>>$COL_CYAN"; echo -n "$i"; echo -e "$COL_RESET<<<"
		read -p "이 문서는 $encoding이 맞습니까? (Y/N) : " -n1
		echo
		if [ "$REPLY" = y ]; then
			path=$(realpath -- "$i")
			trash-put "$path"
			mv -v /tmp/tmp_txt_converting/"$i" "$path"
			rm -v "$i"
			break
		fi
	done
	echo
done

exit