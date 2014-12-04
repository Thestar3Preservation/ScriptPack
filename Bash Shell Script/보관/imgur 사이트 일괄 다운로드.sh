#!/bin/bash
# ~.imgur.com 사이트의 포스트를 추출해옵니다.

source ~/.bash_profile
LOAD_USER_FUNTION

DEBUG=FALSE
SAVE_POST_LIST=TRUE
POST_LIST_PATH=post_url_list.txt
TEMP_DIR_PATH=.imgur-download

debug()
{
	[ $DEBUG = FALSE ] && return
	echo "[DEBUG] $1" 1>&2
}

getPostCodeList()
{
	local blogUrls list blogUrl
	blogUrls=( "$@" )
	list=$(for blogUrl in "${blogUrls[@]}"; do
		debug "blogUrl : $blogUrl"
		wget "$blogUrl" -q -O /dev/stdout | CleanHtml
	done | pugixml '//div[@id="items"]//a/@href' | sed 's#^.*/##')
	echo "$list"
	debug "$list"
}

downloadPostImage()
{
	local postCode imageUrlList imageUrl postTitle postHtml saveFileName maxCountSize orignalFileExtension c max
	postCode=$1
	postHtml=$(wget -q "http://imgur.com/a/$postCode" -O /dev/stdout | CleanHtml)
	postTitle=$(pugixml "//div[@id='album-$postCode']/@data-title" <<<"$postHtml" | html_unescape)
	debug "postTitle : $postTitle"
	echo "제목 : $postTitle"
	saveFileName=$(dupev_name -p . -- "$(trim_webname --noiconv -- "$postTitle").cbz")
	debug "saveFileName : $saveFileName"
	imageUrlList=( $(pugixml '//div[@id="image-container"]//div[contains(@class,"album-view-image-link")]/a/@href' <<<"$postHtml" | sed 's#^#http:#') )
	max=${#imageUrlList[@]}
	(( maxCountSize = $(wc -m <<<"$max") - 1 ))
	debug "maxCountSize : $maxCountSize"
	rm -rf $TEMP_DIR_PATH
	mkdir $TEMP_DIR_PATH
	for ((c = 0; c < max; c++)); do
		imageUrl=${imageUrlList[c]}
		debug "imageUrl : $imageUrl"
		debug "count : $c"
		feed "$(bc <<<"scale=1; ( $c + 1 ) / $max * 100;")%($(( c + 1 ))/$max) : $imageUrl"
		orignalFileExtension=$(grep -oP '(?<=\.)[a-zA-Z0-9]+$' <<<"$imageUrl")
		wget -q "$imageUrl" -O "$TEMP_DIR_PATH/$(printf "%0${maxCountSize}d.$orignalFileExtension" $c)"
	done
	feed '다운로드된 파일을 묶는 중...'
	debug '다운로드 한 이미지를 cbz 파일로 묶습니다.'
	zip -0rjq "$saveFileName" $TEMP_DIR_PATH
	feed "\`$saveFileName'로 저장됨."
	echo
}

printSplitLine()
{
	local c max columns
	columns=$(tput cols)
	if (( columns <= 15 )); then
		max=80
	else
		max=$columns
	fi
	for ((c = 0; c < max; c++)); do
		echo -n '='
	done
	echo
}

main()
{
	local postCode blogUrls postCodeList c max
	blogUrls=( "$@" )
	umask 0077
	if [ $SAVE_POST_LIST = TRUE ]; then
		if [ -e $POST_LIST_PATH ]; then
			echo '기존에 저장된 목록을 사용합니다.'
		else
			feed '게시글 목록 추출중...'
			getPostCodeList "${blogUrls[@]}" > $POST_LIST_PATH
			feed
		fi
		postCodeList=( $(<$POST_LIST_PATH) )
	else
		feed '게시글 목록 추출중...'
		postCodeList=( $(getPostCodeList "${blogUrls[@]}") )
		feed
	fi
	max=${#postCodeList[@]}
	for ((c = 0; c < max; c++)); do
		postCode=${postCodeList[c]}
		printSplitLine
		debug "postCode : $postCode"
		echo "[$(( c + 1 ))/$max] http://imgur.com/a/$postCode"
		downloadPostImage "$postCode"
	done
	rm -rf $TEMP_DIR_PATH
	exit
}

main "$@"
