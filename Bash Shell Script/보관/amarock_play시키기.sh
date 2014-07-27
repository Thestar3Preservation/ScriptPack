#!/bin/bash
#다른 방식으로 이 스크립트에서 추구하는 바를 얻어냄. 이건 백업용. 작동안됨. 미완성.

#날자 계산을 해야함. 이떄, 현재시간을 기준으로 하는게 아니라, 수정될 파일을 기준으로 가감연산을 해야함.

IFS='
'

#/tmp/amarok_check1 은 기준
#/tmp/amarok_check2 는 기준에서 +3
#/tmp/amarok_check3 는 검사

if [ ! -f /tmp/amarok_check1 ]
then
 touch -t `date +%C%y%m%d%H%M -d "-1 second"` /tmp/amarok_check1
fi
touch -t `date -r /tmp/amarok_check1 -d "+1 second" +%C%y%m%d%H%M` /tmp/amarok_check2
touch /tmp/amarok_check3
if [ /tmp/amarok_check2 -ot /tmp/amarok_check3 ] #아직 3초 내라면
then
 amarok --append "$@"
else #3초 밖이라면
 amarok --load --play "$@"
 touch /tmp/amarok_check1
fi


if [ ! -f /tmp/amarok_check1 -o /tmp/amarok_check1 -nt /tmp/amarok_check2 ]
then
 
 touch /tmp/amarok_check1
 touch /tmp/amarok_check2
fi

touch -t `date -d "-3 second"` /tmp/amarok_check2

[ /tmp/amarok_check1 -nt /tmp/amarok_check2 ] && amarok --load --play "$@" || amarok --append "$@"

#for i in $(echo "$@" | sed '1d')
#do
# amarok --append "$i"
#done

 echo '

================================' >> ~/test/a.txt
 echo "$@" >> ~/test/a.txt


exit
