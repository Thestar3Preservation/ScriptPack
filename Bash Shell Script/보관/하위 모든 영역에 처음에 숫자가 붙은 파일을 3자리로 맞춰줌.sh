#!/bin/bash
#예를 들어 1,2,50,111을 001,002,050,111로 변경함.
#즉, 세자리 수 이하의 수에 대해, 수의 자릿수를 맞춰줌.

IFS='
'

date

IFS='
'

#작업 대상이 될 위치들을 추출
temp=`find "$(pwd)" -not \( -type d -name ".*" -prune \) -type d`

#역순으로 정렬
last=`echo "$temp" | fgrep -c ''`
countt=$last
for i in `seq $last`
do
 temp2=`echo "$temp2"; echo "$temp" | sed -n "${countt}p"`
 countt=`expr $countt - 1`
done
temp2=$(echo "$temp2" | sed '1d')

#파일 이름을 고침
for i in $temp2
do
 cd "$i"
 
 #파일 이름을 고침
 for a in `ls`
 do
  f=$(echo "$a" | sed -r -e 's/^([0-9]{2})[^0-9]/0\1/' -e 's/^([0-9])[^0-9]/00\1/')
  if [ "$a" != "$f" ]
  then
   mv -Tv "$a" "$f"
  fi
 done

done

#etc
#for i in *; do mv "$i" "`echo $(echo $i | sed -r -e 's/^K-//I' -e 's/^([0-9]{2})[^0-9]/0\1./' -e 's/^([0-9])[^0-9]/00\1./')`"; done

exit
