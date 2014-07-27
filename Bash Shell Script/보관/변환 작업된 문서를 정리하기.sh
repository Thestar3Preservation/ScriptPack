#!/bin/bash

{
echo '=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+'
date

IFS='
'

mkdir ~/Home/작업공간/...wkrdjqwnd
cd ~/Downloads
ls | grep -iEx 'files\({0,1}[0-9]*\){0,1}.zip' | xargs -I{} mv {} ~/Home/작업공간/...wkrdjqwnd
cd ~/Home/작업공간/...wkrdjqwnd
ls | xargs -I{} unzip {}
mv -v * ~/Home/작업공간/link_document
cd ~/Home/작업공간/link_document
rm -vr ~/Home/작업공간/...wkrdjqwnd

for i in `ls | grep -i '\.doc$' | xargs -I{} readlink {}`
do
 path=`dirname "$i"`
 name=`basename "$i" | sed 's/\.doc$//I'`
 for t in `ls | fgrep -ixe "$name.fb2" -ixe "$name.pdf" -ixe "$name.txt"` #`ls "$name" | grep -ie '\.pdf' -ie '\.fb2' -ie '\.txt'`
 do
  mv -v "$t" "$path"
 done
done

cd ..
rm -rv ~/Home/작업공간/link_document

echo ''
} 2>&1 | tee -a ~/"Home/.usersys/Log_nautilus-scripts/$(basename "$0").log"

exit
