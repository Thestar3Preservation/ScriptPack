#!/usr/bin/env bash_record
#한 폴더 내에는 여러개의 폴더가 있어선 안됨. 이 스크립트는 여러개의 파일을 하나로 묶는 용도임. 다중폴더는 지원안함.
#안에 여러개의 폴더가 있더라도 노틸러스에서 섬네일은 정상적으로 보임. comix 프로그램의 경우 여러 폴더가 존재할 경우에도 정상적으로 섬네일이 보이나, 이것은 한글과 타 언어의 문자가 포함되지 않았을때 만이다.
#zip파일을 발견할 경우 확장자를 cbz로 수정함. bmp는 png로 변환함. 웹브라우져를 통해 긁어오는 경우를 가정하여, 불필요한 파일은 자동으로 삭제하도록 함. 대상: *.swf *index.php.html 등...
:<<\EOF
복구명령어
IFS="\n"; d=`cat list.txt | sed -e "s/\\\`//g" -e "s/'//g" -e 's/ ->//'`; a=`echo "$d" | cut -f 1 -d \ `; b=`echo "$d" | cut -f 2 -d \ `; mkdir a; c=1; for i in $b; do mv -v "$i" "a/`echo "$a" | sed -n ${c}p`"; ((c++)); done
=======================================================================
모든 7z,rar,zip파일을 cbz로 변환시키는 명령
OIFS=$IFS; IFS='
'; home=`pwd`; for i in `find . -type f \( -iname '*.rar' -o -iname '*.7z' -o -iname '*.zip' \)`; do dir=`realpath "$(dirname "$i")"`; name=`basename "$i"`; cd "$dir"; ~/'Home/쉘스크립트/nautilus-scripts/만화 또는 책을 정리/cbz파일로 묶기' "$name"; cd "$home"; done; IFS=$OIFS
EOF
source ~/.bash_profile
LOAD_USER_FUNTION
home=$PWD
# sort=y
notify=y
if [ "$sub" != yes ]; then
	#echo "
#=========위치 변경 됨=========
#현재위치 : $home" >> $error
#else
	mkdir /tmp/cbz_error 2>/dev/null
	error=/tmp/cbz_error/$RANDOM$RANDOM.log
fi
report_error() {
	{ [ "$sub" = yes ] && echo $'\n'"위치 : $home"; echo "대상 : $i"; } >> $error
	echo "*$1" | tee -a $error
	[ "$notify" = n ] || notify-send -i error 'cbz로 묶기' "대상 : $i\n$1"
}
cbz_trash(){
	ls | grep -iFx -e Thumbs.db -e photothumb.db -e desktop.ini | xargs -I{} -d '\n' rm -- {}
	ls | grep -iE -e '\.(url|db|swf|htm|html|txt)$' -e '^list.txt$' -e 'index.php.html$' | xargs -I{} -d '\n' trash-put -- {}
}
echo "현재위치 : $home"$'\n'
if [ -n "$*" ]; then
	worklist=( "$@" )
else
	eval "worklist=( `ls --quoting-style=shell-always` )"
fi
#반디집의 압축해제창이 그대로 뜸. 알아서풀기 기능을 사용하기 때문에 선택작업으로 할 경우, 일부 파일이 풀리기만 하고 압축은 하지 않는 일이 발생할수 있음.
echo "${worklist[@]}" | grep -i '\.hv3$' | (
	while read i; do
		if [ -d "`basename "$i"`" ]; then
			report_error '작업대상 폴더가 이미 존재하고 있습니다. 작업이 중단됩니다.'
			continue
		fi
		list[${#list[*]}]=$i
	done
	if [ "$list" ]; then
		"$PATH_BIN/bandizip_sequential.sh" "${list[@]}" &
		pid=$!
	else
		exit
	fi
	#sleep 1
	#win=$(xdotool search --pid $pid . --sync)
	#for i in $win; do
	#	xdotool windowunmap $i &
	#done
	wait
	for a in "${list[@]}"; do i+=$'\n'"$a"; done
	if kill $pid; then
		report_error 'hv3파일을 압축해제하는 중 문제가 있었습니다. 사용자의 수동확인이 요구됩니다.'
		for i in "${list[@]}"; do rm -r "`ex_name "$i"`"; done
	else
		trash-put "${list[@]}"
	fi
	echo "$i" > .worklist
)
[ -f .worklist ] && eval "worklist+=( `cat .worklist | runfor ex_name | runfor s_quote` )"
[ ! -n "${worklist[*]}" ] && eval "worklist=( `ls --quoting-style=shell-always` )"
unzip_command(){
	unzip -P 1234 -O UHC "$1" -d "$2" || unzip -P 1234 -O Shift_JIS "$1" -d "$2" || unzip -P 1234 "$1" -d "$2"
}
for i in "${worklist[@]}"; do
	cd "$home"
	if test -d "$i"; then
		type=dir
	else
		type=$(ex_ext -d -- "$i" | grep -iPx 'zip|rar|7z|tar|alz' || echo none)
	fi
	if [ $type != none ]; then
		echo "대상 : $i"
		if test $type = dir; then
			name=$i
		else
			name=$(ex_name "$i" | dupev_name -i -p .)
			mkdir "$name"
			case $type in
				zip)
					#인코딩이 잘못된 경우 풀리지 않거나, 이상한 파일명으로 풀린다. 인코딩이 잘못된 상태로 풀린다 하더라도 파일 이름 수정에서 올바른 utf-8 타입의 이름으로 변경되니, 사실 풀리기만 하면 된다. 아래 명령의 목적은 압축 파일을 풀어내는 것이다.
					unzip_command "$i" "$name"
					case $((code=$?)) in
						0)
							echo '*압축파일을 성공적으로 압축해제하였습니다.';;
						1|2|50)
							report_error '파일 일부가 손상되어 있습니다. 손상을 무시하고 강제로 작업을 진행합니다.';;
						5|80|81|82)
							report_error '파일 일부에 암호가 걸려있습니다. 사용자 명령을 요구합니다. 작업이 중단됩니다.'
							rm -r "$name"
							continue;;
						9)
							report_error '파일 일부가 손상되어 있습니다. 손상을 제외하고 강제로 작업을 진행합니다.'
							yes | zip -FF "$i" --out "$i.restore"
							unzip_command "$i.restore" "$name"
							rm "$i.restore";;
						126)
							report_error '이 파일은 ZIP압축파일이 아닙니다.'
							rm -r "$name"
							continue;;
						*)
							report_error "압축해제 중 해결할수 없는 오류 $code을 만나 작업이 중단됩니다."
							rm -r "$name"
							continue;;
					esac;;
				rar)
					unrar x -p- "$i" "$name"
					case $((code=$?)) in
						0)
							echo '*압축파일을 성공적으로 압축해제하였습니다.';;
						3)
							report_error '파일 일부에 암호가 걸려있습니다. 사용자 명령을 요구합니다. 작업이 중단됩니다.'
							rm -r "$name"
							continue;;
						126|10)
							report_error '이 파일은 RAR압축파일이 아닙니다.'
							rm -r "$name"
							continue;;
						*)
							report_error "압축해제 중 해결할수 없는 오류 $code을 만나 작업이 중단됩니다."
							rm -r "$name"
							continue;;
					esac;;
				7z)
					7z x -p1234 -o"$name" "$i"
					case $((code=$?)) in
						0)
							echo '*압축파일을 성공적으로 압축해제하였습니다.';;
						2)
							report_error '파일 일부에 암호가 걸려있습니다. 사용자 명령을 요구합니다. 작업이 중단됩니다.'
							rm -r "$name"
							continue;;
						*)
							report_error "압축해제 중 해결할수 없는 오류 $code을 만나 작업이 중단됩니다."
							rm -r "$name"
							continue;;
					esac;;
				alz)
					unalz -utf8 -d "$i" -pwd 1234 "$name"
					case $((code=$?)) in
						0)
							echo '*압축파일을 성공적으로 압축해제하였습니다.';;
						*)
							report_error "압축해제 중 해결할수 없는 오류 $code을 만나 작업이 중단됩니다."
							rm -r "$name"
							continue;;
					esac;;
				tar)
					tar -xvf "$i" -C "$name"
					case $((code=$?)) in
						0)
							echo '*압축파일을 성공적으로 압축해제하였습니다.';;
						*)
							report_error "압축해제 중 해결할수 없는 오류 $code을 만나 작업이 중단됩니다."
							rm -r "$name"
							continue;;
					esac;;
			esac
		fi
		cd "$name"
		cbz_trash
		check=$(find . -mindepth 1 -type f | xargs -I{} -d '\n' dirname {} | sort -uf)
		if [ -n "$check" ]; then
			if [ $(wc -l <<<"$check") = 1 ]; then
				if [ . != "$check" ]; then
					cd "$check"
					cbz_trash
				fi
				ls=$(ls)
			else
				report_error '대상 안에 하나 이상의 폴더가 존재하고 있습니다. 사용자의 수동 확인이 요구됩니다. 작업을 중단합니다.'
				[ $type != dir ] && { cd "$home"; rm -r "$name"; }
				continue
			fi
		else
			report_error '작업 대상이 비어있습니다. 작업을 중단합니다.'
			cd "$home"
			rm -r "$name"
			continue
		fi
		if [ "`find . -mindepth 1 -maxdepth 1 -type f ! \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.bmp -o -iname \*.png -o -iname \*.gif -o -iname \*.tif -o -iname \*.desktop \)`" ]; then
			if [ -n "`find . -maxdepth 1 -mindepth 1 -type f -iname \*.hdp`" -a -z "`find . -maxdepth 1 -mindepth 1 ! \( -type f -iname \*.hdp \)`" ]; then
				report_error 'JPEG 2000 포멧(.HDP)을 발견했습니다. 해당 포멧은 작업이 불가능합니다.'
			else
				report_error '대상 안에 작업대상 외의 화일이 존재하고 있습니다. 작업을 중단합니다.'
			fi
			if [ $type != dir ]; then
				cd "$home"
				rm -r "$name"
			fi
			continue
		fi
		find . -type f -iname '*.bmp' | while read a; do
			convert "$a" "$(sed 's/\.bmp$/.png/I' <<<"$a")"
		done
# 		if [ "$sort" = y ]; then
		noNotity=y "$PATH_BIN/숫자의 자릿수를 맞추기.sh"
# 		else
# 			c=0
# 			list=$(ls -A)
# 			tc=$(echo "$list" | wc -l | tr -d '\n' | wc -m)
# 			mkdir sort
# 			for a in $list; do
# 				((c++))
# 				mv -v "$a" "sort/`printf "%0${tc}d" $c`.`echo "$a" | sed -r 's/^.*\.([^\.\s]+)$/\1/'`"
# 			done
# 			cd sort
# 		fi
		[ $type = dir ] && trash-put "$home/$i".$(replace_i cbz) "$home/$i".$(replace_i zip) 2>/dev/null || trash-put  "$home/$i" 2>/dev/null
		zip -0rD "$home/$name.cbz" .
		cd "$home"
		if [ "$sub" ]; then
			rm -r "$name"
		else
			if [ $type = dir ]; then
				trash-put "$name"
			else
				rm -r "$name"
			fi
		fi
	else
		echo "$i는 작업대상이 아닙니다."
	fi
	echo
done
rm .worklist 2>/dev/null
if [ ! "$sub" ] && [ -f $error ] && [[ $(wc -l $error) > 2 ]]; then
	xdg-open $error
else
	rm $error 2>/dev/null
fi
exit