#!/home/user/Home/.usersys/bashscriptrecode
source ~/Home/쉘스크립트/function.sh
[ "$@" ] && IFS=$(echo -en "\b") || IFS=$'\n'
#파일 이름을 고침
echo -e '\n파일 이름을 고칩니다.'
echo "작업위치 : $PWD"
target=${*-`ls`}
echo "작업대상 : $target"
for i in $target; do
	f=$(wl_replace "$i") #이름 중 특정 문자를 치환
	if [ "$i" != "$f" -a -e "$f" ]; then
		erro_list+=( "$i" )
	elif [ "$i" != "$f" -a ! -e "$f" ]; then
		mv -Tv "$i" "$f"\
	fi
done
[ "$erro_list" ] && zenity --list --title "알림" --text "수정될 이름을 가진 대상이 존재합니다!" --height 400 --column '이름' "${erro_list[@]}"
fi
exit
