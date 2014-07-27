#!/bin/bash
#해당 text의 encoding을 찾아내어, 해당 encoding으로 pluma에서 열기

IFS=`echo -en \b`
list=`pluma --list-encodings`
for i in "$@"
do
	echo "$i" | grep -i '^file://' && i=`echo "$i" | echo -e "$(sed 's/+/ /g; s/%/\\x/g')" | sed 's/^file:\/\///I'`
	encoding=`nkf -g "$i"`
	[ "$encoding" = UTF-8 ] || encoding=UHC
	#if [ "$encoding" = BINARY ]; then
	#	encoding=UHC
	#else
	#	echo "$list" | grep -Fix "$encoding" || { echo "$encoding" | grep -iE '^cp[0-9]*$' && encoding=UHC; }
	#fi
	exec pluma --encoding=$encoding "$i"
done

exit
