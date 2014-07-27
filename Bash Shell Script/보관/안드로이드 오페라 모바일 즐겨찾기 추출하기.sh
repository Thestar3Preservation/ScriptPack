#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

copyFavorites(){
	[ -e favorites.db ] && return
	adb shell <<-EOF
		su; exit
		mkdir -p /sdcard/tmp
		cp -f /data/data/com.opera.browser/app_opera/favorites.db /sdcard/tmp
		exit
	EOF
	adb pull /sdcard/tmp/favorites.db favorites.db
}

copyFavorites

echo '>> 확인할 것들 <<'
sqlite3 -batch favorites.db <<-EOF
	SELECT url FROM favorites WHERE parent_guid = (SELECT guid FROM favorites WHERE name = "확인할 것들");
EOF
echo
echo '>> 저장할 것들 <<'
sqlite3 -batch favorites.db <<-EOF
	SELECT url FROM favorites WHERE parent_guid = (SELECT guid FROM favorites WHERE name = "저장할 것들");
EOF

exit