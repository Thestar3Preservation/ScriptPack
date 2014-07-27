#!/bin/bash
IFS='
'

#현재위치를 기억
home=`pwd`

#작업 대상이 될 위치들을 추출
temp=`find . -type d`

#역순으로 정렬
last=`echo "$temp" | fgrep -c ''`
countt=$last
for i in `seq $last`
do
 temp2=`echo "$temp2"; echo "$temp" | sed -n "${countt}p"`
 countt=`expr $countt - 1`
done

#파일 이름을 고침
echo -e "\n파일 이름을 고칩니다."; echo "작업위치 : $home";
for i in $temp2
do
 cd "$i" #작업 위치로 이동
 echo ''; echo "$i에서"
 for a in `ls`
 do
  f=$(echo "$a" | sed -r -e 's/[0-9]+$//' -e 's/[-]$//' -e "s/^$RANDOM//") #공통 수정
  if [ "$a" != "$f" -a -e "$f" ] #수정될 이름을 가진 대상이 존재하는지 확인
  then
   erro=$(echo "$erro"; echo "$i/$a") #에러 목록을 작성
  elif [ "$a" != "$f" -a ! -e "$f" ]
  then
   mv -Tv "$a" "$f" #이름을 수정
  fi
 done
 cd "$home" #초기 위치로 복귀
done

#작업 결과를 알림
if [ "$erro" ]
then
 for i in $erro
 do
  path=$(dirname "$i")
  name=$(basename "$i")
  erro_list=`echo -n "${erro_list} \"$name\" \"$path\""`
 done
 bash <<EOF
 zenity --list \
        --title "알림" \
        --text "수정될 이름을 가진 대상이 존재합니다!" \
        --height 400 \
        --column '이름' \
        --column '위치' $erro_list
EOF
else
 if [ "$1" != no ]
 then
  zenity --info --title '알림' --text '작업이 완료되었습니다.'
 fi
fi

exit
