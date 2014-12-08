#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

:<<\EOF
<< 기능 >>
 * 확장자 변경 cbz -> zip
 * 모든 파일은 폴더 경로를 유지한 채로 적절한 경로에 저장됩니다. Book/a/b/c/d.cbz -> Picture/a/b/c/d.zip
 * 사진 폴더에 존재하는 모든 이미지를 북큐브에 적합한 크기로 재조정합니다.
 * pdf 파일을 cbz 파일로 바꿉니다.

<< 주의 >>
 * 작업 대상은 검색 가능하도록 변환되어 있어야 합니다.

<< 사용법 >>
 * 저장 장치를 연결한뒤, 저장 장치에 기록하고 싶은 파일들이 위치한 경로에서 이 스크립트를 실행시킨다.
 * 또는 대상 폴더나 파일을 선택한뒤 이 스크립트를 실행시킨다.

<< 문제 >>
 * 만약 ./a/b/c.cbz 파일이 있고, /media/ebook/Picture/a/b란 파일이 있다면, 파일 경로 생성시 경로명 충돌 오류를 일으키게 된다. 이 문제를 해결하기 위해서는 dupev_mkdir에 -p 옵션을 추가하여 알아서 충복 경로를 회피하여 폴더를 생성하도록 하여야 한다. 미봉책으로, 이런 경로 충돌 문제가 발견 될 경우 처리 하지 않고 사용자에게 보고 하게 하였다.
 * pdf 파일을 코믹북 뷰어 파일로 변환 시킬 경우, 보이지 않아야 할 부분까지 포함되어 저장되는 경우가 있다. 이 문제를 해결하기 위해서는 gimp의 batch 기능을 사용해야 한다. 다른 프로그램은 문자로만 구성된 pdf를 이미지로 변환시키는건 잘되나, 이미지가 포함된 pdf를 변환할 경우 변환된 이미지는 인식 불가능 할 정도로 깨져 버린다.
EOF

EBOOK_ROOT_PATH=$PATH_EBOOKMEMORY # 절대 경로
TEMP_DIR_PATH=/tmp/.bookcube-B815-$$
GV_log=
GV_searchPathList=()
GV_mkdirBreakList=()
GV_processFailList=()
GV_convertFailedOdtList=()

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

makeSearchListArray()
{
	local list path
	list=( "$@" )
	GV_searchPathList=()
	for path in "${list[@]}"; do
		GV_searchPathList+=( "./$path/" )
	done
	(( ${#GV_searchPathList[@]} == 0 )) && GV_searchPathList=( ./ )
}

processForCbz()
{
	local archive skipList saveFullPath
	
	for archive in $(find "${GV_searchPathList[@]}" -type f -a -iname '*.cbz'); do
		# 파일에 존재하는 이미지가 두개 이상의 폴더에 나뉘어 저장되어 있다면 건너뜀.
		if (( $(viewZipList "$archive" | grep -Ei -e '\.jpe?g$' -e '\.png$' -e '\.bmp$' -e '\.gif$' | sed -e 's#^#/#' -e 's#/[^/]*$#/#' | sort -u | wc -l) > 1 )); then
			skipList+=( "$archive" )
			continue
		fi
		
		saveFullPath=$(initSavePath Picture "$archive" "$(ex_name "$archive").zip") || continue
		
		initTempDir
		if ! unzip "$archive" -d $TEMP_DIR_PATH; then
			GV_processFailList+=( "$archive" )
			continue
		fi
		resizePictures $TEMP_DIR_PATH
		if ! mkzip $TEMP_DIR_PATH "$saveFullPath" ; then
			GV_processFailList+=( "$archive" )
			continue
		fi
		clearTempDir
	done
	
	# 처리되지 않은 대상을 기록.
	if (( ${#skipList[@]} > 0 )); then
		GV_log+=$(cat <<-EOF
		<< 처리되지 않은 파일 목록 >>
		 * 파일에 존재하는 이미지가 두개 이상의 폴더에 나뉘어 저장되어 있습니다.
		${skipList[*]}
		EOF
		)$'\n\n'
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
	for file in $(find "${GV_searchPathList[@]}" -type f -a -iname '*.pdf'); do
		saveFullPath=$(initSavePath Picture "$file" "$(ex_name "$file").zip") || continue
		initTempDir
		if ! pdftocairo "$file" -jpeg $TEMP_DIR_PATH/image; then
			GV_processFailList+=( "$file" )
			continue
		fi
		#convert "$file" -trim -colorspace gray -type grayscale -quality 100 -resize 1200x800 $TEMP_DIR_PATH/image.jpg
		resizePictures $TEMP_DIR_PATH
		if ! mkzip $TEMP_DIR_PATH "$saveFullPath"; then
			GV_processFailList+=( "$file" )
			continue
		fi
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
	for image in $(find "${GV_searchPathList[@]}" -type f -a \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' -o -iname '*.gif' \)); do
		saveFullPath=$(initSavePath Picture "$image") || continue
		if ! resizeImage "$image" "$saveFullPath"; then
			GV_processFailList+=( "$image" )
			continue
		fi
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
	for file in $(find "${GV_searchPathList[@]}" -type f -a \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.wma' \)); do
		saveFullPath=$(initSavePath Music "$file") || continue
		cp -f -- "$file" "$saveFullPath"
	done
}

# 기타 책을 분류.
# 다음 형식은 매직 넘버로 분류해야 함. plucker, 
# 알 수 없는 형식. OpenReader, Palmdoc, Mobipocket
# 처리 하지 않는 형식. 확장자가 없는 평문 텍스트 파일.
processForBook()
{
	local file saveFullPath
	for file in $(find "${GV_searchPathList[@]}" -type f -a \( -iname '*.bcb' -o -iname '*.bcp' -o -iname '*.bcz' -o -iname '*.ePub' -o -iname '*.fb2' -o -iname '*.oeb' -o -iname '*.htm' -o -iname '*.html' -o -iname '*.tcr' -o -iname '*.chm' -o -iname '*.rtf' -o -iname '*.txt' \)); do
		saveFullPath=$(initSavePath Book "$file") || continue
		cp -f -- "$file" "$saveFullPath"
	done
}

# Bookcube에서 지원하지 않는 형식의 파일들을 사용자에게 보고.
# zip 확장자의 파일은 압축된 텍스트 파일이나 이미지 파일 묶음에 사용될 수 있으나, 여기서는 처리하지 않음.
findNotSupportFormatFile()
{
	local notSuportedFileList
	notSuportedFileList=$(find "${GV_searchPathList[@]}" -type l -o -type f -a -not \( -iname '*.bcb' -o -iname '*.bcp' -o -iname '*.bcz' -o -iname '*.ePub' -o -iname '*.fb2' -o -iname '*.oeb' -o -iname '*.htm' -o -iname '*.html' -o -iname '*.tcr' -o -iname '*.chm' -o -iname '*.rtf' -o -iname '*.txt' -o -iname '*.mp3' -o -iname '*.wav' -o -iname '*.wma' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' -o -iname '*.gif' -o -iname '*.pdf' -o -iname '*.cbz' -o -iname '*.odt' \))
	if [ -n "$notSuportedFileList" ]; then
		GV_log+=$(cat <<-EOF
		<< 처리되지 않은 파일 목록 >>
		 * 지원하지 않는 형식의 파일
		$notSuportedFileList
		EOF
		)$'\n\n'
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
	[ -n "$GV_log" ] && (kate --stdin <<<"$GV_log") &
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
		GV_log+=$(cat <<-EOF
		<< 처리되지 않은 파일 목록 >>
		 * 상대 경로로 폴더를 생성시 충돌이 발생 했습니다.
		${GV_mkdirBreakList[*]}
		EOF
		)$'\n\n'
	fi	
}

recodeFaileList()
{
	if (( ${#GV_processFailList[@]} > 0 )); then
		GV_log+=$(cat <<-EOF
		<< 처리되지 않은 파일 목록 >>
		 * 알 수 없는 이유로 인하여 파일 처리에 실패했습니다.
		${GV_processFailList[*]}
		EOF
		)$'\n\n'
	fi	
}

processForOdt()
{
	local file saveFullPath i MAX_TRAY ext 
	MAX_TRAY=3
	for file in $(find "${GV_searchPathList[@]}" -type f -a -iname '*.odt'); do
		initTempDir
		if ebook-convert "$file" $TEMP_DIR_PATH/temp.fb2; then
			ext=fb2
		else
			for((i = 0; i < MAX_TRAY; i++)); do
				unoconv --listener &>/dev/null &
				unoconv -o $TEMP_DIR_PATH -f pdf -- "$file" && break
			done
			if (( i == MAX_TRAY )); then
				GV_convertFailedOdtList+=( "$file" )
				continue
			else
				ext=pdf
			fi
		fi
		saveFullPath=$(initSavePath Book "$file" "$(ex_name "$file").$ext") || continue
		cp -f -- "$TEMP_DIR_PATH/$(ls -A $TEMP_DIR_PATH)" "$saveFullPath"
		clearTempDir
	done
}

recodeConvertFailedOdtList()
{
	if (( ${#GV_convertFailedOdtList[@]} > 0 )); then
		GV_log+=$(cat <<-EOF
		<< 변환에 실패한 odt 파일 목록 >>
		 * odt 파일을 fb2 또는 pdf 포멧으로 변환하던 중 오류가 발생했습니다.
		${GV_convertFailedOdtList[*]}
		EOF
		)$'\n\n'
	fi	
}

main()
{
	test -d "$EBOOK_ROOT_PATH" || crash 5 'E-BOOK 메모리 카드를 삽입하여 주십시오!'
	umask 0077
	makeSearchListArray "$@"
	
	processForCbz
	processForPicture
	processForMusic
	processForPdf
	processForOdt
	processForBook
	
	findNotSupportFormatFile
	recodeBreakList
	recodeFaileList
	recodeConvertFailedOdtList
	showLog
	
	reportWorkEnd
	exit 0
}

main "$@"
