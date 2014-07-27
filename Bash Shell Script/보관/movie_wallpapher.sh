#!/bin/bash
#배경화면을 동영상으로 만든다.
#실제로 배경화면에서 동영상이 보여지는건 아니다. 창틀 없는 프로그램이 가장 뒤에, 초점잡히지 않게 설정되어 나타나서 배경화면 역할을 하는것이다.
#첫번째 인자: 동영상 위치

xwinwrap -ni -ov -fs -s -st -sp -b -nf -- mplayer -wid WID -noquiet -nofs -nomouseinput -lavdopts skiploopfilter=all:threads=4 -sub-fuzziness 1 -identify -slave -vo $2 -nokeepaspect -nodr -input nodefault-bindings:conf=/dev/null -monitorpixelaspect 1 -vid 0 -subpos 95 -cache 102400 -osdlevel 0 -noslices -nosound -loop 0 "$1"

#구 mplayer2에 기반한 옵션.
#xwinwrap -ni -ov -fs -s -st -sp -b -nf -- mplayer -wid WID -nofs -nomouseinput -sub-fuzziness 1 -identify -slave -vo gl3 -nokeepaspect -nodr -input nodefault-bindings:conf=/dev/null -monitorpixelaspect 1 -vid 0 -aid 0 -subpos 100 -cache 3000 -ss 13 -osdlevel 0 -autoq 6 -slices -channels 2 -lavdopts skiploopfilter=all:threads=2 -af volnorm=1,scaletempo,equalizer=0:0:0:0:0:0:0:0:0:0 -softvol -softvol-max 110 -loop 0 -nosound "$1" #-vc coreserve, "$1" -vf-add pp  

exit
