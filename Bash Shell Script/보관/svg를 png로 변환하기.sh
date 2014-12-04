#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

filename=$1

for size in 16 20 22 24 32 36 48 64 72 96 128 192 256
do
	inkscape -w $size -h $size -e ../${size}x$size/$filename.png $filename.svg
done

exit
