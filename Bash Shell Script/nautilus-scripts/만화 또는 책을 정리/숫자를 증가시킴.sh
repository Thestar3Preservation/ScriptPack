#!/usr/bin/env bash_record
source ~/.bash_profile
LOAD_USER_FUNTION
#0~22순으로 앞에 붙은 순서의 수치를 증가시켜줍니다.
#파이어폭스 에드온 download them all을 이용한 사진 일괄 다운로드 기능에 사용되기 적합하도록 만들어졌습니다.
input=`zenity --entry \
              --title '수치 입력 창' \
              --text '증가시킬 수치를 입력해주세요.'`
if [ $? = 0 ]
then
	echo "$PWD에서"
	if ls -1 | grep -xE '^[0-9]+\.[^\.\s]+$'; then
		mkdir a
		if ls -1 0*; then
			tc=`ls -A1 | wc -l | tr -d '\n' | wc -m`
			for a in *; do
				mv "$a" "a/`printf "%0${tc}d" $(($(echo "$a" | sed -r 's/^0*([0-9]+)\..*/\1/')+$input))`.`echo "$a" | sed -r 's/^.*\.([^\.\s]+)$/\1/'`"
			done
		else
			for a in $(ls | grep -vx a); do
				mv "$a" "a/$(($(echo "$a" | sed -r 's/^([0-9]+)\..*/\1/')+$input)).$(echo "$a" | sed -r 's/^.*\.([^\.\s]+)$/\1/')"
			done
		fi
	else
		for i in `ls -1 | grep -E '^[0-9]{3}'`; do
			tn=$(echo "$i" | sed -r 's/^([0-9]{3}).*$/\1/')
			tn=`expr $tn + $input`
			c=$(echo -n "$tn" | wc -m)
			if [ $c = 1 ]
			then
				tn=$(echo "00$tn")
			elif [ $c = 2 ]
			then
				tn=$(echo "0$tn")
			fi
			name=$(echo "$i" | sed -r "s/^[0-9]{3}/$tn/")
			mv -Tv "$i" "$name"
		done
	fi
	mv a/* .
	rmdir a
	notify-send -i info '숫자를 증가시킴' 완료
else
	echo '작업이 취소되었습니다.'
fi
exit