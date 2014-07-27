#!/bin/bash
source ~/Home/쉘스크립트/function.sh
IFS='
'
# ex)git clone https://github.com/Thestars3/arkzip
git clone "$URL"
#해당 폴더에 해당 이름을 가진 폴더가 생성된다.
exit
