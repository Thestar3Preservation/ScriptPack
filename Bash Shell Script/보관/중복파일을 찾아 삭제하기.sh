#!/usr/local/bin/bash_record --changename duplicationFileDelete
source ~/.bash_profile
#LOAD_USER_FUNTION

#중복파일을 모두 삭제; 하위 모든 영역에서 중복되는 파일을 찾아 삭제하여, 중복되는 같은 파일 중에서 하나의 파일만 남겨둡니다.
path=$(realpath -- "$1")
echo "'$path'에서 중복파일을 삭제함."
fdupes --recurse --sameline --delete --noprompt --quiet "$path" #--omitfirst
echo -e '\n빈 폴더를 삭제함.'
find "$path" -depth -type d -empty -delete
notify-send "'$path'에서 중복파일 삭제를 완료하였습니다."
echo -e '\n중복 파일 삭제를 완료함.'
exit