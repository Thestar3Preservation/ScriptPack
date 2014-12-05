#!/bin/bash
#history에서 사용한 명령어만 추출해내기
history | awk '{print substr($0,index($0,$2))}'

exit
