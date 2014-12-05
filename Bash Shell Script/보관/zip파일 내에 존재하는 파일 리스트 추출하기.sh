#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

#zip파일 내에 존재하는 파일 리스트 추출하기
unzip -l a.zip | head -n -2 | tail -n +4 | awk '{print substr($0,index($0,$4))}'

exit
