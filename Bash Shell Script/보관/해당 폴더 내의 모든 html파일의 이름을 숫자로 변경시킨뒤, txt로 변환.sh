#!/bin/bash

IFS='
'

for i in `ls *.html`
do
 tn=`expr $tn + 1`
 mv "$i" "$tn.html"
 w3m -dump "$tn.html" >> "$tn.txt"
done

exit
