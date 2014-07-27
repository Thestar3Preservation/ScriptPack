#!/bin/bash
#hwp의 내용을 텍스트문서로 저장합니다. 뒤에 .search.txt란 확장자가 붙게 됩니다. 검색을 위한 파일입니다.
source ~/Home/쉘스크립트/function.sh
IFS='
'
tmp=/tmp/hwpconvert/$$
mkdir -p $tmp
home=$PWD
cd $tmp
for i in $(find "$home" -type f -iname '*.hwp'); do
	dir=`dirname "$i"`
	rname=$(basename "$i" | sed -r 's/\.([^.]+)$//')
	hwp5txt "$i" 2>/dev/null || hwp5proc xml "$i" | html2text -nometa -utf8 -o "$rname.txt"
	mv "$tmp/$rname.txt" "$dir/$rname.search.txt"
done
rm -r $tmp
rmdir /tmp/hwpconvert 2>/dev/null
exit
