#!/bin/bash
#history에서 사용한 명령어만 추출해내기
history | awk '{print substr($0,index($0,$2))}'
#zip파일 내에 존재하는 파일 리스트 추출하기
unzip -l a.zip | head -n -2 | tail -n -3 | awk '{print substr($0,index($0,$4))}'
exit
