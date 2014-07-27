#!/bin/bash
source ~/.bash_profile
# LOAD_USER_FUNTION

#gnash는 일부 파일 경로에서 정상적으로 파일을 찾아 오지 못합니다. 이를 해결하기 위해, 불러올 파일에 대한 심볼릭 링크를 생성시킨뒤, 원본 대신 링크에 접근합니다.

temp=/tmp/.swfopen
mkdir -- "$temp"
link=$temp/$RANDOM$RANDOM$RANDOM.swf
ln -s "$1" "$link"
gnash -- "$link"
#gnash-gtk-launcher

exit