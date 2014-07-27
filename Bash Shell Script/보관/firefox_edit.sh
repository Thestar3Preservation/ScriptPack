#!/bin/bash
file=`cat /usr/bin/firefox`
if [ "`echo "$file" | head -n 1`" = '#!/bin/sh' ]; then
	echo "#!/bin/bash
source /usr/local/etc/firefox_nabi_workaround
source /usr/local/etc/firefox_maff_umount
`echo "$file" | tail -n+2 `" > /usr/lib/firefox/firefox.sh
fi
exit

firefoxRestoreSetting(){
	local path=$(type -p firefox)
	if [ "`head -n 1 $path`" = '#!/bin/sh' ]; then
		cat >$path <<EOF
#!/bin/bash
source /usr/local/etc/firefox_maff_umount
$(tail -n+2 $path)
EOF
	fi
}; firefoxRestoreSetting
rmdir /mnt/* /mnt/.*