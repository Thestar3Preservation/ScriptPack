#!/home/user/Home/.usersys/bashscriptrecode
IFS=$'\n'
for i; do
	target=`echo "$i" | sed 's/\.ui$/.py/I'`
	echo '#!/usr/bin/python' > "$target"
	pyuic4 -x "$i" >> "$target"  #pyuic4 -o "`echo "$i" | sed 's/\.ui$/.py/I'`" "$i"
done
exit
