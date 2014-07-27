#!/bin/bash

IFS='
'

mplayer -vo yuv4mpeg -vf format=i420,scale=1280:720 -nosound  "$1"

exit
