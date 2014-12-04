#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

#텍스트 파일에 UTF8 BOM이 포함되어 있지 않다면 UTF-8 BOM을 삽입한다.
#모든 텍스트 파일은 UTF-8로 인코딩되어 있다고 가정한다.

WORK_DIR_PATH=$PWD
UTF8_BOM=$'\xEF\xBB\xBF'

Main(){
	local file bom data
	for file in $(find . -type f -iname '*.txt'); do
		bom=$(head "$file" -c3)
		if [ "$bom" != "$UTF8_BOM" ]; then
			data=$(<"$file")
			echo -n "$UTF8_BOM$data" > "$file"
		fi
	done
	exit 0
}

Main
