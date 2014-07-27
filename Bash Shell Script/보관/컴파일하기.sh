#!/bin/bash

IFS='
'

for i in $CAJA_SCRIPT_SELECTED_FILE_PATHS
do
 #i=`basename "$i"`
 target=$(echo "$i" | sed -r 's/\.(c|cpp)$//I')
 gcc -o "$target.bin" "$i" && chmod +x "$target.bin"
done
#[ $? == 0 ] &&  mate-terminal

exit
