#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION

#펄스 오디오의 음량을 복구합니다. 펄스 오디오는 로그인 후 이전 값을 찾지 못하고, 음량이 100으로 설정되는 문제가 있습니다.
#음량 : 0~65537
volume=$(pacmd list-sinks | grep -m1 -E '^\s+volume: ' | grep -Po '[0-9]+(?=%$)' | echo "65537*0.`cat`" | bc | grep -oE [0-9]+) #| grep -oE '^[0-9]+')
[ $(wc -l <<<"$volume") != 1 ] && ((volume=$(head -n 1 <<<"$volume")+1))
[[ $volume > 32768 ]] && volume=32768
pacmd set-sink-volume 0 $volume

exit