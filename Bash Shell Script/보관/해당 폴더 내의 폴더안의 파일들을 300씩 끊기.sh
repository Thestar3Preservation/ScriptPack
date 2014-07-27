#!/bin/bash

IFS='
'

for i in $(find . -maxdepth 1 -type d | sed '1d' | sed 's/\.\///')
do
 mkdir ".$i"
 while :
 do
  e=$(ls "$i" -A -1 | grep -m 300 '') #| xargs -I{} mv ./lemon02/{} 1
  if [ ! "$e" ]
  then
   break
  fi
  c=`expr $c + 1`
  mkdir ./".$i/$c"
  echo "$e" | xargs -I{} mv ./"$i/{}" ./".$i/$c"
 done
unset c
rmdir "$i"
mv ".$i" "$i"
done

exit
