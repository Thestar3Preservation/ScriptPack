#!/usr/bin/env bash_record
source ~/.bash_profile
echo "현재 위치에서 관리자 권한으로 탐색창을 엽니다. 위치 : $PWD"
gksudo caja "$PWD"
exit