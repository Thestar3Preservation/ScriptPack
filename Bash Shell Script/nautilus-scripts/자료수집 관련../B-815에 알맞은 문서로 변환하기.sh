#!/usr/bin/env bash_record
#북큐브 전자책 리더기(B-815)에 알맞는 포멧으로 자동으로 변환시킵니다. 검색 가능하도록 변환된 대상들을 대상외에는 정상 작동을 보장하지 않습니다.
source ~/.bash_profile
LOAD_USER_FUNTION

# ### ### ### 환경변수 설정 ### ### ### #
HomeDisk=$PATH_EBOOKMEMORY
# iconvtxtOP=-c

# ### ### ### 작업위치가 올바른지 검사 ### ### ### #
GHomeDisk=$(g_quote "$HomeDisk")
if ! pwd | grep -E -e "^$GHomeDisk/?$" -e "^$GHomeDisk/"; then
	notifyecho critical "$HomeDisk에서만 작동하도록 되어 있습니다."
	exit
fi

# ### ### ### 변수 초기화 및 함수 선언 ### ### ### #
{
	home=$PWD
	Hpid=$$
	Picture=$HomeDisk/Picture
	[ -e "$Picture" ] || mkdir "$Picture"
	workpath=$(sed "s/^$GHomeDisk//" <<<"$home")
	Error=n
	notifyecho(){
		echo "$2" >&2
		notify-send -u $1 "$2"
	}
	mklist(){
		for((;;)); do
			IFS=$'\0' read -r -d $'\0' i || break
			ls+=( "$i" )
		done < <(find "$1" -depth -type f -print0)
	}
	umask 077
	linkPATH=$(dupev_mkdir /tmp/.link)
	mkdir -vp "$linkPATH"/maff{,_f}
	ln_doc(){
		local save=$linkPATH/$1
		ln -s "$PWD/$i" "$save/$(dupev_name -p "$save" -- "$i")"
	}
}

# ### ### ### 작업 대상의 목록을 작성하고 검사 ### ### ### #
{
	if [ -n "$*" ]; then
		for i; do mklist "./$i"; done
	else
		mklist .
		unset ls[$((${#ls[@]}-1))]
	fi

	if [ ${#ls[@]} = 0 ]; then
		notifyecho normal '작업할 대상이 존재하지 않습니다.'
		exit
	fi
}

# ### ### ### 작업 초기화 및 문서 변환 ### ### ### #
{
	echo 0 > /tmp/.progress-$Hpid
	while true; do cat /tmp/.progress-$Hpid; sleep 0.1; done | zenity --title 'B-815에 알맞는 문서로 변환' --text "문서 변환 중...\n작업 위치 : $workpath" --auto-close --progress --width 525 || kill $Hpid &
	count=0
	max=${#ls[@]}

	for i in "${ls[@]}"; do
		((count++))
		temp=$(echo "$count/$max*100" | bc -l | cut -d . -f 1)
		if [ -z "$temp" ]; then
			echo 0
		elif [ $temp = 100 ]; then
			echo 99
		else
			echo $temp
		fi > "/tmp/.progress-$Hpid"
		cd "$home"
		cd "$(dirname "$i")"
		i=$(basename "$i")
		echo "~~~TARGET : $i~~~"
		name=$(ex_name "$i")
		ext=$(ex_ext -d -- "$i")
		case "$ext" in
		cbz)
			dupev_mv -- "$i" "$Picture/$name.zip"
			;;
		zip | jpg | gif | png | jpeg)
			dupev_mv -- "$i" "$Picture"
			;;
		txt)
			code=$(iconv -f UTF-8 "${iconvtxtOP[@]}" -t UHC -- "$i") && cat <<<"$code" >"$i"
			;;
		odt)
			if ebook-convert "./$i" "./$(dupev_name -p . -- "$name.fb2")"; then
				rm -- "$i"
			else
				for j in {1..3}; do
					unoconv --listener &>/dev/null &
					if unoconv -f pdf -- "$i"; then
						rm -- "$i"
						break
					else
						[ $j = 3 ] && Error=y
					fi
				done
			fi
			;;
		maff | webarchive)
			ln_doc maff
			;;
		*)
			echo "'$ext'는 등록되지 않은 확장자입니다."
			unKnownEXT=$i$'\n'
			;;
		esac
	done
}

# ### ### ### 작업 종료 및 작업 결과를 보고 ### ### ### #
{
	cd "$home"
	echo 100 > /tmp/.progress-$Hpid
	echo "$unKnownEXT" > "$linkPATH/UnnownExtList.txt"
	rmdir "$linkPATH"/* "$linkPATH"
	[ -d "$linkPATH" ] && xdg-open "$linkPATH" &

	temp="PATH : <a href='$home'>$workpath</a>"
	if [ $Error = y ]; then
		notify-send -i error -u critical '라이브러리 자료 변환 완료됨.' "작업도중 오류가 발생했습니다.\n$temp"
	else
		notify-send '라이브러리 자료 변환 완료됨.' "$temp"
	fi

	exit
}