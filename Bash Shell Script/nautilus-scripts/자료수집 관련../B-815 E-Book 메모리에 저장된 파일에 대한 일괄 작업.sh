#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

:<<\EOF
<< 기능 >>
 * 확장자 변경 cbz -> zip
 * 모든 파일은 폴더 경로를 유지한 채로 적절한 경로에 저장됩니다. Book/a/b/c/d.cbz -> Picture/a/b/c/d.zip
 * 사진 폴더에 존재하는 모든 이미지를 북큐브에 적합한 크기로 재조정합니다.
 * pdf 파일을 cbz 파일로 바꿉니다.

<< 사용법 >>
 * 저장 장치를 연결한뒤, 저장 장치에 기록하고 싶은 파일들이 위치한 경로에서 이 스크립트를 실행시킨다.

<< 문제 >>
 * 만약 ./a/b/c.cbz 파일이 있고, /media/ebook/Picture/a/b란 파일이 있다면, 파일 경로 생성시 경로명 충돌 오류를 일으키게 된다. 이 문제를 해결하기 위해서는 dupev_mkdir에 -p 옵션을 추가하여 알아서 충복 경로를 회피하여 폴더를 생성하도록 하여야 한다. 미봉책으로, 이런 경로 충돌 문제가 발견 될 경우 처리 하지 않고 사용자에게 보고 하게 하였다.
EOF

EBOOK_ROOT_PATH=$PATH_EBOOKMEMORY # 절대 경로
TEMP_DIR_PATH=/tmp/.bookcube-B815-$$
GV_Log=
GV_mkdirBreakList=

reportError()
{
	local body
	body=$1
	#notify-send -i error -u critical -- 'E-BOOK 형식 변환기' "$body"
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

processForCbz()
{
	local archive skipList saveFullPath
	
	for archive in $(find ./ -type f -a -iname '*.cbz'); do
		# 파일에 존재하는 이미지가 두개 이상의 폴더에 나뉘어 저장되어 있다면 건너뜀.
		if (( $(viewZipList "$archive" | grep -Ei -e '\.jpe?g$' -e '\.png$' -e '\.bmp$' -e '\.gif$' | sed -e 's#^#/#' -e 's#/[^/]*$#/#' | sort -u | wc -l) > 1 )); then
			skipList+=( "$archive" )
			continue
		fi
		
		saveFullPath=$(initSavePath Picture "$archive" "$(ex_name "$archive").zip") || continue
		
		initTempDir
		unzip "$archive" -d $TEMP_DIR_PATH
		resizePictures $TEMP_DIR_PATH
		mkzip $TEMP_DIR_PATH "$saveFullPath" 
		clearTempDir
	done
	
	# 처리되지 않은 대상을 기록.
	if (( ${#skipList[@]} > 0 )); then
		GV_Log+=$(cat <<-EOF
		<< 처리되지 않은 파일 목록 >>
		 * 파일에 존재하는 이미지가 두개 이상의 폴더에 나뉘어 저장되어 있습니다.
		${skipList[*]}
		
		
		EOF
		)
	fi
}

# 저장 루트 폴더 $1(ex. Book, Picture...); 원본 경로 $2; 파일명(선택사항; 지정하지 않는다면 원본 파일명으로 지정됨.) $3(ex. filename.cbz...); 출력 : 중복되지 않는 이북 메모리 상의 저장 경로; 반환 값 : 0 성공, 1 : 실패.
initSavePath()
{
	local savePath type src saveName
	type=$1
	src=$2
	saveName=${3:-$(basename "$src")}
	
	savePath=$EBOOK_ROOT_PATH/$type/$(dirname "$src")
	if ! mkdir -p "$savePath"; then
		GV_mkdirBreakList+=( "$src" )
		return 1
	fi
	
	echo "$savePath/$(dupev_name -p "$savePath" -- "$saveName")"
	return 0
}

# $1을 zip 형식의 파일로 $2(인자는 zip 확장자를 포함한 경로여야 함)에 저장한다.
mkzip()
{
	local dest src
	src=$1
	dest=$2
	zip -0rjq "$dest" "$src"
}

# pdf 파일을 cbz 형식의 파일로 바꾸어 저장한다.
processForPdf()
{
	local file saveFullPath
	for file in $(find ./ -type f -a -iname '*.pdf'); do
		saveFullPath=$(initSavePath Picture "$file" "$(ex_name "$file").zip") || continue
		initTempDir
		pdftocairo "$file" -jpeg $TEMP_DIR_PATH/image
		resizePictures $TEMP_DIR_PATH
		mkzip $TEMP_DIR_PATH "$saveFullPath"
		clearTempDir
	done
}

clearTempDir()
{
	rm -rf $TEMP_DIR_PATH
}

# 지정된 경로의 jpeg, png, bmp, gif 파일을 리사이징 한다(원본 파일을 치환함).
resizePictures()
{
	local image path
	path=$1
	for image in $(find "$path" -type f -a \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' -o -iname '*.gif' \)); do
		resizeImage "$image" "$image"
	done
}

# jpeg, png, bmp, gif 파일을 리사이징 한다.
processForPicture()
{
	local image saveFullPath
	for image in $(find ./ -type f -a \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' -o -iname '*.gif' \)); do
		saveFullPath=$(initSavePath Picture "$image") || continue
		resizeImage "$image" "$saveFullPath"
	done
}

# $1을 리사이징 하여 $2로 저장한다.
resizeImage()
{
	local src dest
	src=$1
	dest=$2
	#mogrify -colorspace gray -type grayscale -quality 100 -resize 1200x800 "$image"
	convert "$src" -colorspace gray -type grayscale -quality 100 -resize 1200x800 "$dest"
}

# 임시 폴더를 초기화.
initTempDir()
{
	test -e $TEMP_DIR_PATH && rm -rf $TEMP_DIR_PATH
	mkdir $TEMP_DIR_PATH
}

# 음악을 분류.
processForMusic()
{
	local file saveFullPath
	for file in $(find ./ -type f -a \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.wma' \)); do
		saveFullPath=$(initSavePath Music "$file") || continue
		resizeImage "$file" "$saveFullPath"
	done
}

# 기타 책을 분류.
# 다음 형식은 매직 넘버로 분류해야 함. plucker, 
# 알 수 없는 형식. OpenReader, Palmdoc, Mobipocket
# 처리 하지 않는 형식. 확장자가 없는 평문 텍스트 파일.
processForBook()
{
	local file saveFullPath
	for file in $(find ./ -type f -a \( -iname '*.bcb' -o -iname '*.bcp' -o -iname '*.bcz' -o -iname '*.ePub' -o -iname '*.fb2' -o -iname '*.oeb' -o -iname '*.htm' -o -iname '*.html' -o -iname '*.tcr' -o -iname '*.chm' -o -iname '*.rtf' -o -iname '*.txt' \)); do
		saveFullPath=$(initSavePath Book "$file") || continue
		dupev_cp -- "$file" "$saveFullPath"
	done
}

# Bookcube에서 지원하지 않는 형식의 파일들을 사용자에게 보고.
# zip 확장자의 파일은 압축된 텍스트 파일이나 이미지 파일 묶음에 사용될 수 있으나, 여기서는 처리하지 않음.
findNotSupportFormatFile()
{
	local notSuportedFileList
	notSuportedFileList=$(find ./ -type l -o -type f -a -not \( -iname '*.bcb' -o -iname '*.bcp' -o -iname '*.bcz' -o -iname '*.ePub' -o -iname '*.fb2' -o -iname '*.oeb' -o -iname '*.htm' -o -iname '*.html' -o -iname '*.tcr' -o -iname '*.chm' -o -iname '*.rtf' -o -iname '*.txt' -o -iname '*.mp3' -o -iname '*.wav' -o -iname '*.wma' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' -o -iname '*.gif' -o -iname '*.pdf' -o -iname '*.cbz' \))
	if [ -n "$notSuportedFileList" ]; then
		GV_Log+=$(cat <<-EOF
		<< 처리되지 않은 파일 목록 >>
		 * 지원하지 않는 형식의 파일
		$notSuportedFileList
		
		
		EOF
		)
	fi
}

# $1경로에 존재하는 zip 파일의 파일 목록을 보여준다.
viewZipList()
{
	local file
	file=$1
	unzip -l "$file" | head -n -2 | tail -n +4 | awk '{print substr($0,index($0,$4))}'
}

# 작업 로그를 보여줌.
showLog()
{
	[ -n "$GV_Log" ] && (kate --stdin <<<"$GV_Log") &
}

# 작업 완료를 보고
reportWorkEnd()
{
	zenity --info --no-wrap --title 'E-BOOK 형식 변환기' --text '작업이 완료되었습니다.'
	#notify-send -u normal 'E-BOOK 형식 변환기' '작업이 완료되었습니다.'
}

# 경로 충돌 대상을 기록.
recodeBreakList()
{
	if (( ${#GV_mkdirBreakList[@]} > 0 )); then
		GV_Log+=$(cat <<-EOF
		<< 처리되지 않은 파일 목록 >>
		 * 상대 경로로 폴더를 생성시 충돌이 발생 했습니다.
		${GV_mkdirBreakList[*]}
		
		
		EOF
		)
	fi	
}

checkCard()
{
	test -d "$EBOOK_ROOT_PATH" || crash 5 'E-BOOK 메모리 카드를 삽입하여 주십시오!'
}

initProgram()
{
	umask 0077
}

main()
{
	checkCard
	initProgram
	
	processForCbz
	processForPicture
	processForPdf
	processForMusic
	processForBook
	
	findNotSupportFormatFile
	recodeBreakList
	showLog
	
	reportWorkEnd
	exit 0
}

main "$@"

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
