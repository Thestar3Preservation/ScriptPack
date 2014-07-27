#!/bin/bash

{
echo '=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+'
date

IFS='
'

path="`pwd`"

#for i in `find "$(pwd)" -iname '*.doc' -type f`
if [ "$path" = "$HOME/Home/작업공간/보존 작업 중" -o "$path" = "/media/ntfs_ssd/Homedir/작업공간/보존 작업 중" ]
then
 temp=`find . ! \( -path "./정리완료" -prune \) -iname '*.doc' -type f`
else
 temp=`find . ! -iname '*.doc' -type f`
fi
for i in $temp #`find . ! \( -path "./작업공간/보존 작업 중/정리완료" -prune \) -iname '*.doc' -type f`
do
 url=`dirname "$i"`
 name=$(basename "$i" | sed 's/\.doc//I')
 finame=$(echo "$name" | sed -e 's/\?/\\?/g' -e 's/\^/\\^/g' -e 's/\[/\\[/g' -e 's/\]/\\]/g' -e 's/\*/\\*/g')
 if [ ! "`find "$url" \( -iname "$finame.fb2" -o -iname "$finame.pdf" -o -iname "$finame.txt" \) -prune`" ]
 then
  #echo "$name" #echo "$finame" #| sed -e 's/\?/\\?/g' -e 's/\^/\\^/g' -e 's/\[/\\[/g' -e 's/\]/\\]/g' -e 's/\*/\\*/g'
  linkt=`echo "$linkt"; echo "$i"`
  arlim=`echo "$arlim"; echo "$url...vlfemrnqns...$name.doc"`
 fi
done

#arlim=`echo "$arlim" | sort`
for i in `echo "$arlim" | sort` #$arlim
do
 #context=`echo -n "$context'"; echo "$i" | cut -d '...vlfemrnqns...' -f 1; echo -n "' '"; echo "$i" | cut -d '...vlfemrnqns...' -f 2; echo -n "' "`
 context=`echo -n "$context'"; echo "$i" | awk -F '...vlfemrnqns...' '{ print $2 }' | tr -d "\n"; echo -n "' '"; echo "$i" | awk -F '...vlfemrnqns...' '{ print $1 }' | tr -d "\n"; echo -n "' "`
done

if [ "$context" ]
then
 bash <<EOF
  zenity --list \
         --title "변환되지 않은 문서목록" \
         --width 700 \
         --height 400 \
         --text '링크를 생성시키려면 확인을, 아니면 취소를 눌러주세요.' \
         --column '문서이름' \
         --column '경로' $context
EOF

 if [ $? = 0 ]
 then
  mkdir ~/Home/작업공간/link_document

  for i in $linkt
  do
   i=$(echo "$i" | sed 's/^\.//')
   ln -vs "$path$i" ~/Home/작업공간/link_document
  done

 fi

else
 zenity --info --title "검색 결과에 대한 알림" --text "모든 doc문서는 변환되어 있습니다."
fi

echo ''
} 2>&1 | tee -a ~/"Home/.usersys/Log_nautilus-scripts/$(basename "$0").log"

exit
