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