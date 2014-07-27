#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

cd "$(dirname "$0")"

COMONFLAG=( -std=c++0x -fPIC -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -I"$PATH_SHELLSCRIPT/소스 코드" )

g++ -c main.cpp "${COMONFLAG[@]}" && g++ -o ark main.o "${COMONFLAG[@]}" -ldl -lpcrecpp -licuuc -licui18n -lpthread || exit

install -s ark "$PATH_SHELLSCRIPT"

rm main.o ark

exit