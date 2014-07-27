#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION
dir=/tmp/webarchiveMountPoint
diskID=$(stat -c%d "$1") #"$(realpath "$PWD")")
for t; do
	name=$diskID-$(ls -i -- "$t" | head -n1 | cut -d \  -f 1)
	if [ -e $dir/$name ]; then
		path=$(<$dir/$name.txt)
	else
		mkdir -p "$dir/$name"
		fuse-zip "$t" "$dir/$name" -o allow_other,ro,user=$USER
		ls=$(ls "$dir/$name")
		if [ 1 = $(wc -l <<<"$ls") ]; then
			path=$dir/$name/$ls
			if [ -f "$path/index.rdf" ]; then
				path+=/$(grep -io '<MAF:indexfilename RDF:resource=".*"/>' "$path/index.rdf" | sed -e 's/"[^"]*$//' -e 's/^[^"]*"//')
			elif [ -f "$path/document_redirection.html" ]; then
				path+=/document_redirection.html
			else
				path+=/index.html
			fi
		else
			{
				echo '<!DOCTYPE html>'
				echo '<html><head><html lang="ko"><meta http-equiv="content-type" content="text/html; charset=UTF-8"/>'
				echo "<title>$(ex_name "$t" | html_escape)</title>"
				echo '</head><body><ol>'
				for i in $(find "$dir/$name" -maxdepth 2 -type f -iname index.rdf); do
					echo "<li><a href=\"$(dirname "$i")/index.html\">$(grep -Ei "^\s+<MAF:title" -- "$i" | grep -Po '(?<=").*(?=")')</a></li>"
				done
				echo '</ol></body></html>'
			} > "$dir/$name.html"
			path=$dir/$name.html #openlist.html
		fi
		echo "$path" > "$dir/$name.txt"
	fi
	firefox "$path"
done
exit