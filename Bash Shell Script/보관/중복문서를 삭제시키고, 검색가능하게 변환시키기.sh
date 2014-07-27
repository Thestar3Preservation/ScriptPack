#!/usr/bin/env bash_record
# 파일 보전 우선순위 htm=html=hwp=mht>odt=odp>doc=docx>pdf>fb2?txt
# 각 폴더 마다 존재하는 같은 이름 다른 확장자를 가진 파일들을 대상으로하여, 원본파일을 새로운 문서포멧으로 변환시키고, 원본과 전자책용 파일들을 삭제시키는 것이 목적.
# 단순 파일이 아니라, 두개 이상의 파일이 모여있을 경우도 처리해야겠다. 예를 들어, txt mp4와 같은 경우. 만약 doc mp4와 같은 경우 mp4는 자동삭제되게 된다. 그러나, 이러한 파일은 삭제되어선 안되는 파일이다.
# 작업하는 이유는 해당 문서의 원본을 보존시키고, 모든 파일을 현 리눅스 데스크탑에서 읽고 처리할수 있도록 하기 위함이다. 또한, 모든 문서는 검색될수 있어야 한다.
# maff 파일 내부의 파일은 검색되지 않았다. 인덱스에 해당되는 html은 어째서인지 검색되었다.
# 모든 문서는 utf-8이어야만 한다. utf-16인 경우 recoll은 분석하지 않았다.
# 설령, html형식의 문서일지라도, 무조건 인코딩은 utf-8이어야 recoll은 분석할수 있다.

#불필요한 파일을 삭제
#echo '불필요한 임시 파일을 삭제합니다.'
#find . -iname '.goutputstream-*' -o -iname Thumbs.db -delete

#문서 위치 검색 함수
# a(){ grep -i \\."$1"\$ list.txt | xargs -I{} realpath {} 2>/dev/null | xargs -I{} dirname {} | sort -uf; }
# b(){ grep -i "\\.$1\$" list.txt | xargs -I{} realpath {} 2>/dev/null; }

#g_qoute의 버그로 인해, ^가 포함된 문서는 처리되지 않던 문제 해결.
#확장자가 정렬되어 있지 않을때, 해당 포멧 그룹은 처리하지 못하던 문제 해결.

source ~/.bash_profile
LOAD_USER_FUNTION
bashcolorset

#작업 영역 내에 존재하는 포멧 패턴을 추출
extract_ext(){
	echo '작업 영역 내에 존재하는 포멧 패턴을 추출합니다...'
	for dir in $(find . -mindepth 1 -type d); do
		ls=$(ls -A "$dir" | xargs -I{} -d '\n' basename -- {})
		for j in $(runfor ex_name <<<"$ls" | sort -u); do
			list=$(grep -xiE "$(g_quote "$j")\.[^.]+" <<<"$ls" | runfor ex_ext | sort -u | tr '\n' \ )
			format+=$'\n'$list
		done
	done
	sort -uf <<<"$format"
	#read -p $'\n'"처리 패턴이 예외 없이 해당합니까?(Y/N) " answer
	#echo "$answer" | grep -i y || exit
	exit
}; #extract_ext

home=$PWD #시작 위치는 언제나 작업 대상의 폴더 내여야 합니다. 예를 들어, a를 작업하기 위해선, 현재경로가 ~/a식으로 되어있어야 합니다.
echo "작업 위치 : $home"
mkdir -p link/{hwp,mht{,_i},html,txt,doc} 2>/dev/null #나중에 문서 파일들을 링크시켜 따로 처리할 것들을 저장할 공간을 생성합니다.

#인자로 준 확장자를 제외한 다른 포멧형태의 동일 파일을 삭제시킵니다. 즉, 해당 디렉토리에서 인자로 준 확장자만을 가진 파일만을 남깁니다.
rm_eternal(){ grep -vix "$1" <<<"$list" | xargs -I{} -d '\n' trash-put -v -- "$j".{}; }

#확장자의 문서를 추후 변환할 목적으로 링크 디렉토리에 링크시킵니다. 그리고, 오류가 존재한다면, 오류 메세지를 따로 저장합니다.
ln_doc(){ ln -s "$PWD/$j.$ext" "$home/link/$1/$(dupev_name -p "$home/link/$1" -- "$j.$ext")" 2> "$home/link/error.log"; }

#인자로 준 확장자에서 현재 타겟이 된 대상 확장자의 실제 확장자를 얻기
ext_ex() { ext=$(grep -iE "$1" <<<"$list"); }

#문서를 주어진 인자의 형식으로 변환시킵니다. 인자2는 변환대상이 될 대상의 확장자를 의미합니다.
convert_doc(){
	local count=0 success=n ext
	while true; do
		((++count>3)) && break
		unoconv --listener &>/dev/null &
		if unoconv -f $1 -- "$j.$2"; then
			success=y
			break
		fi
	done
	if [ $success = n ]; then
		report_error "converting doc : $2->$1으로의 형식변환에 문제가 생겼습니다."
		ext=$2
		ln_doc doc
		return 1 #continue
	fi
	return 0
}

#문서의 인코딩을 UTF-8로 변경시킵니다. 첫번째 인자는 변환이 실패했을 경우, 링크되는 위치를 지정합니다. 만약 이미 UTF-8로 되어있다면, 종료코드 2를 리턴합니다.
convert_txt(){
	encoding=$(nkf -g "./$j.$ext")
	if [ $encoding = UTF-8 ]; then
		echo '이 문서는 이미 UTF-8로 인코딩되어 있습니다.'
		return 2
	else
		for encoding in UHC $encoding; do
			code=$(iconv -f $encoding -- "$j.$ext") && break
		done
		if [ $? != 0 ]; then
			report_error 'convert_txt : 이 문서는 해독불가능한 문서입니다.'
			ln_doc $1 #"$(tr [:upper:] [:lower:] <<<"$e")"
			return 1 #continue
		fi
		echo '이 문서는 변화가 있습니다.'
		cat <<<"$code" > "$j.$ext"
		return 0
	fi
}

#에러 메시지를 처리합니다. 인자를 주면, 그것이 에러 메시지가 됩니다.
report_error(){
	echo "작업 대상의 이름 : $dir/$j"$'\n'"작업 대상의 확장자 : ${list//$'\n'/, }"$'\n'"처리 중인 확장자 : ${ext:+지정되지 않음}"$'\n'"에러 메시지 : $*"$'\n' >> "$home/error.log"
	{ echo -en "$COL_RED"
	echo -n "ERROR : $*"
	echo -e "$COL_RESET"; } >&2
}

#모든 하위 디렉토리에서 모든 파일을 경우 마다 분기하여 처리합니다.
for dir in $(find . -type d); do #하위 모든 디렉토리 마다
	cd "$dir" #해당 위치로 이동
	ls=$(find . -maxdepth 1 -type f | xargs -d '\n' -I{} basename -- {}) #각각의 파일 마다
	for j in $(runfor ex_name <<<"$ls" | sort -uf); do #j는 확장자를 제외한 파일명
		unset ext
		list=$(grep -xi "`g_quote "$j"`\.[^.]*" <<<"$ls" | runfor ex_ext) #list는 해당 하는 이름을 가진 파일들의 확장자.
		echo
		echo "작업 대상의 이름 : $dir/$j" #작업 위치를 알림.
		echo "작업 대상의 확장자 : ${list//$'\n'/, }" #작업 확장자를 알림
		#만약 확장자 중에서 Txt와 txt와 같이 대소문자가 존재하여 서로 무시되는 경우는... 이는 신경쓸 필요가 없다. 우리가 이러한 것을 구분하는 이유는 시스템에서 충돌이 발생할 것을 우려해서다. 그러나, NTFS 파일 시스템은 대소문자가 구분된 파일도 훌륭하게 구분하여 저장하고 엑세스 할수 있으며, 이 쪽에서 사용하는 확장자도 이러한 규칙... 아니, 이 스크립트는 확장자를 무시하고 처리한다. 그러므로 문제가 있지...
		#if [ $(sort -uf <<<"$list" | wc -l) != $(wc -l <<<"$list") ]; then
		#d 변환 명령. 확장자의 대소문자 중복이 발견되지 않았습니다.
		case "$(sort <<<"$list" | tr '\n' ' ' | sed -e 's/\([A-Z]\)/\l\1/g' -e 's/ $//')" in
			#무시하는 경우
			zip|wma|webarchive|nfo|url|tif|sbg|pub|pps|asf|avi|bmp|'bmp jpg'|chm|'chm pdf'|dxf|exe|flv|gif|jpeg|png|jpg|mp3|pdf|'mp4 nfo'|mp4|maff|diz|bz2|odt|fb2|ods|ppt|srt|log|xls)
				#srt는 자막파일로서, 미리 처리함. log는 이 스크립트가 생성함.
				echo '이 확장자 그룹은 무시가 명령되어 있습니다.'
			;;
			#docx를 doc으로 변환하고, doc을 odt로 변환시킴. 그 뒤, odt가 아닌 모든 파일을 제거.
			docx | 'doc docx pdf' | 'docx epub fb2' | 'docx fb2' | 'docx pdf' | 'docx txt')
				ext_ex docx #확장자 추출
				list+=$'\n'doc
				rm_eternal docx
				if convert_doc doc "$ext"; then #docx->doc으로 변환하는 부분.
					rm_eternal doc
					if convert_doc odt doc; then #doc->odt로 변환하는 부분.
						rm_eternal odt #인자로 준 확장자를 제외한 모든 다른 확장자를 삭제처리
					fi
				fi
			;;
			#doc파일을 odt로 변환시킴. 나머지 모두 삭제.
			doc | 'fb2 doc' | 'doc fb2 pdf txt' | 'doc fb2 txt' | 'doc pdf' | 'doc pdf txt' | 'doc txt')
				ext_ex doc
				if convert_doc odt "$ext"; then
					rm_eternal odt
				else
					rm_eternal doc
				fi
			;;
			#hwp만 파일만 남기고, 나머지는 삭제시킴. hwp파일은 링크시켜 따로 처리함.
			'doc fb2 hwp' | 'doc hwp pdf' | 'fb2 hwp' | 'hwp txt' | hwp | 'hwp pdf' | 'hwp pdf txt')
				ext_ex hwp
				ln_doc hwp
				rm_eternal hwp
			;;
			#mht파일만 남기고 링크시킴. maff로 일괄변환
			'doc mht pdf' | mht | 'mht pdf' | 'txt mht')
				ext_ex mht
				ln_doc mht
				cp -v -- "$j.$ext" "$home/link/mht_i/$(dupev_name -p "$home/link/mht_i" -- "$j.$ext")"
				rm_eternal mht
			;;
			#pdf만 남김.
			'fb2 pdf' | 'pdf txt')
				ext_ex pdf
				rm_eternal pdf
			;;
			#htm, html문서를 남기고, 인코딩을 변경시킨다. 나머지는 삭제처리.
			'gif htm' | 'gif html' | htm | 'htm jpg' | html | 'htm pdf' | 'htm txt')
				ext_ex 'html?'
				convert_txt html && code=$(grep -Ei 'charset=[^ "]+' -- "$j.$ext") && ! grep -Fi UTF-8 <<<"$code" && perl -0pe 'use encoding "utf8"; s/charset=[^ "]+/charset=UTF-8/' <"$j.$ext" > "$j.$ext"
				rm_eternal "$ext"
			;;
			#txt파일만 남기고, 인코딩을 모두 UTF-8로 변환한다.
			'jpg txt' | txt | 'gif txt' | 'flv txt')
				ext_ex txt
				convert_txt txt
				rm_eternal txt
			;;
			#만약을 위해 대상목록에 존재하지 않는 패턴일 경우를 보고.
			*)
				echo "${list//$'\n'/, }(은)는 보고되지 않은 확장자입니다."
				not_reported_ext+=$list$'\n'
			;;
		esac
	done
	cd "$home"
done


rmdir link/* 2>/dev/null #만약, 링크된 것이 존재하지 않는 폴더가 존재한다면, 해당 빈 폴더는 삭제합니다.
[ -z "$(cat "$home/link/error.log")" ] && rm "$home/link/error.log" #ln 오류 내역이 내용이 존재하지 않을 경우 삭제처리
ls link | xargs -I{} mkdir link/{}_f #위 쪽 폴더 생성 명령은 원본파일의 링크인데 반해, 이쪽은 원본 파일의 변환된 내용이 저장될 위치를 의미합니다.
rmdir link/mht_i_f link 2>/dev/null
[ -n "$not_reported_ext" ] && echo '등록되지 않은 확장자가 존재합니다!'$'\n'"$(sort -uf <<<"$not_reported_ext")" > "$home/not_reported_ext.log" #만약 보고되지 않은 확장자가 존재한다면 보고서를 작성함.

#만약 오류 보고서가 존재한다면, 해당 보고서를 염.
for error_path in "$home/link/error.log" "$home/error.log" "$home/not_reported_ext.log" "$home/link"; do
	[ -e "$error_path" ] && xdg-open "$error_path" &
done

exit

#==============================구버전===========================================

#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION
# 파일 보전 우선순위 htm=html=hwp=mht>odt=odp>doc=docx>pdf>fb2?txt
# 각 폴더 마다 존재하는 같은 이름 다른 확장자를 가진 파일들을 대상으로하여, 원본파일을 새로운 문서포멧으로 변환시키고, 원본과 전자책용 파일들을 삭제시키는 것이 목적.
# 단순 파일이 아니라, 두개 이상의 파일이 모여있을 경우도 처리해야겠다. 예를 들어, txt mp4와 같은 경우. 만약 doc mp4와 같은 경우 mp4는 자동삭제되게 된다. 그러나, 이러한 파일은 삭제되어선 안되는 파일이다.
# 작업하는 이유는 해당 문서의 원본을 보존시키고, 모든 파일을 현 리눅스 데스크탑에서 읽고 처리할수 있도록 하기 위함이다. 또한, 모든 문서는 검색될수 있어야 한다.
# maff 파일 내부의 파일은 검색되지 않았다. 인덱스에 해당되는 html은 어째서인지 검색되었다.
# 모든 문서는 utf-8이어야만 한다. utf-16인 경우 recoll은 분석하지 않았다.

#불필요한 파일을 삭제
#echo '불필요한 임시 파일을 삭제합니다.'
#find . -iname '.goutputstream-*' -o -iname Thumbs.db -delete

#작업 영역 내에 존재하는 포멧 패턴을 추출
echo '작업 영역 내에 존재하는 포멧 패턴을 추출합니다...'
for dir in $(find . -mindepth 1 -type d); do
	ls=$(ls -A "$dir" | xargs -I{} -d '\n' basename -- {})
	for j in $(runfor ex_name <<<"$ls" | sort -uf); do
		list=$(grep -xiE "$(g_quote "$j")\.[^.]+" <<<"$ls" | runfor ex_ext | sort -uf | tr '\n' \ )
		format+=$'\n'$list
	done
done
sort -uf <<<"$format"
read -p $'\n'"처리 패턴이 예외 없이 해당합니까?(Y/N) " answer
echo "$answer" | grep -i y || exit
exit

#처리작업 시작
home=$PWD
mkdir -p link/{hwp,mht{,i},html,txt} bakup_txt
ls link | xargs -I{} mkdir link/{}_f
rm_eternal(){ grep -vix "$1" <<<"$list" | xargs -I{} -d '\n' trash-put "$j".{}; }
ln_doc(){ echo "$ext" | xargs -I{} -d "\n" ln -s "$PWD/$j".{} "$home/link/$1" 2> "$home/link/error.log"; }
convert_doc(){
	unoconv --listener &>/dev/null &
	if unoconv -f $1 "$j".$extregx; then
		trash-put "$j".$extregx
	else
		unoconv --listener &>/dev/null &
		if unoconv -f $1 "$j".$extregx; then
			trash-put "$j".$extregx
		else
			echo "'$j.$ext'을 변환하는데 문제가 생겼습니다. path: $dir" | tee -a "$home/error.log"
			continue
		fi
	fi
}

ext_ex() { ext=$(grep -xi "`tr \  '\n' <<<"$*"`" <<<"$list"); }
for dir in $(find . -type d); do
	cd "$dir"
	ls=$(find . -maxdepth 1 -type f | xargs -d '\n' -I{} basename {})
	for j in $(echo "$ls" | runfor ex_name | sort -uf); do #j는 확장자를 제외한 파일명
		list=$(echo "$ls" | grep -xi "`g_quote "$j"`\.[^.]*" | runfor ex_ext) #list는 해당 하는 이름을 가진 파일들의 확장자
		echo "작업대상 : $dir/$j"
		#확장자가 하나일 경우
		if [ $(echo "$list" | wc -l) = 1 ]; then
			ext=$(tr [:upper:] [:lower:] <<<"$list")
			extregx=$(replace_i "$ext")
			case $ext in
				#각종 확장자 설명
				#sty : 한글 스타일 정보 파일; scn : 알수없는 파일; epub는 애초에 전자책용 파일이다. gdb : 특수한 강의전용 파일;
				gdb|scn|sty|1|apk|bat|conf|css|desktop|dll|exe|flv|gif|bmp|png|jpg|jpeg|img|js|lnk|maff|mp4|pdf|reg|zip|7z|odt|odp)
					#zip,7z은 따로 확인
					echo "$ext는 무시되는 확장자입니다.";;
				docx)
					ext=$list
					convert_doc doc
					ext=doc
					convert_doc odt;;
				yin)
					#윈도우용 yin 컨버터가 있다. 이 컨버터를 이용하여 일괄 변환시킨다. ywh컨버터의 경우와 달리 변환시킬 파일과 저장될 파일명을 수동으로 지정해줘야 한다. 일괄작업 배치파일을 짜거나, 쉘스크립트의 도움을 받아 각종 작업을 대신한 배치파일을 작성하도록 한다.
					iconv -f UHC -c -o aaa
				ywh)
					#윈도우용 ywh 컨버터가 있다. 이 컨버터를 이용하여 일괄 변환시킨다.
					#이 프로그램은 해당 디렉토리 아래의 모든 파일을 자동으로 인식해서 변환시킨다.
					iconv -f UHC -c -o aaa #이렇게 마무리르 지으면 된다.
				epub)
				#a에 한하여 모두 odt나 이미지를 포함한 문서로 변환시킨다.
				arj)
					j=$(dupev_name "$j" "`ls`")
					mkdir "$j"
					arj e "$j".$extregx "$j"
					trash-put "$j".$extregx;;
				cap)
				#ext변수에 저장될때 확장자가 변경될뿐, list(확장자 목록)에는 변형이 없다. extregx를 사용할 필요 없이, list변수에 저장된 정보를 사용하면 될것 같다.
				#text 변환 작업과 동일하게 처리하나, 확장자를 txt로 하여 저장하는게 다르다.
					text=$(iconv -f JOHAB "$j".$extregx) || text=$(iconv -f UHC "$j".$extregx) || text
				zip)
					#압축파일 명으로 파일을 풀고, 만약 폴더 내에 파일이 하나 뿐이라면, 그 파일명을 압축파일 명으로 수정시킨다.
					#중첩폴더 구조 해제하기 스크립트를 가져오면 좋을것 같다.
					#압축을 풀고, 압축 해제한 파일 혹은 폴더를 대상으로 한번 더 이 스크립트를 적용시킨다.
				doc)
					ext=$list
					convert_doc odt;;
				htm|html)
					ext=$list
					ln_doc html;;
				hwp)
					ext=$list
					ln_doc hwp;;
				mht|mhtml)
					ext=$list
					ln_doc mht
					cp "$PWD/$j.$ext" "$home/link/mht_i";;
				# ppt) #예외: 검색전용 파일 생성 --> 관련 프로그램을 설치하여 검색 가능해짐
				#	ext=$list
				#	convert_doc odp
				#	mv "$j.odp" "$j.search.odp";;
				txt)
					ext=$list
					encoding=$(nkf -g "$j.$ext")
					case $encoding in
						UTF-8)
							echo '이 파일의 인코딩은 UTF-8입니다.';;
						ASCII)
							cp "$j.$ext" "$home/bakup_txt"
							iconv -f UHC -t UTF-8 -c -o "$j.$ext" "$j.$ext";;
						UTF-16)
							cp "$j.$ext" "$home/bakup_txt"
							iconv -f UTF-16 -t UTF-8 -c -o "$j.$ext" "$j.$ext";;
						*) # BINARY|CP51932|EUC-JP|Shift_JIS
							ln_doc txt;;
					esac;;
			esac
		#확장자가 하나 초과일 경우
		else
			if echo "$list" | grep -xi maff; then
				rm_eternal maff
			elif echo "$list" | grep -xi odt; then
				rm_eternal odt
			elif echo "$list" | grep -xi odp; then
				rm_eternal odp
			elif echo "$list" | grep -xi hwp; then
				ext_ex hwp
				ln_doc hwp
				rm_eternal $ext
			elif echo "$list" | grep -xiE 'mht(ml)?'; then
				ext_ex mht mhtml
				ln_doc mht
				rm_eternal $ext
			elif echo "$list" | grep -xiP 'htm|html'; then
				ext_ex htm html
				ln_doc html
				rm_eternal $ext
			elif echo "$list" | grep -xi docx; then
				ext_ex docx
				convert_doc doc
				ext=doc
				convert_doc odt
				rm_eternal odt 2>/dev/null
			elif echo "$list" | grep -xi doc; then
				ext_ex doc
				convert_doc odt
				rm_eternal odt 2>/dev/null
			elif ! grep -xiv -e files -e htm; then
			#이 경우 폴더도 그대로 링크시킨다.
			#작업이 완료되고, 각 파일을 원본과 대치시킬때, html의 경우 모든 원본 영역에서 files란 폴더를 삭제시키게 한다.
			elif ! grep -xiv -e cap -e hwp; then
			#hwp는 링크시키고, cap는 삭제함.
			elif ! grep -xiv -e cap -e txt; then
			#cap는 삭제시키고, txt는 인코딩 변환시킴.
			#elif ! grep -xiv -e asv -e hwp <<<"$list"; then
			#	trash-put "$j".$(replace_i asv)
			#	#hwp파일은 사용자 정의 변환에 링크시킴.
			else
				echo "\"$j\"에서 특이 패턴이 검출되었습니다. 패턴: `echo "$list" | tr '\n' \ `path: $dir" | tee -a "$home/pattern.log"
			fi
		fi
	done
	cd "$home"
done
rmdir link/* 2>/dev/null

exit