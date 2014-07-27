#!/home/user/Home/.usersys/bashscriptrecode
IFS=$'\n'
command=$(zenity --entry --width 350 --title "체크섬 계산하기" --text '[계산할 형식][공백][비교할값]' || exit)
[ -z "$command" ] && exit
if ! type "${command}sum"; then
	zenity --info --title '프로그램이 존재하지 않음' --text "해당 이름을 가진 프로그램이 존재하지 않습니다."
	exit
fi
pwd
gotnl=$(echo "$cmd" | cut -d ' ' -f 1 | tr -s '[:upper:]' '[:lower:]' | tr -d '\n')
rkqt=$(echo "$cmd" | sed 's/^.*\ //')
[ "$rkqt" = "$gotnl" ] && unset rkqt
${gotnl}sum "$@"
echo "$a"
if [ "$rkqt" ]; then
	if [[ $# > 1 ]]; then
		for i in $a; do
			b=$(echo "$i" | cut -d ' ' -f 1)
			d=$(echo "$i" | sed -r 's/[a-z0-9]+[\ ]+//')
			[ "$b" = "$rkqt" ] && wlsfl=일치 || wlsfl=불일치
			rufrhk="$rufrhk \"$wlsfl\" \"$d\" \"$b\""
		done
		zenity --list --title "체크섬 판단 결과" --height 200 --width 450 --text "체크섬을 판단한 결과입니다." --column '판단' --column '파일명' --column "${gotnl}값" $rufrhk
	else
		b=$(echo "$a" | cut -d ' ' -f 1)
		if [ "$b" = "$rkqt" ]; then
			rufrhk="선택된 파일의 $gotnl값과 비교값이 일치합니다."
		else
			rufrhk="선택된 파일의 $gotnl값은 \"$b\"으로서 비교값 \"$rkqt\"와는 불일치합니다."
		fi
		zenity --info --title '체크섬 판단 결과' --text "$rufrhk"
	fi
else
	for i in $a; do
		b=$(echo "$i" | cut -d ' ' -f 1)
		d=$(echo "$i" | sed -r 's/[a-z0-9]+[\ ]+//')
		rufrhk="$rufrhk \"$d\" \"$b\""
	done
	zenity --list --title "체크섬을 계산 결과" --width 400 --height 200 --text "체크섬을 계산한 결과입니다." --column '파일명' --column "${gotnl}값" $rufrhk
fi
exit
