#!/usr/bin/env bash_record
source ~/.bash_profile
echo "다음을 언마운트 합니다."
echo "$*"
sudo userumount "$@"
exit