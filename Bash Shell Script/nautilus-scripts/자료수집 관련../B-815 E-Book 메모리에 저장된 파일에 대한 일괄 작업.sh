#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

:<<\EOF
 * 확장자 변경 cbz -> zip
 * cbz 파일은 폴더 경로를 유지한 채로 폴더 경로가 바뀝니다. Book/a/b/c/d.cbz -> Picture/a/b/c/d.zip
 * 모든 빈 폴더는 삭제 됩니다.
 * 사진 폴더에 존재하는 모든 이미지를 북큐브에 적합한 크기로 재조정합니다.
EOF

EBOOK_ROOT_PATH=$PATH_EBOOKMEMORY
TEMP_DIR_PATH=/tmp/.bookcube-B815-$$

reportError()
{
	local body
	body=$1
# 	notify-send -i error -u critical -- 'E-BOOK 형식 변환기' "$body"
	zenity --error --no-wrap --title 'E-BOOK 형식 변환기' --text "$body"
}

crash()
{
	local exitCode message
	exitCode=$1
	message=$2
	reportError "$message"
	exit $exitCode
}

# 책 폴더에 존재하는 모든 cbz파일을 경로를 유지한 채로 사진 폴더로 이동.
moveBookInCbzToPicture()
{
	local filePath convertedPath
	for filePath in $(find 'Book/' -type f -iname '*.cbz'); do
		convertedPath=${filePath%.[Cc][Bb][Zz]}.zip
		convertedPath=Picture/${convertedPath#Book/}
		mkdir -p "${convertedPath%/*}"
		mv "$filePath" "$convertedPath"
	done
}

# 대상 경로에 존재하는 단일 파일로 존재하는 이미지의 크기를 조정.
resizePicture()
{
	local image path
	path=$1
	for image in $(find "$path" -type f -a \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' -o -iname '*.gif' \)); do
		mogrify "$image" -quality 100 -resize 1200x800
	done
}

# 사진 폴더에 묶음 파일로 존재하는 이미지의 크기 조정.
resizeArchivePicture()
{
	local archive skipList
	test -e $TEMP_DIR_PATH && rm -rf $TEMP_DIR_PATH
	for archive in $(find Picture/ -type f -a -iname '*.zip'); do
		mkdir $TEMP_DIR_PATH
		unzip "$archive" -d $TEMP_DIR_PATH
		if (( $(find $TEMP_DIR_PATH -mindepth 1 -type d | wc -l) > 1 )); then
			skipList+=( "$archive" )
			rm -rf $TEMP_DIR_PATH
			continue
		fi
		resizePicture $TEMP_DIR_PATH
		rm -f "$archive"
		zip -0rjq "$archive" $TEMP_DIR_PATH
		rm -rf $TEMP_DIR_PATH
	done
	if (( ${#skipList[@]} > 0 )); then
		(kate --stdin <<-EOF
		<< 하나 이상의 폴더를 포함한 사진 압축 파일 목록(처리되지 않음) >>
		${skipList[*]}
		EOF
		)&
	fi
}

main()
{
	test -d "$EBOOK_ROOT_PATH" || crash 5 'E-BOOK 메모리 카드를 삽입하여 주십시오!'
	
	cd "$EBOOK_ROOT_PATH" || crash 6 '경로를 변경하던 도중 문제가 발생했습니다!'
	
	umask 0077
	
	mkdir -p 'Picture' 'Book' 'Music' || crash 7 '작업 대상 폴더를 초기화하던 도중 오류가 발생했습니다!'
	
	moveBookInCbzToPicture
	
	# 사진 폴더에 존재하는 모든 cbz파일의 확장자를 zip으로 변경
	find 'Picture/' -type f -iname '*.cbz' -exec rename 's/\.cbz$/.zip/i' {} \;
	
	resizePicture Picture/
	
	resizeArchivePicture
	
	# 모든 빈 폴더를 삭제
	find 'Picture/' 'Book/' 'Music/' -type d -empty -delete
	
	# 작업 완료를 보고
	zenity --info --no-wrap --title 'E-BOOK 형식 변환기' --text '작업이 완료되었습니다.'
	#notify-send -u normal 'E-BOOK 형식 변환기' '작업이 완료되었습니다.'
	
	exit 0
}

main

:<<\EOF
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
# 		txt)
# 			code=$(iconv -f UTF-8 "${iconvtxtOP[@]}" -t UHC -- "$i") && cat <<<"$code" >"$i"
# 			;;
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
EOF
