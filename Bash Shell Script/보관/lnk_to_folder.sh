#!/bin/bash

IFS='
'

if [ ! "$2" ]
then
 caja --no-desktop --browser "$1"
else
 for i in `echo "$*" | sed '1d'`
 do
  mv "$i" "$1"
 done
fi

exit
