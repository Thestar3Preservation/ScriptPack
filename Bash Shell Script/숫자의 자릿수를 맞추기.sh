#!/usr/bin/env bash_record
#숫자 정렬하여 변환함. ㄴㅇㄹㄴㅇㄹ000, ㄴㅇㄹㄴㅇㄹ1 따위를 순서대로 0,1로 바꿔줌.
source ~/.bash_profile
LOAD_USER_FUNTION
noNotity=y "$PATH_BIN/찌꺼기 파일을 알아서 잘 제거하기.sh"
tc=$(ls -1 | wc -l | tr -d '\n' | wc -m)
count=0
tmp=$(dupev_name -n -p . -- temp)
mkdir -- "$tmp"
cd -- "$tmp"
for i in $(ls -1v ..); do
	ext=$(ex_ext "$i")
	test -z "$ext" && continue
	((count++))
	mv -v -- "../$i" "$(printf %0${tc}d $count).$ext"
done
mv -- * ..
cd ..
rmdir "$tmp" || test "$noNotity" = y || notify-send -i info '숫자의 자릿수를 맞추기' '임시폴더를 지우는데 문제가 생겼습니다.'
test "$noNotity" = y || notify-send -i info '숫자의 자릿수를 맞추기' 완료
exit

#이미 정렬된 대상을 숫자로 변환하는 명령어
#c=1; for a in *; do mv "$a" $((c++)).png; done