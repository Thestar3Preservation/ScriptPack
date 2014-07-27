#!/usr/bin/env bash


#동영상 배경화면 실행 명령.
FILE_NAME=test
sleep 2; nohup nice -n 19 ~/Home/.usersys/movie_wallpapher.sh '/home/'$USER'/Home/.usersys/'$FILE_NAME'.yuv' xv &>/dev/null &

exit