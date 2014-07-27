#!/bin/bash
xdotool key ctrl+shift+s
win=`xdotool search --sync --name '다른 이름으로 저장…'`
sleep .3
xdotool key --window $win alt+h
sleep .3
xdotool key --window $win Up
sleep .3
xdotool key --window $win alt+s
sleep .3
xdotool key alt+r
sleep .3
xdotool key Escape
sleep .3
xdotool key alt+s
#xdotool mousemove --sync --window $win 217 605 click --window $win 4
#xdotool key Tab Tab Tab Tab Tab Tab Tab Tab Tab Tab Tab --clearmodifiers	
exit																																																							
